import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class DialogScrim extends StatelessWidget {
  final Widget child;
  final VoidCallback? onClose;
  final bool alignBottom;

  const DialogScrim({
    super.key,
    required this.child,
    this.onClose,
    this.alignBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: const Color(0x6B141414),
          child: Align(
            alignment: alignBottom ? Alignment.bottomCenter : Alignment.center,
            child: GestureDetector(
              onTap: () {},
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class TechFixDialog extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Color iconColor;
  final Widget? child;
  final List<Widget>? actions;
  final VoidCallback? onClose;

  const TechFixDialog({
    super.key,
    this.title,
    this.icon,
    this.iconColor = AppTheme.coral,
    this.child,
    this.actions,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return DialogScrim(onClose: onClose, child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340, maxHeight: 0.8 * double.infinity),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                const SizedBox(height: 4),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, size: 26, color: iconColor),
                ),
                const SizedBox(height: 12),
              ],
              if (title != null)
                Text(
                  title!,
                  textAlign: icon != null ? TextAlign.center : TextAlign.left,
                  style: const TextStyle(
                    
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                    letterSpacing: -0.3,
                  ),
                ),
              if (title != null) const SizedBox(height: 14),
              Flexible(child: SingleChildScrollView(child: child ?? const SizedBox.shrink())),
              if (actions != null) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    ));
  }
}
