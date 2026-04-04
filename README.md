# 🐾 Adote Um Pet

> Conectando corações e patinhas — plataforma mobile para adoção responsável de animais.

---

## Sobre o Projeto

**Adote Um Pet** é um aplicativo Flutter que conecta pessoas com animais disponíveis para doação a pessoas dispostas a adotá-los. A proposta central é simplificar e humanizar o processo de adoção, tornando-o acessível, seguro e afetivo.

Este repositório contém o **MVP (Minimum Viable Product)** — uma versão funcional com dados mock, sem integração com backend, destinada à validação da hipótese de produto.

---

## Funcionalidades do MVP

| Funcionalidade | Status |
|---|---|
| Tela de Login (mock) | ✅ |
| Tela de Cadastro (mock) | ✅ |
| Quiz de Estilo de Vida (adotantes) | ✅ |
| Feed de Animais com filtros | ✅ |
| Detalhes do Animal com galeria | ✅ |
| Favoritar animais | ✅ |
| Chat entre adotante e doador (mock) | ✅ |
| Dashboard do Doador (Meus Pets) | ✅ |
| Cadastro de novo pet (mock) | ✅ |
| Perfil do usuário | ✅ |
| Navegação por tipo de usuário | ✅ |

---

## Arquitetura

O projeto segue **MVVM com Arquitetura em Camadas**:

```
lib/
├── config/             # Tema e roteamento (GoRouter)
├── core/
│   ├── constants/      # Cores, tipografia, dimensões
│   └── widgets/        # Widgets reutilizáveis globais
├── data/
│   └── datasources/
│       └── mock/       # Dados mock para o MVP
├── domain/
│   └── entities/       # Entidades de domínio (Pet, AppUser, Chat)
└── presentation/
    ├── pages/          # Telas do aplicativo
    ├── providers/      # Providers Riverpod (state management)
    └── widgets/        # Widgets de apresentação reutilizáveis
```

---

## Stack Técnica

| Categoria | Tecnologia |
|---|---|
| Framework | Flutter 3.27+ |
| Linguagem | Dart 3.6+ |
| State Management | Riverpod 2.x |
| Navegação | GoRouter 14.x |
| Cache de Imagens | cached_network_image |
| Internacionalização | intl |
| Identificadores únicos | uuid |

---

## Design System

- **Fonte:** Nunito (Google Fonts) — amigável e legível
- **Cor Primária:** `#FF8A65` (Coral) — calor e afeto
- **Cor Secundária:** `#4DB6AC` (Azul-verde) — confiança e saúde
- **Escala de espaçamento:** 4pt base
- **Material Design 3** com customizações

---

## Como Executar

### Pré-requisitos

- Flutter SDK 3.27+
- Dart SDK 3.6+
- Android Studio / VS Code com extensão Flutter

### Instalação

```bash
# Clone o repositório
git clone https://github.com/renexe/adoteumpet.git
cd adoteumpet

# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

> **Nota:** Esta versão MVP utiliza dados mock. Não é necessário configurar Firebase ou qualquer backend.

---

## Estrutura de Branches

| Branch | Descrição |
|---|---|
| `main` | Branch principal — código estável |
| `feat/initial-setup` | Setup inicial do MVP |

---

## Roadmap

- **Fase 1 (atual):** MVP com dados mock — validação da hipótese
- **Fase 2:** Integração com Firebase (Auth + Firestore + Storage)
- **Fase 3:** Chat em tempo real, notificações push
- **Fase 4:** Sistema de avaliações, verificação de doadores

---

## Contribuindo

1. Crie uma branch a partir de `main`: `git checkout -b feat/nome-da-feature`
2. Faça suas alterações seguindo os padrões do projeto
3. Execute `flutter analyze` para garantir zero issues
4. Abra uma Pull Request descrevendo as mudanças

---

## Licença

Este projeto é privado e pertence aos seus mantenedores.
