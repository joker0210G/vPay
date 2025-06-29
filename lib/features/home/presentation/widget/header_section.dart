// features/home/presentation/widgets/header_section.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vpay/core/constants/colors.dart';

class HeaderSection extends StatefulWidget {
  final Function(String) onSearch;
  final String username;
  final VoidCallback onProfileTap;
  final String? avatarUrl;

  const HeaderSection({
    super.key,
    required this.onSearch,
    required this.username,
    required this.onProfileTap,
    this.avatarUrl,
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.onSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    widget.username,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
                    ? CircleAvatar(
                        radius: 20, // Adjust radius as needed
                        backgroundImage: CachedNetworkImageProvider(widget.avatarUrl!),
                        // Optional: Add placeholder and error widgets for CachedNetworkImage
                        // You might need to convert CircleAvatar to use CachedNetworkImage widget
                        // directly if you need more control over placeholder/error states.
                        // For simplicity with backgroundImage, this is a basic approach.
                        // Consider using CachedNetworkImage widget for full features.
                      )
                    : const CircleAvatar(
                        radius: 20, // Adjust radius as needed
                        child: Icon(Icons.person),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search tasks here...',
                      hintStyle: const TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
