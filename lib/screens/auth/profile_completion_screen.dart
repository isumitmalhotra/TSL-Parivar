import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../navigation/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/widgets.dart';

/// Mandatory profile completion step shown after authentication.
class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _isSaving = false;
  bool _isLocating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;

    if (_nameController.text.isEmpty || _nameController.text == 'TSL User') {
      _nameController.text = user.name;
    }
    if (_locationController.text.isEmpty) {
      _locationController.text =
          (user.roleSpecificData['location'] as String?) ?? '';
    }
    if (_addressController.text.isEmpty) {
      _addressController.text = (user.roleSpecificData['address'] as String?) ?? '';
    }
    if (_cityController.text.isEmpty) {
      _cityController.text = (user.roleSpecificData['city'] as String?) ?? '';
    }
    if (_pincodeController.text.isEmpty) {
      _pincodeController.text = (user.roleSpecificData['pincode'] as String?) ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _captureCurrentLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to fetch location. Check permissions.')),
        );
        return;
      }

      _locationController.text = LocationService.formatPosition(position);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location captured successfully.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _saveAndContinue() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isSaving = true);
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.completeMandatoryProfile(
      name: _nameController.text,
      location: _locationController.text,
      address: _addressController.text,
      city: _cityController.text,
      pincode: _pincodeController.text,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.errorMessage ?? 'Failed to save profile details.'),
        ),
      );
      return;
    }

    context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final roleName = authProvider.userRole?.name ?? 'user';

    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.roleSelection);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Complete your profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finish profile setup to continue as $roleName.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                TslTextField(
                  controller: _nameController,
                  label: 'Full name *',
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    if (value.trim().toLowerCase() == 'tsl user') {
                      return 'Please enter your real name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TslTextField(
                  controller: _cityController,
                  label: 'City *',
                  prefixIcon: Icons.location_city,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TslTextField(
                  controller: _locationController,
                  label: 'Coordinates or locality *',
                  prefixIcon: Icons.location_city_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Location is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _isLocating ? null : _captureCurrentLocation,
                    icon: _isLocating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: const Text('Use current location'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TslTextField(
                  controller: _addressController,
                  label: 'Full address *',
                  prefixIcon: Icons.home_outlined,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TslTextField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  prefixIcon: Icons.pin,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: TslPrimaryButton(
                    label: 'Save and continue',
                    isLoading: _isSaving || userProvider.isLoading,
                    onPressed: _saveAndContinue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



