<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Project extends Model
{
    protected $fillable = [
        'name',
        'owner_name',
        'progress',
        'health',
        'deadline',
        'team_size',
    ];

    protected function casts(): array
    {
        return [
            'progress' => 'decimal:2',
            'deadline' => 'date',
        ];
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(Task::class);
    }

    public function members(): HasMany
    {
        return $this->hasMany(TeamMember::class, 'focus_project_id');
    }
}
