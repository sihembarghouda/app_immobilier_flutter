import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@immobilier.com',
      query: 'subject=Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+216 98 123 456');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide et Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FAQ Section
          const Text(
            'Questions fréquentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildFAQItem(
            context,
            'Comment publier une annonce ?',
            'Allez dans votre profil, cliquez sur "Mes annonces", puis sur le bouton "+". Remplissez le formulaire avec les détails de votre propriété et publiez.',
          ),

          _buildFAQItem(
            context,
            'Comment contacter un propriétaire ?',
            'Sur la page de détails d\'une propriété, utilisez les boutons "Appeler" ou "Message" pour contacter directement le propriétaire.',
          ),

          _buildFAQItem(
            context,
            'Comment ajouter une propriété aux favoris ?',
            'Cliquez sur l\'icône cœur sur n\'importe quelle annonce. Retrouvez toutes vos propriétés favorites dans l\'onglet "Favoris".',
          ),

          _buildFAQItem(
            context,
            'Comment rechercher une propriété ?',
            'Utilisez l\'onglet "Recherche" pour filtrer par type de propriété, prix, nombre de pièces, et localisation.',
          ),

          _buildFAQItem(
            context,
            'Puis-je voir les propriétés sur une carte ?',
            'Oui! Utilisez l\'onglet "Carte" pour voir toutes les propriétés géolocalisées sur une carte interactive.',
          ),

          const SizedBox(height: 32),

          // Contact Support
          const Text(
            'Contactez-nous',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email'),
              subtitle: const Text('support@immobilier.com'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _launchEmail,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Téléphone'),
              subtitle: const Text('+216 98 123 456'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _launchPhone,
            ),
          ),

          const SizedBox(height: 32),

          // App Info
          const Text(
            'À propos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.home_work,
                    size: 60,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Immobilier App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Votre plateforme de confiance pour trouver et publier des annonces immobilières.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
