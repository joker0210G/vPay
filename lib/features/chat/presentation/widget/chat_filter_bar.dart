// chat_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:vpay/core/constants/colors.dart';

class ChatFilterBar extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;
  final bool isLoading;
  final bool sortByDeadline;
  final ValueChanged<bool> onSortChanged;

  const ChatFilterBar({
    super.key,
    required this.tabController,
    required this.tabs,
    required this.isLoading,
    required this.sortByDeadline,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: tabController,
          tabs: tabs.map((tab) => Tab(
            child: Opacity(
              opacity: isLoading ? 0.5 : 1.0,
              child: Text(tab),
            ),
          )).toList(),
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        if (isLoading)
          LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 2,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text('Sort by:', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Last Activity'),
                        selected: !sortByDeadline,
                        onSelected: isLoading ? null : (selected) {
                          if (selected) onSortChanged(false);
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Task Deadline'),
                        selected: sortByDeadline,
                        onSelected: isLoading ? null : (selected) {
                          if (selected) onSortChanged(true);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
