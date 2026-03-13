import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/models/task_model.dart';
import '../../shared/widgets/task_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../add_task/add_task_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                expandedHeight: 160,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _getGreeting(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userProvider.userName,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildQuickStats(taskProvider),
                      ],
                    ),
                  ),
                ),
              ),
              
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchBarDelegate(
                  child: _buildSearchBar(taskProvider),
                  height: 80,
                ),
              ),
              
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterChipsDelegate(
                  child: _buildFilterChips(taskProvider),
                  height: 60,
                ),
              ),
            ];
          },
          body: _buildTaskList(taskProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('مهمة جديدة'),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }

  Widget _buildQuickStats(TaskProvider taskProvider) {
    return Row(
      children: [
        _buildStatChip(
          '${taskProvider.todayTasks}',
          'اليوم',
          Icons.today_rounded,
          const Color(0xFF0A84FF),
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          '${taskProvider.pendingTasks}',
          'متبقية',
          Icons.pending_actions_rounded,
          const Color(0xFFFF9500),
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          '${taskProvider.completedTasks}',
          'مكتملة',
          Icons.check_circle_rounded,
          const Color(0xFF30D158),
        ),
      ],
    );
  }

  Widget _buildStatChip(String count, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(TaskProvider taskProvider) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          taskProvider.setSearchQuery(value);
          setState(() {
            _isSearching = value.isNotEmpty;
          });
        },
        decoration: InputDecoration(
          hintText: 'ابحث عن مهمة...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    taskProvider.setSearchQuery('');
                    setState(() {
                      _isSearching = false;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips(TaskProvider taskProvider) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('الكل', TaskFilter.all, taskProvider),
            const SizedBox(width: 8),
            _buildFilterChip('النشطة', TaskFilter.active, taskProvider),
            const SizedBox(width: 8),
            _buildFilterChip('المكتملة', TaskFilter.completed, taskProvider),
            const SizedBox(width: 8),
            _buildFilterChip('اليوم', TaskFilter.today, taskProvider),
            const SizedBox(width: 8),
            _buildFilterChip('المتأخرة', TaskFilter.overdue, taskProvider),
            const SizedBox(width: 8),
            _buildFilterChip('عالية الأولوية', TaskFilter.high, taskProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskFilter filter, TaskProvider taskProvider) {
    final isSelected = taskProvider.currentFilter == filter;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => taskProvider.setFilter(filter),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: const Color(0xFFC0C0C0).withOpacity(0.2),
      checkmarkColor: const Color(0xFFC0C0C0),
      side: BorderSide(
        color: isSelected 
            ? const Color(0xFFC0C0C0) 
            : Colors.transparent,
        width: 1.5,
      ),
    );
  }

  Widget _buildTaskList(TaskProvider taskProvider) {
    final tasks = taskProvider.tasks;

    if (tasks.isEmpty) {
      String message = 'لا توجد مهام';
      if (_isSearching) {
        message = 'لم يتم العثور على نتائج';
      } else if (taskProvider.currentFilter == TaskFilter.completed) {
        message = 'لم تكمل أي مهمة بعد';
      } else if (taskProvider.currentFilter == TaskFilter.today) {
        message = 'لا توجد مهام لليوم';
      }
      
      return EmptyState(
        icon: Icons.task_alt_rounded,
        message: message,
        description: 'ابدأ بإضافة مهمة جديدة',
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100, top: 10),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: TaskCard(
                  task: tasks[index],
                  onToggle: () => taskProvider.toggleTask(tasks[index].id),
                  onDelete: () => _showDeleteDialog(tasks[index], taskProvider),
                  onEdit: () => _navigateToEditTask(tasks[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Task task, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المهمة'),
        content: Text('هل أنت متأكد من حذف "${task.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              taskProvider.deleteTask(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف المهمة')),
              );
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(taskToEdit: task),
      ),
    );
  }
}

// Custom SliverPersistentHeaderDelegate for Search Bar
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SearchBarDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

// Custom SliverPersistentHeaderDelegate for Filter Chips
class _FilterChipsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _FilterChipsDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
