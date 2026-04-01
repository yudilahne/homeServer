enum ProjectHealth { healthy, atRisk, blocked }

enum TaskStage { todo, doing, review, done }

class DashboardMetric {
  const DashboardMetric({
    required this.label,
    required this.value,
    required this.delta,
    required this.accentHex,
  });

  final String label;
  final String value;
  final String delta;
  final int accentHex;
}

class ProjectSummary {
  const ProjectSummary({
    required this.name,
    required this.owner,
    required this.progress,
    required this.health,
    required this.deadline,
    required this.teamSize,
  });

  final String name;
  final String owner;
  final double progress;
  final ProjectHealth health;
  final String deadline;
  final int teamSize;
}

class TaskItem {
  const TaskItem({
    required this.title,
    required this.project,
    required this.assignee,
    required this.priority,
    required this.stage,
    required this.dueLabel,
  });

  final String title;
  final String project;
  final String assignee;
  final String priority;
  final TaskStage stage;
  final String dueLabel;
}

class TeamMember {
  const TeamMember({
    required this.name,
    required this.role,
    required this.focusProject,
    required this.utilization,
    required this.activeTasks,
    required this.statusLabel,
  });

  final String name;
  final String role;
  final String focusProject;
  final double utilization;
  final int activeTasks;
  final String statusLabel;
}

class WorkspaceSnapshot {
  const WorkspaceSnapshot({
    required this.metrics,
    required this.projects,
    required this.tasks,
    required this.members,
    required this.alerts,
  });

  final List<DashboardMetric> metrics;
  final List<ProjectSummary> projects;
  final List<TaskItem> tasks;
  final List<TeamMember> members;
  final List<String> alerts;
}
