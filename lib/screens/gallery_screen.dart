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
    if (fit.sessions.isEmpty) {
      _showNoSessionsWarning();
      return;
    }

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
        if (mounted) {
          _showLinkToSessionSheet(context, base64Str);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar foto: $e')),
        );
      }
    }
  }

  void _showNoSessionsWarning() {
    final gc = context.gc;
    showModalBottomSheet(
      context: context,
      backgroundColor: gc.bgRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 44, color: gc.accent),
            const SizedBox(height: 12),
            Text(
              'Nenhum Treino Encontrado',
              style: AppTheme.d(16, weight: FontWeight.w700, color: gc.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Para salvar fotos de progresso na galeria, é necessário ter pelo menos 1 treino concluído no seu histórico.',
              style: AppTheme.s(13, color: gc.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'ENTENDI',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkToSessionSheet(BuildContext context, String base64Str) {
    final gc = context.gc;
    final sessions = fit.sessions.reversed.toList(); // Newest first
    LoggedSession selectedSession = sessions.first;
    bool isBefore = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: gc.pageBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: gc.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'VINCULAR FOTO AO TREINO',
                  style: AppTheme.d(16, weight: FontWeight.w700, color: gc.text, letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecione a qual treino do seu histórico esta foto pertence:',
                  style: AppTheme.s(12, color: gc.textSecondary),
                ),
                const SizedBox(height: 16),

                // Timing selector (Antes / Depois)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => isBefore = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isBefore ? gc.accentSoft : gc.bgRaised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isBefore ? gc.accent : gc.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t.photoBefore,
                            style: AppTheme.s(12, weight: isBefore ? FontWeight.w700 : FontWeight.w500, color: isBefore ? gc.accent : gc.textSecondary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => isBefore = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isBefore ? gc.accentSoft : gc.bgRaised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: !isBefore ? gc.accent : gc.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t.photoAfter,
                            style: AppTheme.s(12, weight: !isBefore ? FontWeight.w700 : FontWeight.w500, color: !isBefore ? gc.accent : gc.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Text(
                  'TREINOS REGISTRADOS:',
                  style: AppTheme.d(11, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),

                // List of finished sessions
                Expanded(
                  child: ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (ctx, i) {
                      final s = sessions[i];
                      final isSelected = selectedSession == s;
                      final exercisesSummary = s.exercises.map((e) => e.name).join(', ');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => setSheetState(() => selectedSession = s),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? gc.accentSoft : gc.bgRaised,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? gc.accent : gc.border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isSelected ? gc.accent : gc.textTertiary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.longDate(s.date),
                                        style: AppTheme.d(14, weight: FontWeight.w700, color: gc.text),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${s.exercises.length} exercícios · ${fit.volumeLabel(s.volume)}',
                                        style: AppTheme.s(11, color: gc.textSecondary),
                                      ),
                                      if (exercisesSummary.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          exercisesSummary,
                                          style: AppTheme.s(10, color: gc.textTertiary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                PrimaryButton(
                  label: 'VINCULAR E SALVAR FOTO',
                  onTap: () {
                    fit.attachPhotoToSession(selectedSession, base64Str, before: isBefore);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Foto vinculada com sucesso!', style: AppTheme.s(13, color: Colors.white)),
                        backgroundColor: gc.bgRaised,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
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

    return AnimatedBuilder(
      animation: fit,
      builder: (context, _) {
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
      },
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
        height: MediaQuery.of(context).size.height * 0.88,
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
              child: Column(
                children: [
                  PrimaryButton(
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
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      fit.deleteSessionPhoto(item.session, before: item.isBefore);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Foto removida da galeria.', style: AppTheme.s(13, color: Colors.white)),
                          backgroundColor: gc.bgRaised,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    label: Text('Excluir Foto', style: AppTheme.s(13, weight: FontWeight.w600, color: Colors.redAccent)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 48),
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
