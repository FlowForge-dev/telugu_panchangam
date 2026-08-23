import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/date_format.dart';
import '../../domain/models/festival_models.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Festival> _results = [];
  bool _searched = false;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final repos = context.read<Repositories>();
      final results = await repos.festival.search(value);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searched = value.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Search festivals…',
            border: InputBorder.none,
            filled: false,
          ),
          style: theme.textTheme.titleMedium,
        ),
      ),
      body: !_searched
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Icon(Icons.search_rounded, size: 40, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Search by festival name, in English or Telugu.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : _results.isEmpty
              ? Center(child: Text('No results', style: theme.textTheme.bodyMedium))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, i) {
                    final f = _results[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(f.name),
                      subtitle: Text('${f.teluguName} · ${formatDateShort(f.date)}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/festivals/${f.id}'),
                    );
                  },
                ),
    );
  }
}
