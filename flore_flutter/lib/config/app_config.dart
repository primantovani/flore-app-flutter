/// Configuração de ambiente do app.
///
/// Antes cada serviço (`AuthService`, `ClosetService`, `DeliveryService`)
/// tinha sua própria constante `_baseUrl` hardcoded apontando pro backend
/// antigo (`flore-back.onrender.com`, hoje fora do ar). Centralizando aqui
/// e expondo via `--dart-define`, dá pra trocar de ambiente sem tocar em
/// código — mesmo padrão já usado pelas chaves do Firebase (Melhoria H).
///
/// Padrão: aponta pro backend publicado no Render (fork com as correções
/// de build necessárias pra rodar em produção — ver README do backend).
/// Plano free do Render "dorme" com inatividade; a primeira chamada depois
/// de um tempo parado pode demorar ~50s pra responder.
///   flutter run
///
/// Rodando o backend local durante o desenvolvimento:
///   flutter run --dart-define=API_BASE_URL=http://localhost:8080
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://flore-backend-atualizado.onrender.com',
  );

  /// Timeout único das chamadas HTTP. Era 8s em cada serviço — curto demais
  /// pro cold start do Render (plano free, pode levar ~50s pra acordar),
  /// o que fazia a primeira chamada depois de um tempo parado falhar com
  /// "algo deu errado" mesmo o backend estando saudável, só lento pra subir.
  static const Duration requestTimeout = Duration(seconds: 60);
}
