import 'dart:convert';
import 'lib/features/profile/models/profile_model.dart';

void main() {
  // Test data from API response
  String jsonResponse = '''
  {
    "success": true,
    "message": "Préinscription trouvée avec succès",
    "data": {
      "id": 2,
      "uuid": "7e351de3-de64-11f0-905d-68f728e7cdfb",
      "unique_code": "PRE2025176631",
      "faculty": "Faculté des Sciences",
      "last_name": "Ngoumezong tsamo",
      "first_name": "ulrich",
      "middle_name": "Coder",
      "date_of_birth": "2000-01-01",
      "is_birth_date_on_certificate": 1,
      "place_of_birth": "Fongo Tongo",
      "gender": "MASCULIN",
      "cni_number": "543552523",
      "residence_address": "Emana Bonne fontaine",
      "marital_status": "MARIE(E)",
      "phone_number": "693290232",
      "email": "ulrich@gmail.com",
      "first_language": "FRANÇAIS",
      "professional_situation": "EN AUTO-EMPLOI",
      "previous_diploma": "BACCALAUREAT",
      "previous_institution": "Lycee classique de dschang",
      "graduation_year": 2025,
      "graduation_month": "Mai",
      "desired_program": "Simple",
      "study_level": "LICENCE",
      "specialization": null,
      "series_bac": "TI",
      "bac_year": null,
      "bac_center": "Lycla",
      "bac_mention": "BIEN",
      "gpa_score": "2.00",
      "rank_in_class": 1,
      "birth_certificate_path": null,
      "cni_path": null,
      "diploma_path": null,
      "transcript_path": null,
      "photo_path": null,
      "recommendation_letter_path": null,
      "motivation_letter_path": null,
      "medical_certificate_path": null,
      "other_documents_path": null,
      "parent_name": "tsamo pascal",
      "parent_phone": "643734734",
      "parent_email": "pascal@gmail.com",
      "parent_occupation": "Enseignant",
      "parent_address": "dschang",
      "parent_relationship": "PERE",
      "parent_income_level": "MOYEN",
      "payment_method": "MTN_MONEY",
      "payment_reference": "43434234",
      "payment_amount": "10000.00",
      "payment_currency": "XAF",
      "payment_date": null,
      "payment_status": "pending",
      "payment_proof_path": null,
      "scholarship_requested": 1,
      "scholarship_type": "Etude",
      "financial_aid_amount": "300000.00",
      "status": "accepted",
      "documents_status": "pending",
      "review_priority": "NORMAL",
      "reviewed_by": 1,
      "review_date": "2025-12-21 23:41:51",
      "review_comments": "",
      "rejection_reason": null,
      "interview_required": 0,
      "interview_date": null,
      "interview_location": null,
      "interview_type": null,
      "interview_result": null,
      "interview_notes": null,
      "admission_number": "2025008334",
      "admission_date": "2025-12-21 23:41:51",
      "registration_deadline": null,
      "registration_completed": 0,
      "student_id": 42,
      "batch_number": null,
      "contact_preference": null,
      "marketing_consent": 1,
      "data_processing_consent": 1,
      "newsletter_subscription": 1,
      "ip_address": "127.0.0.1",
      "user_agent": "Dart/3.10 (dart:io)",
      "device_type": null,
      "browser_info": null,
      "os_info": null,
      "location_country": null,
      "location_city": null,
      "notes": "RAS",
      "admin_notes": null,
      "internal_comments": null,
      "special_needs": "pas grand chose",
      "medical_conditions": "bonnes",
      "submission_date": "2025-12-21 12:59:24",
      "last_updated": "2025-12-21 23:41:51",
      "created_at": "2025-12-21 12:59:24",
      "updated_at": "2025-12-21 23:41:51",
      "deleted_at": null,
      "applicant_email": null,
      "applicant_phone": null,
      "relationship": "self",
      "is_processed": 0,
      "processed_at": null
    }
  }
  ''';

  try {
    print('=== TESTING JSON PARSING ===');
    
    // Parse JSON
    Map<String, dynamic> json = jsonDecode(jsonResponse);
    Map<String, dynamic> data = json['data'];
    
    print('JSON parsed successfully');
    print('Number of fields: ${data.length}');
    
    // Try to create PreinscriptionDetail
    print('\nCreating PreinscriptionDetail...');
    PreinscriptionDetail preinscription = PreinscriptionDetail.fromJson(data);
    
    print('SUCCESS: PreinscriptionDetail created successfully!');
    print('ID: ${preinscription.id}');
    print('Email: ${preinscription.email}');
    print('Status: ${preinscription.status}');
    print('Scholarship Requested: ${preinscription.scholarshipRequested}');
    print('Interview Required: ${preinscription.interviewRequired}');
    print('Birth Date on Certificate: ${preinscription.isBirthDateOnCertificate}');
    
  } catch (e, stackTrace) {
    print('ERROR: $e');
    print('STACK TRACE: $stackTrace');
  }
}
