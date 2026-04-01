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

  factory DashboardMetric.fromJson(Map<String, dynamic> json) {
    return DashboardMetric(
      label: json['label']?.toString() ?? '-',
      value: json['value']?.toString() ?? '0',
      delta: json['delta']?.toString() ?? '-',
      accentHex: (json['accentHex'] as num?)?.toInt() ?? 0xFF20344A,
    );
  }
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

  factory ProjectSummary.fromJson(Map<String, dynamic> json) {
    return ProjectSummary(
      name: json['name']?.toString() ?? '-',
      owner: json['owner']?.toString() ?? '-',
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      health: parseProjectHealth(json['health']?.toString()),
      deadline: json['deadline']?.toString() ?? '-',
      teamSize: (json['teamSize'] as num?)?.toInt() ?? 0,
    );
  }
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

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      title: json['title']?.toString() ?? '-',
      project: json['project']?.toString() ?? '-',
      assignee: json['assignee']?.toString() ?? '-',
      priority: json['priority']?.toString() ?? 'Medium',
      stage: parseTaskStage(json['stage']?.toString()),
      dueLabel: json['dueLabel']?.toString() ?? '-',
    );
  }
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

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      name: json['name']?.toString() ?? '-',
      role: json['role']?.toString() ?? '-',
      focusProject: json['focusProject']?.toString() ?? '-',
      utilization: (json['utilization'] as num?)?.toDouble() ?? 0,
      activeTasks: (json['activeTasks'] as num?)?.toInt() ?? 0,
      statusLabel: json['statusLabel']?.toString() ?? '-',
    );
  }
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

  factory WorkspaceSnapshot.fromJson(Map<String, dynamic> json) {
    final metrics = (json['metrics'] as List<dynamic>? ?? [])
        .map((item) => DashboardMetric.fromJson(item as Map<String, dynamic>))
        .toList();
    final projects = (json['projects'] as List<dynamic>? ?? [])
        .map((item) => ProjectSummary.fromJson(item as Map<String, dynamic>))
        .toList();
    final tasks = (json['tasks'] as List<dynamic>? ?? [])
        .map((item) => TaskItem.fromJson(item as Map<String, dynamic>))
        .toList();
    final members = (json['members'] as List<dynamic>? ?? [])
        .map((item) => TeamMember.fromJson(item as Map<String, dynamic>))
        .toList();
    final alerts = (json['alerts'] as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .toList();

    return WorkspaceSnapshot(
      metrics: metrics,
      projects: projects,
      tasks: tasks,
      members: members,
      alerts: alerts,
    );
  }
}

ProjectHealth parseProjectHealth(String? value) {
  switch (value) {
    case 'healthy':
      return ProjectHealth.healthy;
    case 'atRisk':
    case 'at_risk':
      return ProjectHealth.atRisk;
    case 'blocked':
      return ProjectHealth.blocked;
    default:
      return ProjectHealth.healthy;
  }
}

TaskStage parseTaskStage(String? value) {
  switch (value) {
    case 'todo':
      return TaskStage.todo;
    case 'doing':
      return TaskStage.doing;
    case 'review':
      return TaskStage.review;
    case 'done':
      return TaskStage.done;
    default:
      return TaskStage.todo;
  }
}
