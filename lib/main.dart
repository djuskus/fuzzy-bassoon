import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MarginaliaApp());
}

const _bg = Color(0xFF111110);
const _gold = Color(0xFFC9A96E);
const _cream = Color(0xFFF0EAD8);

final _texts = <Map<String, String>>[
  {
    'type': 'Essay',
    'title': 'On the Shortness of Life',
    'author': 'Seneca',
    'subject': 'Philosophy',
    'excerpt':
        'It is not that we have a short time to live, but that we waste a lot of it. Life is long enough, and a sufficiently generous amount has been given to us for the highest achievements.',
  },
  {
    'type': 'Excerpt',
    'title': 'The Brothers Karamazov',
    'author': 'Fyodor Dostoevsky',
    'subject': 'Literature',
    'excerpt':
        "Above all, don't lie to yourself. The man who lies to himself and listens to his own lie comes to a point that he cannot distinguish the truth.",
  },
  {
    'type': 'Essay',
    'title': 'Self-Reliance',
    'author': 'Ralph Waldo Emerson',
    'subject': 'Philosophy',
    'excerpt':
        'Trust thyself: every heart vibrates to that iron string. Accept the place the divine providence has found for you; the society of your contemporaries, the connexion of events.',
  },
  {
    'type': 'Excerpt',
    'title': 'Meditations',
    'author': 'Marcus Aurelius',
    'subject': 'Philosophy',
    'excerpt':
        'You have power over your mind, not outside events. Realize this, and you will find strength. The happiness of your life depends upon the quality of your thoughts.',
  },
  {
    'type': 'Essay',
    'title': "A Room of One's Own",
    'author': 'Virginia Woolf',
    'subject': 'Literature',
    'excerpt':
        'A woman must have money and a room of her own if she is to write fiction. And that, as you will see, leaves the great problem of the true nature of woman unsolved.',
  },
  {
    'type': 'Essay',
    'title': 'The Perpetual Peace',
    'author': 'Immanuel Kant',
    'subject': 'Politics',
    'excerpt':
        'The state of peace among men living in close proximity is not the natural state; instead, the natural state is one of war, which does not just consist in open hostilities.',
  },
  {
    'type': 'Excerpt',
    'title': 'On the Origin of Species',
    'author': 'Charles Darwin',
    'subject': 'Science',
    'excerpt':
        'From so simple a beginning endless forms most beautiful and most wonderful have been, and are being, evolved. There is grandeur in this view of life.',
  },
  {
    'type': 'Essay',
    'title': 'The Decline of the West',
    'author': 'Oswald Spengler',
    'subject': 'History',
    'excerpt':
        'Each culture has its own new possibilities of self-expression which arise, ripen, decay and never return. These cultures, sublimated life-essences, grow with the same superb aimlessness as the flowers of the field.',
  },
];

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

class MarginaliaApp extends StatelessWidget {
  const MarginaliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marginalia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(
          surface: _bg,
          primary: _gold,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MarginaliaHome(),
    );
  }
}

// ---------------------------------------------------------------------------
// Home — manages tab + author-filter cross-tab state
// ---------------------------------------------------------------------------

class MarginaliaHome extends StatefulWidget {
  const MarginaliaHome({super.key});

  @override
  State<MarginaliaHome> createState() => _MarginaliaHomeState();
}

class _MarginaliaHomeState extends State<MarginaliaHome> {
  int _tab = 0;
  String _authorFilter = '';

