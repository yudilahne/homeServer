<?php

namespace App\Http\Requests\Api;

use Carbon\CarbonImmutable;
use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ];
    }

    public function deviceName(): string
    {
        return $this->string('device_name')->trim()->value() ?: 'flutter-mobile';
    }

    public function tokenExpiresAt(): ?CarbonImmutable
    {
        $minutes = (int) config('sanctum.expiration', 0);

        if ($minutes <= 0) {
            return null;
        }

        return CarbonImmutable::now()->addMinutes($minutes);
    }
}
