import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:otp/otp.dart';
import 'package:base32/base32.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OTPService {
  static final OTPService _instance = OTPService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _secretKey = '2fa_secret_key';

  factory OTPService() {
    return _instance;
  }

  OTPService._internal();

  // Générer une clé secrète pour l'utilisateur
  Future<String> generateSecretKey() async {
    final random = Random.secure();
    final values = Uint8List.fromList(
        List<int>.generate(20, (i) => random.nextInt(256)));
    final secret = base32.encode(values);
    await _secureStorage.write(key: _secretKey, value: secret);
    return secret;
  }

  // Récupérer la clé secrète
  Future<String?> getSecretKey() async {
    return await _secureStorage.read(key: _secretKey);
  }

  // Générer l'URL pour le QR Code
  String getOtpAuthUrl(String email, String secret) {
    const issuer = 'MyCampus';
    final encodedIssuer = Uri.encodeComponent(issuer);
    final encodedEmail = Uri.encodeComponent(email);
    return 'otpauth://totp/$encodedIssuer:$encodedEmail?secret=$secret&issuer=$encodedIssuer&algorithm=SHA1';
  }

  // Vérifier le code OTP saisi
  Future<bool> verifyOTP(String code) async {
    final secret = await getSecretKey();
    if (secret == null) return false;

    final now = DateTime.now();
    final generatedCode = OTP.generateTOTPCodeString(
      secret,
      now.millisecondsSinceEpoch,
      algorithm: Algorithm.SHA1,
    );
    
    return generatedCode == code;
  }

  // Activer ou désactiver la 2FA
  Future<void> set2FAEnabled(bool enabled) async {
    if (!enabled) {
      await _secureStorage.delete(key: _secretKey);
    }
    await _secureStorage.write(key: '2fa_enabled', value: enabled.toString());
  }

  // Vérifier si la 2FA est activée
  Future<bool> is2FAEnabled() async {
    final enabled = await _secureStorage.read(key: '2fa_enabled');
    return enabled == 'true';
  }

  // Générer un code OTP temporaire (pour les tests)
  String generateCurrentCode(String secret) {
    return OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      algorithm: Algorithm.SHA1,
    );
  }

  // Générer des codes de secours
  List<String> generateBackupCodes({int count = 5}) {
    final random = Random.secure();
    return List.generate(count, (_) => random.nextInt(1000000).toString().padLeft(6, '0'));
  }
}
