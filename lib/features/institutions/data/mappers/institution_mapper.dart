import '../../domain/entities/institution.dart';
import '../../models/institution_model.dart';

class InstitutionMapper {
  // Convertir InstitutionModel en Institution (entité de domaine)
  static Institution toEntity(InstitutionModel model) {
    return Institution(
      id: model.id,
      name: model.name,
      description: model.description,
      logoUrl: model.logoUrl,
      address: model.address,
      city: model.city,
      country: model.country,
      postalCode: model.postalCode,
      phone: model.phone,
      email: model.email,
      website: model.website,
      type: model.type,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      studentCount: model.studentCount,
      teacherCount: model.teacherCount,
      programs: model.programs,
      facilities: model.facilities,
    );
  }

  // Convertir une liste de InstitutionModel en liste de Institution
  static List<Institution> toEntityList(List<InstitutionModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  // Convertir Institution en InstitutionModel
  static InstitutionModel toModel(Institution entity) {
    return InstitutionModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      logoUrl: entity.logoUrl,
      address: entity.address,
      city: entity.city,
      country: entity.country,
      postalCode: entity.postalCode,
      phone: entity.phone,
      email: entity.email,
      website: entity.website,
      type: entity.type,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      studentCount: entity.studentCount,
      teacherCount: entity.teacherCount,
      programs: entity.programs,
      facilities: entity.facilities,
    );
  }

  // Mettre à jour un InstitutionModel existant avec les valeurs d'une Institution
  static InstitutionModel updateModel(InstitutionModel model, Institution entity) {
    return model.copyWith(
      name: entity.name,
      description: entity.description,
      logoUrl: entity.logoUrl,
      address: entity.address,
      city: entity.city,
      country: entity.country,
      postalCode: entity.postalCode,
      phone: entity.phone,
      email: entity.email,
      website: entity.website,
      type: entity.type,
      isActive: entity.isActive,
      studentCount: entity.studentCount,
      teacherCount: entity.teacherCount,
      programs: entity.programs,
      facilities: entity.facilities,
    );
  }
}
