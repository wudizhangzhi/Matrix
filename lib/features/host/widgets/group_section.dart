import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/features/host/widgets/host_card.dart';

class GroupSection extends StatefulWidget {
  final HostGroup group;
  final List<Host> hosts;
  final void Function(Host) onHostTap;
  final void Function(Host) onHostEdit;
  final void Function(Host) onHostDelete;

  const GroupSection({
    super.key,
    required this.group,
    required this.hosts,
    required this.onHostTap,
    required this.onHostEdit,
    required this.onHostDelete,
  });

  @override
  State<GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<GroupSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_more : Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.group.name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.hosts.length}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.hosts.map((host) => HostCard(
                host: host,
                onTap: () => widget.onHostTap(host),
                onEdit: () => widget.onHostEdit(host),
                onDelete: () => widget.onHostDelete(host),
              )),
      ],
    );
  }
}
