import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../data/caught_word_storage.dart';
import '../models/catch_word.dart';
import '../widgets/catch_lingo_bottom_nav.dart';
import '../widgets/word_visuals.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'review_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  static const _storage = CaughtWordStorage();

  late Future<List<CatchWord>> _wordsFuture;
  final _searchController = TextEditingController();
  var _isSearching = false;
  var _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _wordsFuture = _storage.loadWords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openExplore() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ExploreScreen()));

    if (!mounted) {
      return;
    }

    setState(() {
      _wordsFuture = _storage.loadWords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchLingoColors.canvas,
      appBar: AppBar(
        title: const Text('Dictionary'),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            tooltip: _isSearching ? 'Close search' : 'Search',
          ),
        ],
      ),
      bottomNavigationBar: CatchLingoBottomNav(
        selectedTab: CatchLingoTab.dictionary,
        onSelected: _openTab,
      ),
      body: SafeArea(
        child: FutureBuilder<List<CatchWord>>(
          future: _wordsFuture,
          builder: (context, snapshot) {
            final words = snapshot.data ?? [];

            if (words.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  CatchLingoSpacing.screen,
                  CatchLingoSpacing.sm,
                  CatchLingoSpacing.screen,
                  CatchLingoSpacing.screen,
                ),
                children: [_DictionaryEmptyState(onExplore: _openExplore)],
              );
            }

            final searchedWords = _filterWords(words);
            final availableCategories = _groupWordsByCategory(
              searchedWords,
            ).keys.toList();
            final visibleWords = _filterWordsByCategory(searchedWords);
            final groupedWords = _groupWordsByCategory(visibleWords);
            final hasQuery = _searchQuery.trim().isNotEmpty;
            final selectedCategory = _selectedCategory;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                CatchLingoSpacing.screen,
                CatchLingoSpacing.sm,
                CatchLingoSpacing.screen,
                CatchLingoSpacing.screen,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Dictionary',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: CatchLingoColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    _ShelfCountPill(count: words.length),
                  ],
                ),
                const SizedBox(height: CatchLingoSpacing.xs),
                Text(
                  hasQuery
                      ? '${visibleWords.length} ${visibleWords.length == 1 ? 'match' : 'matches'} found'
                      : selectedCategory == null
                      ? '${words.length} words collected'
                      : '${visibleWords.length} ${visibleWords.length == 1 ? 'word' : 'words'} in $selectedCategory',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isSearching) ...[
                  const SizedBox(height: CatchLingoSpacing.md),
                  _DictionarySearchField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ],
                if (visibleWords.isNotEmpty) ...[
                  const SizedBox(height: CatchLingoSpacing.md),
                  _DictionaryFilters(
                    categories: availableCategories,
                    selectedCategory: _selectedCategory,
                    onSelected: _selectCategory,
                  ),
                ],
                const SizedBox(height: CatchLingoSpacing.xl),
                if (visibleWords.isEmpty)
                  _DictionaryNoResults(
                    isFiltered: hasQuery || selectedCategory != null,
                    query: _searchQuery,
                  )
                else
                  for (final entry in groupedWords.entries) ...[
                    _CategorySectionHeader(
                      label: entry.key,
                      count: entry.value.length,
                    ),
                    const SizedBox(height: CatchLingoSpacing.sm),
                    for (final indexedWord in entry.value.indexed) ...[
                      _StaggeredDictionaryEntry(
                        index: indexedWord.$1,
                        child: _DictionaryWordCard(word: indexedWord.$2),
                      ),
                      const SizedBox(height: CatchLingoSpacing.md),
                    ],
                    const SizedBox(height: CatchLingoSpacing.sm),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;

      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _selectCategory(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  List<CatchWord> _filterWords(List<CatchWord> words) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return words;
    }

    return words.where((word) {
      final category = _categoryLabel(word.category).toLowerCase();

      return word.source.toLowerCase().contains(query) ||
          word.translation.toLowerCase().contains(query) ||
          category.contains(query);
    }).toList();
  }

  List<CatchWord> _filterWordsByCategory(List<CatchWord> words) {
    final selectedCategory = _selectedCategory;

    if (selectedCategory == null) {
      return words;
    }

    return words
        .where((word) => _categoryLabel(word.category) == selectedCategory)
        .toList();
  }

  Map<String, List<CatchWord>> _groupWordsByCategory(List<CatchWord> words) {
    final groupedWords = <String, List<CatchWord>>{};

    for (final word in words) {
      final category = _categoryLabel(word.category);
      groupedWords.putIfAbsent(category, () => []).add(word);
    }

    final sortedEntries = groupedWords.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  void _openTab(CatchLingoTab tab) {
    switch (tab) {
      case CatchLingoTab.discover:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case CatchLingoTab.dictionary:
        break;
      case CatchLingoTab.review:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ReviewScreen()),
        );
        break;
    }
  }
}

