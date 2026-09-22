import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../models/profile.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/medal_shelf.dart';
import '../widgets/photo_source_sheet.dart';
import '../widgets/profile_avatar.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _busy = false;

  Future<void> _pickBanner() async {
    if (_busy) return;
    final source = await pickPhotoSource(context);
    if (source == null) return;
    setState(() => _busy = true);
    try {
      final shot = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 900,
        imageQuality: 82,
      );
      if (shot == null) return;
      final bytes = await File(shot.path).readAsBytes();
      fit.setProfileBanner(bytes);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _shareProfile() {
    final lifted = fit.liftedSpan;
    final trained = fit.trainedSpan;
    final text = 'FIT//IRON — @${fit.profileHandle}\n'
        '${t.statWorkouts}: ${fit.totalSessions} | ${t.statLifted}: ${lifted.$1}${lifted.$2}\n'
        '${t.statTrained}: ${trained.$1}${trained.$2} | ${t.statStreak}: ${fit.currentStreak} ${t.statDays}';
    SharePlus.instance.share(ShareParams(subject: 'FIT//IRON Profile', text: text));
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return AnimatedBuilder(
      animation: fit,
      builder: (context, _) {
        final recentPhotos = _recentPhotos();
        final photoTotal = _photoCount();

        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileHeader(
                gc: gc,
                top: MediaQuery.paddingOf(context).top,
                onBanner: _pickBanner,
                onEdit: () => showProfileSheet(context),
                onShare: _shareProfile,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 0, 0),
                child: _stats(gc),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (fit.gamification) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _heading(gc, t.awardsTitle, count: '${fit.awardCount}', onMore: fit.goAwards),
                          const SizedBox(height: 6),
                          const MedalShelf(size: 40),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _heading(gc, t.snapshots, count: photoTotal == 0 ? null : '$photoTotal', onMore: fit.goGallery),
                        const SizedBox(height: 6),
                        _PhotoCarousel(
                          photos: recentPhotos,
                          gc: gc,
                          onTap: fit.goGallery,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _heading(gc, t.yearTitle),
                        const SizedBox(height: 6),
                        _year(gc),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _year(GymColors gc) {
    final months = fit.sessionsByMonth;
    final peak = months.fold(1, math.max);
    final thisMonth = DateTime.now().month;
    final best = fit.bestMonthThisYear;
    final lifted = fit.liftedSpanOf(fit.volumeThisYearKg);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _yearStat(gc, '${fit.sessionsThisYear}', '', t.statWorkouts)),
              Expanded(child: _yearStat(gc, lifted.$1, lifted.$2, t.statLifted)),
              Expanded(
                child: _yearStat(gc, '${fit.monthsTrainedThisYear}', '/12', t.yearMonths),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var m = 1; m <= 12; m++) ...[
                  if (m > 1) const SizedBox(width: 4),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: peak > 0 ? months[m - 1] / peak : 0.0),
                      duration: Duration(milliseconds: 650 + m * 35),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => Container(
                        height: 4 + 30 * v,
                        decoration: BoxDecoration(
                          color: m == thisMonth
                              ? gc.ember
                              : (months[m - 1] > 0 ? gc.textTertiary : gc.bgRaised2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              for (var m = 1; m <= 12; m++) ...[
                if (m > 1) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    t.monthInitial(m),
                    textAlign: TextAlign.center,
                    style: AppTheme.s(9,
                        weight: FontWeight.w600,
                        color: m == thisMonth ? gc.text : gc.textTertiary),
                  ),
                ),
              ],
            ],
          ),
          if (best > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${t.yearBestMonth} · ',
                    style: AppTheme.s(10.5, weight: FontWeight.w500, color: gc.textTertiary)),
                Text(t.monthName(best),
                    style: AppTheme.s(10.5, weight: FontWeight.w700, color: gc.textSecondary)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _yearStat(GymColors gc, String value, String unit, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: AppTheme.d(18, weight: FontWeight.w800, color: gc.text)),
            if (unit.isNotEmpty)
              Text(unit,
                  style: AppTheme.s(10.5, weight: FontWeight.w600, color: gc.textSecondary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.s(8.5,
              weight: FontWeight.w600, color: gc.textTertiary, letterSpacing: 0.8),
        ),
      ],
    );
  }

  Widget _heading(GymColors gc, String title, {String? count, VoidCallback? onMore}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onMore,
      child: Row(
        children: [
          Text(title, style: AppTheme.d(15.5, weight: FontWeight.w700, color: gc.text)),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text(count, style: AppTheme.s(13, weight: FontWeight.w600, color: gc.textTertiary)),
          ],
          const Spacer(),
          if (onMore != null)
            Icon(PhosphorIconsBold.caretRight, size: 14, color: gc.textTertiary),
        ],
      ),
    );
  }

  Widget _stats(GymColors gc) {
    final items = <(String, String, String)>[
      (t.statWorkouts, '${fit.totalSessions}', ''),
      (t.statTrained, fit.trainedSpan.$1, fit.trainedSpan.$2),
      (t.statSets, '${fit.totalSets}', ''),
      (t.statLifted, fit.liftedSpan.$1, fit.liftedSpan.$2),
      (t.statStreak, '${fit.currentStreak}', t.statDays),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (_, i) {
          final (label, value, unit) = items[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTheme.s(8.5,
                    weight: FontWeight.w600, color: gc.textTertiary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: AppTheme.d(17, weight: FontWeight.w800, color: gc.text)),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 3),
                    Text(unit,
                        style: AppTheme.s(10.5, weight: FontWeight.w500, color: gc.textSecondary)),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _recentPhotos() {
    final list = <String>[];
    for (final s in fit.sessions.reversed) {
      for (final p in s.photosAfter.reversed) {
        if (p.isNotEmpty && imageProviderFromSrc(p) != null) {
          list.add(p);
          if (list.length == 3) return list;
        }
      }
      for (final p in s.photosBefore.reversed) {
        if (p.isNotEmpty && imageProviderFromSrc(p) != null) {
          list.add(p);
          if (list.length == 3) return list;
        }
      }
    }
    return list;
  }

  int _photoCount() {
    var count = 0;
    for (final s in fit.sessions) {
      for (final p in s.photosBefore) {
        if (p.isNotEmpty && imageProviderFromSrc(p) != null) {
          count++;
        }
      }
      for (final p in s.photosAfter) {
        if (p.isNotEmpty && imageProviderFromSrc(p) != null) {
          count++;
        }
      }
    }
    return count;
  }
}

ImageProvider? imageProviderFromSrc(String src) {
  if (src.isEmpty) return null;
  try {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return NetworkImage(src);
    }
    if (src.startsWith('file://')) {
      try {
        final uri = Uri.parse(src);
        final f = File(uri.toFilePath());
        if (f.existsSync()) return FileImage(f);
      } catch (_) {
        var cleanPath = src.replaceFirst('file://', '');
        if (Platform.isWindows &&
            cleanPath.startsWith('/') &&
            cleanPath.length > 2 &&
            cleanPath[2] == ':') {
          cleanPath = cleanPath.substring(1);
        }
        final f = File(cleanPath);
        if (f.existsSync()) return FileImage(f);
      }
    }
    if (src.startsWith('/') || (src.length > 2 && src[1] == ':')) {
      final f = File(src);
      if (f.existsSync()) return FileImage(f);
    }
    String clean = src;
    if (clean.contains(',')) {
      clean = clean.split(',').last;
    }
    clean = clean.replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', '').trim();
    final mod4 = clean.length % 4;
    if (mod4 > 0) {
      clean = clean.padRight(clean.length + (4 - mod4), '=');
    }
    Uint8List bytes;
    try {
      bytes = base64Decode(clean);
    } catch (_) {
      final normalized = clean.replaceAll('-', '+').replaceAll('_', '/');
      bytes = base64Decode(normalized);
    }
    if (bytes.isEmpty) return null;
    return MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}

class _PhotoCarousel extends StatefulWidget {
  final List<String> photos;
  final GymColors gc;
  final VoidCallback onTap;

  const _PhotoCarousel({
    required this.photos,
    required this.gc,
    required this.onTap,
  });

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.photos.length == 1 ? 1.0 : 0.78,
    );
  }

  @override
  void didUpdateWidget(_PhotoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.photos.length == 1) != (widget.photos.length == 1)) {
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: widget.photos.length == 1 ? 1.0 : 0.78,
        initialPage: _currentPage.clamp(0, math.max(0, widget.photos.length - 1)),
      );
    }
    if (_currentPage >= widget.photos.length && widget.photos.isNotEmpty) {
      _currentPage = widget.photos.length - 1;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return _buildEmpty();
    }

    final hasMultiple = widget.photos.length > 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 96,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              final provider = imageProviderFromSrc(photo);
              final isCurrent = index == _currentPage;

              return AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: hasMultiple ? 5.0 : 0.0,
                  vertical: hasMultiple && !isCurrent ? 3.0 : 0.0,
                ),
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.gc.bgRaised2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent ? widget.gc.accent.withValues(alpha: 0.45) : widget.gc.border,
                        width: isCurrent ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isCurrent ? 0.35 : 0.18),
                          blurRadius: isCurrent ? 10 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (provider != null)
                          Image(
                            image: provider,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, _, _) => _brokenImage(),
                          )
                        else
                          _brokenImage(),
                        Positioned(
                          left: 10,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${index + 1}',
                              style: AppTheme.d(11, weight: FontWeight.w700, color: Colors.white),
                            ),
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
        if (hasMultiple) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.photos.length, (i) {
              final isSel = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSel ? 14 : 5,
                height: 4,
                decoration: BoxDecoration(
                  color: isSel ? widget.gc.accent : widget.gc.bgRaised2,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildEmpty() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: widget.gc.bgRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.gc.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: widget.gc.bgRaised2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(PhosphorIconsRegular.imagesSquare, size: 20, color: widget.gc.textTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t.photosCard,
                style: AppTheme.s(13, weight: FontWeight.w600, color: widget.gc.text),
              ),
            ),
            Icon(PhosphorIconsBold.caretRight, size: 14, color: widget.gc.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _brokenImage() {
    return Container(
      color: widget.gc.bgRaised2,
      child: Center(
        child: Icon(PhosphorIconsRegular.imageBroken, size: 24, color: widget.gc.textTertiary),
      ),
    );
  }
}

class _ProfileHeader extends SliverPersistentHeaderDelegate {
  _ProfileHeader({
    required this.gc,
    required this.top,
    required this.onBanner,
    required this.onEdit,
    required this.onShare,
  });

  final GymColors gc;
  final double top;
  final VoidCallback onBanner;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  static const _banner = 112.0;
  static const _bar = 50.0;
  static const _levelRow = 24.0;

  double get _cut => fit.gamification ? 0 : _levelRow;
  double get _identity => 90.0 - _cut;
  double get _identityBlock => 98.0 - _cut;

  @override
  double get maxExtent => _banner + _identity;

  @override
  double get minExtent => top + _bar;

  @override
  bool shouldRebuild(_ProfileHeader old) => true;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = maxExtent - minExtent;
    final shrunk = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    final bytes = fit.profileBanner;
    final p = fit.profile;

    final height = math.max(maxExtent - shrinkOffset, minExtent);
    final bannerHeight = (height - 10 - _identityBlock + 24).clamp(minExtent, height);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: bannerHeight,
            child: GestureDetector(
              onTap: onBanner,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: gc.bgRaised,
                      image: DecorationImage(
                        image: bytes == null ? kDefaultBanner : MemoryImage(bytes) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            gc.bg.withValues(alpha: 0.18 + 0.6 * shrunk),
                            gc.bg.withValues(alpha: 0.10 + 0.6 * shrunk),
                            gc.bg.withValues(alpha: 0.55),
                            gc.bg,
                          ],
                          stops: const [0, 0.38, 0.78, 1],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: top + 6,
            right: 14,
            child: Row(children: [
              _round(PhosphorIconsRegular.shareNetwork, onShare),
              const SizedBox(width: 8),
              _round(PhosphorIconsRegular.gearSix, fit.goPreferences),
            ]),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 10,
            child: Opacity(
              opacity: (1 - shrunk * 2).clamp(0.0, 1.0),
              child: _full(p),
            ),
          ),
          Positioned(
            left: 16,
            top: top + 6,
            height: 40,
            child: Opacity(
              opacity: ((shrunk - 0.62) / 0.38).clamp(0.0, 1.0),
              child: _compact(p),
            ),
          ),
        ],
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration:
            BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _compact(Profile p) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ProfileAvatar(size: 32),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(fit.displayName, style: AppTheme.d(14.5, weight: FontWeight.w700, color: gc.text)),
              if (p.badge.isNotEmpty) ...[
                const SizedBox(width: 4),
                Icon(PhosphorIconsFill.sealCheck, size: 13, color: badgeColor(p.badge)),
              ],
            ]),
            Text('@${fit.profileHandle}',
                style: AppTheme.s(11, weight: FontWeight.w500, color: gc.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _full(Profile p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const ProfileAvatar(size: 54),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: gc.bgRaised2,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: gc.border),
                ),
                child: Text(t.editProfile,
                    style: AppTheme.s(12.5, weight: FontWeight.w600, color: gc.text)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(children: [
          Flexible(
            child: Text(p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.d(18, weight: FontWeight.w800, color: gc.text)),
          ),
          if (p.badge.isNotEmpty) ...[
            const SizedBox(width: 6),
            Icon(PhosphorIconsFill.sealCheck, size: 16, color: badgeColor(p.badge)),
          ],
        ]),
        const SizedBox(height: 2),
        Text(
          '@${fit.profileHandle}  ·  ${fit.weightLabel(p.weightKg)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.s(11.5, weight: FontWeight.w500, color: gc.textSecondary),
        ),
        if (fit.gamification) ...[
          const SizedBox(height: 6),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: gc.bgRaised2,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: gc.border),
              ),
              child: Text(t.levelShort(fit.athleteLevel),
                  style: AppTheme.s(10.5, weight: FontWeight.w700, color: gc.text)),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                t.levelToNext(fit.sessionsToNextLevel, fit.athleteLevel + 1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.s(10.5, weight: FontWeight.w500, color: gc.textTertiary),
              ),
            ),
          ]),
        ],
      ],
    );
  }
}
