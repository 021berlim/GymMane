import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

/// Opens the interactive watermark photo editor and sharing modal.
void showSharePhotoSheet(
  BuildContext context, {
  required String durationStr,
  required int prCount,
  required double volumeKg,
  required int calories,
  required String muscleGroupsStr,
  String? initialImagePath,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SharePhotoSheet(
      durationStr: durationStr,
      prCount: prCount,
      volumeKg: volumeKg,
      calories: calories,
      muscleGroupsStr: muscleGroupsStr,
      initialImagePath: initialImagePath,
    ),
  );
}

class SharePhotoSheet extends StatefulWidget {
  final String durationStr;
  final int prCount;
  final double volumeKg;
  final int calories;
  final String muscleGroupsStr;
  final String? initialImagePath;

  const SharePhotoSheet({
    super.key,
    required this.durationStr,
    required this.prCount,
    required this.volumeKg,
    required this.calories,
    required this.muscleGroupsStr,
    this.initialImagePath,
  });

  @override
  State<SharePhotoSheet> createState() => _SharePhotoSheetState();
}

enum _PresetPosition {
  topLeft('Top-Left', Alignment.topLeft),
  topRight('Top-Right', Alignment.topRight),
  center('Center', Alignment.center),
  bottomLeft('Bottom-Left', Alignment.bottomLeft),
  bottomRight('Bottom-Right', Alignment.bottomRight);

  final String label;
  final Alignment alignment;
  const _PresetPosition(this.label, this.alignment);
}

