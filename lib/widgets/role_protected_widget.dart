// lib/widgets/role_protected_widget.dart
// Widget pour protéger l'accès selon le rôle

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/role_helper.dart';

class RoleProtectedWidget extends StatelessWidget {
  final Widget child;
  final String? requiredRole;
  final List<String>? allowedRoles;
  final Widget? fallback;
  final bool showMessage;

  const RoleProtectedWidget({
    super.key,
    required this.child,
    this.requiredRole,
    this.allowedRoles,
    this.fallback,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role;

    // Vérifier les permissions
    bool hasPermission = false;
    if (requiredRole != null) {
      hasPermission = UserRole.hasRole(userRole, requiredRole!);
    } else if (allowedRoles != null) {
      hasPermission = UserRole.hasAnyRole(userRole, allowedRoles!);
    } else {
      hasPermission = true; // Aucune restriction
    }

    if (hasPermission) {
      return child;
    }

    // Pas de permission
    if (fallback != null) {
      return fallback!;
    }

    if (!showMessage) {
      return const SizedBox.shrink();
    }

    // Message par défaut
    return Tooltip(
      message: UserRole.getAccessDeniedMessage(requiredRole ?? 'acheteur'),
      child: Opacity(
        opacity: 0.5,
        child: child,
      ),
    );
  }
}

/// Bouton protégé par rôle avec message d'explication
class RoleProtectedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? requiredRole;
  final List<String>? allowedRoles;

  const RoleProtectedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.requiredRole,
    this.allowedRoles,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role;

    // Vérifier les permissions
    bool hasPermission = false;
    if (requiredRole != null) {
      hasPermission = UserRole.hasRole(userRole, requiredRole!);
    } else if (allowedRoles != null) {
      hasPermission = UserRole.hasAnyRole(userRole, allowedRoles!);
    } else {
      hasPermission = true;
    }

    if (hasPermission) {
      // Utilisateur autorisé - bouton fonctionnel
      return child;
    }

    // Utilisateur non autorisé - bouton désactivé avec message
    return Tooltip(
      message: UserRole.getAccessDeniedMessage(requiredRole ?? ''),
      child: Opacity(
        opacity: 0.5,
        child: IgnorePointer(
          child: child,
        ),
      ),
    );
  }
}

/// IconButton pour favoris avec protection de rôle
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role;
    final canAddFavorites = UserRole.canAddFavorites(userRole);

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: canAddFavorites
          ? onPressed
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    UserRole.getAccessDeniedMessage(UserRole.acheteur),
                  ),
                  backgroundColor: Colors.orange,
                  action: SnackBarAction(
                    label: 'Profil',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                  ),
                ),
              );
            },
    );
  }
}

/// Badge de rôle utilisateur
class RoleBadge extends StatelessWidget {
  final String role;
  final bool showLabel;

  const RoleBadge({
    super.key,
    required this.role,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(UserRole.getRoleColor(role)).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(UserRole.getRoleColor(role)),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            UserRole.getRoleIcon(role),
            style: const TextStyle(fontSize: 16),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              UserRole.getRoleDescription(role).split(' - ')[0],
              style: TextStyle(
                color: Color(UserRole.getRoleColor(role)),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
