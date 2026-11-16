import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/features/missions/color_sequence/models/sequence_color.dart';

class ColorSequencePad extends StatelessWidget {
  const ColorSequencePad({
    super.key,
    required this.color,
    required this.isFlashing,
    required this.isLocked,
    required this.onTap,
  });

  final SequenceColor color;
  final bool isFlashing;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = isFlashing;

    return Semantics(
      button: true,
      label: '${color.displayName} pad',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: active ? color.activeColor : color.baseColor,
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              border: Border.all(
                color: active ? Colors.white : Colors.black12,
                width: active ? 3.0 : 1.5,
              ),
              boxShadow: active
                  ? <BoxShadow>[
                      BoxShadow(
                        color: color.activeColor.withValues(alpha: 0.6),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 140),
                opacity: active ? 1.0 : 0.75,
                child: Text(
                  color.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 1.0,
                    shadows: <Shadow>[
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
