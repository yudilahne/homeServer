<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_and_receive_token(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Flutter User',
            'email' => 'flutter@example.com',
            'password' => 'Password123',
            'password_confirmation' => 'Password123',
            'device_name' => 'pixel-8',
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('message', 'Registration successful')
            ->assertJsonPath('data.user.email', 'flutter@example.com')
            ->assertJsonStructure([
                'data' => [
                    'token',
                    'token_type',
                    'user' => ['id', 'name', 'email'],
                ],
            ]);
    }

    public function test_user_can_login_fetch_profile_and_logout(): void
    {
        $user = User::factory()->create([
            'email' => 'mobile@example.com',
            'password' => 'Password123',
        ]);

        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => 'mobile@example.com',
            'password' => 'Password123',
            'device_name' => 'iphone-15',
        ]);

        $token = $loginResponse->json('data.token');

        $loginResponse
            ->assertOk()
            ->assertJsonPath('message', 'Login successful');

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/auth/me')
            ->assertOk()
            ->assertJsonPath('data.user.email', $user->email);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/auth/logout')
            ->assertOk()
            ->assertJsonPath('message', 'Logout successful');
    }

    public function test_user_can_update_profile_and_password(): void
    {
        $user = User::factory()->create([
            'email' => 'profile@example.com',
            'password' => 'Password123',
        ]);

        $token = $user->createToken('profile-test')->plainTextToken;

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->putJson('/api/v1/auth/me', [
                'name' => 'Updated Profile',
                'email' => 'updated@example.com',
            ])
            ->assertOk()
            ->assertJsonPath('message', 'Profile updated successfully')
            ->assertJsonPath('data.user.email', 'updated@example.com');

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->putJson('/api/v1/auth/password', [
                'current_password' => 'Password123',
                'password' => 'Password456',
                'password_confirmation' => 'Password456',
            ])
            ->assertOk()
            ->assertJsonPath('message', 'Password updated successfully');

        $this->postJson('/api/v1/auth/login', [
            'email' => 'updated@example.com',
            'password' => 'Password456',
            'device_name' => 'android',
        ])->assertOk();
    }

    public function test_user_can_logout_all_devices(): void
    {
        $user = User::factory()->create([
            'password' => 'Password123',
        ]);

        $firstToken = $user->createToken('android')->plainTextToken;
        $user->createToken('ios');

        $this->withHeader('Authorization', 'Bearer '.$firstToken)
            ->postJson('/api/v1/auth/logout-all')
            ->assertOk()
            ->assertJsonPath('message', 'Logged out from all devices successfully');

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_health_endpoint_is_available(): void
    {
        $this->getJson('/api/v1/health')
            ->assertOk()
            ->assertJsonPath('version', 'v1');
    }

    public function test_profile_requires_authentication(): void
    {
        $this->getJson('/api/v1/auth/me')
            ->assertUnauthorized();
    }
}
