import 'package:flutter/material.dart';

import '../models/stored_session.dart';
import '../models/workspace_models.dart';
import '../services/auth_service.dart';
import '../services/mock_workspace_repository.dart';
import '../services/workspace_repository.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.session,
    required this.onLoggedOut,
    super.key,
  });

  final StoredSession session;
  final Future<void> Function() onLoggedOut;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final MockWorkspaceRepository _repository = MockWorkspaceRepository();
  final WorkspaceRepository _workspaceRepository = WorkspaceRepository();
  final AuthService _authService = AuthService();
  late Future<WorkspaceSnapshot> _snapshotFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
  }

  Future<WorkspaceSnapshot> _loadSnapshot() async {
    try {
      return await _workspaceRepository.fetchSnapshot(widget.session);
    } catch (_) {
      return _repository.load();
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout(widget.session);
    } catch (_) {
      // Tetap logout lokal jika server tidak bisa dijangkau.
    }

    await widget.onLoggedOut();
  }

  Future<void> _refresh() async {
    final future = _loadSnapshot();

    setState(() {
      _snapshotFuture = future;
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(['Dashboard', 'Projects', 'Tasks', 'Team'][_currentIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.session.userName),
                      Text(
                        widget.session.userEmail,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  widget.session.userName.characters.first.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<WorkspaceSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Data workspace belum tersedia.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refresh,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final tabs = [
            _DashboardTab(snapshot: data, session: widget.session),
            _ProjectsTab(projects: data.projects),
            _TasksTab(tasks: data.tasks),
            _TeamTab(members: data.members),
          ];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: tabs[_currentIndex],
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rtl_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Team',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.snapshot,
    required this.session,
  });

  final WorkspaceSnapshot snapshot;
  final StoredSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0E5A5A), Color(0xFF1A7D6E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${session.userName.split(' ').first}',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Pantau ritme kerja tim, kondisi project, dan task prioritas harian dari satu layar.',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: snapshot.alerts
                    .map(
                      (alert) => Container(
                        constraints: const BoxConstraints(maxWidth: 280),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          alert,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.metrics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.18,
          ),
          itemBuilder: (context, index) {
            final metric = snapshot.metrics[index];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Color(metric.accentHex),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const Spacer(),
                    Text(metric.value, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 6),
                    Text(metric.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      metric.delta,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Radar Project', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                ...snapshot.projects.map(
                  (project) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                project.name,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            _StatusChip(health: project.health),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: project.progress,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(project.progress * 100).round()}% • Owner ${project.owner} • Deadline ${project.deadline}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab({required this.projects});

  final List<ProjectSummary> projects;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: projects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final project = projects[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    _StatusChip(health: project.health),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Owner: ${project.owner}'),
                Text('Deadline: ${project.deadline}'),
                Text('Tim aktif: ${project.teamSize} orang'),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: project.progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(99),
                ),
                const SizedBox(height: 8),
                Text('Progress ${(project.progress * 100).round()}%'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab({required this.tasks});

  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    final grouped = {
      TaskStage.todo: tasks.where((item) => item.stage == TaskStage.todo).toList(),
      TaskStage.doing: tasks.where((item) => item.stage == TaskStage.doing).toList(),
      TaskStage.review: tasks.where((item) => item.stage == TaskStage.review).toList(),
      TaskStage.done: tasks.where((item) => item.stage == TaskStage.done).toList(),
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_labelForStage(entry.key), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...entry.value.map(
                    (task) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4EE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text('${task.project} • ${task.assignee}'),
                          const SizedBox(height: 4),
                          Text('${task.priority} priority • ${task.dueLabel}'),
                        ],
                      ),
                    ),
                  ),
                  if (entry.value.isEmpty) const Text('Belum ada task di kolom ini.'),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _labelForStage(TaskStage stage) {
    switch (stage) {
      case TaskStage.todo:
        return 'To Do';
      case TaskStage.doing:
        return 'In Progress';
      case TaskStage.review:
        return 'In Review';
      case TaskStage.done:
        return 'Done';
    }
  }
}

class _TeamTab extends StatelessWidget {
  const _TeamTab({required this.members});

  final List<TeamMember> members;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: members.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final member = members[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    member.name.characters.first,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('${member.role} • ${member.focusProject}'),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: member.utilization,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Load ${(member.utilization * 100).round()}% • ${member.activeTasks} task aktif • ${member.statusLabel}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.health});

  final ProjectHealth health;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (health) {
      ProjectHealth.healthy => ('On Track', const Color(0xFF2D8F6F)),
      ProjectHealth.atRisk => ('At Risk', const Color(0xFFD8733F)),
      ProjectHealth.blocked => ('Blocked', const Color(0xFFB33A3A)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
