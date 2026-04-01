<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TeamMember extends Model
{
    protected $fillable = [
        'name',
        'role',
        'focus_project_id',
        'utilization',
        'active_tasks',
        'status_label',
    ];

    protected function casts(): array
    {
        return [
            'utilization' => 'decimal:2',
        ];
    }

    public function focusProject(): BelongsTo
    {
        return $this->belongsTo(Project::class, 'focus_project_id');
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(Task::class);
    }
}
