import 'package:flutter/material.dart';
import 'package:mycampus/features/preinscription/presentation/pages/preinscription_form_page.dart';
import 'package:mycampus/features/preinscription/presentation/pages/preinscription_home_page.dart';
import 'package:mycampus/features/preinscription/presentation/pages/preinscription_info_page.dart';

class PreinscriptionRoutes {
  static const String preinscriptionHome = '/preinscription';
  static const String preinscriptionInfo = '/preinscription/info';
  static const String preinscriptionForm = '/preinscription/form';
  static const String preinscriptionUy1 = '/preinscription/uy1';
  static const String preinscriptionFalsh = '/preinscription/falsh';
  static const String preinscriptionFs = '/preinscription/fs';
  static const String preinscriptionFse = '/preinscription/fse';
  static const String preinscriptionFmsb = '/preinscription/fmsb';
  static const String preinscriptionIut = '/preinscription/iut';
  static const String preinscriptionEnspy = '/preinscription/enspy';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      preinscriptionHome: (context) => PreinscriptionHomePage(),
      preinscriptionInfo: (context) => const PreinscriptionInfoPage(),
      '$preinscriptionForm/:type': (context) {
        final type = ModalRoute.of(context)!.settings.arguments as String? ?? 
                    (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?)?['type'] ??
                    'Général';
        return PreinscriptionFormPage(formationType: type);
      },
    };
  }
  
  // Fonction utilitaire pour naviguer vers la page de préinscription
  static void navigateToPreinscriptionForm(BuildContext context, String type) {
    Navigator.pushNamed(
      context, 
      preinscriptionForm,
      arguments: {'type': type},
    );
  }
  
  // Fonction utilitaire pour naviguer vers la page d'informations
  static void navigateToPreinscriptionInfo(BuildContext context) {
    Navigator.pushNamed(context, preinscriptionInfo);
  }
  
  // Fonction pour obtenir toutes les routes avec leurs noms
  static Map<String, String> getRouteNames() {
    return {
      preinscriptionHome: 'Préinscription',
      preinscriptionForm: 'Formulaire de préinscription',
      preinscriptionInfo: 'Informations de préinscription',
      preinscriptionUy1: 'Préinscription UY1',
      preinscriptionFalsh: 'Préinscription FALSH',
      preinscriptionFs: 'Préinscription Faculté des Sciences',
      preinscriptionFse: 'Préinscription Faculté des Sciences de l\'Éducation',
      preinscriptionFmsb: 'Préinscription Faculté de Médecine et des Sciences Biomédicales',
      preinscriptionIut: 'Préinscription Institut Universitaire de Technologies du Bois',
      preinscriptionEnspy: 'Préinscription École Nationale Supérieure Polytechnique de Yaoundé',
    };
  }
  
  // Fonction utilitaire pour naviguer vers la page de préinscription UY1
  static void navigateToUy1Preinscription(BuildContext context) {
    Navigator.pushNamed(context, preinscriptionUy1);
  }
  
  // Fonction utilitaire pour naviguer vers la page de préinscription FALSH
  static void navigateToFalshPreinscription(BuildContext context) {
    debugPrint('navigateToFalshPreinscription called');
    debugPrint('Navigating to route: $preinscriptionFalsh');
    Navigator.pushNamed(context, preinscriptionFalsh);
  }
  
  // Fonction utilitaire pour naviguer vers la page de préinscription FS
  static void navigateToFsPreinscription(BuildContext context) {
    debugPrint('navigateToFsPreinscription called');
    debugPrint('Navigating to route: $preinscriptionFs');
    Navigator.pushNamed(context, preinscriptionFs);
  }
  
  // Fonction utilitaire pour naviguer vers la page de préinscription FSE
  static void navigateToFsePreinscription(BuildContext context) {
    debugPrint('navigateToFsePreinscription called');
    debugPrint('Navigating to route: $preinscriptionFse');
    Navigator.pushNamed(context, preinscriptionFse);
  }
  
  // Fonction utilitaire pour naviguer vers la page de préinscription FMSB
  static void navigateToFmsbPreinscription(BuildContext context) {
    debugPrint('navigateToFmsbPreinscription called');
    debugPrint('Navigating to route: $preinscriptionFmsb');
    Navigator.pushNamed(context, preinscriptionFmsb);
  }
  
  // Fonction utilitaire pour naviguer vers la page de préinscription IUT
  static void navigateToIutPreinscription(BuildContext context) {
    debugPrint('navigateToIutPreinscription called');
    debugPrint('Navigating to route: $preinscriptionIut');
    Navigator.pushNamed(context, preinscriptionIut);
  }
  
  // Fonction utilitaire pour naviguer vers la page de préinscription ENSPY
  static void navigateToEnspyPreinscription(BuildContext context) {
    debugPrint('navigateToEnspyPreinscription called');
    debugPrint('Navigating to route: $preinscriptionEnspy');
    Navigator.pushNamed(context, preinscriptionEnspy);
  }
}
