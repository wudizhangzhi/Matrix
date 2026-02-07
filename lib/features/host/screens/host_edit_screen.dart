import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/features/host/providers/host_provider.dart';

class HostEditScreen extends ConsumerStatefulWidget {
  final Host? host;

  const HostEditScreen({super.key, this.host});

  @override
  ConsumerState<HostEditScreen> createState() => _HostEditScreenState();
}

class _HostEditScreenState extends ConsumerState<HostEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _hostnameCtrl;
  late final TextEditingController _portCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  String _authType = 'password';
  String? _selectedGroupId;

  bool get _isEditing => widget.host != null;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.host?.label ?? '');
    _hostnameCtrl = TextEditingController(text: widget.host?.hostname ?? '');
    _portCtrl =
        TextEditingController(text: (widget.host?.port ?? 22).toString());
    _usernameCtrl =
        TextEditingController(text: widget.host?.username ?? 'root');
    _passwordCtrl = TextEditingController();
    _authType = widget.host?.authType ?? 'password';
    _selectedGroupId = widget.host?.groupId;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _hostnameCtrl.dispose();
    _portCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(hostGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Host' : 'New Host'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildField('Label', _labelCtrl, 'My Server'),
            const SizedBox(height: 16),
            _buildField('Hostname', _hostnameCtrl, '192.168.1.1'),
            const SizedBox(height: 16),
            _buildField('Port', _portCtrl, '22',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildField('Username', _usernameCtrl, 'root'),
            const SizedBox(height: 16),
            const Text('Authentication',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'password', label: Text('Password')),
                ButtonSegment(value: 'privateKey', label: Text('Key')),
                ButtonSegment(value: 'totp', label: Text('TOTP')),
              ],
              selected: {_authType},
              onSelectionChanged: (v) =>
                  setState(() => _authType = v.first),
              style: ButtonStyle(
                foregroundColor:
                    WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? Colors.white
                      : AppColors.textSecondary;
                }),
              ),
            ),
            const SizedBox(height: 16),
            if (_authType == 'password')
              _buildField('Password', _passwordCtrl, '',
                  obscure: true, required: !_isEditing),
            const SizedBox(height: 16),
            groupsAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (groups) {
                if (groups.isEmpty) return const SizedBox();
                return DropdownButtonFormField<String?>(
                  initialValue: _selectedGroupId,
                  decoration: const InputDecoration(labelText: 'Group'),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('No group')),
                    ...groups.map((g) => DropdownMenuItem(
                        value: g.id, child: Text(g.name))),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedGroupId = v),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(hostNotifierProvider);

    if (_isEditing) {
      notifier.updateHost(
        id: widget.host!.id,
        label: _labelCtrl.text.trim(),
        hostname: _hostnameCtrl.text.trim(),
        port: int.tryParse(_portCtrl.text) ?? 22,
        username: _usernameCtrl.text.trim(),
        authType: _authType,
        groupId: _selectedGroupId,
        password:
            _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null,
      );
    } else {
      notifier.addHost(
        label: _labelCtrl.text.trim(),
        hostname: _hostnameCtrl.text.trim(),
        port: int.tryParse(_portCtrl.text) ?? 22,
        username: _usernameCtrl.text.trim(),
        authType: _authType,
        groupId: _selectedGroupId,
        password:
            _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null,
      );
    }

    Navigator.pop(context);
  }
}
