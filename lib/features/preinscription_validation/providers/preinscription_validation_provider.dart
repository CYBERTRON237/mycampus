import 'package:flutter/foundation.dart';
import 'package:mycampus/features/preinscription_validation/models/preinscription_validation_model.dart';
import 'package:mycampus/features/preinscription_validation/services/preinscription_validation_repository.dart';

class PreinscriptionValidationProvider extends ChangeNotifier {
  final PreinscriptionValidationRepository _repository;
  
  PreinscriptionValidationProvider(this._repository);

  // État
  List<PreinscriptionValidationModel> _preinscriptions = [];
  List<PreinscriptionValidationModel> _filteredPreinscriptions = [];
  ValidationStatsModel? _stats;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  String _searchQuery = '';
  String _selectedFaculty = 'Toutes';
  String _selectedStatus = 'Toutes';
  String _selectedPaymentStatus = 'Toutes';

  // Getters
  List<PreinscriptionValidationModel> get preinscriptions => _filteredPreinscriptions;
  List<PreinscriptionValidationModel> get allPreinscriptions => _preinscriptions;
  ValidationStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedFaculty => _selectedFaculty;
  String get selectedStatus => _selectedStatus;
  String get selectedPaymentStatus => _selectedPaymentStatus;

  // Getters pour les statistiques
  int get pendingCount => _stats?.pendingValidation ?? 0;
  int get withUserAccountCount => _stats?.withUserAccount ?? 0;
  int get totalCount => _preinscriptions.length;
  
  // Getter pour vérifier si des filtres sont actifs
  bool get hasActiveFilters => 
      _searchQuery.isNotEmpty || 
      _selectedFaculty != 'Toutes' || 
      _selectedStatus != 'Toutes' || 
      _selectedPaymentStatus != 'Toutes';

