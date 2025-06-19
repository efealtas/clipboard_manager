import 'package:flutter/material.dart';
import 'clipboard_database.dart';
import 'clipboard_monitor.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final themeString = prefs.getString('theme_mode') ?? 'light';
  switch (themeString) {
    case 'dark':
      themeNotifier.value = ThemeMode.dark;
      break;
    case 'light':
      themeNotifier.value = ThemeMode.light;
      break;
    case 'system':
      themeNotifier.value = ThemeMode.system;
      break;
    default:
      themeNotifier.value = ThemeMode.light;
  }
}

Future<void> saveThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  String themeString = 'light';
  if (mode == ThemeMode.dark) themeString = 'dark';
  if (mode == ThemeMode.system) themeString = 'system';
  await prefs.setString('theme_mode', themeString);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadThemeMode();
  ClipboardMonitor.instance.start();
  runApp(const ClipboardManagerApp());
}

class ClipboardManagerApp extends StatelessWidget {
  const ClipboardManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Clipboard Manager',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          themeMode: mode,
          home: const ClipboardHomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class ClipboardHomePage extends StatefulWidget {
  const ClipboardHomePage({super.key});

  @override
  State<ClipboardHomePage> createState() => _ClipboardHomePageState();
}

class _ClipboardHomePageState extends State<ClipboardHomePage> {
  List<ClipboardEntry> _entries = [];
  String _searchQuery = '';
  Timer? _refreshTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) => _loadEntries());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      _loadEntries();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    List<ClipboardEntry> entries;
    if (_searchQuery.isEmpty) {
      entries = await ClipboardDatabase.instance.getAllEntries();
    } else {
      entries = await ClipboardDatabase.instance.searchEntries(_searchQuery);
    }
    setState(() {
      _entries = entries;
    });
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  Future<void> _deleteEntry(int id) async {
    await ClipboardDatabase.instance.deleteEntry(id);
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard Manager'),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return Row(
                children: [
                  Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                  Switch(
                    value: mode == ThemeMode.dark,
                    onChanged: (val) async {
                      final newMode = val ? ThemeMode.dark : ThemeMode.light;
                      themeNotifier.value = newMode;
                      await saveThemeMode(newMode);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search clipboard history',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text('No clipboard history yet.'))
                  : ListView.separated(
                      itemCount: _entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return ListTile(
                          title: Text(
                            entry.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            entry.timestamp.toLocal().toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy',
                                onPressed: () => _copyToClipboard(entry.content),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Delete',
                                onPressed: () => _deleteEntry(entry.id!),
                              ),
                            ],
                          ),
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
