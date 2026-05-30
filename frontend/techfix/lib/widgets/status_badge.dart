import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool sm;

  const StatusBadge({super.key, required this.status, this.sm = false});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.clay;
      case 'repairing':
      case 'in progress':
        return AppTheme.sky;
      case 'ready':
        return AppTheme.teal;
      case 'cancelled':
        return AppTheme.grey;
      case 'delivered':
      case 'completed':
        return AppTheme.teal;
      default:
        return AppTheme.coral;
    }
  }

  Color get _bg {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0x1FB86B4B);
      case 'repairing':
      case 'in progress':
        return const Color(0x1F2D7BD1);
      case 'ready':
        return const Color(0x242A9D8F);
      case 'cancelled':
        return const Color(0x299A958C);
      case 'delivered':
      case 'completed':
        return const Color(0x242A9D8F);
      default:
        return const Color(0x1FF26B4A);
    }
  }

  IconData get _icon {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'repairing':
      case 'in progress':
        return Icons.build;
      case 'ready':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'delivered':
      case 'completed':
        return Icons.local_shipping;
      default:
        return Icons.help_outline;
    }
  }

  String get _label {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'repairing':
        return 'Repairing';
      case 'in progress':
        return 'Repairing';
      case 'ready':
        return 'Ready';
      case 'cancelled':
        return 'Cancelled';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Delivered';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sm ? 9 : 11, vertical: sm ? 3 : 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: sm ? 13 : 15, color: _color),
          const SizedBox(width: 5),
          Text(
            _label,
            style: TextStyle(
              
              fontSize: sm ? 11.5 : 12.5,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
