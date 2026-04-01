<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\PasswordUpdateRequest;
use App\Http\Requests\Api\ProfileUpdateRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        return response()->json([
            'message' => 'Profile fetched successfully',
            'data' => [
                'user' => new UserResource($request->user()),
            ],
        ]);
    }

    public function update(ProfileUpdateRequest $request): JsonResponse
    {
        $user = $request->user();
        $user->update($request->validated());

        return response()->json([
            'message' => 'Profile updated successfully',
            'data' => [
                'user' => new UserResource($user->fresh()),
            ],
        ]);
    }

    public function updatePassword(PasswordUpdateRequest $request): JsonResponse
    {
        $user = $request->user();

        if (! Hash::check($request->string('current_password')->value(), $user->password)) {
            return response()->json([
                'message' => 'The provided password is incorrect.',
                'errors' => [
                    'current_password' => ['The provided password is incorrect.'],
                ],
            ], 422);
        }

        $user->update([
            'password' => $request->string('password')->value(),
        ]);

        return response()->json([
            'message' => 'Password updated successfully',
        ]);
    }
}
