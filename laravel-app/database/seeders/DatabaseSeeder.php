<?php

namespace Database\Seeders;

use App\Models\Project;
use App\Models\Task;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $adminEmail = env('ADMIN_EMAIL');
        $adminPassword = env('ADMIN_PASSWORD');

        if (! $adminEmail || ! $adminPassword) {
            return;
        }

        User::query()->updateOrCreate(
            ['email' => $adminEmail],
            [
                'name' => env('ADMIN_NAME', 'Administrator'),
                'password' => Hash::make($adminPassword),
            ],
        );

        if (! filter_var(env('RUN_WORKSPACE_SAMPLE_SEED', true), FILTER_VALIDATE_BOOL)) {
            return;
        }

        if (Project::query()->exists()) {
            return;
        }

        $mobileRevamp = Project::query()->create([
            'name' => 'Mobile Revamp',
            'owner_name' => 'Dinda',
            'progress' => 74,
            'health' => 'healthy',
            'deadline' => Carbon::now()->addDays(10),
            'team_size' => 7,
        ]);

        $opsDashboard = Project::query()->create([
            'name' => 'Ops Dashboard',
            'owner_name' => 'Rama',
            'progress' => 52,
            'health' => 'atRisk',
            'deadline' => Carbon::now()->addDays(14),
            'team_size' => 5,
        ]);

        $customerPortal = Project::query()->create([
            'name' => 'Customer Portal',
            'owner_name' => 'Nina',
            'progress' => 28,
            'health' => 'blocked',
            'deadline' => Carbon::now()->addDays(23),
            'team_size' => 9,
        ]);

        $ayu = TeamMember::query()->create([
            'name' => 'Ayu Putri',
            'role' => 'Flutter Engineer',
            'focus_project_id' => $mobileRevamp->id,
            'utilization' => 76,
            'active_tasks' => 4,
            'status_label' => 'Fokus',
        ]);

        $raka = TeamMember::query()->create([
            'name' => 'Raka Mahesa',
            'role' => 'Backend Engineer',
            'focus_project_id' => $opsDashboard->id,
            'utilization' => 89,
            'active_tasks' => 6,
            'status_label' => 'Padat',
        ]);

        $nina = TeamMember::query()->create([
            'name' => 'Nina Ardani',
            'role' => 'Product Lead',
            'focus_project_id' => $customerPortal->id,
            'utilization' => 64,
            'active_tasks' => 3,
            'status_label' => 'Stabil',
        ]);

        $salsa = TeamMember::query()->create([
            'name' => 'Salsa K.',
            'role' => 'QA Analyst',
            'focus_project_id' => $mobileRevamp->id,
            'utilization' => 58,
            'active_tasks' => 2,
            'status_label' => 'Longgar',
        ]);

        Task::query()->create([
            'project_id' => $mobileRevamp->id,
            'team_member_id' => $ayu->id,
            'title' => 'Implement push notification digest',
            'priority' => 'high',
            'stage' => 'doing',
            'due_date' => Carbon::today(),
        ]);

        Task::query()->create([
            'project_id' => $opsDashboard->id,
            'team_member_id' => $raka->id,
            'title' => 'Finalize KPI widgets',
            'priority' => 'medium',
            'stage' => 'review',
            'due_date' => Carbon::tomorrow(),
        ]);

        Task::query()->create([
            'project_id' => $customerPortal->id,
            'team_member_id' => $nina->id,
            'title' => 'Align API contract for timeline',
            'priority' => 'high',
            'stage' => 'todo',
            'due_date' => Carbon::today()->addDays(3),
        ]);

        Task::query()->create([
            'project_id' => $mobileRevamp->id,
            'team_member_id' => $salsa->id,
            'title' => 'Close QA defects sprint 12',
            'priority' => 'low',
            'stage' => 'done',
            'due_date' => Carbon::yesterday(),
        ]);
    }
}