String _categoryLabel(String category) {
  final trimmedCategory = category.trim();

  if (trimmedCategory.isEmpty) {
    return 'Other';
  }

  return trimmedCategory;
}

class _DictionaryFilters extends StatelessWidget {
  const _DictionaryFilters({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = ['All', ...categories];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < filters.length; index++) ...[
            if (index > 0) const SizedBox(width: CatchLingoSpacing.sm),
            _FilterChip(
              label: filters[index],
              isSelected: index == 0
                  ? selectedCategory == null
                  : selectedCategory == filters[index],
              onTap: () => onSelected(index == 0 ? null : filters[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _DictionarySearchField extends StatelessWidget {
  const _DictionarySearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search caught words',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: CatchLingoColors.warmSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CatchLingoRadius.button),
          borderSide: BorderSide(
            color: CatchLingoColors.textPrimary.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CatchLingoRadius.button),
          borderSide: BorderSide(
            color: CatchLingoColors.textPrimary.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CatchLingoRadius.button),
          borderSide: const BorderSide(
            color: CatchLingoColors.warmGreen,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
        child: AnimatedContainer(
          duration: CatchLingoMotion.chip,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? CatchLingoColors.warmGreen
                : CatchLingoColors.warmSurface,
            borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
            border: Border.all(
              color: isSelected
                  ? CatchLingoColors.warmGreen
                  : CatchLingoColors.textPrimary.withValues(alpha: 0.06),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? Colors.white : CatchLingoColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DictionaryNoResults extends StatelessWidget {
  const _DictionaryNoResults({required this.isFiltered, required this.query});

  final bool isFiltered;
  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CatchLingoSpacing.lg),
      decoration: BoxDecoration(
        color: CatchLingoColors.warmSurface,
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
        border: Border.all(
          color: CatchLingoColors.textPrimary.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CatchLingoColors.amber.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.manage_search_rounded,
              color: CatchLingoColors.amber,
            ),
          ),
          const SizedBox(width: CatchLingoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No matching words',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CatchLingoColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  !isFiltered
                      ? 'Catch more real-world words to grow this collection.'
                      : query.trim().isEmpty
                      ? 'Search your caught words by word, translation, or category.'
                      : 'Try another caught word, translation, or category.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w500,
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

class _DictionaryEmptyState extends StatelessWidget {
  const _DictionaryEmptyState({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: CatchLingoColors.warmSurface,
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: CatchLingoColors.mint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(CatchLingoRadius.card),
              border: Border.all(
                color: CatchLingoColors.mint.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 42,
              color: CatchLingoColors.mint,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.lg),
          Text(
            'No words collected yet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: CatchLingoColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.sm),
          Text(
            'Catch words in Explore and they will appear here as your collection grows.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CatchLingoColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.lg),
          FilledButton.icon(
            onPressed: onExplore,
            style: FilledButton.styleFrom(
              backgroundColor: CatchLingoColors.warmGreen,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.travel_explore_rounded),
            label: const Text('Start Exploring'),
          ),
        ],
      ),
    );
  }
}

class _ShelfCountPill extends StatelessWidget {
  const _ShelfCountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CatchLingoColors.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
        border: Border.all(
          color: CatchLingoColors.mint.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        '$count caught words',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: CatchLingoColors.mint,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CategorySectionHeader extends StatelessWidget {
  const _CategorySectionHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CatchLingoColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '$count ${count == 1 ? 'word' : 'words'}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: CatchLingoColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StaggeredDictionaryEntry extends StatelessWidget {
  const _StaggeredDictionaryEntry({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (index.clamp(0, 5) * 45)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final eased = Curves.easeOutCubic.transform(value);

        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - eased)),
            child: Transform.scale(
              scale: 0.985 + 0.015 * eased,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _DictionaryWordCard extends StatelessWidget {
  const _DictionaryWordCard({required this.word});

  final CatchWord word;

  @override
  Widget build(BuildContext context) {
    final category = _categoryLabel(word.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showWordDetail(context, word),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(CatchLingoSpacing.md),
          decoration: BoxDecoration(
            color: CatchLingoColors.warmSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _WordObjectBadge(word: word),
              const SizedBox(width: CatchLingoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: CatchLingoColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                              children: [
                                TextSpan(text: word.source),
                                TextSpan(
                                  text: '   ${word.translation}',
                                  style: TextStyle(
                                    color: CatchLingoColors.textMuted
                                        .withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$category · ${_lastSeenLabel(word.lastSeenAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CatchLingoColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CatchLingoSpacing.sm),
              Icon(
                Icons.bookmark_rounded,
                color: CatchLingoColors.warmGreen,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showWordDetail(BuildContext context, CatchWord word) {
  final category = _categoryLabel(word.category);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: CatchLingoColors.warmSurface,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(CatchLingoRadius.panel),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchLingoSpacing.screen,
              CatchLingoSpacing.sm,
              CatchLingoSpacing.screen,
              CatchLingoSpacing.screen,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _WordObjectBadge(word: word),
                    const SizedBox(width: CatchLingoSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word.source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: CatchLingoColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Text(
                            word.translation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: CatchLingoColors.warmGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: CatchLingoSpacing.lg),
                _WordDetailFactRow(
                  icon: Icons.category_rounded,
                  label: 'Category',
                  value: category,
                ),
                _WordDetailFactRow(
                  icon: Icons.visibility_rounded,
                  label: 'Sightings',
                  value: _seenCountLabel(word.seenCount),
                ),
                _WordDetailFactRow(
                  icon: Icons.schedule_rounded,
                  label: 'Last seen',
                  value: _lastSeenLabel(word.lastSeenAt),
                ),
                const SizedBox(height: CatchLingoSpacing.lg),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReviewScreen(initialWordId: word.id),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: CatchLingoColors.warmGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.style_rounded),
                  label: const Text('Review this word'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _WordDetailFactRow extends StatelessWidget {
  const _WordDetailFactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchLingoSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CatchLingoColors.amber.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: CatchLingoColors.warmGreen, size: 19),
          ),
          const SizedBox(width: CatchLingoSpacing.md),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CatchLingoColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: CatchLingoSpacing.md),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CatchLingoColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _seenCountLabel(int seenCount) {
  final count = seenCount <= 0 ? 1 : seenCount;
  return '$count ${count == 1 ? 'time' : 'times'}';
}

String _lastSeenLabel(DateTime? lastSeenAt) {
  if (lastSeenAt == null) {
    return 'Last spotted recently';
  }

  final difference = DateTime.now().difference(lastSeenAt);

  if (difference.inDays == 0) {
    return 'Last spotted today';
  }

  if (difference.inDays == 1) {
    return 'Last spotted yesterday';
  }

  return 'Last spotted ${difference.inDays} days ago';
}

class _WordObjectBadge extends StatelessWidget {
  const _WordObjectBadge({required this.word});

  final CatchWord word;

  @override
  Widget build(BuildContext context) {
    final icon = catchWordIcon(word);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: CatchLingoColors.amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: CatchLingoColors.textPrimary, size: 26),
    );
  }
}
