import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_cubit.dart';
import 'presentation/auth/bloc/auth_cubit.dart';

void main() {
  configureDependencies();
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
