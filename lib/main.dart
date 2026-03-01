import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_cubit.dart';
import 'data/drift/app_database.dart';
import 'data/repositories/drift_product_repository.dart';
import 'data/repositories/drift_store_repository.dart';
import 'data/sync/sync_engine.dart';
import 'presentation/auth/bloc/auth_cubit.dart';
import 'presentation/store/bloc/store_cubit.dart';
import 'presentation/sync/bloc/sync_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  configureDependencies();

  final db = getIt<AppDatabase>();
  await seedStores(db.storeDao);
  await seedProducts(db.productDao);

  getIt<SyncEngine>().start();

  runApp(const TalonApp());
}

class TalonApp extends StatelessWidget {
  const TalonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider.value(value: getIt<AuthCubit>()),
        BlocProvider.value(value: getIt<StoreCubit>()),
        BlocProvider(create: (_) => SyncCubit(getIt<SyncEngine>())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: themeState.themeData,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
