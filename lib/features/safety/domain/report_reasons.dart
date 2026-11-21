class ReportReason {
  final String id;
  final String label;

  const ReportReason(this.id, this.label);

  static const values = [
    ReportReason('impersonation', 'Suplantación de identidad'),
    ReportReason('money_request', 'Pide dinero'),
    ReportReason('inappropriate_minor', 'Contacto inapropiado con un menor'),
    ReportReason('fake_profile', 'Perfil falso'),
    ReportReason('offensive', 'Contenido ofensivo'),
  ];
}
