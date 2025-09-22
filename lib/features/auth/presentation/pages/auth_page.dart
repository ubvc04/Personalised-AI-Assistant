import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/pages/main_dashboard.dart';
import '../providers/simple_auth_provider.dart';

enum AuthPageType { login, signup, otp }

class AuthPage extends ConsumerStatefulWidget {
  final AuthPageType initialPage;

  const AuthPage({super.key, required this.initialPage});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AuthPageType _currentPage;
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  // Form keys
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(
      initialPage: widget.initialPage == AuthPageType.login ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildLoginPage(),
                    _buildSignupPage(),
                    _buildOTPPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _getHeaderTitle(),
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 8),
          Text(
            _getHeaderSubtitle(),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  String _getHeaderTitle() {
    switch (_currentPage) {
      case AuthPageType.login:
        return 'Welcome Back!';
      case AuthPageType.signup:
        return 'Create Account';
      case AuthPageType.otp:
        return 'Verify Your Email';
    }
  }

  String _getHeaderSubtitle() {
    switch (_currentPage) {
      case AuthPageType.login:
        return 'Sign in to continue your AI journey';
      case AuthPageType.signup:
        return 'Join thousands of users experiencing AI assistance';
      case AuthPageType.otp:
        return 'We\'ve sent a verification code to your email';
    }
  }

  Widget _buildLoginPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            // Email Field
            _buildInputField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ).animate().fadeIn(delay: 300.ms).slideX(),
            
            const SizedBox(height: 20),
            
            // Password Field
            _buildInputField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              onPasswordToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              validator: _validatePassword,
            ).animate().fadeIn(delay: 400.ms).slideX(),
            
            const SizedBox(height: 16),
            
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),
            
            const SizedBox(height: 32),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Login', style: AppTextStyles.buttonLarge),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(),
            
            const SizedBox(height: 24),
            
            // Divider
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ).animate().fadeIn(delay: 700.ms),
            
            const SizedBox(height: 24),
            
            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account? ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => _switchPage(AuthPageType.signup),
                  child: Text(
                    'Sign Up',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _signupFormKey,
        child: Column(
          children: [
            // Name Field
            _buildInputField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              validator: _validateName,
            ).animate().fadeIn(delay: 300.ms).slideX(),
            
            const SizedBox(height: 20),
            
            // Email Field
            _buildInputField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ).animate().fadeIn(delay: 400.ms).slideX(),
            
            const SizedBox(height: 20),
            
            // Phone Field
            _buildInputField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ).animate().fadeIn(delay: 500.ms).slideX(),
            
            const SizedBox(height: 20),
            
            // Password Field
            _buildInputField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create a strong password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              onPasswordToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              validator: _validatePassword,
            ).animate().fadeIn(delay: 600.ms).slideX(),
            
            const SizedBox(height: 20),
            
            // Confirm Password Field
            _buildInputField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _isConfirmPasswordVisible,
              onPasswordToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              validator: _validateConfirmPassword,
            ).animate().fadeIn(delay: 700.ms).slideX(),
            
            const SizedBox(height: 32),
            
            // Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Create Account', style: AppTextStyles.buttonLarge),
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(),
            
            const SizedBox(height: 24),
            
            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => _switchPage(AuthPageType.login),
                  child: Text(
                    'Login',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _otpFormKey,
        child: Column(
          children: [
            // OTP Illustration
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ).animate().scale(delay: 300.ms),
            
            const SizedBox(height: 32),
            
            Text(
              'Check your email',
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 8),
            
            Text(
              'We sent a verification code to\n${_emailController.text}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 500.ms),
            
            const SizedBox(height: 40),
            
            // OTP Input
            _buildOTPInput().animate().fadeIn(delay: 600.ms).slideY(),
            
            const SizedBox(height: 32),
            
            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleOTPVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Verify', style: AppTextStyles.buttonLarge),
              ),
            ).animate().fadeIn(delay: 700.ms).slideY(),
            
            const SizedBox(height: 24),
            
            // Resend Code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Didn\'t receive the code? ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: _handleResendOTP,
                  child: Text(
                    'Resend',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onPasswordToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !isPasswordVisible,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onPasswordToggle,
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) => _buildOTPBox(index)),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _otpController.text.length > index
              ? AppColors.primary
              : AppColors.inputBorder,
          width: _otpController.text.length > index ? 2 : 1,
        ),
      ),
      child: TextFormField(
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
          setState(() {});
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        style: AppTextStyles.headline4.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Action methods
  void _switchPage(AuthPageType page) {
    setState(() => _currentPage = page);
    int pageIndex = page == AuthPageType.login ? 0 : page == AuthPageType.signup ? 1 : 2;
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(simpleAuthProvider.notifier);
      await authNotifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        _showSuccessDialog('Login Successful!', 'Welcome back to your AI assistant.');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainDashboard()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Login Failed', e.toString());
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(simpleAuthProvider.notifier);
      await authNotifier.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        _showSuccessDialog('Account Created!', 'Please verify your email to continue.');
        _switchPage(AuthPageType.otp);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Signup Failed', e.toString());
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleOTPVerification() async {
    if (_otpController.text.length != 6) {
      _showErrorDialog('Invalid OTP', 'Please enter the complete 6-digit code.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(simpleAuthProvider.notifier);
      await authNotifier.verifyOTP(
        email: _emailController.text.trim(),
        otp: _otpController.text,
      );
      
      if (mounted) {
        _showSuccessDialog('Verification Successful!', 'Your account has been verified.');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainDashboard()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Verification Failed', e.toString());
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleResendOTP() async {
    try {
      final authNotifier = ref.read(simpleAuthProvider.notifier);
      await authNotifier.resendOTP(_emailController.text.trim());
      
      if (mounted) {
        _showSuccessDialog('Code Sent!', 'A new verification code has been sent to your email.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to Send Code', e.toString());
      }
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text('Password reset functionality will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
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
