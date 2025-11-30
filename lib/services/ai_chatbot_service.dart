// services/ai_chatbot_service.dart
import '../models/property.dart';

class AIChatbotService {
  static final AIChatbotService _instance = AIChatbotService._internal();
  factory AIChatbotService() => _instance;
  AIChatbotService._internal();

  static const String botUserId = 'ai_chatbot_assistant';
  static const String botUserName = 'Assistant IA Immobilier';

  List<Property>? _availableProperties;

  void setProperties(List<Property> properties) {
    _availableProperties = properties;
  }

  String generateResponse(String userMessage, {String? userCity}) {
    final message = userMessage.toLowerCase();

    // Greetings
    if (_containsAny(
        message, ['bonjour', 'salut', 'hello', 'hi', 'hey', 'السلام'])) {
      return '👋 Bonjour! Je suis votre assistant immobilier intelligent. Je peux vous aider à:\n\n'
          '🏠 Trouver des propriétés (appartement, maison, villa, studio)\n'
          '💰 Comparer les prix\n'
          '📍 Recommander des quartiers\n'
          '📋 Expliquer le processus d\'achat/location\n'
          '🗺️ Voir les itinéraires vers les propriétés\n\n'
          'Que recherchez-vous?';
    }

    // Help
    if (_containsAny(message, ['aide', 'help', 'مساعدة'])) {
      return '💡 Je peux vous aider avec:\n\n'
          '1️⃣ Recherche de propriété par type (studio, appartement, maison, villa)\n'
          '2️⃣ Budget et prix (demandez "quel est le prix moyen?")\n'
          '3️⃣ Comparaison de quartiers\n'
          '4️⃣ Conseils d\'achat ou location\n'
          '5️⃣ Recommandations personnalisées\n'
          '6️⃣ Calculer les mensualités de crédit\n\n'
          'Posez-moi une question spécifique!';
    }

    // Property types
    if (_containsAny(message, ['studio'])) {
      return _getPropertyTypeInfo('studio');
    }
    if (_containsAny(message, ['appartement', 'apartment'])) {
      return _getPropertyTypeInfo('apartment');
    }
    if (_containsAny(message, ['maison', 'house'])) {
      return _getPropertyTypeInfo('house');
    }
    if (_containsAny(message, ['villa'])) {
      return _getPropertyTypeInfo('villa');
    }

    // Transaction types
    if (_containsAny(
        message, ['acheter', 'achat', 'buy', 'vente', 'sale', 'شراء'])) {
      return '🏡 **Guide d\'achat immobilier:**\n\n'
          '1️⃣ Définissez votre budget (incluant frais notaire 5-7%)\n'
          '2️⃣ Obtenez une pré-approbation bancaire\n'
          '3️⃣ Visitez plusieurs propriétés (minimum 3-5)\n'
          '4️⃣ Faites inspecter la propriété\n'
          '5️⃣ Négociez le prix (marge: 5-15%)\n'
          '6️⃣ Signez le compromis de vente\n'
          '7️⃣ Finalisez avec l\'acte authentique\n\n'
          '💰 Crédit immobilier disponible jusqu\'à 80% du prix.\n'
          'Voulez-vous que je vous montre les meilleures propriétés à vendre?';
    }

    if (_containsAny(message, ['louer', 'location', 'rent', 'إيجار'])) {
      return '🔑 **Guide de location:**\n\n'
          '1️⃣ Budget: loyer ≤ 30% de vos revenus\n'
          '2️⃣ Documents requis:\n'
          '   • CIN + justificatifs revenus\n'
          '   • Caution (2-3 mois de loyer)\n'
          '3️⃣ Visitez aux heures de pointe\n'
          '4️⃣ Vérifiez l\'état des lieux\n'
          '5️⃣ Lisez le contrat attentivement\n'
          '6️⃣ Faites l\'état des lieux d\'entrée\n\n'
          '💡 Astuce: Négociez toujours le prix!\n'
          'Voulez-vous voir les propriétés disponibles en location?';
    }

    // Price and budget
    if (_containsAny(message,
        ['prix', 'budget', 'combien', 'coût', 'cost', 'price', 'سعر'])) {
      return _getPriceInfo(userCity);
    }

    // Calculate monthly payment
    if (_containsAny(
        message, ['mensualité', 'crédit', 'emprunt', 'loan', 'monthly'])) {
      return '🏦 **Calculateur de crédit immobilier:**\n\n'
          '📊 Exemple pour 200,000 TND:\n'
          '• Sur 15 ans (7%): ~1,800 TND/mois\n'
          '• Sur 20 ans (7%): ~1,550 TND/mois\n'
          '• Sur 25 ans (7%): ~1,400 TND/mois\n\n'
          '💡 Formule: M = P × (r(1+r)^n) / ((1+r)^n - 1)\n'
          'Où: M=mensualité, P=principal, r=taux/12, n=mois\n\n'
          'Quel montant souhaitez-vous emprunter?';
    }

    // Location/Area
    if (_containsAny(
        message, ['quartier', 'zone', 'où', 'location', 'area', 'منطقة'])) {
      return _getLocationInfo();
    }

    // Property recommendations
    if (_containsAny(
        message, ['recommand', 'suggest', 'meilleur', 'best', 'مقترح'])) {
      return _getRecommendations(userCity);
    }

    // Property count
    if (_containsAny(
        message, ['combien de', 'nombre', 'how many', 'count', 'كم عدد'])) {
      return _getPropertyCount();
    }

    // Specific property search
    if (_containsAny(message,
        ['cherche', 'recherche', 'trouver', 'search', 'find', 'بحث'])) {
      return _searchProperties(message, userCity);
    }

    // Show properties
    if (_containsAny(message, ['montre', 'affiche', 'voir', 'show', 'عرض'])) {
      return '🏘️ Je peux vous montrer les propriétés sur la carte!\n\n'
          'Pour voir les propriétés:\n'
          '1️⃣ Utilisez la page "Carte"\n'
          '2️⃣ Cliquez sur un marqueur\n'
          '3️⃣ Appuyez sur "Voir l\'itinéraire" pour la navigation GPS\n\n'
          'Filtrez par:\n'
          '• Type (studio, appartement, maison, villa)\n'
          '• Prix (min/max)\n'
          '• Transaction (vente/location)\n\n'
          'Quel type de propriété vous intéresse?';
    }

    // Route/Navigation
    if (_containsAny(message, [
      'itinéraire',
      'trajet',
      'route',
      'navigation',
      'comment aller',
      'طريق'
    ])) {
      return '🗺️ **Navigation GPS vers les propriétés:**\n\n'
          '1️⃣ Allez sur la page "Carte"\n'
          '2️⃣ Sélectionnez une propriété\n'
          '3️⃣ Cliquez sur "Voir l\'itinéraire"\n'
          '4️⃣ Google Maps s\'ouvre automatiquement\n\n'
          '🚗 Affiche:\n'
          '• Distance en temps réel\n'
          '• Meilleur itinéraire\n'
          '• Temps de trajet\n'
          '• Trafic en direct\n\n'
          'Quelle propriété voulez-vous visiter?';
    }

    // Documents
    if (_containsAny(message, ['document', 'papier', 'dossier', 'وثائق'])) {
      return '📋 **Documents nécessaires:**\n\n'
          '**Pour acheter:**\n'
          '• CIN valide\n'
          '• Justificatifs de revenus (3 derniers mois)\n'
          '• Relevé bancaire\n'
          '• Promesse de vente\n'
          '• Certificat de propriété du vendeur\n\n'
          '**Pour louer:**\n'
          '• CIN\n'
          '• Fiche de paie ou attestation travail\n'
          '• Caution (2-3 mois)\n'
          '• Garant éventuel\n\n'
          'Besoin d\'autres informations?';
    }

    // Thank you
    if (_containsAny(message, ['merci', 'thank', 'شكرا'])) {
      return '😊 Avec grand plaisir! N\'hésitez pas si vous avez d\'autres questions.\n\n'
          '💡 Astuce: Utilisez la carte pour voir toutes les propriétés disponibles et obtenir des itinéraires!';
    }

    // Goodbye
    if (_containsAny(
        message, ['au revoir', 'bye', 'goodbye', 'ciao', 'وداعا'])) {
      return '👋 Au revoir! Revenez quand vous voulez. Bonne recherche immobilière!';
    }

    // Default response with context
    return '🤔 Je peux vous aider avec:\n\n'
        '• 🏠 Propriétés disponibles (${_getPropertyCount()})\n'
        '• 💰 Prix et budgets\n'
        '• 📍 Quartiers et zones\n'
        '• 🗺️ Itinéraires GPS\n'
        '• 📋 Conseils achat/location\n\n'
        'Posez-moi une question précise (ex: "Montre-moi des appartements à Tunis")?';
  }

