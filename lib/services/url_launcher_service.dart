import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for launching external URLs, phone calls, SMS, and maps
class UrlLauncherService {
  static const String _privacyPolicyUrl = 'https://tslsteel.com/privacy-policy';
  static const String _termsOfServiceUrl = 'https://tslsteel.com/terms-of-service';
  static const String _helpSupportUrl = 'https://tslsteel.com/support';
  static const String _contactSupportEmail = 'support@tslsteel.com';
  static const String _androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.tslsteel.parivar';

  /// Launch phone dialer with the given phone number
  static Future<bool> launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        debugPrint('❌ Cannot launch phone: $phoneNumber');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error launching phone: $e');
      return false;
    }
  }

  /// Launch SMS app with the given phone number and optional body
  static Future<bool> launchSms(String phoneNumber, {String? body}) async {
    final uri = body != null
        ? Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(body)}')
        : Uri.parse('sms:$phoneNumber');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        debugPrint('❌ Cannot launch SMS: $phoneNumber');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error launching SMS: $e');
      return false;
    }
  }

  /// Launch Google Maps with an address search query
  static Future<bool> launchMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('❌ Cannot launch maps for: $address');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error launching maps: $e');
      return false;
    }
  }

  /// Launch Google Maps with specific coordinates
  static Future<bool> launchMapsCoords(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('❌ Cannot launch maps for coordinates: $lat, $lng');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error launching maps: $e');
      return false;
    }
  }

  /// Launch a generic URL in the browser
  static Future<bool> launchWebUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('❌ Cannot launch URL: $url');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error launching URL: $e');
      return false;
    }
  }

  static Future<bool> launchPrivacyPolicy() => launchWebUrl(_privacyPolicyUrl);

  static Future<bool> launchTermsOfService() => launchWebUrl(_termsOfServiceUrl);

  static Future<bool> launchHelpSupport() => launchWebUrl(_helpSupportUrl);

  static Future<bool> launchContactSupport() {
    return launchWebUrl(
      'mailto:$_contactSupportEmail?subject=${Uri.encodeComponent('TSL Parivar Support')}',
    );
  }

  static Future<bool> launchRateApp() => launchWebUrl(_androidStoreUrl);

  static Future<bool> launchShareApp() {
    const body = 'Try TSL Parivar app: https://play.google.com/store/apps/details?id=com.tslsteel.parivar';
    return launchSms('', body: body);
  }
}

