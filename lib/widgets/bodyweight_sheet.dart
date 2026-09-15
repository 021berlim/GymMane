import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/l10n.dart';
import '../models/weight_entry.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

Future<void> showBodyweightSheet(BuildContext context, {bool? beforeWorkout}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BodyweightSheet(beforeWorkout: beforeWorkout),
  );
}

class BodyweightSheet extends StatefulWidget {
  const BodyweightSheet({super.key, this.beforeWorkout});

  final bool? beforeWorkout;

  @override
  State<BodyweightSheet> createState() => _BodyweightSheetState();
}

class _BodyweightSheetState extends State<BodyweightSheet> {
  late double _shown =
      ((fit.toDisplayWeight(fit.latestBodyweight?.kg ?? fit.profile.weightKg)) * 10).round() / 10;
  String? _base64Photo;
  bool _loadingPhoto = false;

  void _bump(double d) => setState(() => _shown = ((_shown + d) * 10).round() / 10);

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 640,
      maxHeight: 640,
      imageQuality: 60,
    );
    if (image == null) return;

    setState(() => _loadingPhoto = true);
    final bytes = await File(image.path).readAsBytes();
    setState(() {
      _base64Photo = base64Encode(bytes);
      _loadingPhoto = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final showPhotoBtn = fit.enablePhotos &&
        widget.beforeWorkout != null &&
        (fit.photoTiming == 'both' ||
            (widget.beforeWorkout == true && fit.photoTiming == 'before') ||
            (widget.beforeWorkout == false && fit.photoTiming == 'after'));

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 18),
          Text(t.logBodyweight,
              style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(
            widget.beforeWorkout == true
                ? t.bodyweightBeforeWorkout
                : widget.beforeWorkout == false
                    ? t.bodyweightAfterWorkout
                    : t.trackWeight,
            style: AppTheme.s(13, color: gc.textSecondary),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _round(gc, '–', () => _bump(-0.1)),
              const SizedBox(width: 22),
              SizedBox(
                width: 130,
                child: Text('${fmt(_shown)} ${fit.units}',
                    textAlign: TextAlign.center,
                    style: AppTheme.d(40, weight: FontWeight.w700, color: gc.text)),
              ),
              const SizedBox(width: 22),
              _round(gc, '+', () => _bump(0.1)),
            ],
          ),
          const SizedBox(height: 22),
          if (showPhotoBtn) ...[
            if (_base64Photo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.memory(
                      base64Decode(_base64Photo!),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _base64Photo = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_loadingPhoto)
              const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
            else
              GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: gc.bgRaised2,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: gc.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsRegular.camera, size: 18, color: gc.textSecondary),
                      const SizedBox(width: 8),
                      Text(t.takePhoto, style: AppTheme.s(12, weight: FontWeight.w600, color: gc.textSecondary)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 22),
          ],
          PrimaryButton(
            label: t.save,
            onTap: () {
              final kg = fit.fromDisplayWeight(_shown);
              final ctx = widget.beforeWorkout == true
                  ? WeightContext.preWorkout
                  : widget.beforeWorkout == false
                      ? WeightContext.postWorkout
                      : WeightContext.manual;
              fit.addBodyweight(kg, context: ctx);
              if (widget.beforeWorkout != null) {
                fit.recordSessionBodyweight(kg, before: widget.beforeWorkout!);
                if (_base64Photo != null) {
                  fit.recordSessionPhoto(_base64Photo!, before: widget.beforeWorkout!);
                }
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _round(GymColors gc, String glyph, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: gc.bgRaised2, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(glyph, style: TextStyle(color: gc.text, fontSize: 26, height: 1)),
      ),
    );
  }
}
