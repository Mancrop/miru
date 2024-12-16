import 'package:fluent_ui/fluent_ui.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class DownloadManagerPage extends StatefulWidget {
  const DownloadManagerPage({super.key, this.tag});

  final String? tag;

  @override
  State<DownloadManagerPage> createState() => _DownloadManagerPageState();
}

class Task {
  String name;
  bool isPaused;
  bool isExpanded;

  Task({
    required this.name,
    this.isPaused = false,
    this.isExpanded = false,
  });
}

class _DownloadManagerPageState extends State<DownloadManagerPage> {
  List<Task> _tasks = []; // 任务列表
  Set<Task> _selectedTasks = {}; // 选中的任务

  @override
  void initState() {
    super.initState();
    _tasks = [
      Task(name: '任务1'),
      Task(name: '任务2'),
      Task(name: '任务3'),
    ];
  }

  bool get _isAnySelected => _selectedTasks.isNotEmpty;

  Widget _buildAndroid(BuildContext context) {
    return const Text('Not implemented');
  }

  Widget _buildDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DownloadManager',
            style: FluentTheme.of(context).typography.title,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                child: const Text('继续'),
                onPressed: _isAnySelected ? _resumeSelectedTasks : null,
              ),
              const SizedBox(width: 8),
              Button(
                child: const Text('暂停'),
                onPressed: _isAnySelected ? _pauseSelectedTasks : null,
              ),
              const SizedBox(width: 8),
              Button(
                child: const Text('取消'),
                onPressed: _isAnySelected ? _cancelSelectedTasks : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: FluentTheme.of(context).micaBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListTile.selectable(
                        tileColor: ButtonState.resolveWith((states) {
                          if (states.isHovering || states.isFocused) {
                            return FluentTheme.of(context)
                                .accentColor
                                .withOpacity(0.1);
                          }
                          return FluentTheme.of(context).micaBackgroundColor;
                        }),
                        selected: _selectedTasks.contains(task),
                        onSelectionChange: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTasks.add(task);
                            } else {
                              _selectedTasks.remove(task);
                            }
                          });
                        },
                        leading: Checkbox(
                          checked: _selectedTasks.contains(task),
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                _selectedTasks.add(task);
                              } else {
                                _selectedTasks.remove(task);
                              }
                            });
                          },
                        ),
                        title: Text(task.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(task.isPaused
                                  ? FluentIcons.play
                                  : FluentIcons.pause),
                              onPressed: () {
                                setState(() {
                                  task.isPaused = !task.isPaused;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(task.isExpanded
                                  ? FluentIcons.chevron_up
                                  : FluentIcons.chevron_down),
                              onPressed: () {
                                setState(() {
                                  task.isExpanded = !task.isExpanded;
                                });
                              },
                            ),
                          ],
                        ),
                        subtitle: task.isExpanded
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('任务详情...'),
                                  Button(
                                    child: const Text('取消下载'),
                                    onPressed: () {
                                      // 取消下载逻辑
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resumeSelectedTasks() {
    // 恢复选中任务的逻辑
  }

  void _pauseSelectedTasks() {
    // 暂停选中任务的逻辑
  }

  void _cancelSelectedTasks() {
    // 取消选中任务的逻辑
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
