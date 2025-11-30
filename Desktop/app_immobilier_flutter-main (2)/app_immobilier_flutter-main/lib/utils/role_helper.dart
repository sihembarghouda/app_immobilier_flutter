// lib/utils/role_helper.dart
// Utilitaires pour gérer les rôles utilisateur

class UserRole {
  static const String visiteur = 'visiteur';
  static const String acheteur = 'acheteur';
  static const String vendeur = 'vendeur';

  /// Vérifie si l'utilisateur a un rôle spécifique
  static bool hasRole(String? userRole, String requiredRole) {
    return userRole == requiredRole;
  }

  /// Vérifie si l'utilisateur a un des rôles autorisés
  static bool hasAnyRole(String? userRole, List<String> allowedRoles) {
    return userRole != null && allowedRoles.contains(userRole);
  }

  /// Vérifie si l'utilisateur peut ajouter des favoris
  static bool canAddFavorites(String? userRole) {
    return hasAnyRole(userRole, [acheteur, vendeur]);
  }

  /// Vérifie si l'utilisateur peut créer des propriétés
  static bool canCreateProperty(String? userRole) {
    return hasRole(userRole, vendeur);
  }

  /// Vérifie si l'utilisateur peut modifier une propriété
  static bool canEditProperty(String? userRole) {
    return hasRole(userRole, vendeur);
  }

  /// Vérifie si l'utilisateur peut contacter un vendeur
  static bool canContactSeller(String? userRole) {
    return hasAnyRole(userRole, [acheteur, vendeur]);
  }

  /// Vérifie si l'utilisateur peut voir ses statistiques
  static bool canViewStats(String? userRole) {
    return hasRole(userRole, vendeur);
  }

  /// Retourne la description du rôle
  static String getRoleDescription(String role) {
    switch (role) {
      case visiteur:
        return 'Visiteur - Consulter les propriétés';
      case acheteur:
        return 'Acheteur - Rechercher et sauvegarder';
      case vendeur:
        return 'Vendeur - Publier des propriétés';
      default:
        return 'Utilisateur';
    }
  }

  /// Retourne l'icône du rôle
  static String getRoleIcon(String role) {
    switch (role) {
      case visiteur:
        return '👁️';
      case acheteur:
        return '🏠';
      case vendeur:
        return '🏢';
      default:
        return '👤';
    }
  }

  /// Retourne la couleur du rôle
  static int getRoleColor(String role) {
    switch (role) {
      case visiteur:
        return 0xFF9E9E9E; // Gris
      case acheteur:
        return 0xFF2196F3; // Bleu
      case vendeur:
        return 0xFF4CAF50; // Vert
      default:
        return 0xFF757575;
    }
  }

  /// Message à afficher si l'utilisateur n'a pas la permission
  static String getAccessDeniedMessage(String requiredRole) {
    switch (requiredRole) {
      case acheteur:
        return 'Cette fonctionnalité est réservée aux acheteurs. Changez votre rôle dans votre profil.';
      case vendeur:
        return 'Cette fonctionnalité est réservée aux vendeurs. Changez votre rôle dans votre profil.';
      default:
        return 'Vous n\'avez pas accès à cette fonctionnalité.';
    }
  }

  /// Liste tous les rôles disponibles
  static List<Map<String, String>> getAllRoles() {
    return [
      {
        'value': visiteur,
        'label': 'Visiteur',
        'description': 'Parcourir et consulter les propriétés',
        'icon': '👁️',
      },
      {
        'value': acheteur,
        'label': 'Acheteur',
        'description': 'Rechercher, sauvegarder et contacter',
        'icon': '🏠',
      },
      {
        'value': vendeur,
        'label': 'Vendeur',
        'description': 'Publier et gérer vos propriétés',
        'icon': '🏢',
      },
    ];
  }
}
