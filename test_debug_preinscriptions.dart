import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'lib/features/preinscriptions_management/providers/preinscription_provider.dart';
import 'lib/features/preinscriptions_management/presentation/pages/preinscription_home_page.dart';

void main() {
  runApp(const DebugApp());
}

class DebugApp extends StatelessWidget {
  const DebugApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🚀 [MAIN DEBUG] Démarrage de l\'application de debug');
    }
    
    return ChangeNotifierProvider(
      create: (context) {
        if (kDebugMode) {
          print('🏭 [MAIN DEBUG] Création du PreinscriptionProvider');
        }
        return PreinscriptionProvider();
      },
      child: MaterialApp(
        title: 'Debug Préinscriptions',
        debugShowCheckedModeBanner: true,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const DebugHomePage(),
      ),
    );
  }
}

class DebugHomePage extends StatefulWidget {
  const DebugHomePage({Key? key}) : super(key: key);

  @override
  State<DebugHomePage> createState() => _DebugHomePageState();
}

class _DebugHomePageState extends State<DebugHomePage> {
  @override
  void initState() {
    super.initState();
    
    if (kDebugMode) {
      print('🏠 [MAIN DEBUG] DebugHomePage initState');
    }
    
    // Initialiser le provider après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        print('🏠 [MAIN DEBUG] Initialisation du provider depuis DebugHomePage');
      }
      context.read<PreinscriptionProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🎨 [MAIN DEBUG] DebugHomePage build');
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Module Préinscriptions'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header de debug
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🐛 MODULE DE DEBUG',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Consultez la console pour voir les traces de debug',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Consumer<PreinscriptionProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loading: ${provider.isLoading}',
                          style: const TextStyle(color: Colors.yellow),
                        ),
                        Text(
                          'Error: ${provider.error ?? "None"}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        Text(
                          'Preinscriptions: ${provider.preinscriptions.length}',
                          style: const TextStyle(color: Colors.green),
                        ),
                        Text(
                          'Stats: ${provider.stats}',
                          style: const TextStyle(color: Colors.cyan),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (kDebugMode) {
                          print('🔄 [MAIN DEBUG] Bouton refresh cliqué');
                        }
                        context.read<PreinscriptionProvider>().fetchPreinscriptions(refresh: true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text('Refresh'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (kDebugMode) {
                          print('📊 [MAIN DEBUG] Bouton fetchStats cliqué');
                        }
                        context.read<PreinscriptionProvider>().fetchStats();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text('Fetch Stats'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Le module de gestion des préinscriptions
          const Expanded(
            child: PreinscriptionHomePage(),
          ),
        ],
      ),
    );
  }
}
