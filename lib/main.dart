// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/shared/config/supabase_config.dart';
import 'app.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

  };
  _startApp();
}

Future<void> _startApp() async {
  try {
     await Supabase.initialize(
       url: SupabaseConfig.url,
       anonKey: SupabaseConfig.anonKey,
     );
    runApp(
      ProviderScope(
        child: AppWidget(),
      ),
    );
  } catch (e) {

    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: _BackendErrorScreen(
            error: e,
            onRetry: _startApp,
          ),
        ),
      ),
    ));
  }
}

// Simple fallback error screen with retry button
class _BackendErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _BackendErrorScreen({required this.error, required this.onRetry});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
        const SizedBox(height: 16),
        Text(
          'Failed to initialize backend',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SelectableText(  // Allows text selection for debugging
          error.toString(),
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
        TextButton(
          onPressed: () => _showSupportDialog(context),
          child: const Text('Contact Support'),
        ),
      ],
    );
  }
  
  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('Please email support@vpay.com with the error details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