  String _getPropertyTypeInfo(String type) {
    final counts = _getPropertyCountByType();
    final count = counts[type] ?? 0;

    final info = {
      'studio': '🏢 **Studios disponibles: $count**\n\n'
          '✨ Caractéristiques:\n'
          '• Surface: 25-50 m²\n'
          '• Prix vente: 50,000-120,000 TND\n'
          '• Prix location: 400-800 TND/mois\n'
          '• Idéal pour: étudiants, jeunes professionnels\n\n'
          'Voulez-vous voir la liste des studios disponibles?',
      'apartment': '🏠 **Appartements disponibles: $count**\n\n'
          '✨ Caractéristiques:\n'
          '• Surface: 60-150 m²\n'
          '• Prix vente: 100,000-400,000 TND\n'
          '• Prix location: 600-1,500 TND/mois\n'
          '• Chambres: 1-3\n'
          '• Idéal pour: couples, petites familles\n\n'
          'Quelle ville vous intéresse?',
      'house': '🏡 **Maisons disponibles: $count**\n\n'
          '✨ Caractéristiques:\n'
          '• Surface: 120-300 m²\n'
          '• Prix vente: 200,000-600,000 TND\n'
          '• Prix location: 1,000-2,500 TND/mois\n'
          '• Chambres: 2-5\n'
          '• Idéal pour: familles\n\n'
          'Voulez-vous filtrer par ville?',
      'villa': '🏰 **Villas de luxe disponibles: $count**\n\n'
          '✨ Caractéristiques:\n'
          '• Surface: 250-500 m²\n'
          '• Prix vente: 500,000-1,500,000 TND\n'
          '• Prix location: 2,000-5,000 TND/mois\n'
          '• Chambres: 3-6\n'
          '• Souvent avec piscine et jardin\n'
          '• Idéal pour: grandes familles, luxe\n\n'
          'Quelle zone préférez-vous?',
    };

    return info[type] ?? 'Type de propriété non reconnu.';
  }

