class AppConstants {
  static const String appName = 'NGO Assistance System';
  static const String baseUrl = 'https://ngobackend.virtuohr.com/api';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String verifyCnicEndpoint = '/beneficiary/verify-cnic';
  static const String syncAssistanceEndpoint = '/assistance/sync';

  // Local Storage Boxes
  static const String settingsBox = 'settings';
  static const String offlineAssistanceBox = 'offline_assistance';
}