  // Méthodes
  Future<void> loadPendingPreinscriptions() async {
    _setLoading(true);
    _error = null;
    
    try {
      _preinscriptions = await _repository.getPendingPreinscriptions();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await _repository.getValidationStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> validatePreinscription(int preinscriptionId, String comments) async {
    _setProcessing(true);
    _error = null;
    
    try {
      final result = await _repository.validatePreinscription(preinscriptionId, comments);
      
      // Mettre à jour la préinscription localement
      final index = _preinscriptions.indexWhere((p) => p.id == preinscriptionId);
      if (index != -1) {
        // Créer une copie mise à jour
        final updatedPreinscription = PreinscriptionValidationModel(
          id: _preinscriptions[index].id,
          uuid: _preinscriptions[index].uuid,
          uniqueCode: _preinscriptions[index].uniqueCode,
          faculty: _preinscriptions[index].faculty,
          lastName: _preinscriptions[index].lastName,
          firstName: _preinscriptions[index].firstName,
          middleName: _preinscriptions[index].middleName,
          dateOfBirth: _preinscriptions[index].dateOfBirth,
          isBirthDateOnCertificate: _preinscriptions[index].isBirthDateOnCertificate,
          placeOfBirth: _preinscriptions[index].placeOfBirth,
          gender: _preinscriptions[index].gender,
          cniNumber: _preinscriptions[index].cniNumber,
          residenceAddress: _preinscriptions[index].residenceAddress,
          maritalStatus: _preinscriptions[index].maritalStatus,
          phoneNumber: _preinscriptions[index].phoneNumber,
          email: _preinscriptions[index].email,
          firstLanguage: _preinscriptions[index].firstLanguage,
          professionalSituation: _preinscriptions[index].professionalSituation,
          previousDiploma: _preinscriptions[index].previousDiploma,
          previousInstitution: _preinscriptions[index].previousInstitution,
          graduationYear: _preinscriptions[index].graduationYear,
          graduationMonth: _preinscriptions[index].graduationMonth,
          desiredProgram: _preinscriptions[index].desiredProgram,
          studyLevel: _preinscriptions[index].studyLevel,
          specialization: _preinscriptions[index].specialization,
          seriesBac: _preinscriptions[index].seriesBac,
          bacYear: _preinscriptions[index].bacYear,
          bacCenter: _preinscriptions[index].bacCenter,
          bacMention: _preinscriptions[index].bacMention,
          gpaScore: _preinscriptions[index].gpaScore,
          rankInClass: _preinscriptions[index].rankInClass,
          birthCertificatePath: _preinscriptions[index].birthCertificatePath,
          cniPath: _preinscriptions[index].cniPath,
          diplomaPath: _preinscriptions[index].diplomaPath,
          transcriptPath: _preinscriptions[index].transcriptPath,
          photoPath: _preinscriptions[index].photoPath,
          recommendationLetterPath: _preinscriptions[index].recommendationLetterPath,
          motivationLetterPath: _preinscriptions[index].motivationLetterPath,
          medicalCertificatePath: _preinscriptions[index].medicalCertificatePath,
          otherDocumentsPath: _preinscriptions[index].otherDocumentsPath,
          parentName: _preinscriptions[index].parentName,
          parentPhone: _preinscriptions[index].parentPhone,
          parentEmail: _preinscriptions[index].parentEmail,
          parentOccupation: _preinscriptions[index].parentOccupation,
          parentAddress: _preinscriptions[index].parentAddress,
          parentRelationship: _preinscriptions[index].parentRelationship,
          parentIncomeLevel: _preinscriptions[index].parentIncomeLevel,
          paymentMethod: _preinscriptions[index].paymentMethod,
          paymentReference: _preinscriptions[index].paymentReference,
          paymentAmount: _preinscriptions[index].paymentAmount,
          paymentCurrency: _preinscriptions[index].paymentCurrency,
          paymentDate: _preinscriptions[index].paymentDate,
          paymentStatus: _preinscriptions[index].paymentStatus,
          paymentProofPath: _preinscriptions[index].paymentProofPath,
          scholarshipRequested: _preinscriptions[index].scholarshipRequested,
          scholarshipType: _preinscriptions[index].scholarshipType,
          financialAidAmount: _preinscriptions[index].financialAidAmount,
          status: 'accepted', // Mettre à jour le statut
          documentsStatus: _preinscriptions[index].documentsStatus,
          reviewPriority: _preinscriptions[index].reviewPriority,
          reviewedBy: _preinscriptions[index].reviewedBy,
          reviewDate: DateTime.now().toIso8601String(),
          reviewComments: comments,
          rejectionReason: _preinscriptions[index].rejectionReason,
          interviewRequired: _preinscriptions[index].interviewRequired,
          interviewDate: _preinscriptions[index].interviewDate,
          interviewLocation: _preinscriptions[index].interviewLocation,
          interviewType: _preinscriptions[index].interviewType,
          interviewResult: _preinscriptions[index].interviewResult,
          interviewNotes: _preinscriptions[index].interviewNotes,
          admissionNumber: result['admission_number'],
          admissionDate: DateTime.now().toIso8601String(),
          registrationDeadline: _preinscriptions[index].registrationDeadline,
          registrationCompleted: _preinscriptions[index].registrationCompleted,
          studentId: result['user_id'],
          batchNumber: _preinscriptions[index].batchNumber,
          contactPreference: _preinscriptions[index].contactPreference,
          marketingConsent: _preinscriptions[index].marketingConsent,
          dataProcessingConsent: _preinscriptions[index].dataProcessingConsent,
          newsletterSubscription: _preinscriptions[index].newsletterSubscription,
          ipAddress: _preinscriptions[index].ipAddress,
          userAgent: _preinscriptions[index].userAgent,
          deviceType: _preinscriptions[index].deviceType,
          browserInfo: _preinscriptions[index].browserInfo,
          osInfo: _preinscriptions[index].osInfo,
          locationCountry: _preinscriptions[index].locationCountry,
          locationCity: _preinscriptions[index].locationCity,
          notes: _preinscriptions[index].notes,
          adminNotes: _preinscriptions[index].adminNotes,
          internalComments: _preinscriptions[index].internalComments,
          specialNeeds: _preinscriptions[index].specialNeeds,
          medicalConditions: _preinscriptions[index].medicalConditions,
          submissionDate: _preinscriptions[index].submissionDate,
          lastUpdated: DateTime.now().toIso8601String(),
          createdAt: _preinscriptions[index].createdAt,
          updatedAt: DateTime.now().toIso8601String(),
          deletedAt: _preinscriptions[index].deletedAt,
          applicantEmail: _preinscriptions[index].applicantEmail,
          applicantPhone: _preinscriptions[index].applicantPhone,
          relationship: _preinscriptions[index].relationship,
          isProcessed: true,
          processedAt: DateTime.now().toIso8601String(),
          userId: _preinscriptions[index].userId,
          userEmail: _preinscriptions[index].userEmail,
          userRole: 'student', // Mettre à jour le rôle
          hasUserAccount: _preinscriptions[index].hasUserAccount,
          canBeValidated: false, // Ne peut plus être validée
        );
        
        _preinscriptions[index] = updatedPreinscription;
        _applyFilters();
      }
      
      // Recharger les statistiques
      await loadStats();
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  Future<bool> rejectPreinscription(int preinscriptionId, String rejectionReason) async {
    _setProcessing(true);
    _error = null;
    
    try {
      final success = await _repository.rejectPreinscription(preinscriptionId, rejectionReason);
      
      if (success) {
        // Mettre à jour la préinscription localement
        final index = _preinscriptions.indexWhere((p) => p.id == preinscriptionId);
        if (index != -1) {
          final updatedPreinscription = PreinscriptionValidationModel(
            id: _preinscriptions[index].id,
            uuid: _preinscriptions[index].uuid,
            uniqueCode: _preinscriptions[index].uniqueCode,
            faculty: _preinscriptions[index].faculty,
            lastName: _preinscriptions[index].lastName,
            firstName: _preinscriptions[index].firstName,
            middleName: _preinscriptions[index].middleName,
            dateOfBirth: _preinscriptions[index].dateOfBirth,
            isBirthDateOnCertificate: _preinscriptions[index].isBirthDateOnCertificate,
            placeOfBirth: _preinscriptions[index].placeOfBirth,
            gender: _preinscriptions[index].gender,
            cniNumber: _preinscriptions[index].cniNumber,
            residenceAddress: _preinscriptions[index].residenceAddress,
            maritalStatus: _preinscriptions[index].maritalStatus,
            phoneNumber: _preinscriptions[index].phoneNumber,
            email: _preinscriptions[index].email,
            firstLanguage: _preinscriptions[index].firstLanguage,
            professionalSituation: _preinscriptions[index].professionalSituation,
            previousDiploma: _preinscriptions[index].previousDiploma,
            previousInstitution: _preinscriptions[index].previousInstitution,
            graduationYear: _preinscriptions[index].graduationYear,
            graduationMonth: _preinscriptions[index].graduationMonth,
            desiredProgram: _preinscriptions[index].desiredProgram,
            studyLevel: _preinscriptions[index].studyLevel,
            specialization: _preinscriptions[index].specialization,
            seriesBac: _preinscriptions[index].seriesBac,
            bacYear: _preinscriptions[index].bacYear,
            bacCenter: _preinscriptions[index].bacCenter,
            bacMention: _preinscriptions[index].bacMention,
            gpaScore: _preinscriptions[index].gpaScore,
            rankInClass: _preinscriptions[index].rankInClass,
            birthCertificatePath: _preinscriptions[index].birthCertificatePath,
            cniPath: _preinscriptions[index].cniPath,
            diplomaPath: _preinscriptions[index].diplomaPath,
            transcriptPath: _preinscriptions[index].transcriptPath,
            photoPath: _preinscriptions[index].photoPath,
            recommendationLetterPath: _preinscriptions[index].recommendationLetterPath,
            motivationLetterPath: _preinscriptions[index].motivationLetterPath,
            medicalCertificatePath: _preinscriptions[index].medicalCertificatePath,
            otherDocumentsPath: _preinscriptions[index].otherDocumentsPath,
            parentName: _preinscriptions[index].parentName,
            parentPhone: _preinscriptions[index].parentPhone,
            parentEmail: _preinscriptions[index].parentEmail,
            parentOccupation: _preinscriptions[index].parentOccupation,
            parentAddress: _preinscriptions[index].parentAddress,
            parentRelationship: _preinscriptions[index].parentRelationship,
            parentIncomeLevel: _preinscriptions[index].parentIncomeLevel,
            paymentMethod: _preinscriptions[index].paymentMethod,
            paymentReference: _preinscriptions[index].paymentReference,
            paymentAmount: _preinscriptions[index].paymentAmount,
            paymentCurrency: _preinscriptions[index].paymentCurrency,
            paymentDate: _preinscriptions[index].paymentDate,
            paymentStatus: _preinscriptions[index].paymentStatus,
            paymentProofPath: _preinscriptions[index].paymentProofPath,
            scholarshipRequested: _preinscriptions[index].scholarshipRequested,
            scholarshipType: _preinscriptions[index].scholarshipType,
            financialAidAmount: _preinscriptions[index].financialAidAmount,
            status: 'rejected', // Mettre à jour le statut
            documentsStatus: _preinscriptions[index].documentsStatus,
            reviewPriority: _preinscriptions[index].reviewPriority,
            reviewedBy: _preinscriptions[index].reviewedBy,
            reviewDate: DateTime.now().toIso8601String(),
            reviewComments: _preinscriptions[index].reviewComments,
            rejectionReason: rejectionReason,
            interviewRequired: _preinscriptions[index].interviewRequired,
            interviewDate: _preinscriptions[index].interviewDate,
            interviewLocation: _preinscriptions[index].interviewLocation,
            interviewType: _preinscriptions[index].interviewType,
            interviewResult: _preinscriptions[index].interviewResult,
            interviewNotes: _preinscriptions[index].interviewNotes,
            admissionNumber: _preinscriptions[index].admissionNumber,
            admissionDate: _preinscriptions[index].admissionDate,
            registrationDeadline: _preinscriptions[index].registrationDeadline,
            registrationCompleted: _preinscriptions[index].registrationCompleted,
            studentId: _preinscriptions[index].studentId,
            batchNumber: _preinscriptions[index].batchNumber,
            contactPreference: _preinscriptions[index].contactPreference,
            marketingConsent: _preinscriptions[index].marketingConsent,
            dataProcessingConsent: _preinscriptions[index].dataProcessingConsent,
            newsletterSubscription: _preinscriptions[index].newsletterSubscription,
            ipAddress: _preinscriptions[index].ipAddress,
            userAgent: _preinscriptions[index].userAgent,
            deviceType: _preinscriptions[index].deviceType,
            browserInfo: _preinscriptions[index].browserInfo,
            osInfo: _preinscriptions[index].osInfo,
            locationCountry: _preinscriptions[index].locationCountry,
            locationCity: _preinscriptions[index].locationCity,
            notes: _preinscriptions[index].notes,
            adminNotes: _preinscriptions[index].adminNotes,
            internalComments: _preinscriptions[index].internalComments,
            specialNeeds: _preinscriptions[index].specialNeeds,
            medicalConditions: _preinscriptions[index].medicalConditions,
            submissionDate: _preinscriptions[index].submissionDate,
            lastUpdated: DateTime.now().toIso8601String(),
            createdAt: _preinscriptions[index].createdAt,
            updatedAt: DateTime.now().toIso8601String(),
            deletedAt: _preinscriptions[index].deletedAt,
            applicantEmail: _preinscriptions[index].applicantEmail,
            applicantPhone: _preinscriptions[index].applicantPhone,
            relationship: _preinscriptions[index].relationship,
            isProcessed: true,
            processedAt: DateTime.now().toIso8601String(),
            userId: _preinscriptions[index].userId,
            userEmail: _preinscriptions[index].userEmail,
            userRole: _preinscriptions[index].userRole,
            hasUserAccount: _preinscriptions[index].hasUserAccount,
            canBeValidated: false, // Ne peut plus être validée
          );
          
          _preinscriptions[index] = updatedPreinscription;
          _applyFilters();
        }
        
        // Recharger les statistiques
        await loadStats();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setFacultyFilter(String faculty) {
    _selectedFaculty = faculty;
    _applyFilters();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void setPaymentStatusFilter(String paymentStatus) {
    _selectedPaymentStatus = paymentStatus;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedFaculty = 'Toutes';
    _selectedStatus = 'Toutes';
    _selectedPaymentStatus = 'Toutes';
    _applyFilters();
  }

  void _applyFilters() {
    _filteredPreinscriptions = _preinscriptions.where((preinscription) {
      // Filtre de recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch = 
            preinscription.fullName.toLowerCase().contains(query) ||
            preinscription.email.toLowerCase().contains(query) ||
            preinscription.uniqueCode.toLowerCase().contains(query) ||
            preinscription.phoneNumber.contains(query);
        if (!matchesSearch) return false;
      }

      // Filtre de faculté
      if (_selectedFaculty != 'Toutes' && preinscription.faculty != _selectedFaculty) {
        return false;
      }

      // Filtre de statut
      if (_selectedStatus != 'Toutes' && preinscription.status != _selectedStatus) {
        return false;
      }

      // Filtre de statut de paiement
      if (_selectedPaymentStatus != 'Toutes' && preinscription.paymentStatus != _selectedPaymentStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([
      loadPendingPreinscriptions(),
      loadStats(),
    ]);
  }
}
