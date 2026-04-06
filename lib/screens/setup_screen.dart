import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';
import '../models/mtg_color.dart';
import '../models/theme_notifier.dart';
import 'game_screen.dart';

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
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _buildHeader(theme, colorScheme, isDark),
                      const SizedBox(height: 40),
                      _buildSectionCard(
                        colorScheme: colorScheme,
                        isDark: isDark,
                        icon: Icons.people_outline,
                        title: 'PLAYERS',
                        child: _buildPlayerSelector(colorScheme, isDark),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        colorScheme: colorScheme,
                        isDark: isDark,
                        icon: Icons.favorite_outline,
                        title: 'STARTING LIFE',
                        child: _buildLifeSelector(colorScheme, isDark),
                      ),
                      const SizedBox(height: 36),
                      _buildStartButton(colorScheme, isDark),
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
                  color: colorScheme.onSurface.withOpacity(0.5),
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

  Widget _buildHeader(ThemeData theme, ColorScheme cs, bool isDark) {
    return Column(
      children: [
        // Logo orb
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFA78BFA), Color(0xFF5B21B6), Color(0xFF2D1060)],
              stops: [0.0, 0.55, 1.0],
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.55),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.2),
                      blurRadius: 60,
                      spreadRadius: 8,
                    ),
                  ]
                : [
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
                fontSize: 36,
                color: Colors.white,
                shadows: [Shadow(color: Colors.white70, blurRadius: 8)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Mana icons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: MtgColor.values.map((color) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.circleColor,
                  boxShadow: [
                    BoxShadow(
                      color: color.circleColor.withOpacity(isDark ? 0.6 : 0.3),
                      blurRadius: isDark ? 8 : 4,
                      spreadRadius: isDark ? 1 : 0.5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.5),
                  child: SvgPicture.asset(
                    color.assetPath,
                    colorFilter: ColorFilter.mode(color.iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        Text(
          'MTG LIFE TRACKER',
          style: GoogleFonts.russoOne(
            fontSize: 22,
            letterSpacing: 3,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Set up your game',
          style: GoogleFonts.chakraPetch(
            fontSize: 13,
            letterSpacing: 1.5,
            color: cs.onSurface.withOpacity(0.4),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required ColorScheme colorScheme,
    required bool isDark,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF0E0E1C) : colorScheme.surfaceContainerLow,
        border: Border.all(
          color: isDark
              ? colorScheme.primary.withOpacity(0.2)
              : colorScheme.outlineVariant.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.06),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.chakraPetch(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: colorScheme.primary,
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

  Widget _buildPlayerSelector(ColorScheme cs, bool isDark) {
    return Column(
      children: [
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
                      ? cs.primary.withOpacity(isDark ? 0.2 : 1.0)
                      : (isDark
                          ? const Color(0xFF111122)
                          : cs.surfaceContainerHighest),
                  border: Border.all(
                    color: isSelected
                        ? cs.primary
                        : (isDark
                            ? const Color(0xFF252540)
                            : cs.outlineVariant.withOpacity(0.4)),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected && isDark
                      ? [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: GoogleFonts.russoOne(
                      fontSize: 20,
                      color: isSelected
                          ? (isDark ? cs.primary : cs.onPrimary)
                          : cs.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 14,
              color: cs.onSurface.withOpacity(0.3),
            ),
            const SizedBox(width: 4),
            Text(
              '$_playerCount player${_playerCount != 1 ? 's' : ''}',
              style: GoogleFonts.chakraPetch(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLifeSelector(ColorScheme cs, bool isDark) {
    return Column(
      children: [
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
                          ? cs.primary.withOpacity(isDark ? 0.2 : 1.0)
                          : (isDark
                              ? const Color(0xFF111122)
                              : cs.surfaceContainerHighest),
                      border: Border.all(
                        color: isSelected
                            ? cs.primary
                            : (isDark
                                ? const Color(0xFF252540)
                                : cs.outlineVariant.withOpacity(0.4)),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected && isDark
                          ? [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.4),
                                blurRadius: 12,
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
                            size: 14,
                            color: isSelected
                                ? (isDark ? cs.primary : cs.onPrimary)
                                : cs.error.withOpacity(0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$preset',
                            style: GoogleFonts.russoOne(
                              fontSize: 17,
                              color: isSelected
                                  ? (isDark ? cs.primary : cs.onPrimary)
                                  : cs.onSurface.withOpacity(0.55),
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
        TextField(
          controller: _lifeController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _MaxValueFormatter(999),
          ],
          style: GoogleFonts.chakraPetch(
            fontSize: 16,
            color: cs.onSurface,
          ),
          decoration: InputDecoration(
            labelText: 'Custom',
            prefixIcon: Icon(
              Icons.edit_outlined,
              color: cs.primary.withOpacity(0.6),
              size: 20,
            ),
          ),
          onChanged: _onLifeChanged,
        ),
      ],
    );
  }

  Widget _buildStartButton(ColorScheme cs, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF7C3AED), Color(0xFF8B5CF6)],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.55),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                  blurRadius: 48,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                BoxShadow(
                  color: cs.primary.withOpacity(0.35),
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
          splashColor: Colors.white.withOpacity(0.15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  'START GAME',
                  style: GoogleFonts.russoOne(
                    fontSize: 18,
                    letterSpacing: 3,
                    color: Colors.white,
                    shadows: isDark
                        ? [
                            const Shadow(
                              color: Colors.white38,
                              blurRadius: 12,
                            ),
                          ]
                        : null,
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
