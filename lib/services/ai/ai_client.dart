import 'dart:io';

class AiMessage {
  final String role; // system|user|assistant
  final String? text;
  final List<AiImage>? images; // optional vision
  AiMessage.user(this.text, {this.images}) : role = 'user';
  AiMessage.system(this.text) : role = 'system', images = null;
  AiMessage.assistant(this.text) : role = 'assistant', images = null;
}

class AiImage {
  final File file;
  final String mimeType; // e.g., image/jpeg
  AiImage(this.file, this.mimeType);
}

abstract class AiClient {
  Future<String> chat({required List<AiMessage> messages});
}

