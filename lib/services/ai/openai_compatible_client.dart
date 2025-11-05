import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'ai_client.dart';

class OpenAiCompatibleClient implements AiClient {
  final String apiKey;
  final String baseUrl; // e.g., https://api.openai.com or https://api.x.ai
  final String chatPath; // e.g., /v1/chat/completions
  final String model;

  OpenAiCompatibleClient({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    this.chatPath = '/v1/chat/completions',
  });

  @override
  Future<String> chat({required List<AiMessage> messages}) async {
    final url = Uri.parse(baseUrl + chatPath);

    final converted = messages.map((m) {
      if (m.images != null && m.images!.isNotEmpty) {
        final content = <Map<String, dynamic>>[];
        if ((m.text ?? '').isNotEmpty) {
          content.add({'type': 'text', 'text': m.text});
        }
        for (final img in m.images!) {
          final bytes = img.file.readAsBytesSync();
          final b64 = base64Encode(bytes);
          content.add({
            'type': 'image_url',
            'image_url': {'url': 'data:${img.mimeType};base64,$b64'},
          });
        }
        return {
          'role': m.role,
          'content': content,
        };
      }
      return {
        'role': m.role,
        'content': [{
          'type': 'text',
          'text': m.text ?? '',
        }],
      };
    }).toList();

    final body = jsonEncode({
      'model': model,
      'messages': converted,
      'temperature': 0.2,
    });

    final res = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $apiKey',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: body,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('AI error ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    // OpenAI-style response
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return '';
    final msg = choices.first['message'] as Map<String, dynamic>;
    final content = msg['content'];
    if (content is String) return content;
    if (content is List) {
      // May be a list of content parts
      final texts = content.whereType<Map>().where((p) => p['type'] == 'text').map((p) => p['text']).whereType<String>();
      return texts.join('\n');
    }
    return '';
  }
}