  void _filterByAuthor(String author) {
    setState(() {
      _tab = 0;
      _authorFilter = author;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              tab: _tab,
              onTabChanged: (t) => setState(() {
                _tab = t;
                if (t != 0) _authorFilter = '';
              }),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _LibraryPage(authorFilter: _authorFilter),
                  _AuthorsPage(onAuthorTap: _filterByAuthor),
                  const _RequestsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.tab, required this.onTabChanged});

  final int tab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marginalia',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: _cream,
              letterSpacing: 0.66,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _NavTab(
                label: 'Library',
                active: tab == 0,
                onTap: () => onTabChanged(0),
              ),
              _NavTab(
                label: 'By author',
                active: tab == 1,
                onTap: () => onTabChanged(1),
              ),
              _NavTab(
                label: 'Requests',
                active: tab == 2,
                onTap: () => onTabChanged(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatefulWidget {
  const _NavTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.active ? _gold : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              color: widget.active
                  ? _cream
                  : _hovered
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Library page
// ---------------------------------------------------------------------------

class _LibraryPage extends StatefulWidget {
  const _LibraryPage({this.authorFilter = ''});

  final String authorFilter;

  @override
  State<_LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<_LibraryPage> {
  late final TextEditingController _searchController;
  String _typeFilter = '';
  String _subjectFilter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.authorFilter);
    _searchController.addListener(_onSearch);
  }

  void _onSearch() => setState(() {});

  @override
  void didUpdateWidget(_LibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.authorFilter != oldWidget.authorFilter &&
        widget.authorFilter.isNotEmpty) {
      _subjectFilter = 'all';
      _typeFilter = '';
      _searchController.text = widget.authorFilter;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filtered {
    final q = _searchController.text.toLowerCase();
    return _texts.where((t) {
      final matchQ = q.isEmpty ||
          t['title']!.toLowerCase().contains(q) ||
          t['author']!.toLowerCase().contains(q) ||
          t['excerpt']!.toLowerCase().contains(q);
      final matchType = _typeFilter.isEmpty || t['type'] == _typeFilter;
      final matchSubject =
          _subjectFilter == 'all' || t['subject'] == _subjectFilter;
      return matchQ && matchType && matchSubject;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SearchInput(controller: _searchController)),
              const SizedBox(width: 10),
              _TypeFilter(
                value: _typeFilter,
                onChanged: (v) => setState(() => _typeFilter = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SubjectChips(
            active: _subjectFilter,
            onChanged: (s) => setState(() => _subjectFilter = s),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Texts'),
          const SizedBox(height: 14),
          _TextGrid(texts: _filtered),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Authors page
// ---------------------------------------------------------------------------

class _AuthorsPage extends StatelessWidget {
  const _AuthorsPage({required this.onAuthorTap});

  final ValueChanged<String> onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final authors = _texts.map((t) => t['author']!).toSet().toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Browse by author'),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cols = (width / 200).floor().clamp(1, 5);
              final cardWidth = (width - 10.0 * (cols - 1)) / cols;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: authors.map((author) {
                  final works =
                      _texts.where((t) => t['author'] == author).toList();
                  return SizedBox(
                    width: cardWidth,
                    child: _AuthorCard(
                      author: author,
                      works: works,
                      onTap: () => onAuthorTap(author),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Requests page
// ---------------------------------------------------------------------------

class _Request {
  const _Request({
    required this.text,
    required this.votes,
    required this.date,
  });

  final String text;
  final int votes;
  final String date;

  _Request copyWith({String? text, int? votes, String? date}) => _Request(
        text: text ?? this.text,
        votes: votes ?? this.votes,
        date: date ?? this.date,
      );
}

class _RequestsPage extends StatefulWidget {
  const _RequestsPage();

  @override
  State<_RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<_RequestsPage> {
  final _controller = TextEditingController();
  var _requests = const [
    _Request(
        text: 'Complete essays by Montaigne', votes: 14, date: 'Apr 18'),
    _Request(
        text: 'Hannah Arendt — The Origins of Totalitarianism',
        votes: 9,
        date: 'Apr 15'),
    _Request(
        text: 'Nietzsche — Beyond Good and Evil excerpts',
        votes: 7,
        date: 'Apr 12'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final val = _controller.text.trim();
    if (val.isEmpty) return;
    setState(() {
      _requests = [
        _Request(text: val, votes: 1, date: 'Today'),
        ..._requests,
      ];
      _controller.clear();
    });
  }

  void _vote(int i) {
    setState(() {
      final updated = List<_Request>.from(_requests);
      updated[i] = updated[i].copyWith(votes: updated[i].votes + 1);
      updated.sort((a, b) => b.votes.compareTo(a.votes));
      _requests = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _styledTextField(
                  controller: _controller,
                  hint: 'Request a text, author, or subject…',
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 10),
              _GoldButton(label: 'Submit request', onTap: _submit),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Community requests'),
          const SizedBox(height: 14),
          ...List.generate(
            _requests.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RequestItem(
                request: _requests[i],
                onVote: () => _vote(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared input helper
// ---------------------------------------------------------------------------

TextField _styledTextField({
  required TextEditingController controller,
  required String hint,
  ValueChanged<String>? onSubmitted,
}) {
  return TextField(
    controller: controller,
    onSubmitted: onSubmitted,
    style: const TextStyle(fontSize: 14, color: _cream),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.25),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _gold.withValues(alpha: 0.5), width: 1),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Search input (with leading icon)
// ---------------------------------------------------------------------------

class _SearchInput extends StatelessWidget {
  const _SearchInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: _cream),
      decoration: InputDecoration(
        hintText: 'Search essays, books…',
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(
            Icons.search,
            size: 16,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 36, minHeight: 0),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _gold.withValues(alpha: 0.5), width: 1),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Type filter dropdown
// ---------------------------------------------------------------------------

class _TypeFilter extends StatelessWidget {
  const _TypeFilter({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1A1A18),
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          icon: Icon(
            Icons.expand_more,
            size: 16,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          items: [
            DropdownMenuItem(
              value: '',
              child: Text(
                'All types',
                style:
                    TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            DropdownMenuItem(
              value: 'Essay',
              child: Text(
                'Essay',
                style:
                    TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            DropdownMenuItem(
              value: 'Excerpt',
              child: Text(
                'Excerpt',
                style:
                    TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
          ],
          onChanged: (v) => onChanged(v ?? ''),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subject chips
// ---------------------------------------------------------------------------

class _SubjectChips extends StatelessWidget {
  const _SubjectChips({required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  static const _subjects = [
    'all',
    'Philosophy',
    'Literature',
    'Science',
    'History',
    'Politics',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _subjects.map((s) {
        return _Chip(
          label: s == 'all' ? 'All' : s,
          active: active == s,
          onTap: () => onChanged(s),
        );
      }).toList(),
    );
  }
}

class _Chip extends StatefulWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: widget.active
                ? _gold.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.active
                  ? _gold.withValues(alpha: 0.5)
                  : _hovered
                      ? _gold.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: widget.active
                  ? _gold
                  : _hovered
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.1,
        color: Colors.white.withValues(alpha: 0.25),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Text grid + card
// ---------------------------------------------------------------------------

class _TextGrid extends StatelessWidget {
  const _TextGrid({required this.texts});

  final List<Map<String, String>> texts;

  @override
  Widget build(BuildContext context) {
    if (texts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Center(
          child: Text(
            'No texts found',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = (width / 260).floor().clamp(1, 4);
        final cardWidth = (width - 14.0 * (cols - 1)) / cols;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: texts
              .map((t) => SizedBox(
                    width: cardWidth,
                    child: _TextCard(text: t),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _TextCard extends StatefulWidget {
  const _TextCard({required this.text});

  final Map<String, String> text;

  @override
  State<_TextCard> createState() => _TextCardState();
}

class _TextCardState extends State<_TextCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? _gold.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.text['type']} · ${widget.text['subject']}',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.0,
                color: _gold.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.text['title']!,
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: _cream,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.text['author']!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.text['excerpt']!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Author card
// ---------------------------------------------------------------------------

class _AuthorCard extends StatefulWidget {
  const _AuthorCard({
    required this.author,
    required this.works,
    required this.onTap,
  });

  final String author;
  final List<Map<String, String>> works;
  final VoidCallback onTap;

  @override
  State<_AuthorCard> createState() => _AuthorCardState();
}

class _AuthorCardState extends State<_AuthorCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered
                  ? _gold.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.works.length} text${widget.works.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.0,
                  color: _gold.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.author,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  color: _cream,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.works.map((w) => w['title']!).join(' · '),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gold action button
// ---------------------------------------------------------------------------

class _GoldButton extends StatefulWidget {
  const _GoldButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered
                ? _gold.withValues(alpha: 0.25)
                : _gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: _gold.withValues(alpha: 0.35), width: 0.5),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontSize: 13, color: _gold),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Request list item + vote column
// ---------------------------------------------------------------------------

class _RequestItem extends StatelessWidget {
  const _RequestItem({required this.request, required this.onVote});

  final _Request request;
  final VoidCallback onVote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _VoteColumn(votes: request.votes, onVote: onVote),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              request.text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            request.date,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteColumn extends StatefulWidget {
  const _VoteColumn({required this.votes, required this.onVote});

  final int votes;
  final VoidCallback onVote;

  @override
  State<_VoteColumn> createState() => _VoteColumnState();
}

class _VoteColumnState extends State<_VoteColumn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onVote,
            child: Text(
              '▲',
              style: TextStyle(
                fontSize: 14,
                color:
                    _hovered ? _gold : Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${widget.votes}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
