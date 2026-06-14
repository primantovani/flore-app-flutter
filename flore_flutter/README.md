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

- Login e cadastro de usuário
- Home com resumo de pedidos ativos
- Rastreamento de pedidos com timeline
- Mapa com pontos logísticos e dados climáticos em tempo real (Open-Meteo API)
- Notificações push via Firebase Cloud Messaging
- Perfil com closet circular do usuário

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

---

## Links

- Site do projeto: [flore-topaz.vercel.app](https://flore-topaz.vercel.app)
- Backend: [github.com/Gabrielnotari/flore-back](https://github.com/Gabrielnotari/flore-back)
