
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';
import 'package:smart_resource_ai/data/services/notification_service.dart';
import 'package:smart_resource_ai/viewmodels/auth_view_model.dart';
import 'package:smart_resource_ai/viewmodels/language_view_model.dart';
import 'package:smart_resource_ai/viewmodels/user_view_model.dart';
import 'package:smart_resource_ai/views/auth/auth_view.dart';
import 'package:smart_resource_ai/views/onboarding/preferences_view.dart';


class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserViewModel>(context, listen: false).fetchUserData()
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userViewModel = Provider.of<UserViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final languageViewModel = Provider.of<LanguageViewModel>(context);
    final l10n = AppLocalizations.of(context)!;

    final userData = userViewModel.userData;
    final currentUser = FirebaseAuth.instance.currentUser;

    final avatarPath = (userData?['avatarPath'] as String?) ?? 'default';
    final fullName = (userData?['fullName'] as String?) ?? 'User';
    final nickname = (userData?['nickname'] as String?) ?? '...';
    final email = (userData?['email'] as String?) ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userViewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p24,
          vertical: AppDimens.p20,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppDimens.p20),

            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _showAvatarPicker(context, userViewModel),
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          padding: const EdgeInsets.all(AppDimens.p4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [AppColors.shadowMedium],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withOpacity(0.05),
                            child: _buildAvatarImage(avatarPath, fullName),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(AppDimens.p8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: AppDimens.iconSmall),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.p16),

                  Text(
                    fullName,
                    style: AppTextStyles.header.copyWith(fontSize: 22),
                  ),
                  Text(
                    '@$nickname',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.p32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.p20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.r20),
                boxShadow: [AppColors.shadowLow],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser?.uid)
                    .collection('history')
                    .snapshots(),
                builder: (context, snapshot) {
                  var recipeCount = 0;
                  var workoutCount = 0;
                  var totalScore = 0;

                  if (snapshot.hasData) {
                    final docs = snapshot.data!.docs;

                    final completedDocs = docs.where((doc) {
                      final data = doc.data()! as Map<String, dynamic>;
                      return true == (data['isCompleted'] as bool?);
                    }).toList();

                    recipeCount = completedDocs.where((doc) => doc['type'] == 'food').length;
                    workoutCount = completedDocs.where((doc) => doc['type'] != 'food').length;
                    totalScore = (recipeCount + workoutCount) * 50;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCleanStat(l10n.recipes, '$recipeCount', AppColors.foodAccent),
                      Container(width: 1, height: 30, color: Colors.grey.shade200),
                      _buildCleanStat(l10n.fitness, '$workoutCount', AppColors.sportAccent),
                      Container(width: 1, height: 30, color: Colors.grey.shade200),
                      _buildCleanStat(l10n.score, '$totalScore', AppColors.primary),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: AppDimens.p32),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: AppDimens.p8, bottom: AppDimens.p12),
                child: Text(l10n.accountDetails, style: AppTextStyles.label.copyWith(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.r20),
                boxShadow: [AppColors.shadowLow],
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.tune_outlined,
                    title: l10n.preferences,
                    value: '',
                    iconColor: AppColors.primary,
                    isArrowVisible: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PreferencesView(isEditing: true),
                        ),
                      );
                    },
                  ),

                  _buildSettingsTile(icon: Icons.email_outlined, title: l10n.email, value: email, iconColor: Colors.blueGrey),
                  Divider(height: 1, color: Colors.grey.shade100, indent: 60, endIndent: 20),

                  _buildSettingsTile(
                    icon: Icons.notifications_active_outlined,
                    title: l10n.dailyReminder,
                    value: l10n.setReminder,
                    iconColor: Colors.orange,
                    isArrowVisible: true,
                    onTap: () => _pickReminderTime(context),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100, indent: 60, endIndent: 20),

                  _buildSettingsTile(icon: Icons.verified_user_outlined, title: l10n.membership, value: l10n.premium, iconColor: AppColors.success, isValueBold: true),
                  Divider(height: 1, color: Colors.grey.shade100, indent: 60, endIndent: 20),
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: l10n.language,
                    value: languageViewModel.currentLocale.languageCode == 'tr' ? l10n.turkish : l10n.english,
                    iconColor: Colors.purpleAccent,
                    isArrowVisible: true,
                    onTap: () => _showLanguageBottomSheet(context, languageViewModel),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100, indent: 60, endIndent: 20),
                  _buildSettingsTile(icon: Icons.lock_reset, title: l10n.changePassword, value: '', iconColor: AppColors.foodAccent, isArrowVisible: true, onTap: () => _showChangePasswordSheet(context)),
                  Divider(height: 1, color: Colors.grey.shade100, indent: 60, endIndent: 20),
                  _buildSettingsTile(icon: Icons.logout, title: l10n.logout, value: '', iconColor: AppColors.textDark, isArrowVisible: true, onTap: () => _showLogoutDialog(context, authViewModel, l10n)),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.p20),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimens.r20), boxShadow: [AppColors.shadowLow]),
              child: _buildSettingsTile(
                icon: Icons.delete_forever,
                title: l10n.deleteAccount,
                value: '',
                iconColor: AppColors.error,
                isValueBold: true,
                onTap: () => _showDeleteConfirmDialog(context, authViewModel, l10n),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }


  Widget _buildAvatarImage(String path, String? fullName) {
    if (path == 'man') return const Icon(Icons.face, size: 60, color: AppColors.primary);
    if (path == 'woman') return const Icon(Icons.face_3, size: 60, color: Colors.pinkAccent);
    if (path == 'robot') return const Icon(Icons.smart_toy, size: 60, color: Colors.teal);

    return Text(
      (fullName != null && fullName.isNotEmpty) ? fullName[0].toUpperCase() : 'U',
      style: AppTextStyles.header.copyWith(fontSize: 40, color: AppColors.primary),
    );
  }

  void _showAvatarPicker(BuildContext context, UserViewModel userVM) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24))),
      builder: (context) {
        return Padding(
          padding: AppDimens.all24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: AppDimens.p20),
              Text('Avatar Seç', style: AppTextStyles.subHeader),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _avatarOption(context, userVM, 'man', Icons.face, AppColors.primary),
                  _avatarOption(context, userVM, 'woman', Icons.face_3, Colors.pinkAccent),
                  _avatarOption(context, userVM, 'robot', Icons.smart_toy, Colors.teal),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _avatarOption(BuildContext context, UserViewModel userVM, String path, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        userVM.updateAvatar(path);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            padding: AppDimens.all16,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 40, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await NotificationService().scheduleDailyNotification(
        hour: picked.hour,
        minute: picked.minute,
        title: l10n.notificationReminderTitle,
        body: l10n.notificationReminderBody,
        channelName: l10n.notificationChannelReminder,
        channelDesc: l10n.notificationChannelReminderDesc,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.notificationChannelReminder}: ${picked.format(context)}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, AuthViewModel authVM, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r24)),
        title: Text(l10n.deleteAccount, style: AppTextStyles.subHeader.copyWith(color: AppColors.error)),
        content:  Text(l10n.deleteAccountWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: AppTextStyles.label)
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                if (context.mounted) {
                  await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthView()), (route) => false);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(l10n.errorSecurity)));
                }
              }
            },
            child:  Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.header.copyWith(fontSize: 20, color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 12)),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    bool isValueBold = false,
    bool isArrowVisible = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.r20),
      child: Padding(
        padding: AppDimens.all16,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimens.r12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppDimens.p16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.label.copyWith(color: AppColors.textDark),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                    fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
                    color: isValueBold ? iconColor : AppColors.textGray
                ),
              ),
            if (isArrowVisible)
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
              ),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, LanguageViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(l10n.language, style: AppTextStyles.subHeader),
              const SizedBox(height: 20),
              _buildLanguageOption(context, viewModel,l10n.turkish, const Locale('tr')),
              const Divider(height: 1),
              _buildLanguageOption(context, viewModel, l10n.english, const Locale('en')),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, LanguageViewModel viewModel, String name, Locale locale) {
    final isSelected = viewModel.currentLocale.languageCode == locale.languageCode;
    return ListTile(
      leading: Text(locale.languageCode == 'tr' ? '🇹🇷' : '🇺🇸', style: const TextStyle(fontSize: 24)),
      title: Text(name, style: AppTextStyles.body.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
      onTap: () {
        viewModel.changeLanguage(locale);
        Navigator.pop(context);
      },
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 25, left: 25, right: 25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              Text(l10n.changePassword, style: AppTextStyles.subHeader),
              const SizedBox(height: 25),
              _buildCleanTextField(controller: passwordController, label: l10n.newPassword, icon: Icons.lock_outline, errorText: l10n.passwordMinLength),
              const SizedBox(height: 16),
              _buildCleanTextField(controller: confirmController, label: l10n.confirmPassword, icon: Icons.lock, errorText: l10n.passwordMinLength),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final authVM = Provider.of<AuthViewModel>(context, listen: false);
                      Navigator.pop(context);
                      var success = await authVM.updatePassword(passwordController.text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? l10n.passwordUpdated : l10n.errorOccurred), backgroundColor: success ? AppColors.success : AppColors.error, behavior: SnackBarBehavior.floating));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(l10n.update, style: AppTextStyles.buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanTextField({required TextEditingController controller, required String label, required IconData icon, required String errorText}) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: AppTextStyles.input,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body,
        prefixIcon: Icon(icon, color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: (v) => v!.length < 6 ? errorText : null,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authViewModel, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.logout, style: AppTextStyles.subHeader),
        content: Text(l10n.logoutConfirmation, style: AppTextStyles.body),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: AppTextStyles.label)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authViewModel.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error.withOpacity(0.1), foregroundColor: AppColors.error, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(l10n.logout, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}