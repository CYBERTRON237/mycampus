<?php

namespace App\Api\Messaging\Controllers;

use App\Api\Messaging\Models\Message;
use App\Api\Messaging\Models\Conversation;
use App\Api\Auth\Models\User;
use App\Core\Controllers\BaseController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class MessageController extends BaseController
{
    public function index(Request $request)
    {
        try {
            $user = Auth::user();
            $limit = $request->get('limit', 50);
            $offset = $request->get('offset', 0);

            $conversations = Conversation::where('user_id', $user->id)
                ->with(['participant', 'lastMessage'])
                ->orderBy('last_activity', 'desc')
                ->offset($offset)
                ->limit($limit)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $conversations
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch conversations: ' . $e->getMessage()
            ], 500);
        }
    }

    public function show($conversationId)
    {
        try {
            $user = Auth::user();
            
            $conversation = Conversation::where('id', $conversationId)
                ->where('user_id', $user->id)
                ->with(['participant', 'lastMessage'])
                ->firstOrFail();

            return response()->json([
                'success' => true,
                'data' => $conversation
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Conversation not found'
            ], 404);
        }
    }

    public function getMessages(Request $request, $conversationId)
    {
        try {
            $user = Auth::user();
            $limit = $request->get('limit', 50);
            $offset = $request->get('offset', 0);

            // Verify conversation belongs to user
            $conversation = Conversation::where('id', $conversationId)
                ->where('user_id', $user->id)
                ->firstOrFail();

            $messages = Message::where(function($query) use ($conversationId, $user) {
                    $query->where('conversation_id', $conversationId)
                          ->orWhere(function($q) use ($conversationId, $user) {
                              $q->where('sender_id', $user->id)
                                ->where('receiver_id', $conversation->participant_id);
                          });
                })
                ->where('is_deleted', false) // Only get non-deleted messages
                ->whereNotIn('id', function($query) use ($user) {
                    // Exclude messages deleted for this user
                    $query->select('message_id')
                          ->from('message_deletions')
                          ->where('user_id', $user->id);
                })
                ->with(['sender', 'receiver'])
                ->orderBy('created_at', 'desc')
                ->offset($offset)
                ->limit($limit)
                ->get();

            // Add metadata about message status (edited, deleted_for_everyone, etc.)
            $messages->each(function($message) {
                $metadata = $message->metadata ?? [];
                $message->is_edited = isset($metadata['edited']) && $metadata['edited'];
                $message->edited_at = $metadata['edited_at'] ?? null;
                $message->deleted_for_everyone = isset($metadata['deleted_for_everyone']) && $metadata['deleted_for_everyone'];
            });

            return response()->json([
                'success' => true,
                'data' => $messages,
                'pagination' => [
                    'limit' => $limit,
                    'offset' => $offset,
                    'has_more' => $messages->count() == $limit
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch messages: ' . $e->getMessage()
            ], 500);
        }
    }

    public function send(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'receiver_id' => 'required|exists:users,id',
                'content' => 'required|string|max:1000',
                'type' => 'in:text,image,file,audio,video,system',
                'attachment_url' => 'nullable|string',
                'attachment_name' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $sender = Auth::user();
            $receiverId = $request->get('receiver_id');

            // Check if receiver exists and is not the sender
            $receiver = User::findOrFail($receiverId);
            if ($receiver->id === $sender->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot send message to yourself'
                ], 400);
            }

            // Find or create conversation
            $conversation = $this->findOrCreateConversation($sender->id, $receiverId);

            // Create message
            $message = Message::create([
                'sender_id' => $sender->id,
                'receiver_id' => $receiverId,
                'conversation_id' => $conversation->id,
                'content' => $request->get('content'),
                'type' => $request->get('type', 'text'),
                'status' => 'sent',
                'attachment_url' => $request->get('attachment_url'),
                'attachment_name' => $request->get('attachment_name'),
                'created_at' => now(),
            ]);

            // Update conversation last activity
            $conversation->update([
                'last_activity' => now(),
                'last_message_id' => $message->id,
            ]);

            // Update receiver's conversation
            $receiverConversation = Conversation::where('user_id', $receiverId)
                ->where('participant_id', $sender->id)
                ->first();
            
            if ($receiverConversation) {
                $receiverConversation->update([
                    'last_activity' => now(),
                    'last_message_id' => $message->id,
                    'unread_count' => DB::raw('unread_count + 1'),
                ]);
            }

            $message->load(['sender', 'receiver']);

            return response()->json([
                'success' => true,
                'data' => $message
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to send message: ' . $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $messageId)
    {
        try {
            $validator = Validator::make($request->all(), [
                'content' => 'required|string|max:1000',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = Auth::user();
            
            $message = Message::where('id', $messageId)
                ->where('sender_id', $user->id)
                ->where('is_deleted', false)
                ->firstOrFail();

            // WhatsApp-like editing rules
            if ($message->type !== 'text') {
                return response()->json([
                    'success' => false,
                    'message' => 'Only text messages can be edited'
                ], 400);
            }

            // Allow editing within 15 minutes (WhatsApp style)
            if ($message->created_at->diffInMinutes(now()) > 15) {
                return response()->json([
                    'success' => false,
                    'message' => 'Messages can only be edited within 15 minutes'
                ], 400);
            }

            // Store original content for "edited" indicator
            $originalContent = $message->content;
            
            $message->update([
                'content' => $request->get('content'),
                'updated_at' => now(),
                'metadata' => array_merge($message->metadata ?? [], [
                    'edited' => true,
                    'edited_at' => now()->toISOString(),
                    'original_content' => $originalContent
                ])
            ]);

            $message->load(['sender', 'receiver']);

            return response()->json([
                'success' => true,
                'data' => $message,
                'message' => 'Message updated successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update message: ' . $e->getMessage()
            ], 500);
        }
    }

    public function destroy(Request $request, $messageId)
    {
        try {
            $user = Auth::user();
            $deleteForEveryone = $request->get('delete_for_everyone', false);
            
            $message = Message::where('id', $messageId)
                ->where(function($query) use ($user) {
                    $query->where('sender_id', $user->id)
                          ->orWhere('receiver_id', $user->id);
                })
                ->where('is_deleted', false)
                ->firstOrFail();

            // WhatsApp-like deletion rules
            if ($deleteForEveryone) {
                // Can only delete for everyone if you're the sender and within 1 hour
                if ($message->sender_id !== $user->id) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Only sender can delete message for everyone'
                    ], 403);
                }

                if ($message->created_at->diffInHours(now()) > 1) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Messages can only be deleted for everyone within 1 hour'
                    ], 400);
                }

                // Delete for everyone - soft delete with special flag
                $message->update([
                    'is_deleted' => true,
                    'deleted_by' => $user->id,
                    'deleted_at' => now(),
                    'delete_type' => 'everyone', // 'me' or 'everyone'
                    'content' => 'This message was deleted', // Placeholder for deleted messages
                    'metadata' => array_merge($message->metadata ?? [], [
                        'deleted_for_everyone' => true,
                        'deleted_at' => now()->toISOString(),
                        'original_content' => $message->content
                    ])
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Message deleted for everyone'
                ]);

            } else {
                // Delete for me only - create a deletion record
                $existingDeletion = \DB::table('message_deletions')
                    ->where('message_id', $messageId)
                    ->where('user_id', $user->id)
                    ->first();

                if (!$existingDeletion) {
                    \DB::table('message_deletions')->insert([
                        'message_id' => $messageId,
                        'user_id' => $user->id,
                        'deleted_at' => now(),
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }

                return response()->json([
                    'success' => true,
                    'message' => 'Message deleted for you'
                ]);
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete message: ' . $e->getMessage()
            ], 500);
        }
    }

    public function markAsRead($messageId)
    {
        try {
            $user = Auth::user();
            
            $message = Message::where('id', $messageId)
                ->where('receiver_id', $user->id)
                ->firstOrFail();

            $message->update([
                'status' => 'read',
                'read_at' => now(),
            ]);

            // Update conversation unread count
            $conversation = Conversation::where('user_id', $user->id)
                ->where('participant_id', $message->sender_id)
                ->first();

            if ($conversation && $conversation->unread_count > 0) {
                $conversation->update([
                    'unread_count' => DB::raw('unread_count - 1'),
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Message marked as read'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to mark message as read: ' . $e->getMessage()
            ], 500);
        }
    }

    public function markConversationAsRead($conversationId)
    {
        try {
            $user = Auth::user();
            
            $conversation = Conversation::where('id', $conversationId)
                ->where('user_id', $user->id)
                ->firstOrFail();

            // Mark all unread messages as read
            Message::where('receiver_id', $user->id)
                ->where('sender_id', $conversation->participant_id)
                ->where('status', '!=', 'read')
                ->update([
                    'status' => 'read',
                    'read_at' => now(),
                ]);

            // Reset unread count
            $conversation->update(['unread_count' => 0]);

            return response()->json([
                'success' => true,
                'message' => 'Conversation marked as read'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to mark conversation as read: ' . $e->getMessage()
            ], 500);
        }
    }

    public function search(Request $request)
    {
        try {
            $user = Auth::user();
            $query = $request->get('q');

            if (empty($query)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Search query is required'
                ], 400);
            }

            $messages = Message::where(function($q) use ($user, $query) {
                    $q->where('sender_id', $user->id)
                      ->orWhere('receiver_id', $user->id);
                })
                ->where('content', 'LIKE', "%{$query}%")
                ->where('is_deleted', false)
                ->with(['sender', 'receiver'])
                ->orderBy('created_at', 'desc')
                ->limit(100)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $messages
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to search messages: ' . $e->getMessage()
            ], 500);
        }
    }

    public function searchUsers(Request $request)
    {
        try {
            $user = Auth::user();
            $query = $request->get('q');

            if (empty($query)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Search query is required'
                ], 400);
            }

            $users = \App\Models\User::where('id', '!=', $user->id)
                ->where('account_status', 'active')
                ->where('is_active', 1)
                ->where(function($q) use ($query) {
                    $q->where('first_name', 'LIKE', "%{$query}%")
                      ->orWhere('last_name', 'LIKE', "%{$query}%")
                      ->orWhere('email', 'LIKE', "%{$query}%")
                      ->orWhere(DB::raw("CONCAT(first_name, ' ', last_name)"), 'LIKE', "%{$query}%");
                })
                ->select('id', 'first_name', 'last_name', 'email', 'profile_photo_url', 'profile_picture', 'phone', 'primary_role')
                ->limit(20)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $users
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to search users: ' . $e->getMessage()
            ], 500);
        }
    }

    public function searchUsersByPhone(Request $request)
    {
        try {
            $user = Auth::user();
            $phone = $request->get('phone');

            if (empty($phone)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Phone number is required'
                ], 400);
            }

            // Nettoyer le numéro de téléphone (supprimer les espaces, tirets, etc.)
            $cleanPhone = preg_replace('/[^0-9]/', '', $phone);

            $users = \App\Models\User::where('id', '!=', $user->id)
                ->where('account_status', 'active')
                ->where('is_active', 1)
                ->where('phone', '!=', null)
                ->where(function($q) use ($cleanPhone) {
                    $q->where('phone', '=', $cleanPhone)
                      ->orWhere('phone', 'LIKE', '%'.$cleanPhone)
                      ->orWhere(DB::raw("REPLACE(phone, ' ', '')"), 'LIKE', '%'.$cleanPhone)
                      ->orWhere(DB::raw("REPLACE(REPLACE(phone, '-', ''), ' ', '')"), 'LIKE', '%'.$cleanPhone);
                })
                ->select('id', 'first_name', 'last_name', 'email', 'profile_photo_url', 'profile_picture', 'phone', 'primary_role')
                ->limit(10)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $users
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to search users by phone: ' . $e->getMessage()
            ], 500);
        }
    }

    private function findOrCreateConversation($userId, $participantId)
    {
        $conversation = Conversation::where('user_id', $userId)
            ->where('participant_id', $participantId)
            ->first();

        if (!$conversation) {
            $conversation = Conversation::create([
                'user_id' => $userId,
                'participant_id' => $participantId,
                'last_activity' => now(),
                'unread_count' => 0,
            ]);

            // Also create conversation for the other user
            Conversation::create([
                'user_id' => $participantId,
                'participant_id' => $userId,
                'last_activity' => now(),
                'unread_count' => 0,
            ]);
        }

        return $conversation;
    }
}
