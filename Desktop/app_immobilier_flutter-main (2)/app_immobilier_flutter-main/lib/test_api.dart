import 'package:http/http.dart' as http;
import 'core/config/app_config.dart';

Future<void> testApi() async {
  try {
    final url = Uri.parse('${AppConfig.baseUrl}/auth/me');
    final response = await http.get(url);
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('API test failed: $e');
    // Continue anyway
  }
}
