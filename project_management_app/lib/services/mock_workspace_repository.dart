import '../models/workspace_models.dart';

class MockWorkspaceRepository {
  WorkspaceSnapshot load() {
    return const WorkspaceSnapshot(
      metrics: [
        DashboardMetric(
          label: 'Project Aktif',
          value: '12',
          delta: '+2 bulan ini',
          accentHex: 0xFF0E5A5A,
        ),
        DashboardMetric(
          label: 'Task Due Hari Ini',
          value: '18',
          delta: '5 perlu review',
          accentHex: 0xFFD8733F,
        ),
        DashboardMetric(
          label: 'Utilisasi Tim',
          value: '82%',
          delta: 'masih aman',
          accentHex: 0xFF20344A,
        ),
        DashboardMetric(
          label: 'Issue Kritis',
          value: '3',
          delta: 'perlu follow-up',
          accentHex: 0xFFB33A3A,
        ),
      ],
      projects: [
        ProjectSummary(
          name: 'Mobile Revamp',
          owner: 'Dinda',
          progress: 0.74,
          health: ProjectHealth.healthy,
          deadline: '12 Apr',
          teamSize: 7,
        ),
        ProjectSummary(
          name: 'Ops Dashboard',
          owner: 'Rama',
          progress: 0.52,
          health: ProjectHealth.atRisk,
          deadline: '16 Apr',
          teamSize: 5,
        ),
        ProjectSummary(
          name: 'Customer Portal',
          owner: 'Nina',
          progress: 0.28,
          health: ProjectHealth.blocked,
          deadline: '25 Apr',
          teamSize: 9,
        ),
      ],
      tasks: [
        TaskItem(
          title: 'Implement push notification digest',
          project: 'Mobile Revamp',
          assignee: 'Ayu',
          priority: 'High',
          stage: TaskStage.doing,
          dueLabel: 'Hari ini',
        ),
        TaskItem(
          title: 'Finalize KPI widgets',
          project: 'Ops Dashboard',
          assignee: 'Raka',
          priority: 'Medium',
          stage: TaskStage.review,
          dueLabel: 'Besok',
        ),
        TaskItem(
          title: 'Align API contract for timeline',
          project: 'Customer Portal',
          assignee: 'Wawan',
          priority: 'High',
          stage: TaskStage.todo,
          dueLabel: '3 hari lagi',
        ),
        TaskItem(
          title: 'Close QA defects sprint 12',
          project: 'Mobile Revamp',
          assignee: 'Salsa',
          priority: 'Low',
          stage: TaskStage.done,
          dueLabel: 'Selesai',
        ),
      ],
      members: [
        TeamMember(
          name: 'Ayu Putri',
          role: 'Flutter Engineer',
          focusProject: 'Mobile Revamp',
          utilization: 0.76,
          activeTasks: 4,
          statusLabel: 'Fokus',
        ),
        TeamMember(
          name: 'Raka Mahesa',
          role: 'Backend Engineer',
          focusProject: 'Ops Dashboard',
          utilization: 0.89,
          activeTasks: 6,
          statusLabel: 'Padat',
        ),
        TeamMember(
          name: 'Nina Ardani',
          role: 'Product Lead',
          focusProject: 'Customer Portal',
          utilization: 0.64,
          activeTasks: 3,
          statusLabel: 'Stabil',
        ),
        TeamMember(
          name: 'Salsa K.',
          role: 'QA Analyst',
          focusProject: 'Mobile Revamp',
          utilization: 0.58,
          activeTasks: 2,
          statusLabel: 'Longgar',
        ),
      ],
      alerts: [
        'Customer Portal tertahan karena dependensi API billing.',
        '2 engineer melewati utilization 85% minggu ini.',
        '5 task prioritas tinggi perlu review sebelum jam 17.00.',
      ],
    );
  }
}
