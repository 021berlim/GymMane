import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'svg_icon.dart';
import 'glass.dart';
export 'app_toast.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.borderColor,
    this.color,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? borderColor;
  final Color? color;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return Container(
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color ?? gc.bgRaised,
        border: Border.all(color: borderColor ?? gc.border),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

class RoundBtn extends StatelessWidget {
  const RoundBtn({super.key, required this.icon, required this.onTap, this.iconColor});
  final List<IconPath> icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: gc.bgRaised,
          shape: BoxShape.circle,
          border: Border.all(color: gc.border),
        ),
        child: Center(child: SvgPathIcon(icon, size: 16, color: iconColor ?? gc.text)),
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key, this.size = 22, this.spacing = 2});
  final String text;
  final double size;
  final double spacing;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTheme.d(size, weight: FontWeight.w700, color: context.gc.text, letterSpacing: spacing));
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle,
    this.titleSize = 20,
    this.titleSpacing = 2,
    this.actions = const [],
  });

  final String title;
  final VoidCallback onBack;
  final String? subtitle;
  final double titleSize;
  final double titleSpacing;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return Row(
      children: [
        RoundBtn(icon: Ic.chevronLeft, onTap: onBack),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenTitle(title, size: titleSize, spacing: titleSpacing),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: AppTheme.s(12.5,
                        weight: FontWeight.w500, color: gc.textSecondary)),
              ],
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}

class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, required this.color, this.size = 12, this.spacing = 3});
  final String text;
  final Color color;
  final double size;
  final double spacing;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTheme.d(size, weight: FontWeight.w600, color: color, letterSpacing: spacing));
}

class StepperControl extends StatelessWidget {
  const StepperControl({
    super.key,
    required this.value,
    required this.onDec,
    required this.onInc,
    this.onEdit,
    this.minWidth = 70,
    this.btnSize = 30,
    this.gap = 14,
    this.fontSize = 16,
    this.btnRadius = 8,
  });

  final String value;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final VoidCallback? onEdit;
  final double minWidth;
  final double btnSize;
  final double gap;
  final double fontSize;
  final double btnRadius;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    Widget btn(String glyph, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Container(
            width: btnSize,
            height: btnSize,
            decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(btnRadius)),
            alignment: Alignment.center,
            child: Text(glyph, style: TextStyle(color: gc.text, fontSize: fontSize + 2, height: 1, fontWeight: FontWeight.w500)),
          ),
        );
    Widget label = Container(
      constraints: BoxConstraints(minWidth: minWidth),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(value, maxLines: 1, style: AppTheme.d(fontSize, weight: FontWeight.w700, color: gc.text)),
      ),
    );
    if (onEdit != null) {
      label = GestureDetector(behavior: HitTestBehavior.opaque, onTap: onEdit, child: label);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn('–', onDec),
        SizedBox(width: gap),
        Flexible(child: label),
        SizedBox(width: gap),
        btn('+', onInc),
      ],
    );
  }
}

class ToolRow extends StatelessWidget {
  const ToolRow({super.key, required this.label, required this.control});
  final String label;
  final Widget control;
  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return SoftCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: AppTheme.s(13, weight: FontWeight.w600, color: gc.textSecondary)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: control,
            ),
          ),
        ],
      ),
    );
  }
}

class SegOption {
  const SegOption(this.label, this.selected, this.onTap);
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class SegToggle extends StatelessWidget {
  const SegToggle(this.options, {super.key, this.hPad = 14, this.vPad = 7, this.fontSize = 12});
  final List<SegOption> options;
  final double hPad;
  final double vPad;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final o in options)
            GestureDetector(
              onTap: o.onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                decoration: BoxDecoration(
                  color: o.selected ? gc.ember : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(o.label,
                    style: AppTheme.s(fontSize,
                        weight: FontWeight.w600, color: o.selected ? gc.onEmber : gc.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.hPad = 14,
    this.vPad = 8,
    this.fontSize = 13,
  });
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final double hPad;
  final double vPad;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
        child: Text(label, style: AppTheme.s(fontSize, weight: FontWeight.w600, color: fg)),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.bg,
    this.fg,
    this.height = 56,
    this.icon,
  });
  final String label;
  final VoidCallback onTap;
  final Color? bg;
  final Color? fg;
  final double height;
  final List<IconPath>? icon;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final f = fg ?? gc.onEmber;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(color: bg ?? gc.ember, borderRadius: BorderRadius.circular(100)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[SvgPathIcon(icon!, size: 18, color: f), const SizedBox(width: 10)],
            Text(label, style: AppTheme.d(16, weight: FontWeight.w600, color: f, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}

Future<bool> showConfirmDeleteModal({
  required BuildContext context,
  required String title,
  String? message,
  String? confirmLabel,
  String? cancelLabel,
}) async {
  final gc = context.gc;
  final result = await showAppDialog<bool>(
    context: context,
    builder: (dctx) => AlertDialog(
      backgroundColor: gc.bgRaised,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text)),
      content: message != null && message.isNotEmpty
          ? Text(message, style: AppTheme.s(13, color: gc.textSecondary))
          : null,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dctx).pop(false),
          child: Text(cancelLabel ?? t.cancel, style: AppTheme.s(14, color: gc.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(dctx).pop(true),
          child: Text(confirmLabel ?? t.delete, style: AppTheme.s(14, weight: FontWeight.w700, color: gc.accent)),
        ),
      ],
    ),
  );
  return result ?? false;
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.padding = const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Icon(icon, size: 48, color: gc.textTertiary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.d(16, weight: FontWeight.w700, color: gc.text),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTheme.s(13, color: gc.textSecondary),
          ),
        ],
      ),
    );
  }
}


