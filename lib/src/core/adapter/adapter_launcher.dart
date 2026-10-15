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
    // wa.me solo acepta dígitos: "+593 96-296-1049" → "593962961049".
    final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      // externalApplication: abre la app de WhatsApp en lugar de la página
      // web de wa.me dentro de un navegador embebido.
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
