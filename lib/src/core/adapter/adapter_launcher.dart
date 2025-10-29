import 'package:url_launcher/url_launcher.dart';

class AdapterLauncher {
  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  //? OPEN WHATSAPP
  Future<void> launchWhatsApp(String phoneNumber) async {
    final Uri uri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  //? OPEN PHONE
  Future<void> launchPhone(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  //? OPEN MAPS
  Future<void> launchMapsDirections({
    required String latOrigin,
    required String lngOrigin,
    required String latDestination,
    required String lngDestination,
  }) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$latOrigin,$lngOrigin&destination=$latDestination,$lngDestination&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $latOrigin,$lngOrigin to $latDestination,$lngDestination';
    }
  }
}
