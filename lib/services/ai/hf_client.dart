import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'ai_client.dart';

class HfClient implements AiClient {
  final String token;
  final String model; // e.g. mistralai/Mistral-7B-Instruct-v0.2
  HfClient({required this.token, required this.model});

  @override
  Future<String> chat({required List<AiMessage> messages}) async {
    final url = Uri.parse('https://api-inference.huggingface.co/models/$model');
    // Construct a simple prompt from chat messages
    final prompt = messages.map((m) {
      final tag = m.role.toUpperCase();
      final text = m.text ?? '';
      return '[$tag] $text';
    }).join('\n');

    final body = jsonEncode({
      'inputs': prompt,
      'parameters': {'max_new_tokens': 256, 'temperature': 0.2},
    });
    final res = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: body,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HF error ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body);
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      final out = first['generated_text'] ?? first.toString();
      return out is String ? out : out.toString();
    }
    if (data is Map && data['generated_text'] is String) {
      return data['generated_text'];
    }
    return data.toString();
  }
}