class _SharePhotoSheetState extends State<SharePhotoSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  File? _photoFile;
  final ImagePicker _picker = ImagePicker();

  Alignment _alignment = Alignment.bottomLeft;
  Offset? _customOffset;
  bool _useCustomOffset = false;

  int _styleIndex = 0; // 0: Full Stats Card, 1: Compact Card, 2: Minimal
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      _photoFile = File(widget.initialImagePath!);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (picked != null) {
        setState(() {
          _photoFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting photo: $e')),
        );
      }
    }
  }

  Future<void> _shareImage() async {
    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione ou tire uma foto primeiro.')),
      );
      return;
    }

    setState(() => _isSharing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Boundary rendering failed');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('PNG byte encoding failed');

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/fitiron_workout_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes, flush: true);

      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'FIT//IRON Workout',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao compartilhar foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.92,
      decoration: BoxDecoration(
        color: gc.pageBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle & title header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: gc.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COMPARTILHAR FOTO',
                      style: AppTheme.d(16, weight: FontWeight.w700, color: gc.text, letterSpacing: 2),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: gc.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Photo preview + draggable watermark container
                  _buildPreviewCanvas(gc),

                  const SizedBox(height: 16),

                  // Action buttons to choose photo
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickPhoto(ImageSource.gallery),
                          icon: Icon(Icons.photo_library, size: 18, color: gc.accent),
                          label: Text('Galeria', style: AppTheme.s(13, weight: FontWeight.w600, color: gc.text)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: gc.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickPhoto(ImageSource.camera),
                          icon: Icon(Icons.camera_alt, size: 18, color: gc.accent),
                          label: Text('Câmera', style: AppTheme.s(13, weight: FontWeight.w600, color: gc.text)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: gc.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Preset corner positions bar
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'POSICIONAMENTO (Arraste ou selecione)',
                      style: AppTheme.d(10, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _PresetPosition.values.map((pos) {
                        final isSelected = !_useCustomOffset && _alignment == pos.alignment;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(pos.label),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _useCustomOffset = false;
                                _alignment = pos.alignment;
                              });
                            },
                            selectedColor: gc.accentSoft,
                            labelStyle: AppTheme.s(
                              12,
                              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? gc.accent : gc.textSecondary,
                            ),
                            backgroundColor: gc.bgRaised,
                            side: BorderSide(color: isSelected ? gc.accent : gc.border),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Watermark style selector
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ESTILO DA MARCA D\'ÁGUA',
                      style: AppTheme.d(10, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _styleChip(gc, 0, 'Completo'),
                      const SizedBox(width: 8),
                      _styleChip(gc, 1, 'Compacto'),
                      const SizedBox(width: 8),
                      _styleChip(gc, 2, 'Mínimo'),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Share button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: PrimaryButton(
              label: _isSharing ? 'Preparando Imagem...' : 'COMPARTILHAR FOTO',
              onTap: _isSharing ? () {} : _shareImage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _styleChip(GymColors gc, int index, String label) {
    final isSelected = _styleIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _styleIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? gc.accentSoft : gc.bgRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? gc.accent : gc.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.s(
              12,
              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? gc.accent : gc.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCanvas(GymColors gc) {
    return AspectRatio(
      aspectRatio: 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141712),
            border: Border.all(color: gc.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: RepaintBoundary(
            key: _boundaryKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasW = constraints.maxWidth;
                final canvasH = constraints.maxHeight;

                return Stack(
                  children: [
                    // Photo background or placeholder
                    Positioned.fill(
                      child: _photoFile != null
                          ? Image.file(
                              _photoFile!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: const Color(0xFF1A1F18),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 48, color: gc.textTertiary),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Selecione ou tire uma foto',
                                    style: AppTheme.s(14, color: gc.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    // Draggable Watermark Card
                    if (_useCustomOffset && _customOffset != null)
                      Positioned(
                        left: _customOffset!.dx,
                        top: _customOffset!.dy,
                        child: _buildDraggableWatermark(gc, canvasW, canvasH),
                      )
                    else
                      Align(
                        alignment: _alignment,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildDraggableWatermark(gc, canvasW, canvasH),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableWatermark(GymColors gc, double canvasW, double canvasH) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          final current = _customOffset ?? _getOffsetFromAlignment(canvasW, canvasH);
          final newDx = (current.dx + details.delta.dx).clamp(8.0, (canvasW - 240.0).clamp(8.0, canvasW));
          final newDy = (current.dy + details.delta.dy).clamp(8.0, (canvasH - 120.0).clamp(8.0, canvasH));

          _useCustomOffset = true;
          _customOffset = Offset(newDx, newDy);
        });
      },
      child: _buildWatermarkCard(gc),
    );
  }

  Offset _getOffsetFromAlignment(double canvasW, double canvasH) {
    const cardW = 240.0;
    const cardH = 180.0;
    final align = _alignment;
    double x = 16;
    double y = 16;

    if (align == Alignment.topRight || align == Alignment.bottomRight) {
      x = canvasW - cardW - 16;
    } else if (align == Alignment.center) {
      x = (canvasW - cardW) / 2;
    }

    if (align == Alignment.bottomLeft || align == Alignment.bottomRight) {
      y = canvasH - cardH - 16;
    } else if (align == Alignment.center) {
      y = (canvasH - cardH) / 2;
    }

    return Offset(x.clamp(0, canvasW), y.clamp(0, canvasH));
  }

  Widget _buildWatermarkCard(GymColors gc) {
    if (_styleIndex == 2) {
      // Minimal Emblem Badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xDD090B08),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0x44A3E635)),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: const DecorationImage(
                  image: AssetImage('assets/icon/ic_1024.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'FIT//IRON',
              style: AppTheme.d(13, weight: FontWeight.w700, color: Colors.white, letterSpacing: 2),
            ),
          ],
        ),
      );
    }

    if (_styleIndex == 1) {
      // Compact Card
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xEE090B08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x44A3E635)),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: const DecorationImage(
                      image: AssetImage('assets/icon/ic_1024.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'FIT//IRON',
                  style: AppTheme.d(14, weight: FontWeight.w700, color: const Color(0xFFA3E635), letterSpacing: 2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.durationStr} · ${fit.volumeLabel(widget.volumeKg)}',
              style: AppTheme.d(14, weight: FontWeight.w700, color: Colors.white),
            ),
            if (widget.muscleGroupsStr.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.muscleGroupsStr,
                style: AppTheme.s(11, weight: FontWeight.w600, color: const Color(0xB3FFFFFF)),
              ),
            ],
          ],
        ),
      );
    }

    // Style 0: Full Stats Card matching reference layout
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xEE090B08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x44A3E635), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0xCC000000), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIT//IRON Header Logo
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  image: const DecorationImage(
                    image: AssetImage('assets/icon/ic_1024.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FIT//IRON',
                style: AppTheme.d(16, weight: FontWeight.w700, color: const Color(0xFFA3E635), letterSpacing: 2.5),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Grid 2x2: Tempo & Recordes
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Tempo',
                  widget.durationStr,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Recordes',
                  '${widget.prCount} 🏆',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Grid 2x2: Calorias & Peso total
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Calorias',
                  '${widget.calories} KCAL',
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Peso total',
                  fit.volumeLabel(widget.volumeKg),
                ),
              ),
            ],
          ),

          if (widget.muscleGroupsStr.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x22FFFFFF))),
              ),
              child: Text(
                widget.muscleGroupsStr,
                style: AppTheme.s(12, weight: FontWeight.w600, color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.s(11, weight: FontWeight.w500, color: const Color(0x99FFFFFF)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.d(16, weight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }
}
