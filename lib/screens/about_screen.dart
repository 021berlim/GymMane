import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../catalog/exercise_catalog.dart';
import '../l10n/l10n.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/svg_icon.dart';
import '../widgets/ui_kit.dart';

const _kArtSourceUrl = 'https://github.com/bryllim/workout-guide';
const _kArtLicenseUrl = 'https://creativecommons.org/licenses/by-sa/4.0/';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '1.0.6';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = info.version;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              RoundBtn(icon: Ic.chevronLeft, onTap: fit.backFromAbout),
              const SizedBox(width: 12),
              Text(t.about, style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text, letterSpacing: 1)),
            ]),
            const SizedBox(height: 20),
            _hero(gc),
            const SizedBox(height: 24),
            _principle(gc, PhosphorIconsRegular.gift, t.freeForever, t.freeForeverWhy),
            const SizedBox(height: 10),
            _principle(gc, PhosphorIconsRegular.wifiSlash, t.fullyOffline, t.fullyOfflineWhy),
            const SizedBox(height: 10),
            _principle(gc, PhosphorIconsRegular.export, t.yoursToTake, t.yoursToTakeWhy),
            const SizedBox(height: 24),
            Text(t.whatsInside,
                style: AppTheme.d(12, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 3)),
            const SizedBox(height: 10),
            _principle(gc, PhosphorIconsRegular.barbell, t.exercisesInside(kExercises.length),
                t.exercisesInsideWhy),
            const SizedBox(height: 10),
            _principle(gc, PhosphorIconsRegular.calculator, t.calculatorsInside, t.calculatorsInsideWhy),
            const SizedBox(height: 10),
            _principle(gc, PhosphorIconsRegular.chartLineUp, t.mathInside, t.mathInsideWhy),
            const SizedBox(height: 24),
            if (fit.hasData) ...[
              Text(t.yourNumbers,
                  style: AppTheme.d(12, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 3)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _stat(gc, t.sessionsCaps, '${fit.totalSessions}')),
                const SizedBox(width: 10),
                Expanded(child: _stat(gc, t.liftedCaps, fit.volumeLabel(_allTimeVolume))),
                const SizedBox(width: 10),
                Expanded(child: _stat(gc, t.streakCaps, '${fit.currentStreak} ${t.daysUnit(fit.currentStreak)}')),
              ]),
              const SizedBox(height: 24),
            ],
            Text(t.aboutBlurb,
                textAlign: TextAlign.center, style: AppTheme.s(12, color: gc.textTertiary, height: 1.6)),
            const SizedBox(height: 20),
            _creditsCard(gc),
          ],
        ),
      ),
    );
  }

  Widget _creditsCard(GymColors gc) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.info, size: 20, color: gc.accent),
              const SizedBox(width: 10),
              Text(
                'CRÉDITOS E VERSÃO',
                style: AppTheme.d(13, weight: FontWeight.w700, color: gc.text, letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Versão do aplicativo:',
                style: AppTheme.s(13, color: gc.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gc.accentSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'v$_version',
                  style: AppTheme.d(13, weight: FontWeight.w700, color: gc.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0x1FFFFFFF), height: 1),
          const SizedBox(height: 14),
          Text(
            'Ilustrações de Exercícios:',
            style: AppTheme.s(12, weight: FontWeight.w600, color: gc.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            t.artCredit,
            style: AppTheme.s(11, color: gc.textTertiary, height: 1.4),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _link(gc, 'Workout Guide', _kArtSourceUrl),
              Text('  ·  ', style: AppTheme.s(11, color: gc.textTertiary)),
              _link(gc, 'CC BY-SA 4.0', _kArtLicenseUrl),
            ],
          ),
        ],
      ),
    );
  }

  Widget _link(GymColors gc, String label, String url) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(url),
        child: Text(label, style: AppTheme.s(11, weight: FontWeight.w600, color: gc.accent)),
      );

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  double get _allTimeVolume => fit.sessions.fold(0.0, (a, s) => a + s.volume);

  Widget _hero(GymColors gc) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: gc.bgRaised,
          border: Border.all(color: gc.border),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -50,
              bottom: -60,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(color: gc.accentSoft, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: -10,
              top: 8,
              bottom: 8,
              child: Opacity(
                opacity: 0.5,
                child: Image.asset('assets/img/runner.png', fit: BoxFit.fitHeight),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('FIT//IRON',
                      style: AppTheme.d(34, weight: FontWeight.w700, color: gc.text, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(t.version(_version), style: AppTheme.s(12, color: gc.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _principle(GymColors gc, IconData icon, String title, String why) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: gc.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text)),
                const SizedBox(height: 3),
                Text(why, style: AppTheme.s(12, color: gc.textSecondary, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(GymColors gc, String label, String value) {
    Widget fit1(Widget child) =>
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: child);
    return SoftCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fit1(Text(label,
              maxLines: 1,
              softWrap: false,
              style: AppTheme.s(9, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 1))),
          const SizedBox(height: 4),
          fit1(Text(value,
              maxLines: 1, softWrap: false, style: AppTheme.d(17, weight: FontWeight.w700, color: gc.text))),
        ],
      ),
    );
  }
}
