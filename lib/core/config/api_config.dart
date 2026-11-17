const String kDefaultApiBaseUrl = 'https://yordy.shop/api/v1';

const bool kEnableDemoLogin = bool.fromEnvironment(
  'ENABLE_DEMO_LOGIN',
  defaultValue: false,
);

const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: kDefaultApiBaseUrl,
);
const String kApiFallbackBaseUrl = String.fromEnvironment(
  'API_FALLBACK_BASE_URL',
  defaultValue: kDefaultApiBaseUrl,
);
const String kBaseUrl = 'https://yordy.shop';
