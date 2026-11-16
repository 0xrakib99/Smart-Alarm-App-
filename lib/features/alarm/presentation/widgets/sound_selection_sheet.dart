import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/constants/app_sounds.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/core/widgets/app_primary_button.dart';
import 'package:smart_alarm/data/models/alarm_sound.dart';

class SoundSelectionResult {
  const SoundSelectionResult({
    required this.soundId,
    this.customSoundPath,
    this.customSoundName,
  });

  final String soundId;
  final String? customSoundPath;
  final String? customSoundName;
}

class SoundSelectionSheet extends StatefulWidget {
  const SoundSelectionSheet({
    super.key,
    required this.initialSoundId,
    this.initialCustomPath,
    this.initialCustomName,
  });

  final String initialSoundId;
  final String? initialCustomPath;
  final String? initialCustomName;

  static Future<SoundSelectionResult?> show(
    BuildContext context, {
    required String currentSoundId,
    String? currentCustomPath,
    String? currentCustomName,
  }) {
    return showModalBottomSheet<SoundSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SoundSelectionSheet(
        initialSoundId: currentSoundId,
        initialCustomPath: currentCustomPath,
        initialCustomName: currentCustomName,
      ),
    );
  }

  @override
  State<SoundSelectionSheet> createState() => _SoundSelectionSheetState();
}

class _SoundSelectionSheetState extends State<SoundSelectionSheet> {
  late String _selectedSoundId;
  String? _customSoundPath;
  String? _customSoundName;

  // Audio Preview State
  String? _previewingId; // Either soundId or 'custom'
  bool _isPlayingPreview = false;
  bool _isPicking = false;
  String? _errorMessage;

  AlarmNativeService? get _nativeService {
    if (Get.isRegistered<AlarmNativeService>()) {
      return Get.find<AlarmNativeService>();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedSoundId = widget.initialSoundId;
    _customSoundPath = widget.initialCustomPath;
    _customSoundName = widget.initialCustomName;

    _nativeService?.onAudioPreviewStopped = () {
      if (mounted) {
        setState(() {
          _isPlayingPreview = false;
          _previewingId = null;
        });
      }
    };
  }

  @override
  void dispose() {
    _stopPreview();
    super.dispose();
  }

  Future<void> _stopPreview() async {
    await _nativeService?.stopAudioPreview();
    if (mounted) {
      setState(() {
        _isPlayingPreview = false;
        _previewingId = null;
      });
    }
  }

  Future<void> _togglePreview({required String id, String? customPath}) async {
    final service = _nativeService;
    if (service == null) return;

    // If currently playing this specific sound, pause/stop it
    if (_previewingId == id && _isPlayingPreview) {
      await _stopPreview();
      return;
    }

    // Stop existing preview before playing another sound
    await _stopPreview();

    setState(() {
      _errorMessage = null;
    });

    final success = await service.playAudioPreview(
      path: id == 'custom' ? customPath : null,
      soundId: id != 'custom' ? id : null,
    );

    if (mounted) {
      if (success) {
        setState(() {
          _previewingId = id;
          _isPlayingPreview = true;
        });
      } else {
        setState(() {
          _isPlayingPreview = false;
          _previewingId = null;
          _errorMessage =
              'Could not play audio preview. The file format may be unsupported.';
        });
      }
    }
  }

  Future<void> _pickCustomAudio() async {
    final service = _nativeService;
    if (service == null) return;

    await _stopPreview();

    setState(() {
      _isPicking = true;
      _errorMessage = null;
    });

    try {
      final result = await service.pickCustomSound();
      if (!mounted) return;

      if (result != null && result.path.isNotEmpty) {
        setState(() {
          _selectedSoundId = 'custom';
          _customSoundPath = result.path;
          _customSoundName = result.name;
        });

        // Auto-audition the newly picked custom sound
        await _togglePreview(id: 'custom', customPath: result.path);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to select audio: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  void _selectBuiltIn(AlarmSound sound) {
    setState(() {
      _selectedSoundId = sound.id;
    });
  }

  void _applySelection() {
    _stopPreview();
    Navigator.of(context).pop(
      SoundSelectionResult(
        soundId: _selectedSoundId,
        customSoundPath: _selectedSoundId == 'custom' ? _customSoundPath : null,
        customSoundName: _selectedSoundId == 'custom' ? _customSoundName : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.cardRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Sheet Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Sheet Title & Close
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.horizontalPadding,
                vertical: 6,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Alarm sound',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Close',
                    onPressed: () {
                      _stopPreview();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding,
                  vertical: 8,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Scrollable List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding,
                  vertical: 12,
                ),
                children: <Widget>[
                  // Custom Audio Section
                  Text(
                    'DEVICE AUDIO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_customSoundPath != null &&
                      _customSoundName != null) ...<Widget>[
                    _buildCustomSoundTile(theme, colorScheme),
                    const SizedBox(height: 10),
                  ],

                  OutlinedButton.icon(
                    onPressed: _isPicking ? null : _pickCustomAudio,
                    icon: _isPicking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.folder_open_rounded, size: 20),
                    label: Text(
                      _customSoundPath != null
                          ? 'Choose another audio file'
                          : 'Select custom audio from device',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.buttonRadius,
                        ),
                      ),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Built-in Sounds Section
                  Text(
                    'BUILT-IN ALARM SOUNDS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: <Widget>[
                        for (
                          int i = 0;
                          i < AppSounds.builtIn.length;
                          i++
                        ) ...<Widget>[
                          if (i > 0) const Divider(height: 1),
                          _buildBuiltInSoundRow(
                            theme,
                            colorScheme,
                            AppSounds.builtIn[i],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Apply Bar
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.horizontalPadding,
                10,
                AppConstants.horizontalPadding,
                12,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: AppPrimaryButton(
                label: 'Save selection',
                icon: Icons.check_rounded,
                onPressed: _applySelection,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSoundTile(ThemeData theme, ColorScheme colorScheme) {
    final isSelected = _selectedSoundId == 'custom';
    final isPlaying = _previewingId == 'custom' && _isPlayingPreview;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderColor: isSelected ? colorScheme.primary : null,
      backgroundColor: isSelected
          ? colorScheme.primary.withValues(alpha: 0.05)
          : null,
      onTap: () {
        setState(() {
          _selectedSoundId = 'custom';
        });
      },
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.music_note_rounded,
              size: 20,
              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _customSoundName ?? 'Custom Audio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Saved in app private storage',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Preview Button
          IconButton(
            tooltip: isPlaying ? 'Stop preview' : 'Play preview',
            icon: Icon(
              isPlaying
                  ? Icons.stop_circle_rounded
                  : Icons.play_circle_fill_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
            onPressed: () =>
                _togglePreview(id: 'custom', customPath: _customSoundPath),
          ),

          // Selection Indicator
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 4),
            child: Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 22,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuiltInSoundRow(
    ThemeData theme,
    ColorScheme colorScheme,
    AlarmSound sound,
  ) {
    final isSelected = _selectedSoundId == sound.id;
    final isPlaying = _previewingId == sound.id && _isPlayingPreview;

    return InkWell(
      onTap: () => _selectBuiltIn(sound),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 22,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    sound.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  if (sound.id == 'default')
                    Text(
                      'Default system sound',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: isPlaying ? 'Stop preview' : 'Play preview',
              icon: Icon(
                isPlaying
                    ? Icons.stop_circle_rounded
                    : Icons.play_circle_outline_rounded,
                color: isPlaying
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              onPressed: () => _togglePreview(id: sound.id),
            ),
          ],
        ),
      ),
    );
  }
}
