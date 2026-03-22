import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';
import '../models/mtg_color.dart';
import '../models/theme_notifier.dart';
import 'game_screen.dart';

/// Initial screen where the user selects player count and starting life total
/// before starting a new game.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with SingleTickerProviderStateMixin {
  static const _prefKeyPlayerCount = 'playerCount';
  static const _prefKeyStartingLife = 'startingLife';

  int _playerCount = 2;
  int _startingLife = 20;
  final _lifeController = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _lifeController.text = _startingLife.toString();
    _loadPrefs();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _lifeController.dispose();
    _animController.dispose();
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
          colors: List.generate(_playerCount, (_) => []),
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
            FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      // Header with orb and title
                      _buildHeader(theme, colorScheme),
                      const SizedBox(height: 40),

                      // Player count section
                      _buildSectionCard(
                        theme: theme,
                        colorScheme: colorScheme,
                        icon: Icons.people_outline,
                        title: 'Players',
                        child: _buildPlayerSelector(colorScheme),
                      ),
                      const SizedBox(height: 16),

                      // Starting life section
                      _buildSectionCard(
                        theme: theme,
                        colorScheme: colorScheme,
                        icon: Icons.favorite_outline,
                        title: 'Starting Life',
                        child: _buildLifeSelector(colorScheme),
                      ),
                      const SizedBox(height: 32),

                      // Start button
                      _buildStartButton(colorScheme),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            // Theme toggle
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Logo orb
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF9B72D8), Color(0xFF533483)],
              stops: [0.2, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF533483).withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '♦',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                shadows: [Shadow(color: Colors.white38, blurRadius: 8)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Mana icons row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: MtgColor.values.map((color) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.circleColor,
                  boxShadow: [
                    BoxShadow(
                      color: color.circleColor.withOpacity(0.35),
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: SvgPicture.asset(
                    color.assetPath,
                    colorFilter: ColorFilter.mode(
                      color.iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          'MTG Life Tracker',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Set up your game',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerLow,
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPlayerSelector(ColorScheme colorScheme) {
    return Column(
      children: [
        // Grid of player count options
        GridView.count(
          crossAxisCount: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(6, (i) {
            final count = i + 1;
            final isSelected = _playerCount == count;
            return GestureDetector(
              onTap: () => setState(() => _playerCount = count),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withOpacity(0.4),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        // Player count label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(width: 4),
            Text(
              '$_playerCount player${_playerCount != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLifeSelector(ColorScheme colorScheme) {
    return Column(
      children: [
        // Preset buttons
        Row(
          children: [20, 30, 40].map((preset) {
            final isSelected = _startingLife == preset &&
                _lifeController.text == preset.toString();
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _setLifePreset(preset),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant.withOpacity(0.4),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.error.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$preset',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Custom input
        TextField(
          controller: _lifeController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _MaxValueFormatter(999),
          ],
          decoration: InputDecoration(
            labelText: 'Custom',
            prefixIcon: Icon(
              Icons.edit_outlined,
              color: colorScheme.primary.withOpacity(0.6),
              size: 20,
            ),
          ),
          onChanged: _onLifeChanged,
        ),
      ],
    );
  }

  Widget _buildStartButton(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withBlue(
              (colorScheme.primary.blue + 30).clamp(0, 255),
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _startGame,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'START GAME',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
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
