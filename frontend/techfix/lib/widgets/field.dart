/// Reusable text input field used across all forms in the app.
///
/// Supports single-line, multiline, icons, obscure text, auto-focus,
/// keyboard actions, and a suffix widget. Uses [AnimatedContainer]
/// to highlight the border on focus.
import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class Field extends StatefulWidget {
  final String? label;
  final String? value;
  final ValueChanged<String>? onChanged;
  final IconData? icon;
  final String? placeholder;
  final bool multiline;
  final int rows;
  final bool autoFocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final Widget? suffix;

  const Field({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.icon,
    this.placeholder,
    this.multiline = false,
    this.rows = 3,
    this.autoFocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
    this.suffix,
  });

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  late TextEditingController _controller;
  bool _focus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(Field oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        constraints: widget.multiline ? null : const BoxConstraints(minHeight: 50),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _focus ? AppTheme.teal : AppTheme.line2, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: FocusScope(
          child: Focus(
            onFocusChange: (v) => setState(() => _focus = v),
            child: Row(
              crossAxisAlignment: widget.multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                if (widget.icon != null)
                  Padding(
                    padding: EdgeInsets.only(left: 14, top: widget.multiline ? 14 : 0),
                    child: Icon(widget.icon, size: 20, color: _focus ? AppTheme.teal : AppTheme.faint),
                  ),
                Expanded(child: widget.multiline ? _buildMultiline() : _buildSingleLine()),
                if (widget.suffix != null)
                  Padding(padding: const EdgeInsets.only(right: 14), child: widget.suffix!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleLine() {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autoFocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        hintText: widget.placeholder ?? widget.label,
        hintStyle: const TextStyle(color: AppTheme.faint, fontSize: 15),
      ),
      style: const TextStyle(fontSize: 15, color: AppTheme.ink),
    );
  }

  Widget _buildMultiline() {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLines: widget.rows,
      autofocus: widget.autoFocus,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        hintText: widget.placeholder ?? widget.label,
        hintStyle: const TextStyle(color: AppTheme.faint, fontSize: 15),
      ),
      style: const TextStyle(fontSize: 15, color: AppTheme.ink),
    );
  }
}
