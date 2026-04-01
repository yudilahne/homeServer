<?php

namespace Tests\Feature\Api;

use App\Models\Project;
use App\Models\Task;
use App\Models\TeamMember;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WorkspaceApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_workspace_endpoints_require_authentication(): void
    {
        $this->getJson('/api/v1/dashboard')->assertUnauthorized();
        $this->getJson('/api/v1/projects')->assertUnauthorized();
        $this->getJson('/api/v1/tasks')->assertUnauthorized();
        $this->getJson('/api/v1/team-members')->assertUnauthorized();
    }

    public function test_workspace_snapshot_and_lists_can_be_fetched(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('workspace-test')->plainTextToken;

        $project = Project::query()->create([
            'name' => 'API Monitoring',
            'owner_name' => 'Rani',
            'progress' => 66,
            'health' => 'healthy',
            'deadline' => now()->addDays(4),
            'team_size' => 4,
        ]);

        $member = TeamMember::query()->create([
            'name' => 'Ari',
            'role' => 'Backend Engineer',
            'focus_project_id' => $project->id,
            'utilization' => 80,
            'active_tasks' => 3,
            'status_label' => 'Fokus',
        ]);

        Task::query()->create([
            'project_id' => $project->id,
            'team_member_id' => $member->id,
            'title' => 'Build dashboard API',
            'priority' => 'high',
            'stage' => 'doing',
            'due_date' => now()->addDay(),
        ]);

        $headers = ['Authorization' => 'Bearer '.$token];

        $this->withHeaders($headers)
            ->getJson('/api/v1/dashboard')
            ->assertOk()
            ->assertJsonPath('message', 'Workspace snapshot fetched successfully')
            ->assertJsonPath('data.projects.0.name', 'API Monitoring')
            ->assertJsonPath('data.tasks.0.title', 'Build dashboard API')
            ->assertJsonPath('data.members.0.name', 'Ari');

        $this->withHeaders($headers)
            ->getJson('/api/v1/projects')
            ->assertOk()
            ->assertJsonPath('data.0.name', 'API Monitoring');

        $this->withHeaders($headers)
            ->getJson('/api/v1/tasks')
            ->assertOk()
            ->assertJsonPath('data.0.title', 'Build dashboard API');

        $this->withHeaders($headers)
            ->getJson('/api/v1/team-members')
            ->assertOk()
            ->assertJsonPath('data.0.name', 'Ari');
    }
}
