import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/chat/presentation/widget/chat_header.dart';
import 'package:vpay/features/chat/presentation/widget/chat_filter_bar.dart';
import 'package:vpay/features/chat/presentation/widget/chat_list_item.dart';
import 'package:vpay/features/chat/domain/chat_list_item_model.dart';
import 'package:vpay/features/task/domain/task_status.dart';
import 'package:vpay/features/chat/presentation/screens/chat_detail_screen.dart';
import 'package:vpay/features/chat/provider/chat_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _sortByDeadline = false;
  late TabController _tabController;
  String _currentTab = 'All';
  bool _isLoading = false;

  final List<String> _tabs = ['All', 'Active', 'Needs Action', 'Archived'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController.addListener(_debouncedFilterChats);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _debouncedFilterChats() {
    if (_searchController.text.isEmpty) {
      setState(() {});
      return;
    }
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentTab = _tabs[_tabController.index];
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 7) {
      return '${time.day}/${time.month}';
    } else if (difference.inDays > 0) {
      switch (difference.inDays) {
        case 1:
          return 'Yesterday';
        case 7:
          return 'Week ago';
        default:
          return '${difference.inDays}d ago';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool _isHighPriority(ChatListItemModel chatItem) {
    final now = DateTime.now();
    final deadlineThreshold = const Duration(days: 2);
    return chatItem.status == TaskStatus.paymentDue ||
           chatItem.status == TaskStatus.disputed ||
           (chatItem.status == TaskStatus.pending && 
            now.difference(chatItem.lastActivity) > deadlineThreshold);
  }

  Color _getPriorityColor(ChatListItemModel chatItem) {
    if (chatItem.status == TaskStatus.disputed) {
      return Colors.red.shade700;
    } else if (chatItem.status == TaskStatus.paymentDue) {
      return Colors.orange.shade700;
    } else {
      return Colors.amber.shade600;
    }
  }

  IconData _getPriorityIcon(ChatListItemModel chatItem) {
    if (chatItem.status == TaskStatus.disputed) {
      return Icons.warning;
    } else if (chatItem.status == TaskStatus.paymentDue) {
      return Icons.payment;
    } else {
      return Icons.access_time;
    }
  }

  Widget _buildStatusChip(TaskStatus status) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case TaskStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case TaskStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.work;
        break;
      case TaskStatus.awaitingReview:
        statusColor = Colors.purple;
        statusIcon = Icons.rate_review;
        break;
      case TaskStatus.paymentDue:
        statusColor = Colors.red;
        statusIcon = Icons.payment;
        break;
      case TaskStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case TaskStatus.disputed:
        statusColor = Colors.red.shade700;
        statusIcon = Icons.warning;
        break;
      case TaskStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withAlpha((0.5 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            status.name,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please login first'));
    }

    final chatRooms = ref.watch(filteredChatRoomsProvider((
      query: _searchController.text,
      tab: _currentTab,
    )));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ChatHeader(
              searchController: _searchController,
              onSettingsPressed: () {
                context.go('/personalization');
              },
            ),
            ChatFilterBar(
              tabController: _tabController,
              tabs: _tabs,
              isLoading: _isLoading,
              sortByDeadline: _sortByDeadline,
              onSortChanged: (value) => setState(() => _sortByDeadline = value),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  // chatRooms is a List<ChatListItemModel>
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (chatRooms.isEmpty) {
                    return const Center(child: Text('No chats found'));
                  }
                  final sortedRooms = [...chatRooms];
                  if (_sortByDeadline) {
                    sortedRooms.sort((a, b) =>
                      (a.lastActivity).compareTo(b.lastActivity));
                  } else {
                    sortedRooms.sort((a, b) =>
                      (b.lastActivity).compareTo(a.lastActivity));
                  }
                  return ListView.separated(
                    itemCount: sortedRooms.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final chatItem = sortedRooms[index];
                      return ChatListItem(
                        chatItem: chatItem,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(chatItem: chatItem),
                            ),
                          );
                        },
                        onTaskDetails: () {
                          Navigator.of(context).pushNamed(
                            '/task-details',
                            arguments: chatItem.taskId,
                          );
                        },
                        timeString: _formatTime(chatItem.lastActivity),
                        isHighPriority: _isHighPriority(chatItem),
                        priorityColor: _getPriorityColor(chatItem),
                        priorityIcon: _getPriorityIcon(chatItem),
                        statusChip: _buildStatusChip(chatItem.status),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
