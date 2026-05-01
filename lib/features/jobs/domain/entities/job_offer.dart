import 'package:equatable/equatable.dart';

class JobOffer extends Equatable {
  final String id;
  final String title;
  final String description;
  final String company;
  final String location;
  final String modality;
  final String experienceLevel;
  final DateTime createdAt;
  final String? companyLogoUrl;
  final String? applicationType;
  final String? applicationUrl;
  final DateTime? deadline;
  final String? sportName;
  final bool isSaved;
  final bool hasApplied;
  final bool isOwner;
  final int applicationsCount;

  const JobOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.modality,
    required this.experienceLevel,
    required this.createdAt,
    this.companyLogoUrl,
    this.applicationType,
    this.applicationUrl,
    this.deadline,
    this.sportName,
    this.isSaved = false,
    this.hasApplied = false,
    this.isOwner = false,
    this.applicationsCount = 0,
  });

  JobOffer copyWith({
    bool? isSaved,
    bool? hasApplied,
  }) {
    return JobOffer(
      id: id,
      title: title,
      description: description,
      company: company,
      location: location,
      modality: modality,
      experienceLevel: experienceLevel,
      createdAt: createdAt,
      companyLogoUrl: companyLogoUrl,
      applicationType: applicationType,
      applicationUrl: applicationUrl,
      deadline: deadline,
      sportName: sportName,
      isSaved: isSaved ?? this.isSaved,
      hasApplied: hasApplied ?? this.hasApplied,
      isOwner: isOwner,
      applicationsCount: applicationsCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        company,
        location,
        modality,
        experienceLevel,
        createdAt,
        companyLogoUrl,
        applicationType,
        applicationUrl,
        deadline,
        sportName,
        isSaved,
        hasApplied,
        isOwner,
        applicationsCount,
      ];
}
