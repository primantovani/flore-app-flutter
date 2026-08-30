/// Configuração de ambiente do app.
///
/// Antes cada serviço (`AuthService`, `ClosetService`, `DeliveryService`)
/// tinha sua própria constante `_baseUrl` hardcoded apontando pro backend
/// antigo (`flore-back.onrender.com`, hoje fora do ar). Centralizando aqui
/// e expondo via `--dart-define`, dá pra trocar de ambiente sem tocar em
/// código — mesmo padrão já usado pelas chaves do Firebase (Melhoria H).
///
/// Local (padrão, backend rodando em `flutter run` na própria máquina):
///   flutter run
///
/// Apontando pra um backend publicado:
///   flutter run --dart-define=API_BASE_URL=https://seu-backend.exemplo.com
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
