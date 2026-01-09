import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/core/widgets/common_widgets.dart';
import 'package:smart_resource_ai/viewmodels/auth_view_model.dart';
import 'package:smart_resource_ai/views/onboarding/preferences_view.dart';


class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool isLogin = true;

  // Controller'lar
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();

  String? _selectedGender;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          // ✅ AppDimens kullanımı
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.p24,
              vertical: AppDimens.p20
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. HEADER
              const Icon(
                  Icons.auto_awesome,
                  size: 60, // Logo boyutu spesifik kalabilir veya AppDimens'e eklenebilir
                  color: AppColors.primary
              ),
              const SizedBox(height: AppDimens.p20),

              Text(
                isLogin ? l10n.welcomeBack : l10n.joinUs,
                textAlign: TextAlign.center,
                style: AppTextStyles.header,
              ),
              const SizedBox(height: AppDimens.p8),
              Text(
                isLogin ? l10n.loginSubtitle : l10n.registerSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 40), // Geniş boşluklar için AppDimens.p48 veya sabit kalabilir

              // 2. FORM ALANI
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- KAYIT OL ALANLARI ---
                    if (!isLogin) ...[
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _fullNameController,
                              label: l10n.fullName,
                              icon: Icons.person_outline,
                            ),
                          ),
                          const SizedBox(width: AppDimens.p12),
                          Expanded(
                            child: CustomTextField(
                              controller: _nicknameController,
                              label: l10n.nickname,
                              icon: Icons.alternate_email,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.p16),
                      _buildGenderDropdown(l10n),
                      const SizedBox(height: AppDimens.p16),
                    ],

                    // --- STANDART ALANLAR ---
                    CustomTextField(
                        controller: _emailController,
                        label: l10n.emailAddress,
                        icon: Icons.email_outlined
                    ),
                    const SizedBox(height: AppDimens.p16),

                    CustomTextField(
                        controller: _passwordController,
                        label: l10n.password,
                        icon: Icons.lock_outline,
                        isPassword: true
                    ),

                    const SizedBox(height: AppDimens.p24),

                    // --- HATA MESAJI ---
                    if (authViewModel.errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: AppDimens.all12, // ✅
                        margin: const EdgeInsets.only(bottom: AppDimens.p20),
                        decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimens.r12),
                            border: Border.all(color: AppColors.error.withOpacity(0.3))
                        ),
                        child: Text(
                          authViewModel.errorMessage!,
                          style: AppTextStyles.body.copyWith(color: AppColors.error, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // --- BUTON ---
                    CustomButton(
                      text: isLogin ? l10n.login : l10n.signUp,
                      isLoading: authViewModel.isLoading,
                      color: isLogin ? AppColors.primary : AppColors.sportAccent,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          FocusScope.of(context).unfocus();

                          if (isLogin) {
                            await authViewModel.signIn(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                          } else {
                            if (_selectedGender == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.pleaseSelectGender), backgroundColor: AppColors.error)
                              );
                              return;
                            }
                            final success = await authViewModel.signUp(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              fullName: _fullNameController.text.trim(),
                              nickname: _nicknameController.text.trim(),
                              gender: _selectedGender!, // 'male', 'female' gönderir
                            );
                            if (success && context.mounted) {
                              await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PreferencesView())
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.p24),

              // 3. TOGGLE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? l10n.dontHaveAccount : l10n.alreadyMember,
                    style: AppTextStyles.body,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        authViewModel.errorMessage = null;
                      });
                    },
                    child: Text(
                      isLogin ? l10n.signUp : l10n.login,
                      style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      dropdownColor: Colors.white,
      style: AppTextStyles.input,
      decoration: InputDecoration(
        labelText: l10n.gender,
        labelStyle: AppTextStyles.body,
        prefixIcon: const Icon(Icons.wc, color: AppColors.textLight),
        filled: true,
        fillColor: Colors.white,
        // ✅ AppDimens kullanımı
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.r16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.r16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.r16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: AppDimens.p16,
            horizontal: AppDimens.p20
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
      items: [
        // ✅ Backend'e 'male' gider, ekranda 'Erkek' yazar
        DropdownMenuItem(value: 'male', child: Text(l10n.male)),
        DropdownMenuItem(value: 'female', child: Text(l10n.female)),
        DropdownMenuItem(value: 'preferNotToSay', child: Text(l10n.preferNotToSay)),
      ],
      onChanged: (val) => setState(() => _selectedGender = val),
      validator: (value) => value == null ? l10n.pleaseSelectGender : null,
    );
  }
}