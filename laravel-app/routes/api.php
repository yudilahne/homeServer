<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\WorkspaceController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::get('/health', fn () => response()->json([
        'message' => 'API is healthy',
        'version' => 'v1',
    ]))->middleware('throttle:30,1');

    Route::prefix('auth')->group(function (): void {
        Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:5,1');
        Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');

        Route::middleware(['auth:sanctum', 'throttle:60,1'])->group(function (): void {
            Route::post('/logout', [AuthController::class, 'logout']);
            Route::post('/logout-all', [AuthController::class, 'logoutAll']);
            Route::get('/me', [ProfileController::class, 'show']);
            Route::put('/me', [ProfileController::class, 'update']);
            Route::put('/password', [ProfileController::class, 'updatePassword']);
        });
    });

    Route::middleware(['auth:sanctum', 'throttle:60,1'])->group(function (): void {
        Route::get('/dashboard', [WorkspaceController::class, 'dashboard']);
        Route::get('/projects', [WorkspaceController::class, 'projects']);
        Route::get('/tasks', [WorkspaceController::class, 'tasks']);
        Route::get('/team-members', [WorkspaceController::class, 'members']);
    });
});
