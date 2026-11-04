import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  // Retry otomatis dimatikan: layar error sudah punya tombol "Coba lagi".
  runApp(
    ProviderScope(retry: (_, _) => null, child: const DirekapinApp()),
  );
}
