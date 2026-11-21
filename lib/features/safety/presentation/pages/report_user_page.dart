import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/safety/domain/report_reasons.dart';
import 'package:sport/features/safety/presentation/providers/reports_providers.dart';

class ReportUserPage extends ConsumerStatefulWidget {
  final String? targetUserId;
  final int? conversationId;
  final String? targetName;

  const ReportUserPage({
    super.key,
    this.targetUserId,
    this.conversationId,
    this.targetName,
  });

  @override
  ConsumerState<ReportUserPage> createState() => _ReportUserPageState();
}

class _ReportUserPageState extends ConsumerState<ReportUserPage> {
  String? _reason;
  final _detailsCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un motivo')),
      );
      return;
    }
    setState(() => _saving = true);
    final result = await ref.read(reportsRepositoryProvider).submit(
          targetUserId: widget.targetUserId,
          conversationId: widget.conversationId,
          reason: _reason!,
          details: _detailsCtrl.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
      (msg) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        Navigator.pop(context, true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.targetName == null
              ? 'Reportar'
              : 'Reportar a ${widget.targetName}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Motivo',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          ...ReportReason.values.map((reason) {
            return RadioListTile<String>(
              value: reason.id,
              groupValue: _reason,
              activeColor: const Color(0xFF3B82F6),
              title: Text(reason.label, style: const TextStyle(color: Colors.white)),
              onChanged: (v) => setState(() => _reason = v),
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'Detalles (opcional)',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _detailsCtrl,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Enviar reporte',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