  String _getPriceInfo(String? city) {
    final avgPrices = _getAveragePrices();

    String response = '💰 **Analyse des prix immobiliers:**\n\n';

    if (avgPrices.isNotEmpty) {
      response += '📊 Prix moyens:\n';
      avgPrices.forEach((type, price) {
        final typeNames = {
          'studio': 'Studios',
          'apartment': 'Appartements',
          'house': 'Maisons',
          'villa': 'Villas'
        };
        response += '• ${typeNames[type]}: ${price.toStringAsFixed(0)} TND\n';
      });
    }

    response += '\n📈 Tendances du marché:\n'
        '• Studios: 2,000-2,500 TND/m²\n'
        '• Appartements: 2,500-3,500 TND/m²\n'
        '• Maisons: 1,500-2,500 TND/m²\n'
        '• Villas: 2,000-3,000 TND/m²\n\n'
        '💡 Conseils:\n'
        '• Négociez 5-10% sous le prix affiché\n'
        '• Comparez au moins 3 propriétés similaires\n';

    if (city != null) {
      response += '\n🔍 Voulez-vous voir les propriétés à $city?';
    }

    return response;
  }

  String _getLocationInfo() {
    return '📍 **Guide des quartiers populaires:**\n\n'
        '🏙️ **Tunis:**\n'
        '• Centre-Ville: commerces, bureaux (3,500 TND/m²)\n'
        '• Les Berges du Lac: moderne, calme (4,000 TND/m²)\n'
        '• La Marsa: résidentiel, plage (3,800 TND/m²)\n'
        '• Ariana: accessible, famille (2,800 TND/m²)\n\n'
        '🌊 **Côte (Sousse, Monastir):**\n'
        '• Tourisme, plage (2,500-3,000 TND/m²)\n\n'
        '🏭 **Sfax:**\n'
        '• Industriel, économique (2,200 TND/m²)\n\n'
        '💡 Critères de choix:\n'
        '✅ Proximité écoles/travail\n'
        '✅ Transports en commun\n'
        '✅ Commerces et services\n'
        '✅ Sécurité du quartier\n'
        '✅ Potentiel de plus-value\n\n'
        'Quelle ville vous intéresse?';
  }

