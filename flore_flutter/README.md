# Florê — Hub da Moda Circular Inteligente

Projeto acadêmico FIAP | SMART HAS 2026  
Parceria técnica: Leroy Merlin Brasil

---

## Sobre o projeto

O Florê é um aplicativo mobile de moda circular que conecta compra, venda e rastreamento de peças de vestuário, promovendo consumo consciente e logística inteligente.

Esta implementação foi desenvolvida em **Flutter**, permitindo uma base de código multiplataforma com foco na experiência mobile.

---

## Equipe

| Nome | RM | Responsabilidade |
|---|---|---|
| Gabriel Notari | 95937 | Arquitetura de rede e monitoramento |
| Priscila Mantovani | 555862 | Implementação mobile Flutter e evolução do projeto |
| Sophie Moreau | 557784 | Mapas, geolocalização e Firebase |

---

## Funcionalidades

- Login e cadastro de usuário, com sessão real via JWT
- Home com resumo de pedidos ativos
- Rastreamento de pedidos com timeline
- Mapa com pontos logísticos e dados climáticos em tempo real (Open-Meteo API)
- Notificações push via Firebase Cloud Messaging
- Perfil com closet circular do usuário: cadastro, edição, remoção e "marcar como vendida"
- Marketplace: compra de peças de outras usuárias, com busca por nome e filtro por categoria

---

## Tecnologias

- **Flutter** + Dart
- **Provider** — gerenciamento de estado
- **Geolocator** — geolocalização
- **Open-Meteo API** — dados climáticos
- **Firebase Cloud Messaging** — notificações push
- **HTTP** — integração com backend Spring Boot

---

## Como rodar

```bash
cd flore_flutter
flutter pub get
flutter run
```

Por padrão o app aponta pro backend rodando localmente (`http://localhost:8080`). Pra apontar
pra um backend publicado, use `--dart-define` (ver [Melhorias desta fase](#melhorias-desta-fase-flutter)):

```bash
flutter run --dart-define=API_BASE_URL=https://seu-backend.exemplo.com
```

---

## Melhorias desta fase (Flutter)

Continuação da evolução técnica do app mobile (Opção B: aprimoramento da solução existente),
com foco em robustez, arquitetura e uma funcionalidade nova visível na demo.

**Robustez — configuração de ambiente via `--dart-define`**
`AuthService`, `ClosetService` e `DeliveryService` apontavam cada um pra sua própria constante
`_baseUrl`, hardcoded pro backend antigo (`flore-back.onrender.com`), hoje **fora do ar**. Criado
`lib/config/app_config.dart`, único ponto de configuração da URL da API (mesmo padrão já usado
pelas chaves do Firebase). Valor de fallback agora é `localhost:8080`, batendo com o ambiente real
de desenvolvimento do backend nesta fase; trocar de ambiente não exige mais mexer em código.

**Arquitetura — `ClosetProvider` como fonte única de estado**
Perfil, Marketplace e Cadastro/Edição de peça cada um mantinha sua própria cópia local da lista
de peças em `State`. Editar uma peça só refletia em outra tela se o resultado voltasse "na mão"
pelo `Navigator.pop`. Criado `lib/providers/closet_provider.dart` (mesmo padrão já usado pelo
`MapProvider`), centralizando "Meu Closet" e "Marketplace": as telas passaram a só cuidar de UI,
e qualquer alteração (criar, editar, remover, marcar vendida, comprar) aparece automaticamente em
todas as telas que dependem do closet.

**Funcionalidade nova — busca e filtro no Marketplace**
Adicionada busca por nome e filtro por categoria (chips gerados dinamicamente a partir dos dados
carregados) na tela de Marketplace, cobertos por testes de widget e de unidade do `ClosetProvider`.

**Cobertura de testes**
13 testes novos (widget do Marketplace + unitários do `ClosetProvider`), incluindo o filtro
combinado busca+categoria e o caso de erro na compra não sendo engolido silenciosamente.

---

## Links

- Site do projeto: [flore-topaz.vercel.app](https://flore-topaz.vercel.app)
- Backend: [github.com/Gabrielnotari/flore-backend-atualizado](https://github.com/Gabrielnotari/flore-backend-atualizado)
