// lib/utils/role_helper.dart
// Utilitaires pour gérer les rôles utilisateur

class UserRole {
  // French role names (used in UI)
  static const String visiteur = 'visiteur';
  static const String acheteur = 'acheteur';
  static const String vendeur = 'vendeur';

  // English role names (used in database)
  static const String visitor = 'visitor';
  static const String buyer = 'buyer';
  static const String seller = 'seller';

  /// Normalize role to French (for display)
  static String normalizeFr(String role) {
    print('🔍 DEBUG normalizeFr - Input: "$role"');
    final normalized = role.toLowerCase().trim();
    print('🔍 DEBUG normalizeFr - After lowercase/trim: "$normalized"');
    switch (normalized) {
      case 'visitor':
      case 'visiteur':
        print(
            '🔍 DEBUG normalizeFr - Matched visitor/visiteur → returning "$visiteur"');
        return visiteur;
      case 'buyer':
      case 'acheteur':
        print(
            '🔍 DEBUG normalizeFr - Matched buyer/acheteur → returning "$acheteur"');
        return acheteur;
      case 'seller':
      case 'vendeur':
        print(
            '🔍 DEBUG normalizeFr - Matched seller/vendeur → returning "$vendeur"');
        return vendeur;
      default:
        print(
            '❌ DEBUG normalizeFr - No match for "$normalized", returning default "$visiteur"');
        return visiteur;
    }
  }

  /// Normalize role to English (for API)
  static String normalizeEn(String role) {
    final normalized = role.toLowerCase().trim();
    switch (normalized) {
      case 'visitor':
      case 'visiteur':
        return visitor;
      case 'buyer':
      case 'acheteur':
        return buyer;
      case 'seller':
      case 'vendeur':
        return seller;
      default:
        return visitor;
    }
  }

  /// Vérifie si l'utilisateur a un rôle spécifique
  static bool hasRole(String? userRole, String requiredRole) {
    if (userRole == null) return false;
    // Normalize both roles to French for comparison
    return normalizeFr(userRole) == normalizeFr(requiredRole);
  }

  /// Vérifie si l'utilisateur a un des rôles autorisés
  static bool hasAnyRole(String? userRole, List<String> allowedRoles) {
    if (userRole == null) return false;
    // Normalize user role and check against normalized allowed roles
    final normalizedUserRole = normalizeFr(userRole);
    final normalizedAllowedRoles =
        allowedRoles.map((r) => normalizeFr(r)).toList();
    return normalizedAllowedRoles.contains(normalizedUserRole);
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
    print('🔍 DEBUG getRoleDescription - Input role: "$role"');
    final normalized = normalizeFr(role);
    print('🔍 DEBUG getRoleDescription - Normalized role: "$normalized"');
    switch (normalized) {
      case visiteur:
        return 'Visiteur - Consulter les propriétés';
      case acheteur:
        return 'Acheteur - Rechercher et sauvegarder';
      case vendeur:
        return 'Vendeur - Publier des propriétés';
      default:
        print(
            '❌ DEBUG getRoleDescription - Unknown normalized role: "$normalized"');
        return 'Utilisateur';
    }
  }

  /// Retourne l'icône du rôle
  static String getRoleIcon(String role) {
    final normalized = normalizeFr(role);
    switch (normalized) {
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
    final normalized = normalizeFr(role);
    switch (normalized) {
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
