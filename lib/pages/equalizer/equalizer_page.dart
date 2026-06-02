import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';

/// Custom equalizer page with visual sliders
class EqualizerPage extends ConsumerStatefulWidget {
  const EqualizerPage({super.key});

  @override
  ConsumerState<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends ConsumerState<EqualizerPage> {
  // Equalizer bands (Hz): 60, 230, 910, 3600, 14000
  final List<String> _bandLabels = ['60', '230', '910', '3.6k', '14k'];
  List<double> _bandValues = [0, 0, 0, 0, 0];
  String _selectedPreset = 'flat';

  // Presets
  final Map<String, List<double>> _presets = {
    'flat': [0, 0, 0, 0, 0],
    'bass_boost': [6, 4, 0, 0, 0],
    'rock': [4, 2, -1, 3, 4],
    'pop': [-1, 2, 4, 2, -1],
    'jazz': [3, 0, 1, 3, 4],
    'classical': [4, 2, 0, 2, 4],
  };

  void _applyPreset(String key) {
    setState(() {
      _selectedPreset = key;
      _bandValues = List.from(_presets[key]!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('equalizer'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Presets
            Text(
              'Presets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.keys.map((key) {
                final isSelected = _selectedPreset == key;
                final label = 'eq_$key'.tr();
                return GestureDetector(
                  onTap: () => _applyPreset(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? themeState.accentColor.withValues(alpha: 0.2)
                          : (isDark ? AppColors.darkCard : AppColors.lightCard),
                      border: Border.all(
                        color: isSelected ? themeState.accentColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? themeState.accentColor : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // EQ Sliders
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  return _EQBand(
                    label: _bandLabels[i],
                    value: _bandValues[i],
                    accentColor: themeState.accentColor,
                    onChanged: (val) {
                      setState(() {
                        _bandValues[i] = val;
                        _selectedPreset = 'custom';
                      });
                    },
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: 100 * i),
                        duration: 400.ms,
                      );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // dB scale reference
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('+12 dB', style: Theme.of(context).textTheme.labelSmall),
                Text('0 dB', style: Theme.of(context).textTheme.labelSmall),
                Text('-12 dB', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual EQ band slider
class _EQBand extends StatelessWidget {
  final String label;
  final double value; // -12 to +12
  final Color accentColor;
  final ValueChanged<double> onChanged;

  const _EQBand({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Value label
        Text(
          value > 0 ? '+${value.toStringAsFixed(0)}' : value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: value != 0 ? accentColor : null,
          ),
        ),
        const SizedBox(height: 8),

        // Vertical slider
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: accentColor,
                inactiveTrackColor: isDark
                    ? AppColors.darkCardBorder
                    : AppColors.lightCardBorder,
                thumbColor: accentColor,
                overlayColor: accentColor.withValues(alpha: 0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: value,
                min: -12,
                max: 12,
                divisions: 24,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Frequency label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}
