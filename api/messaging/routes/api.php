<?php

use App\Api\Messaging\Controllers\MessageController;
use App\Api\Messaging\Controllers\ConversationController;
use Illuminate\Support\Facades\Route;

// Message routes
Route::prefix('messages')->middleware('auth:api')->group(function () {
    
    // Conversations
    Route::get('/conversations', [MessageController::class, 'index']);
    Route::get('/conversations/{id}', [MessageController::class, 'show']);
    Route::get('/conversations/{id}/messages', [MessageController::class, 'getMessages']);
    Route::put('/conversations/{id}/read', [MessageController::class, 'markConversationAsRead']);
    Route::delete('/conversations/{id}', [MessageController::class, 'destroyConversation']);
    Route::post('/conversations', [MessageController::class, 'createConversation']);
    
    // Messages
    Route::post('/send', [MessageController::class, 'send']);
    Route::put('/{id}', [MessageController::class, 'update']);
    Route::delete('/{id}', [MessageController::class, 'destroy']);
    Route::put('/{id}/read', [MessageController::class, 'markAsRead']);
    Route::get('/search', [MessageController::class, 'search']);
    
    // User management
    Route::post('/users/{id}/block', [MessageController::class, 'blockUser']);
    Route::post('/users/{id}/unblock', [MessageController::class, 'unblockUser']);
    
    // Conversation settings
    Route::post('/conversations/{id}/mute', [MessageController::class, 'muteConversation']);
    Route::post('/conversations/{id}/unmute', [MessageController::class, 'unmuteConversation']);
});

// Messaging routes
Route::prefix('messaging')->middleware('auth:api')->group(function () {
    // User search for messaging
    Route::get('/users/search', [MessageController::class, 'searchUsers'])
        ->name('messaging.users.search');

    Route::get('/users/search/phone', [MessageController::class, 'searchUsersByPhone'])
        ->name('messaging.users.search.phone');
});
