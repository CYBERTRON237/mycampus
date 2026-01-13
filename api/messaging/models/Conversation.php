<?php

namespace App\Api\Messaging\Models;

use Illuminate\Database\Eloquent\Model;
use App\Api\Auth\Models\User;

class Conversation extends Model
{
    protected $fillable = [
        'user_id',
        'participant_id',
        'last_message_id',
        'last_activity',
        'unread_count',
        'is_online',
        'is_blocked',
        'is_muted',
    ];

    protected $casts = [
        'last_activity' => 'datetime',
        'is_online' => 'boolean',
        'is_blocked' => 'boolean',
        'is_muted' => 'boolean',
        'unread_count' => 'integer',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function participant()
    {
        return $this->belongsTo(User::class, 'participant_id');
    }

    public function lastMessage()
    {
        return $this->belongsTo(Message::class, 'last_message_id');
    }

    public function messages()
    {
        return $this->hasMany(Message::class, 'conversation_id');
    }

    // Scopes
    public function scopeUnread($query)
    {
        return $query->where('unread_count', '>', 0);
    }

    public function scopeActive($query)
    {
        return $query->where('is_blocked', false);
    }

    public function scopeMuted($query)
    {
        return $query->where('is_muted', true);
    }

    // Accessors
    public function getFormattedLastActivityAttribute()
    {
        if ($this->last_activity->isToday()) {
            return $this->last_activity->format('H:i');
        } elseif ($this->last_activity->isYesterday()) {
            return 'Yesterday';
        } else {
            return $this->last_activity->format('M d');
        }
    }

    public function getParticipantNameAttribute()
    {
        return $this->participant ? $this->participant->full_name : 'Unknown User';
    }

    public function getParticipantAvatarAttribute()
    {
        return $this->participant ? $this->participant->avatar_url : null;
    }

    // Methods
    public function markAsRead()
    {
        $this->update(['unread_count' => 0]);
        
        // Mark all messages as read
        Message::where('receiver_id', $this->user_id)
            ->where('sender_id', $this->participant_id)
            ->where('status', '!=', 'read')
            ->update([
                'status' => 'read',
                'read_at' => now(),
            ]);
    }

    public function incrementUnreadCount()
    {
        $this->increment('unread_count');
    }

    public function decrementUnreadCount()
    {
        if ($this->unread_count > 0) {
            $this->decrement('unread_count');
        }
    }

    public function block()
    {
        $this->update(['is_blocked' => true]);
    }

    public function unblock()
    {
        $this->update(['is_blocked' => false]);
    }

    public function mute()
    {
        $this->update(['is_muted' => true]);
    }

    public function unmute()
    {
        $this->update(['is_muted' => false]);
    }

    public function updateLastActivity($messageId = null)
    {
        $this->update([
            'last_activity' => now(),
            'last_message_id' => $messageId,
        ]);
    }
}
