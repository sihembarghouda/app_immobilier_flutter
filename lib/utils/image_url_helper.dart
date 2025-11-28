import '../screens/utils/constants.dart';

class ImageUrlHelper {
  /// Convertit une URL d'image relative ou localhost en URL complète
  static String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    // Si c'est déjà une URL complète avec http/https, la retourner telle quelle
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Remplacer localhost par l'IP du serveur
      if (imageUrl.contains('localhost') || imageUrl.contains('127.0.0.1')) {
        final serverUrl = AppConstants.apiBaseUrl.replaceAll('/api', '');
        return imageUrl
            .replaceAll('http://localhost:3000', serverUrl)
            .replaceAll('http://127.0.0.1:3000', serverUrl);
      }
      return imageUrl;
    }

    // Si c'est un chemin relatif (commence par /uploads)
    if (imageUrl.startsWith('/uploads')) {
      final serverUrl = AppConstants.apiBaseUrl.replaceAll('/api', '');
      return '$serverUrl$imageUrl';
    }

    // Si c'est juste un nom de fichier
    final serverUrl = AppConstants.apiBaseUrl.replaceAll('/api', '');
    return '$serverUrl/uploads/$imageUrl';
  }

  /// Vérifie si une URL d'image est valide
  static bool isValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return false;
    }

    return imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://') ||
        imageUrl.startsWith('/uploads');
  }
}
