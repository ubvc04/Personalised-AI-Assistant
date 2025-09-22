import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';

class EmailService {
  static EmailService? _instance;
  late final SmtpServer _smtpServer;

  EmailService._() {
    _smtpServer = gmail(AppConstants.alertEmail, AppConstants.smtpCode);
  }

  static EmailService get instance {
    _instance ??= EmailService._();
    return _instance!;
  }

  Future<void> sendOTPEmail({
    required String toEmail,
    required String otp,
    required String type,
  }) async {
    try {
      final subject = _getOTPSubject(type);
      final body = _getOTPBody(otp, type);

      final message = Message()
        ..from = Address(AppConstants.alertEmail, AppConstants.appName)
        ..recipients.add(toEmail)
        ..subject = subject
        ..html = body;

      await send(message, _smtpServer);
    } catch (e) {
      throw ServerException('Failed to send OTP email: ${e.toString()}');
    }
  }

  Future<void> sendLoginAlert({
    required String toEmail,
    required String deviceInfo,
    required String location,
    required DateTime timestamp,
  }) async {
    try {
      const subject = '🔐 Login Alert - AI Assistant';
      final body = _getLoginAlertBody(deviceInfo, location, timestamp);

      final message = Message()
        ..from = Address(AppConstants.alertEmail, AppConstants.appName)
        ..recipients.add(toEmail)
        ..subject = subject
        ..html = body;

      await send(message, _smtpServer);
    } catch (e) {
      throw ServerException('Failed to send login alert: ${e.toString()}');
    }
  }

