import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../domain/entities/user_role.dart';
import '../bloc/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _selectedRole = UserRole.cashier;
  var _isFormValid = false;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateFormValidity);
    _passwordController.addListener(_updateFormValidity);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateFormValidity() {
    final valid = _emailRegex.hasMatch(_emailController.text) &&
        _passwordController.text.isNotEmpty;
    if (valid != _isFormValid) setState(() => _isFormValid = valid);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeType = context.read<ThemeCubit>().state.themeType;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.appName, style: theme.textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(AppStrings.tagline, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 48),
                  Semantics(
                    label: AppStrings.email,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: AppStrings.email),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) {
                        if (value == null || value.isEmpty) return AppStrings.emailRequired;
                        if (!_emailRegex.hasMatch(value)) return AppStrings.emailInvalid;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: AppStrings.password,
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: AppStrings.password),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) { if (_isFormValid) _submit(); },
                      validator: (value) {
                        if (value == null || value.isEmpty) return AppStrings.passwordRequired;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppStrings.role, style: theme.textTheme.labelSmall),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      label: AppStrings.role,
                      child: SegmentedButton<UserRole>(
                        segments: const [
                          ButtonSegment(value: UserRole.cashier, label: Text(AppStrings.roleCashier)),
                          ButtonSegment(value: UserRole.manager, label: Text(AppStrings.roleManager)),
                          ButtonSegment(value: UserRole.admin, label: Text(AppStrings.roleAdmin)),
                        ],
                        selected: {_selectedRole},
                        onSelectionChanged: (selected) =>
                            setState(() => _selectedRole = selected.first),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppStrings.error(themeType, state.failure.message))),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isFormValid && !isLoading ? _submit : null,
                          child: isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(AppStrings.login),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
