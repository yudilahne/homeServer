<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Models\Task;
use App\Models\TeamMember;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;

class WorkspaceController extends Controller
{
    public function dashboard(): JsonResponse
    {
        $projects = Project::query()->latest()->get();
        $tasks = Task::query()->with(['project', 'assignee'])->latest()->get();
        $members = TeamMember::query()->with('focusProject')->latest()->get();

        $metrics = [
            [
                'label' => 'Project Aktif',
                'value' => (string) $projects->count(),
                'delta' => sprintf('%d berjalan minggu ini', $projects->count()),
                'accentHex' => 0xFF0E5A5A,
            ],
            [
                'label' => 'Task Due Hari Ini',
                'value' => (string) $tasks->filter(
                    fn (Task $task): bool => optional($task->due_date)?->isToday() ?? false
                )->count(),
                'delta' => sprintf('%d perlu review', $tasks->where('stage', 'review')->count()),
                'accentHex' => 0xFFD8733F,
            ],
            [
                'label' => 'Utilisasi Tim',
                'value' => sprintf('%d%%', (int) round($members->avg('utilization') ?? 0)),
                'delta' => 'berdasarkan workload aktif',
                'accentHex' => 0xFF20344A,
            ],
            [
                'label' => 'Issue Kritis',
                'value' => (string) $projects->where('health', 'blocked')->count(),
                'delta' => 'project dalam status blocked',
                'accentHex' => 0xFFB33A3A,
            ],
        ];

        $alerts = collect([
            $projects->where('health', 'blocked')->isNotEmpty()
                ? sprintf('%d project sedang blocked dan perlu eskalasi.', $projects->where('health', 'blocked')->count())
                : null,
            $members->where('utilization', '>', 85)->isNotEmpty()
                ? sprintf('%d anggota tim melewati utilization 85%%.', $members->where('utilization', '>', 85)->count())
                : null,
            $tasks->where('priority', 'high')->where('stage', '!=', 'done')->isNotEmpty()
                ? sprintf('%d task prioritas tinggi masih aktif.', $tasks->where('priority', 'high')->where('stage', '!=', 'done')->count())
                : null,
        ])->filter()->values()->all();

        return response()->json([
            'message' => 'Workspace snapshot fetched successfully',
            'data' => [
                'metrics' => $metrics,
                'projects' => $projects->map(fn (Project $project): array => [
                    'name' => $project->name,
                    'owner' => $project->owner_name,
                    'progress' => (float) $project->progress,
                    'health' => $project->health,
                    'deadline' => optional($project->deadline)?->format('d M'),
                    'teamSize' => $project->team_size,
                ])->all(),
                'tasks' => $tasks->map(fn (Task $task): array => [
                    'title' => $task->title,
                    'project' => $task->project?->name ?? '-',
                    'assignee' => $task->assignee?->name ?? 'Unassigned',
                    'priority' => ucfirst($task->priority),
                    'stage' => $task->stage,
                    'dueLabel' => $this->formatDueLabel($task->due_date),
                ])->all(),
                'members' => $members->map(fn (TeamMember $member): array => [
                    'name' => $member->name,
                    'role' => $member->role,
                    'focusProject' => $member->focusProject?->name ?? '-',
                    'utilization' => (float) $member->utilization / 100,
                    'activeTasks' => $member->active_tasks,
                    'statusLabel' => $member->status_label,
                ])->all(),
                'alerts' => $alerts,
            ],
        ]);
    }

    public function projects(): JsonResponse
    {
        return response()->json([
            'message' => 'Projects fetched successfully',
            'data' => Project::query()->latest()->get()->map(fn (Project $project): array => [
                'name' => $project->name,
                'owner' => $project->owner_name,
                'progress' => (float) $project->progress,
                'health' => $project->health,
                'deadline' => optional($project->deadline)?->format('d M'),
                'teamSize' => $project->team_size,
            ])->all(),
        ]);
    }

    public function tasks(): JsonResponse
    {
        return response()->json([
            'message' => 'Tasks fetched successfully',
            'data' => Task::query()->with(['project', 'assignee'])->latest()->get()->map(fn (Task $task): array => [
                'title' => $task->title,
                'project' => $task->project?->name ?? '-',
                'assignee' => $task->assignee?->name ?? 'Unassigned',
                'priority' => ucfirst($task->priority),
                'stage' => $task->stage,
                'dueLabel' => $this->formatDueLabel($task->due_date),
            ])->all(),
        ]);
    }

    public function members(): JsonResponse
    {
        return response()->json([
            'message' => 'Team members fetched successfully',
            'data' => TeamMember::query()->with('focusProject')->latest()->get()->map(fn (TeamMember $member): array => [
                'name' => $member->name,
                'role' => $member->role,
                'focusProject' => $member->focusProject?->name ?? '-',
                'utilization' => (float) $member->utilization / 100,
                'activeTasks' => $member->active_tasks,
                'statusLabel' => $member->status_label,
            ])->all(),
        ]);
    }

    private function formatDueLabel(?Carbon $date): string
    {
        if (! $date) {
            return 'Tanpa deadline';
        }

        if ($date->isToday()) {
            return 'Hari ini';
        }

        if ($date->isTomorrow()) {
            return 'Besok';
        }

        if ($date->isPast()) {
            return 'Overdue';
        }

        return sprintf('%d hari lagi', now()->startOfDay()->diffInDays($date->startOfDay()));
    }
}
