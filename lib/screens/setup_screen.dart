import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';
import '../models/mtg_color.dart';
import '../models/theme_notifier.dart';
import '../widgets/mana_color_picker.dart';
import 'game_screen.dart';

/// Initial screen where the user selects player count and starting life total
/// before starting a new game.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  static const _prefKeyPlayerCount = 'playerCount';
  static const _prefKeyStartingLife = 'startingLife';

  int _playerCount = 2;
  int _startingLife = 20;
  final _lifeController = TextEditingController();
  // One color set per player (index 0..5), empty = no colors chosen.
  final List<Set<MtgColor>> _playerColors = List.generate(6, (_) => {});

  @override
  void initState() {
    super.initState();
    _lifeController.text = _startingLife.toString();
    _loadPrefs();
  }

  @override
  void dispose() {
    _lifeController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _playerCount = prefs.getInt(_prefKeyPlayerCount) ?? 2;
      _startingLife = prefs.getInt(_prefKeyStartingLife) ?? 20;
      _lifeController.text = _startingLife.toString();
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyPlayerCount, _playerCount);
    await prefs.setInt(_prefKeyStartingLife, _startingLife);
  }

  void _onLifeChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 1) {
      setState(() => _startingLife = parsed);
    }
  }

  void _setLifePreset(int value) {
    setState(() {
      _startingLife = value;
      _lifeController.text = value.toString();
    });
  }

  void _startGame() {
    final parsed = int.tryParse(_lifeController.text);
    final life = (parsed != null && parsed >= 1) ? parsed : 20;
    _startingLife = life;
    _savePrefs();

    context.read<GameState>().startGame(
          playerCount: _playerCount,
          startingLife: _startingLife,
          colors: _playerColors.take(_playerCount).map((s) => s.toList()).toList(),
        );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeNotifier>().isDark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'MTG Life Tracker',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'New Game Setup',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Player count
                  Text('Number of Players', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Center(
                    child: SegmentedButton<int>(
                      segments: List.generate(
                        6,
                        (i) => ButtonSegment<int>(
                          value: i + 1,
                          label: Text('${i + 1}'),
                        ),
                      ),
                      selected: {_playerCount},
                      onSelectionChanged: (s) =>
                          setState(() => _playerCount = s.first),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Per-player color pickers
                  Text('Player Colors', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...List.generate(_playerCount, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 72,
                            child: Text(
                              'P${i + 1}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.54),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ManaColorPicker(
                              selected: _playerColors[i],
                              onChanged: (colors) =>
                                  setState(() => _playerColors[i] = colors),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Starting life total
                  Text('Starting Life Total', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [20, 30, 40].map((preset) {
                      final isSelected = _startingLife == preset &&
                          _lifeController.text == preset.toString();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$preset'),
                          selected: isSelected,
                          onSelected: (_) => _setLifePreset(preset),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lifeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _MaxValueFormatter(999),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Custom life total',
                      prefixIcon: Icon(
                        Icons.favorite,
                        color: colorScheme.error,
                      ),
                    ),
                    onChanged: _onLifeChanged,
                  ),
                  const SizedBox(height: 56),

                  FilledButton(
                    onPressed: _startGame,
                    child: const Text('START GAME'),
                  ),
                ],
              ),
            ),
            // Theme toggle in top-right corner
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                onPressed: context.read<ThemeNotifier>().toggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Limits text field input to a maximum integer value.
class _MaxValueFormatter extends TextInputFormatter {
  final int maxValue;
  _MaxValueFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final parsed = int.tryParse(newValue.text);
    if (parsed == null || parsed > maxValue) return oldValue;
    return newValue;
  }
}
