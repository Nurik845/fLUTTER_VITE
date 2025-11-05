class AppConfig {
  // OpenAI (ChatGPT) config
  static const openaiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const openaiBaseUrl = String.fromEnvironment(
    'OPENAI_BASE_URL',
    defaultValue: 'https://api.openai.com',
  );
  static const openaiModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );

  // xAI (Grok) config
  static const xaiApiKey = String.fromEnvironment('XAI_API_KEY');
  static const xaiBaseUrl = String.fromEnvironment(
    'XAI_BASE_URL',
    defaultValue: 'https://api.x.ai',
  );
  static const xaiModel = String.fromEnvironment(
    'XAI_MODEL',
    defaultValue: 'grok-2-latest',
  );

  // Hugging Face (free tier)
  static const hfToken = String.fromEnvironment('HF_TOKEN');
  static const hfModel = String.fromEnvironment('HF_MODEL', defaultValue: 'mistralai/Mistral-7B-Instruct-v0.2');

  // OpenStreetMap / Nominatim courtesy email (for polite usage)
  static const osmEmail = String.fromEnvironment('OSM_EMAIL', defaultValue: 'supertown6@gmail.com');

  static bool get hasOpenAi => openaiApiKey.isNotEmpty;
  static bool get hasXai => xaiApiKey.isNotEmpty;
  static bool get hasHf => hfToken.isNotEmpty;
}
