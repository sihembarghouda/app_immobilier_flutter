import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationHelper {
  // Notification générique
  static void notify(
    BuildContext context,
    String title,
    String message,
    String type,
  ) {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.addNotification(
      title: title,
      message: message,
      type: type,
    );
  }

  // Notifications pour les propriétés
  static void notifyPropertyCreated(BuildContext context, String propertyName) {
    notify(
      context,
      'Propriété créée',
      'La propriété "$propertyName" a été ajoutée avec succès',
      'create',
    );
  }

  static void notifyPropertyUpdated(BuildContext context, String propertyName) {
    notify(
      context,
      'Propriété modifiée',
      'La propriété "$propertyName" a été mise à jour',
      'update',
    );
  }

  static void notifyPropertyDeleted(BuildContext context, String propertyName) {
    notify(
      context,
      'Propriété supprimée',
      'La propriété "$propertyName" a été supprimée',
      'delete',
    );
  }

  // Notifications pour les favoris
  static void notifyFavoriteAdded(BuildContext context, String propertyName) {
    notify(
      context,
      'Favori ajouté',
      '"$propertyName" a été ajouté à vos favoris',
      'create',
    );
  }

  static void notifyFavoriteRemoved(BuildContext context, String propertyName) {
    notify(
      context,
      'Favori retiré',
      '"$propertyName" a été retiré de vos favoris',
      'delete',
    );
  }

  // Notifications pour les messages
  static void notifyNewMessage(BuildContext context, String senderName) {
    notify(
      context,
      'Nouveau message',
      'Vous avez reçu un message de $senderName',
      'create',
    );
  }

  // Notifications pour le profil
  static void notifyProfileUpdated(BuildContext context) {
    notify(
      context,
      'Profil mis à jour',
      'Votre profil a été modifié avec succès',
      'update',
    );
  }

  static void notifyAvatarUpdated(BuildContext context) {
    notify(
      context,
      'Photo de profil mise à jour',
      'Votre photo de profil a été changée avec succès',
      'update',
    );
  }

  // Notifications système
  static void notifyError(BuildContext context, String message) {
    notify(
      context,
      'Erreur',
      message,
      'delete',
    );
  }

  static void notifySuccess(BuildContext context, String message) {
    notify(
      context,
      'Succès',
      message,
      'create',
    );
  }

  static void notifyInfo(BuildContext context, String message) {
    notify(
      context,
      'Information',
      message,
      'update',
    );
  }
}
