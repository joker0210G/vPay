// features/home/presentation/screens/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/core/constants/colors.dart';
import 'package:vpay/features/home/domain/navigation.dart';
import 'package:vpay/features/home/presentation/widget/categories_section.dart';
import 'package:vpay/features/home/presentation/widget/header_section.dart';
import 'package:vpay/features/home/presentation/widget/stats_section.dart';
import 'package:vpay/features/task/presentation/screens/task_list_screen.dart';
import 'package:vpay/features/chat/presentation/screens/chat_screen.dart';
import 'package:vpay/features/account/presentation/screens/account_screen.dart';
import 'package:vpay/features/home/provider/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(key: PageStorageKey('home-content')),
    FutureBuilder(
      key: PageStorageKey('tasks-content'),
      future: Future.delayed(const Duration(milliseconds: 300)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return const TaskListScreen();
      },
    ),
    FutureBuilder(
      key: PageStorageKey('chat-content'),
      future: Future.delayed(const Duration(milliseconds: 300)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return const ChatScreen();
      },
    ),
    FutureBuilder(
      key: PageStorageKey('account-content'),
      future: Future.delayed(const Duration(milliseconds: 300)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return const AccountScreen();
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: AppNavigation.items,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: constraints.maxWidth > 400,
            type: BottomNavigationBarType.fixed,
            iconSize: constraints.maxWidth < 360 ? 20 : 24,
          );
        },
      ),
    );
  }
}

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  Timer? _searchTimer;
  List<String> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              err.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(userProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (user) {
        void handleProfileTap() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccountScreen()),
          );
        }

        Future<void> handleSearch(String query) async {
          
          // Cancel previous timer if exists
          _searchTimer?.cancel();
          
          if (query.isEmpty) {
            setState(() {
              _searchResults = [];
            });
            return;
          }

          
          _searchTimer = Timer(const Duration(milliseconds: 300), () async {
            try {
              final results = await ref.read(searchProvider(query).future);
              if (!mounted) return;
              
              setState(() {
                _searchResults = List<String>.from(results);
              });
              
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search Results'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchResults.isEmpty)
                        const Text('No results found')
                      else
                        ..._searchResults.map((result) => 
                          ListTile(
                            title: Text(result),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          )
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search failed: ${e.toString()}'))
              );
            }
          });
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              HeaderSection(
                onSearch: handleSearch,
                username: user?.username ?? 'Unknown User',
                onProfileTap: handleProfileTap,
                avatarUrl: user?.avatarUrl,
              ),
              const SizedBox(height: 24),
              const StatsSection(),
              const SizedBox(height: 24),
              const CategoriesSection(),
            ],
          ),
        );
      },
    );
  }
}