  Future<void> sendWelcomeEmail({
    required String toEmail,
    required String userName,
  }) async {
    try {
      const subject = '🎉 Welcome to AI Assistant!';
      final body = _getWelcomeBody(userName);

      final message = Message()
        ..from = Address(AppConstants.alertEmail, AppConstants.appName)
        ..recipients.add(toEmail)
        ..subject = subject
        ..html = body;

      await send(message, _smtpServer);
    } catch (e) {
      throw ServerException('Failed to send welcome email: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail({
    required String toEmail,
    required String resetToken,
  }) async {
    try {
      const subject = '🔑 Password Reset - AI Assistant';
      final body = _getPasswordResetBody(resetToken);

      final message = Message()
        ..from = Address(AppConstants.alertEmail, AppConstants.appName)
        ..recipients.add(toEmail)
        ..subject = subject
        ..html = body;

      await send(message, _smtpServer);
    } catch (e) {
      throw ServerException('Failed to send password reset email: ${e.toString()}');
    }
  }

  String _getOTPSubject(String type) {
    switch (type) {
      case 'signup':
        return '🔐 Verify Your Email - AI Assistant';
      case 'signin':
        return '🔐 Sign In Verification - AI Assistant';
      case 'reset':
        return '🔑 Password Reset Verification - AI Assistant';
      default:
        return '🔐 Verification Code - AI Assistant';
    }
  }

  String _getOTPBody(String otp, String type) {
    final action = type == 'signup' 
        ? 'complete your registration'
        : type == 'signin'
            ? 'sign in to your account'
            : 'reset your password';

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verification Code</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background-color: #f8fafc;
            margin: 0;
            padding: 0;
            line-height: 1.6;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #6366f1, #8b5cf6);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 600;
        }
        .content {
            padding: 40px 30px;
        }
        .otp-box {
            background-color: #f1f5f9;
            border: 2px dashed #6366f1;
            border-radius: 12px;
            padding: 30px;
            text-align: center;
            margin: 30px 0;
        }
        .otp-code {
            font-size: 36px;
            font-weight: bold;
            color: #6366f1;
            letter-spacing: 8px;
            margin: 0;
            font-family: 'Courier New', monospace;
        }
        .footer {
            background-color: #f8fafc;
            padding: 30px;
            text-align: center;
            color: #64748b;
            font-size: 14px;
        }
        .warning {
            background-color: #fef3c7;
            border-left: 4px solid #f59e0b;
            padding: 16px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .button {
            display: inline-block;
            background: linear-gradient(135deg, #6366f1, #8b5cf6);
            color: white;
            padding: 12px 30px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 AI Assistant</h1>
            <p>Your Personal AI Companion</p>
        </div>
        
        <div class="content">
            <h2>Verification Code</h2>
            <p>Hello! You requested to $action. Please use the verification code below:</p>
            
            <div class="otp-box">
                <p class="otp-code">$otp</p>
                <p style="margin: 10px 0 0 0; color: #64748b;">Enter this code to continue</p>
            </div>
            
            <div class="warning">
                <strong>⚠️ Important:</strong> This code will expire in 5 minutes. Do not share this code with anyone.
            </div>
            
            <p>If you didn't request this verification, please ignore this email or contact our support team.</p>
        </div>
        
        <div class="footer">
            <p>© 2025 AI Assistant. All rights reserved.</p>
            <p>This is an automated message. Please do not reply to this email.</p>
        </div>
    </div>
</body>
</html>
''';
  }

  String _getLoginAlertBody(String deviceInfo, String location, DateTime timestamp) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Alert</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background-color: #f8fafc;
            margin: 0;
            padding: 0;
            line-height: 1.6;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .content {
            padding: 40px 30px;
        }
        .login-info {
            background-color: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            margin: 10px 0;
            padding: 5px 0;
            border-bottom: 1px solid #e5e7eb;
        }
        .info-row:last-child {
            border-bottom: none;
        }
        .footer {
            background-color: #f8fafc;
            padding: 30px;
            text-align: center;
            color: #64748b;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Login Alert</h1>
            <p>AI Assistant Security Notification</p>
        </div>
        
        <div class="content">
            <h2>New Login Detected</h2>
            <p>We detected a new login to your AI Assistant account. Here are the details:</p>
            
            <div class="login-info">
                <div class="info-row">
                    <strong>Time:</strong>
                    <span>${timestamp.toString()}</span>
                </div>
                <div class="info-row">
                    <strong>Device:</strong>
                    <span>$deviceInfo</span>
                </div>
                <div class="info-row">
                    <strong>Location:</strong>
                    <span>$location</span>
                </div>
            </div>
            
            <p>If this was you, no action is needed. If you don't recognize this login, please:</p>
            <ul>
                <li>Change your password immediately</li>
                <li>Review your account activity</li>
                <li>Contact our support team if you need assistance</li>
            </ul>
        </div>
        
        <div class="footer">
            <p>© 2025 AI Assistant. All rights reserved.</p>
            <p>This is an automated security notification.</p>
        </div>
    </div>
</body>
</html>
''';
  }

  String _getWelcomeBody(String userName) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to AI Assistant</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background-color: #f8fafc;
            margin: 0;
            padding: 0;
            line-height: 1.6;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #6366f1, #8b5cf6);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .content {
            padding: 40px 30px;
        }
        .feature-list {
            background-color: #f8fafc;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        .feature-item {
            margin: 15px 0;
            display: flex;
            align-items: center;
        }
        .feature-icon {
            font-size: 24px;
            margin-right: 15px;
        }
        .footer {
            background-color: #f8fafc;
            padding: 30px;
            text-align: center;
            color: #64748b;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 Welcome to AI Assistant!</h1>
            <p>Your Personal AI Companion</p>
        </div>
        
        <div class="content">
            <h2>Hello, $userName! 👋</h2>
            <p>Welcome to the future of personal assistance! We're excited to have you on board.</p>
            
            <div class="feature-list">
                <h3>🚀 What you can do with AI Assistant:</h3>
                
                <div class="feature-item">
                    <span class="feature-icon">🤖</span>
                    <div>
                        <strong>AI Conversations:</strong> Chat with your personalized AI avatar
                    </div>
                </div>
                
                <div class="feature-item">
                    <span class="feature-icon">🎯</span>
                    <div>
                        <strong>Task Management:</strong> Organize your life with smart productivity tools
                    </div>
                </div>
                
                <div class="feature-item">
                    <span class="feature-icon">🎵</span>
                    <div>
                        <strong>Entertainment:</strong> Music, videos, games, and more
                    </div>
                </div>
                
                <div class="feature-item">
                    <span class="feature-icon">🛠️</span>
                    <div>
                        <strong>Smart Tools:</strong> Calculator, QR scanner, weather, and utilities
                    </div>
                </div>
                
                <div class="feature-item">
                    <span class="feature-icon">🎙️</span>
                    <div>
                        <strong>Voice Commands:</strong> Control everything with your voice
                    </div>
                </div>
            </div>
            
            <p>Start exploring your new AI companion and discover all the amazing features we've built for you!</p>
        </div>
        
        <div class="footer">
            <p>© 2025 AI Assistant. All rights reserved.</p>
            <p>Need help? Contact our support team anytime.</p>
        </div>
    </div>
</body>
</html>
''';
  }

  String _getPasswordResetBody(String resetToken) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background-color: #f8fafc;
            margin: 0;
            padding: 0;
            line-height: 1.6;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .content {
            padding: 40px 30px;
        }
        .token-box {
            background-color: #fef3c7;
            border: 2px dashed #f59e0b;
            border-radius: 12px;
            padding: 30px;
            text-align: center;
            margin: 30px 0;
        }
        .reset-token {
            font-size: 24px;
            font-weight: bold;
            color: #d97706;
            margin: 0;
            word-break: break-all;
        }
        .footer {
            background-color: #f8fafc;
            padding: 30px;
            text-align: center;
            color: #64748b;
            font-size: 14px;
        }
        .warning {
            background-color: #fee2e2;
            border-left: 4px solid #ef4444;
            padding: 16px;
            margin: 20px 0;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔑 Password Reset</h1>
            <p>AI Assistant Account Recovery</p>
        </div>
        
        <div class="content">
            <h2>Reset Your Password</h2>
            <p>You requested to reset your password. Use the token below to create a new password:</p>
            
            <div class="token-box">
                <p class="reset-token">$resetToken</p>
                <p style="margin: 10px 0 0 0; color: #92400e;">Enter this token in the app</p>
            </div>
            
            <div class="warning">
                <strong>⚠️ Security Notice:</strong> This token will expire in 15 minutes. If you didn't request this reset, please ignore this email.
            </div>
            
            <p>For your security, this link can only be used once and will expire soon.</p>
        </div>
        
        <div class="footer">
            <p>© 2025 AI Assistant. All rights reserved.</p>
            <p>This is an automated message. Please do not reply to this email.</p>
        </div>
    </div>
</body>
</html>
''';
  }
}