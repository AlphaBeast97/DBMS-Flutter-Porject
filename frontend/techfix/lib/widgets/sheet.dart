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
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: const Color(0x6B141414),
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
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
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.line2,
                      borderRadius: BorderRadius.circular(2),
                    ),
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
                              Text(
                                title,
                                style: const TextStyle(
                                  
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.ink,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  subtitle!,
                                style: TextStyle(
                                  
                                  fontSize: 13.5,
                                  color: AppTheme.muted,
                                ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: Icon(Icons.close, color: AppTheme.muted),
                        ),
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
            ),
          ),
        ),
      ),
    );
  }
}
