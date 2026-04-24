import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MarginaliaApp());
}

const _bg = Color(0xFF111110);
const _gold = Color(0xFFC9A96E);
const _cream = Color(0xFFF0EAD8);
const _apiBase = 'http://66.42.121.203';

// ---------------------------------------------------------------------------
// API
// ---------------------------------------------------------------------------

class _Api {
  static Future<List<Map<String, dynamic>>> getTexts() async {
    final res = await http.get(Uri.parse('$_apiBase/texts'));
    if (res.statusCode != 200) throw Exception('Failed to load texts');
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  static Future<Map<String, dynamic>> getText(int id) async {
    final res = await http.get(Uri.parse('$_apiBase/texts/$id'));
    if (res.statusCode != 200) throw Exception('Not found');
    return Map<String, dynamic>.from(jsonDecode(res.body));
  }
}

// ---------------------------------------------------------------------------
// Saved store (local)
// ---------------------------------------------------------------------------

class SavedStore extends ChangeNotifier {
  static const _key = 'saved_ids';
  Set<int> _ids = {};

  Set<int> get ids => _ids;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _ids = raw.map(int.parse).toSet();
    notifyListeners();
  }

  bool isSaved(int id) => _ids.contains(id);

  Future<void> toggle(int id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.map((e) => e.toString()).toList());
  }
}

final _saved = SavedStore();

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
        colorScheme: const ColorScheme.dark(surface: _bg, primary: _gold),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const _FeedScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Feed screen
// ---------------------------------------------------------------------------

class _FeedScreen extends StatefulWidget {
  const _FeedScreen();

  @override
  State<_FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<_FeedScreen> {
  List<Map<String, dynamic>> _texts = [];
  List<Map<String, dynamic>> _source = [];
  bool _loading = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _saved.load();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _Api.getTexts();
      data.shuffle();
      if (mounted) setState(() {
        _source = List.from(data);
        _texts = List.from(data);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 600) {
      _appendBatch();
    }
  }

  void _appendBatch() {
    final batch = List<Map<String, dynamic>>.from(_source)..shuffle();
    setState(() => _texts = [..._texts, ...batch]);
  }

  void _openSaved() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _SavedScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            if (_loading)
              const Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 1.5))
            else
              ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(0, 56, 0, 48),
                itemCount: _texts.length,
                separatorBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.06), thickness: 0.5)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('✦', style: TextStyle(fontSize: 9, color: _gold.withValues(alpha: 0.35))),
                      ),
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.06), thickness: 0.5)),
                    ],
                  ),
                ),
                itemBuilder: (context, i) => _ExcerptCard(
                  text: _texts[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => _TextScreen(text: _texts[i])),
                  ),
                ),
              ),
            // Header
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 16, 20, 12),
                decoration: BoxDecoration(
                  color: _bg,
                  border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 0.5)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Marginalia',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: _cream,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _openSaved,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.bookmark_border, color: Colors.white.withValues(alpha: 0.4), size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Excerpt card
// ---------------------------------------------------------------------------

class _ExcerptCard extends StatelessWidget {
  const _ExcerptCard({required this.text, required this.onTap});

  final Map<String, dynamic> text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text['title'] ?? '',
              style: GoogleFonts.playfairDisplay(
                fontSize: 19,
                color: _cream,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text['author'] ?? '',
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
            ),
            const SizedBox(height: 14),
            Text(
              text['excerpt'] ?? '',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.55),
                height: 1.75,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Read more',
              style: TextStyle(
                fontSize: 11,
                color: _gold.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full text screen
// ---------------------------------------------------------------------------

class _TextScreen extends StatefulWidget {
  const _TextScreen({required this.text});

  final Map<String, dynamic> text;

  @override
  State<_TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<_TextScreen> {
  @override
  Widget build(BuildContext context) {
    final id = widget.text['id'] as int;
    return ListenableBuilder(
      listenable: _saved,
      builder: (context, _) {
        final isSaved = _saved.isSaved(id);
        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              children: [
                // Nav bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white.withValues(alpha: 0.4)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _saved.toggle(id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSaved ? _gold.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSaved ? _gold.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.12),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                size: 14,
                                color: isSaved ? _gold : Colors.white.withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSaved ? 'Saved' : 'Save',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSaved ? _gold : Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.text['subject'] ?? '',
                          style: TextStyle(fontSize: 10, letterSpacing: 1.3, color: _gold.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.text['title'] ?? '',
                          style: GoogleFonts.playfairDisplay(fontSize: 26, color: _cream, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.text['author'] ?? '',
                          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.35)),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          widget.text['body'] ?? widget.text['excerpt'] ?? '',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white.withValues(alpha: 0.75),
                            height: 1.85,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Source attribution
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.auto_stories_outlined, size: 14, color: Colors.white.withValues(alpha: 0.2)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _sourceAttribution(widget.text),
                                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3), height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _sourceAttribution(Map<String, dynamic> t) {
    final title = t['title'] ?? '';
    final author = t['author'] ?? '';
    final type = t['type'] ?? 'Excerpt';
    return '$type from "$title" by $author';
  }
}

// ---------------------------------------------------------------------------
// Saved screen
// ---------------------------------------------------------------------------

class _SavedScreen extends StatefulWidget {
  const _SavedScreen();

  @override
  State<_SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<_SavedScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = _saved.ids.toList();
    final results = await Future.wait(ids.map(_Api.getText));
    if (mounted) setState(() { _items = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white.withValues(alpha: 0.4)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Saved',
                    style: GoogleFonts.playfairDisplay(fontSize: 20, color: _cream),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 1.5))
                  : _items.isEmpty
                      ? Center(
                          child: Text(
                            'Nothing saved yet',
                            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.25)),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(28, 8, 28, 48),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => Divider(
                            color: Colors.white.withValues(alpha: 0.06),
                            height: 32,
                            thickness: 0.5,
                          ),
                          itemBuilder: (context, i) => GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => _TextScreen(text: _items[i])),
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _items[i]['title'] ?? '',
                                    style: GoogleFonts.playfairDisplay(fontSize: 16, color: _cream),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _items[i]['author'] ?? '',
                                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _items[i]['excerpt'] ?? '',
                                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.45), height: 1.6),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
