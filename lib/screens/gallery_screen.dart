import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/l10n.dart';
import '../models/workout.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/share_photo_sheet.dart';
import '../widgets/ui_kit.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryItem {
  final DateTime date;
  final String label;
  final String data; // Base64 string or file path
  final LoggedSession session;
  final bool isBefore;

  _GalleryItem({
    required this.date,
    required this.label,
    required this.data,
    required this.session,
    required this.isBefore,
  });
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();

  List<_GalleryItem> _getPhotos() {
    final list = <_GalleryItem>[];
    for (final s in fit.sessions) {
      if (s.photoBefore != null && s.photoBefore!.isNotEmpty) {
        list.add(_GalleryItem(
          date: s.date,
          label: t.photoBefore,
          data: s.photoBefore!,
          session: s,
          isBefore: true,
        ));
      }
      if (s.photoAfter != null && s.photoAfter!.isNotEmpty) {
        list.add(_GalleryItem(
          date: s.date,
          label: t.photoAfter,
          data: s.photoAfter!,
          session: s,
          isBefore: false,
        ));
      }
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> _addNewPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (picked != null) {
        final bytes = await File(picked.path).readAsBytes();
        final base64Str = base64Encode(bytes);
        setState(() {
          fit.recordSessionPhoto(base64Str, before: false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar foto: $e')),
        );
      }
    }
  }

  void _showAddPhotoOptions() {
    final gc = context.gc;
    showModalBottomSheet(
      context: context,
      backgroundColor: gc.bgRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: gc.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt, color: gc.accent),
              title: Text(t.takePhoto, style: AppTheme.s(14, color: gc.text)),
              onTap: () {
                Navigator.pop(context);
                _addNewPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: gc.accent),
              title: Text(t.chooseGallery, style: AppTheme.s(14, color: gc.text)),
              onTap: () {
                Navigator.pop(context);
                _addNewPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final photos = _getPhotos();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: gc.text),
                    onPressed: fit.goHome,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.photoGallery,
                      style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text, letterSpacing: 2),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_a_photo, color: gc.accent),
                    onPressed: _showAddPhotoOptions,
                  ),
                ],
              ),
            ),

            // Photos Grid
            Expanded(
              child: photos.isEmpty
                  ? _buildEmptyState(gc)
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final item = photos[index];
                        return _buildPhotoTile(gc, item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(GymColors gc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: gc.bgRaised,
                shape: BoxShape.circle,
                border: Border.all(color: gc.border),
              ),
              child: Icon(Icons.photo_library_outlined, size: 36, color: gc.textTertiary),
            ),
            const SizedBox(height: 16),
            Text(
              t.noPhotosYet,
              style: AppTheme.d(16, weight: FontWeight.w700, color: gc.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tire fotos do seu progresso antes ou depois dos seus treinos para visualizar sua evolução.',
              style: AppTheme.s(13, color: gc.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: t.addPhoto.toUpperCase(),
              onTap: _showAddPhotoOptions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTile(GymColors gc, _GalleryItem item) {
    final imageWidget = _buildImageWidget(item.data);

    return GestureDetector(
      onTap: () => _openPhotoDetail(context, gc, item),
      child: Container(
        decoration: BoxDecoration(
          color: gc.bgRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gc.border),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: imageWidget),
            // Gradient Overlay at bottom for readable badge text
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 60,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.shortDate(item.date),
                    style: AppTheme.d(12, weight: FontWeight.w700, color: Colors.white),
                  ),
                  Text(
                    item.label,
                    style: AppTheme.s(10, weight: FontWeight.w500, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String data) {
    if (data.startsWith('/') || data.startsWith('file://')) {
      final file = File(data.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    try {
      final bytes = base64Decode(data);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return Container(
        color: const Color(0xFF1F241C),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white38),
        ),
      );
    }
  }

  void _openPhotoDetail(BuildContext context, GymColors gc, _GalleryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: gc.pageBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.label} · ${t.shortDate(item.date)}',
                    style: AppTheme.d(14, weight: FontWeight.w700, color: gc.text),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: gc.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildImageWidget(item.data),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'COMPARTILHAR FOTO',
                      onTap: () {
                        Navigator.pop(context);
                        final durMins = item.session.durationSec > 0 ? (item.session.durationSec / 60).round() : 30;
                        showSharePhotoSheet(
                          context,
                          durationStr: '$durMins MIN',
                          prCount: 0,
                          volumeKg: item.session.volume,
                          calories: (durMins * 5 + item.session.volume * 0.02).round().clamp(20, 2000),
                          muscleGroupsStr: 'Treino ${t.shortDate(item.date)}',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
