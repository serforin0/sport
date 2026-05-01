import '../../domain/entities/job_offer.dart';

class JobOfferModel extends JobOffer {
  const JobOfferModel({
    required super.id,
    required super.title,
    required super.description,
    required super.company,
    required super.location,
    required super.modality,
    required super.experienceLevel,
    required super.createdAt,
    super.companyLogoUrl,
    super.applicationType,
    super.applicationUrl,
    super.deadline,
    super.sportName,
    super.isSaved,
    super.hasApplied,
    super.isOwner,
    super.applicationsCount,
  });

  factory JobOfferModel.fromApi(Map<String, dynamic> json) {
    final authorRaw = json['user'] ?? json['employer'];
    String companyName = json['company']?.toString() ?? 'Empresa Desconocida';
    String? logoUrl;
    
    if (authorRaw is Map) {
      if (authorRaw['name'] != null) {
        companyName = authorRaw['name'].toString();
      } else if (authorRaw['profile'] is Map) {
        final pf = authorRaw['profile'];
        companyName = '${pf['first_name'] ?? ''} ${pf['last_name'] ?? ''}'.trim();
        if (companyName.isEmpty) companyName = 'Usuario';
      }
      logoUrl = authorRaw['avatar']?.toString() ?? authorRaw['photo_url']?.toString();
    }

    return JobOfferModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Sin título',
      description: json['description']?.toString() ?? '',
      company: companyName,
      location: json['location']?.toString() ?? 'Remoto',
      modality: json['modality']?.toString() ?? json['contract_type']?.toString() ?? 'Jornada completa',
      experienceLevel: json['experience_level']?.toString() ?? json['sport_name']?.toString() ?? 'Deporte',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      companyLogoUrl: logoUrl,
      applicationType: json['application_type']?.toString(),
      applicationUrl: json['application_url']?.toString(),
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline'].toString()) : null,
      sportName: json['sport_name']?.toString(),
      isSaved: json['is_saved'] == true,
      hasApplied: json['has_applied'] == true,
      isOwner: json['is_owner'] == true,
      applicationsCount: json['applications_count'] is int ? json['applications_count'] as int : int.tryParse(json['applications_count']?.toString() ?? '') ?? 0,
    );
  }
}
