import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
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
  final Set<Task> _selectedTasks = {}; // 选中的任务

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
  return Scaffold(
    appBar: AppBar(
      title: Text('Download Manager'),
      actions: [
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: _isAnySelected ? _resumeSelectedTasks : null,
        ),
        IconButton(
          icon: Icon(Icons.pause),
          onPressed: _isAnySelected ? _pauseSelectedTasks : null,
        ),
        IconButton(
          icon: Icon(Icons.cancel),
          onPressed: _isAnySelected ? _cancelSelectedTasks : null,
        ),
      ],
    ),
    body: ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ListTile(
                leading: Checkbox(
                  value: _selectedTasks.contains(task),
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
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        setState(() {
                          _tasks.remove(task);
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(task.isPaused ? Icons.play_arrow : Icons.pause),
                      onPressed: () {
                        setState(() {
                          task.isPaused = !task.isPaused;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LinearProgressIndicator(
                  value: 0.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Details of ${task.name}...'),
              ),
            ],
          ),
        );
      },
    ),
  );
}


  Widget _buildDesktop(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Center(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: width * 0.8 < 1600 ? width * 0.8 : 1600,
                  maxHeight: height * 0.8 < 1200 ? height * 0.8 : 1200),
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                    color: fluent.FluentTheme.of(context).menuColor,
                    borderRadius: BorderRadius.circular(12),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Download Manager',
                              style: fluent.FluentTheme.of(context)
                                  .typography
                                  .title,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                fluent.Button(
                                  onPressed: _isAnySelected
                                      ? _resumeSelectedTasks
                                      : null,
                                  child: const Text('继续'),
                                ),
                                const SizedBox(width: 8),
                                fluent.Button(
                                  onPressed: _isAnySelected
                                      ? _pauseSelectedTasks
                                      : null,
                                  child: const Text('暂停'),
                                ),
                                const SizedBox(width: 8),
                                fluent.Button(
                                  onPressed: _isAnySelected
                                      ? _cancelSelectedTasks
                                      : null,
                                  child: const Text('取消'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: ListView.builder(
                              itemCount: _tasks.length,
                              itemBuilder: (context, index) {
                                final task = _tasks[index];
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: fluent.FluentTheme.of(context)
                                        .micaBackgroundColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: fluent.ListTile.selectable(
                                    tileColor: WidgetStateProperty.resolveWith(
                                        (states) {
                                      if (states.isHovered ||
                                          states.isFocused) {
                                        return fluent.FluentTheme.of(context)
                                            .accentColor
                                            .withOpacity(1);
                                      }
                                      return fluent.FluentTheme.of(context)
                                          .micaBackgroundColor;
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
                                    leading: fluent.Checkbox(
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
                                    title: Row(
                                      children: [
                                        Text(task.name),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: fluent.ProgressBar(
                                            value: 50,
                                            backgroundColor: Colors.grey[200],
                                            strokeWidth: 6,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            icon:
                                                Icon(fluent.FluentIcons.cancel),
                                            onPressed: () {
                                              setState(() {
                                                _tasks.remove(task);
                                              });
                                            }),
                                        IconButton(
                                          icon: Icon(task.isPaused
                                              ? fluent.FluentIcons.play
                                              : fluent.FluentIcons.pause),
                                          onPressed: () {
                                            setState(() {
                                              task.isPaused = !task.isPaused;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(task.isExpanded
                                              ? fluent.FluentIcons.chevron_up
                                              : fluent
                                                  .FluentIcons.chevron_down),
                                          onPressed: () {
                                            setState(() {
                                              task.isExpanded =
                                                  !task.isExpanded;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    subtitle: task.isExpanded
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              const Text('任务详情...'),
                                              const SizedBox(height: 8),
                                            ],
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        );
      },
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
