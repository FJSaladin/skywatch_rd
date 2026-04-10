import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'features/observations/observation_provider.dart';
import 'features/observations/screens/home_screen.dart';
import 'features/profile/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null); // ← Fechas en español
  runApp(const CieloObsApp());
}

class CieloObsApp extends StatelessWidget {
  const CieloObsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ObservationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title:                    'CieloObs',
        debugShowCheckedModeBanner: false,
        theme:                    AppTheme.darkTheme,
        locale:                   const Locale('es'),
        home:                     const HomeScreen(),
      ),
    );
  }
}