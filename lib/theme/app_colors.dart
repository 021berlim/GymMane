import 'package:flutter/material.dart';

@immutable
class GymColors extends ThemeExtension<GymColors> {
  const GymColors({
    required this.pageBg,
    required this.bg,
    required this.bgRaised,
    required this.bgRaised2,
    required this.border,
    required this.navBg,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.ember,
    required this.emberDeep,
    required this.onEmber,
    required this.emberSoft,
    required this.emberShadow,
    required this.accent,
    required this.accentSoft,
    required this.brass,
    required this.sage,
    required this.sageSoft,
    required this.mutedFill,
    required this.heatEmpty,
    required this.warn,
    required this.danger,
  });

  final Color pageBg;
  final Color bg;
  final Color bgRaised;
  final Color bgRaised2;
  final Color border;
  final Color navBg;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;
  final Color ember;
  final Color emberDeep;
  final Color onEmber;
  final Color emberSoft;
  final Color emberShadow;
  final Color accent;
  final Color accentSoft;
  final Color brass;
  final Color sage;
  final Color sageSoft;
  final Color mutedFill;
  final Color heatEmpty;
  final Color warn;
  final Color danger;

  static const dark = GymColors(
    pageBg: Color(0xFF090B08),
    bg: Color(0xFF0A0A0A),
    bgRaised: Color(0xFF161616),
    bgRaised2: Color(0xFF202020),
    border: Color(0xFF2A2A2A),
    navBg: Color(0xD90A0A0A),
    text: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9A9A9A),
    textTertiary: Color(0xFF666666),
    ember: Color(0xFFFFFFFF),
    emberDeep: Color(0xFFD0D0D0),
    onEmber: Color(0xFF0A0A0A),
    emberSoft: Color(0x1AFFFFFF),
    emberShadow: Color(0x80000000),
    accent: Color(0xFFA3E635),
    accentSoft: Color(0x29A3E635),
    brass: Color(0xFFBEF264),
    sage: Color(0xFFA3E635),
    sageSoft: Color(0x29A3E635),
    mutedFill: Color(0xFF2A2A2A),
    heatEmpty: Color(0xFF181818),
    warn: Color(0xFFE0B15A),
    danger: Color(0xFFE5674C),
  );

  static const light = GymColors(
    pageBg: Color(0xFFEAF2E2),
    bg: Color(0xFFF5F9F1),
    bgRaised: Color(0xFFFFFFFF),
    bgRaised2: Color(0xFFE8F0E1),
    border: Color(0xFFD5E2CB),
    navBg: Color(0xE6F5F9F1),
    text: Color(0xFF17210F),
    textSecondary: Color(0xFF53634B),
    textTertiary: Color(0xFF71806A),
    ember: Color(0xFF17210F),
    emberDeep: Color(0xFF000000),
    onEmber: Color(0xFFF7FBF3),
    emberSoft: Color(0x1417210F),
    emberShadow: Color(0x2417210F),
    accent: Color(0xFF4D7C0F),
    accentSoft: Color(0x1F4D7C0F),
    brass: Color(0xFF4D7C0F),
    sage: Color(0xFF65A30D),
    sageSoft: Color(0x2365A30D),
    mutedFill: Color(0xFFD7E4CE),
    heatEmpty: Color(0xFFE3ECDD),
    warn: Color(0xFF9A6A12),
    danger: Color(0xFFC0392B),
  );

  @override
  GymColors copyWith({
    Color? pageBg,
    Color? bg,
    Color? bgRaised,
    Color? bgRaised2,
    Color? border,
    Color? navBg,
    Color? text,
    Color? textSecondary,
    Color? textTertiary,
    Color? ember,
    Color? emberDeep,
    Color? onEmber,
    Color? emberSoft,
    Color? emberShadow,
    Color? accent,
    Color? accentSoft,
    Color? brass,
    Color? sage,
    Color? sageSoft,
    Color? mutedFill,
    Color? heatEmpty,
    Color? warn,
    Color? danger,
  }) {
    return GymColors(
      pageBg: pageBg ?? this.pageBg,
      bg: bg ?? this.bg,
      bgRaised: bgRaised ?? this.bgRaised,
      bgRaised2: bgRaised2 ?? this.bgRaised2,
      border: border ?? this.border,
      navBg: navBg ?? this.navBg,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      ember: ember ?? this.ember,
      emberDeep: emberDeep ?? this.emberDeep,
      onEmber: onEmber ?? this.onEmber,
      emberSoft: emberSoft ?? this.emberSoft,
      emberShadow: emberShadow ?? this.emberShadow,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      brass: brass ?? this.brass,
      sage: sage ?? this.sage,
      sageSoft: sageSoft ?? this.sageSoft,
      mutedFill: mutedFill ?? this.mutedFill,
      heatEmpty: heatEmpty ?? this.heatEmpty,
      warn: warn ?? this.warn,
      danger: danger ?? this.danger,
    );
  }

  @override
  GymColors lerp(GymColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return GymColors(
      pageBg: c(pageBg, other.pageBg),
      bg: c(bg, other.bg),
      bgRaised: c(bgRaised, other.bgRaised),
      bgRaised2: c(bgRaised2, other.bgRaised2),
      border: c(border, other.border),
      navBg: c(navBg, other.navBg),
      text: c(text, other.text),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      ember: c(ember, other.ember),
      emberDeep: c(emberDeep, other.emberDeep),
      onEmber: c(onEmber, other.onEmber),
      emberSoft: c(emberSoft, other.emberSoft),
      emberShadow: c(emberShadow, other.emberShadow),
      accent: c(accent, other.accent),
      accentSoft: c(accentSoft, other.accentSoft),
      brass: c(brass, other.brass),
      sage: c(sage, other.sage),
      sageSoft: c(sageSoft, other.sageSoft),
      mutedFill: c(mutedFill, other.mutedFill),
      heatEmpty: c(heatEmpty, other.heatEmpty),
      warn: c(warn, other.warn),
      danger: c(danger, other.danger),
    );
  }
}

extension GymColorsX on BuildContext {
  GymColors get gc => Theme.of(this).extension<GymColors>()!;
}
