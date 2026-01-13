import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:otp/otp.dart';
import 'package:base32/base32.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OTPService {
  static final OTPService _instance = OTPService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Clés de stockage sécurisé
  static const String _secretKey = '2fa_secret_key';
  static const String _otpEnabledKey = '2fa_enabled';
  static const String _otpBackupCodesKey = '2fa_backup_codes';
  static const int _backupCodeCount = 8;
  static const int _secretKeyLength = 20;
  static const int _otpTimeStep = 30; // 30 secondes par défaut (standard TOTP)

  factory OTPService() => _instance;
  OTPService._internal();

  // Générer une clé secrète sécurisée
  Future<String> generateSecretKey() async {
    try {
      final random = Random.secure();
      final values = Uint8List.fromList(
        List.generate(_secretKeyLength, (i) => random.nextInt(256)),
      );
      final secret = base32.encode(values);
      await _secureStorage.write(key: _secretKey, value: secret);
      return secret;
    } catch (e) {
      throw Exception('Erreur lors de la génération de la clé secrète: $e');
    }
  }

  // Récupérer la clé secrète
  Future<String?> getSecretKey() async {
    try {
      return await _secureStorage.read(key: _secretKey);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la clé secrète: $e');
    }
  }

  // Vérifier si la 2FA est activée
  Future<bool> is2FAEnabled() async {
    try {
      return await _secureStorage.read(key: _otpEnabledKey) == 'true';
    } catch (e) {
      return false;
    }
  }

  // Activer/désactiver la 2FA
  Future<void> set2FAEnabled(bool enabled) async {
    try {
      if (enabled) {
        // S'assurer qu'une clé secrète existe
        if (await getSecretKey() == null) {
          await generateSecretKey();
        }
        // Générer des codes de secours uniquement si on active
        await generateBackupCodes();
      } else {
        // Ne supprimer la clé que si on désactive explicitement
        await _secureStorage.delete(key: _secretKey);
        await _secureStorage.delete(key: _otpBackupCodesKey);
      }
      await _secureStorage.write(key: _otpEnabledKey, value: enabled.toString());
    } catch (e) {
      throw Exception('Erreur lors de la modification de l\'état 2FA: $e');
    }
  }

  // Vérifier le code OTP avec une fenêtre de temps
  Future<bool> verifyOTP(String code, {int window = 1}) async {
    try {
      if (code.isEmpty || code.length != 6) return false; // Code OTP standard à 6 chiffres
      
      final secret = await getSecretKey();
      if (secret == null) return false;

      final now = DateTime.now();
      // Vérifier le code actuel et les fenêtres précédentes/suivantes
      for (int i = -window; i <= window; i++) {
        final time = now.add(Duration(seconds: _otpTimeStep * i));
        final otp = OTP.generateTOTPCodeString(
          secret,
          time.millisecondsSinceEpoch,
          algorithm: Algorithm.SHA1,
          isGoogle: true,
        );
        
        if (otp == code) return true;
      }
    } catch (e) {
      // En cas d'erreur, on considère le code comme invalide
    }
    return false;
  }

  // Vérifier un code de secours
  Future<bool> verifyBackupCode(String code) async {
    try {
      if (code.isEmpty) return false;
      
      final codes = await getBackupCodes();
      final normalizedCode = code.trim();
      
      if (codes.contains(normalizedCode)) {
        await _removeBackupCode(normalizedCode);
        return true;
      }
    } catch (e) {
      // Erreur de lecture/écriture du stockage
    }
    return false;
  }

  // Supprimer un code de secours après utilisation
  Future<void> _removeBackupCode(String code) async {
    final codes = await getBackupCodes();
    codes.remove(code);
    await _secureStorage.write(
      key: _otpBackupCodesKey, 
      value: jsonEncode(codes)
    );
  }

  // Générer des codes de secours sécurisés
  Future<List<String>> generateBackupCodes() async {
    try {
      final random = Random.secure();
      final codes = List.generate(_backupCodeCount, (_) => 
        '${random.nextInt(9000) + 1000}-${random.nextInt(9000) + 1000}');
      
      await _secureStorage.write(
        key: _otpBackupCodesKey, 
        value: jsonEncode(codes)
      );
      return codes;
    } catch (e) {
      throw Exception('Erreur lors de la génération des codes de secours: $e');
    }
  }

  // Récupérer les codes de secours
  Future<List<String>> getBackupCodes() async {
    try {
      final codesJson = await _secureStorage.read(key: _otpBackupCodesKey);
      if (codesJson == null) return [];
      
      final List<dynamic> codes = jsonDecode(codesJson);
      return codes.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  // Générer l'URL pour le QR Code (format standard otpauth)
  String getOtpAuthUrl({
    required String email,
    required String secret,
    String issuer = 'MyCampus',
    int digits = 6,
    int period = 30,
  }) {
    return 'otpauth://totp/$issuer:$email?secret=$secret&issuer=$issuer&digits=$digits&period=$period';
  }

  // Générer un code OTP actuel (pour le débogage)
  Future<String?> generateCurrentCode() async {
    try {
      final secret = await getSecretKey();
      if (secret == null) return null;
      
      return OTP.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
    } catch (e) {
      return null;
    }
  }

  // Nettoyage complet
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw Exception('Erreur lors du nettoyage du stockage OTP: $e');
    }
  }
}