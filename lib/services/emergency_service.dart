import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';

class EmergencyService {
  static Future<void> callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri);
  }

  static Future<void> smsWithGps(String phone) async {
    final pos = await LocationService.currentPosition();
    final text = pos == null
        ? 'Emergency! Please help. Location unavailable.'
        : 'Emergency! Please help. My location: https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': text},
    );
    await launchUrl(uri);
  }
}
