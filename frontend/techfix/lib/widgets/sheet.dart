/// Reusable bottom sheet shell used for all sheet-based workflows.
///
/// Slides up from the bottom with a drag handle, title, optional subtitle,
/// scrollable content area, and a sticky action bar. The scrim fades in
/// via [TweenAnimationBuilder].
import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class Sheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? child;
  final List<Widget>? actions;
  final VoidCallback? onClose;

  const Sheet({
    super.key,
    required this.title,
    this.subtitle,
    this.child,
    this.actions,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              color: const Color(0x6B141414).withValues(alpha: val * 0.42),
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {},
                child: Transform.translate(
                  offset: Offset(0, 40.0 * (1 - val)),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Container(
      constraints: const BoxConstraints(maxHeight: double.infinity),
      decoration: const BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(color: AppTheme.line2, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppTheme.ink, letterSpacing: -0.3)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(subtitle!, style: const TextStyle(fontSize: 13.5, color: AppTheme.muted)),
                      ],
                    ],
                  ),
                ),
                IconButton(onPressed: onClose, icon: Icon(Icons.close, color: AppTheme.muted)),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          if (actions != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.line)),
                color: Colors.white.withOpacity(0.5),
              ),
              child: Row(children: actions!),
            ),
        ],
      ),
    );
  }
}