  String _getRecommendations(String? city) {
    if (_availableProperties == null || _availableProperties!.isEmpty) {
      return '🏘️ Je peux vous recommander des propriétés une fois que vous aurez accédé à la page d\'accueil ou carte.\n\n'
          'En attendant, voici mes conseils:\n'
          '• Visitez toujours en personne\n'
          '• Vérifiez l\'état général\n'
          '• Demandez l\'historique\n'
          '• Comparez les prix du quartier';
    }

    // Get best properties (lowest price per m²)
    final sorted = List<Property>.from(_availableProperties!)
      ..sort((a, b) => (a.price / a.surface).compareTo(b.price / b.surface));

    final top3 = sorted.take(3).toList();

    String response = '⭐ **Mes meilleures recommandations:**\n\n';

    for (var i = 0; i < top3.length; i++) {
      final p = top3[i];
      final pricePerM2 = (p.price / p.surface).toStringAsFixed(0);
      response += '${i + 1}. **${p.title}**\n'
          '   📍 ${p.city}\n'
          '   💰 ${p.price.toStringAsFixed(0)} TND ($pricePerM2 TND/m²)\n'
          '   📏 ${p.surface.toInt()} m² • ${p.bedrooms} chambres\n\n';
    }

    response += '💡 Ces propriétés offrent le meilleur rapport qualité/prix!\n'
        'Voulez-vous voir leur emplacement sur la carte?';

    return response;
  }

  String _getPropertyCount() {
    if (_availableProperties == null) {
      return '🏘️ Plus de 1000 propriétés disponibles';
    }

    final total = _availableProperties!.length;
    final forSale =
        _availableProperties!.where((p) => p.transactionType == 'sale').length;
    final forRent =
        _availableProperties!.where((p) => p.transactionType == 'rent').length;

    return '📊 **Statistiques:**\n'
        '• Total: $total propriétés\n'
        '• À vendre: $forSale\n'
        '• À louer: $forRent\n\n'
        'Que cherchez-vous?';
  }

  String _searchProperties(String message, String? city) {
    String response = '🔍 **Résultats de recherche:**\n\n';

    if (_availableProperties == null || _availableProperties!.isEmpty) {
      return response +
          'Aucune propriété chargée. Allez sur la page d\'accueil ou carte pour voir les propriétés disponibles.';
    }

    // Filter by message content
    List<Property> results = _availableProperties!;

    if (city != null) {
      results = results
          .where((p) => p.city.toLowerCase() == city.toLowerCase())
          .toList();
    }

    if (message.contains('studio')) {
      results = results.where((p) => p.type == 'studio').toList();
    } else if (message.contains('appartement') ||
        message.contains('apartment')) {
      results = results.where((p) => p.type == 'apartment').toList();
    } else if (message.contains('maison') || message.contains('house')) {
      results = results.where((p) => p.type == 'house').toList();
    } else if (message.contains('villa')) {
      results = results.where((p) => p.type == 'villa').toList();
    }

    if (message.contains('vente') ||
        message.contains('acheter') ||
        message.contains('buy')) {
      results = results.where((p) => p.transactionType == 'sale').toList();
    } else if (message.contains('location') ||
        message.contains('louer') ||
        message.contains('rent')) {
      results = results.where((p) => p.transactionType == 'rent').toList();
    }

    if (results.isEmpty) {
      return response +
          'Aucune propriété ne correspond à vos critères.\n\n'
              'Essayez:\n'
              '• "Montre-moi des appartements"\n'
              '• "Studios à louer"\n'
              '• "Maisons à vendre"';
    }

    response += 'Trouvé ${results.length} propriété(s)!\n\n';

    // Show top 3
    final top = results.take(3).toList();
    for (var i = 0; i < top.length; i++) {
      final p = top[i];
      response += '${i + 1}. **${p.title}**\n'
          '   📍 ${p.city}\n'
          '   💰 ${p.price.toStringAsFixed(0)} TND\n'
          '   📏 ${p.surface.toInt()} m²\n\n';
    }

    if (results.length > 3) {
      response += '... et ${results.length - 3} autre(s).\n\n';
    }

    response +=
        'Consultez la page "Carte" pour voir toutes les propriétés et obtenir des itinéraires!';

    return response;
  }

  Map<String, int> _getPropertyCountByType() {
    if (_availableProperties == null) return {};

    final counts = <String, int>{};
    for (var property in _availableProperties!) {
      counts[property.type] = (counts[property.type] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, double> _getAveragePrices() {
    if (_availableProperties == null) return {};

    final sums = <String, double>{};
    final counts = <String, int>{};

    for (var property in _availableProperties!) {
      sums[property.type] = (sums[property.type] ?? 0) + property.price;
      counts[property.type] = (counts[property.type] ?? 0) + 1;
    }

    final averages = <String, double>{};
    sums.forEach((type, sum) {
      averages[type] = sum / counts[type]!;
    });

    return averages;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  static bool isChatbot(String userId) => userId == botUserId;
}
