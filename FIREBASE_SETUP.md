# Configuração do Firebase — Adote Um Pet

Este documento descreve como configurar o Firebase para o projeto **Adote Um Pet**.
Nenhum arquivo de credenciais deve ser commitado no repositório — todos estão listados no `.gitignore`.

---

## Pré-requisitos

| Ferramenta | Versão mínima | Instalação |
|---|---|---|
| Flutter SDK | 3.41.x | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.10.x | Incluído no Flutter |
| Firebase CLI | 13.x | `npm install -g firebase-tools` |
| FlutterFire CLI | 1.x | `dart pub global activate flutterfire_cli` |
| Node.js | 18.x | [nodejs.org](https://nodejs.org) |

---

## 1. Criar o projeto no Firebase Console

1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. Clique em **Adicionar projeto**
3. Nome sugerido: `adote-um-pet`
4. Desative o Google Analytics (opcional para MVP)
5. Clique em **Criar projeto**

---

## 2. Ativar os serviços necessários

### Firebase Authentication

1. No menu lateral, acesse **Authentication → Começar**
2. Na aba **Sign-in method**, ative:
   - **E-mail/senha** → Ativar → Salvar

### Cloud Firestore

1. No menu lateral, acesse **Firestore Database → Criar banco de dados**
2. Selecione **Modo de produção** (as regras de segurança serão configuradas abaixo)
3. Escolha a região: `southamerica-east1` (São Paulo)

### Firebase Storage

1. No menu lateral, acesse **Storage → Começar**
2. Selecione **Modo de produção**
3. Mesma região: `southamerica-east1`

---

## 3. Registrar os apps no Firebase

### Android

1. No console, clique em **Adicionar app → Android**
2. **Package name:** `br.com.adoteumpet.app`
3. Apelido: `Adote Um Pet Android`
4. Baixe o arquivo `google-services.json`
5. Coloque em: `android/app/google-services.json`

> **Atenção:** Este arquivo está no `.gitignore` e **nunca deve ser commitado**.
> Use `android/app/google-services.json.template` como referência.

### iOS

1. No console, clique em **Adicionar app → iOS**
2. **Bundle ID:** `br.com.adoteumpet.app`
3. Apelido: `Adote Um Pet iOS`
4. Baixe o arquivo `GoogleService-Info.plist`
5. Coloque em: `ios/Runner/GoogleService-Info.plist`

> **Atenção:** Este arquivo está no `.gitignore` e **nunca deve ser commitado**.
> Use `ios/Runner/GoogleService-Info.plist.template` como referência.

---

## 4. Gerar o firebase_options.dart com FlutterFire CLI

Na raiz do projeto, execute:

```bash
# Faça login no Firebase CLI
firebase login

# Configure o FlutterFire para o projeto
flutterfire configure --project=SEU_PROJECT_ID
```

O comando irá:
- Detectar automaticamente os apps Android e iOS registrados
- Gerar o arquivo `lib/firebase_options.dart`

> **Atenção:** `lib/firebase_options.dart` está no `.gitignore` e **nunca deve ser commitado**.
> Use `lib/firebase_options.dart.template` como referência da estrutura esperada.

---

## 5. Instalar dependências e executar

```bash
flutter pub get
flutter run
```

---

## 6. Configurar regras de segurança do Firestore

No Firebase Console → Firestore → Regras, aplique:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── Usuários ─────────────────────────────────────────────────────────────
    match /users/{userId} {
      // Leitura pública de dados não sensíveis
      allow read: if request.auth != null;
      // Escrita apenas pelo próprio usuário
      allow write: if request.auth != null && request.auth.uid == userId;

      // Favoritos — apenas o próprio usuário
      match /favorites/{petId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // ── Pets ──────────────────────────────────────────────────────────────────
    match /pets/{petId} {
      // Qualquer usuário autenticado pode ver pets disponíveis
      allow read: if request.auth != null;
      // Criar: qualquer usuário autenticado
      allow create: if request.auth != null
        && request.resource.data.ownerId == request.auth.uid;
      // Atualizar/deletar: apenas o dono
      allow update, delete: if request.auth != null
        && resource.data.ownerId == request.auth.uid;
    }

    // ── Chats ─────────────────────────────────────────────────────────────────
    match /chats/{chatId} {
      // Apenas participantes do chat podem ler
      allow read: if request.auth != null
        && (resource.data.requesterId == request.auth.uid
          || resource.data.ownerId == request.auth.uid);
      // Criar: qualquer usuário autenticado
      allow create: if request.auth != null
        && request.resource.data.requesterId == request.auth.uid;
      // Atualizar (lastMessage, lastMessageTime): apenas participantes
      allow update: if request.auth != null
        && (resource.data.requesterId == request.auth.uid
          || resource.data.ownerId == request.auth.uid);

      // Mensagens
      match /messages/{messageId} {
        allow read: if request.auth != null
          && (get(/databases/$(database)/documents/chats/$(chatId)).data.requesterId == request.auth.uid
            || get(/databases/$(database)/documents/chats/$(chatId)).data.ownerId == request.auth.uid);
        allow create: if request.auth != null
          && request.resource.data.senderId == request.auth.uid;
        allow update: if request.auth != null;
      }
    }
  }
}
```

---

## 7. Configurar regras do Firebase Storage

No Firebase Console → Storage → Regras, aplique:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Fotos de pets — leitura pública, escrita apenas pelo dono
    match /pets/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Fotos de perfil — leitura pública, escrita apenas pelo próprio usuário
    match /profiles/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 8. Estrutura das coleções no Firestore

### `users/{uid}`

```json
{
  "uid": "string",
  "displayName": "string",
  "email": "string",
  "photoUrl": "string | null",
  "bio": "string | null",
  "city": "string | null",
  "state": "string | null",
  "phone": "string | null",
  "whatsapp": "string | null",
  "instagram": "string | null",
  "showLocation": false,
  "showContact": false,
  "createdAt": "timestamp"
}
```

### `pets/{petId}`

```json
{
  "ownerId": "string",
  "name": "string",
  "species": "dog | cat | bird | rabbit | other",
  "breed": "string",
  "age": "string",
  "gender": "male | female",
  "size": "small | medium | large | giant",
  "color": "string",
  "description": "string",
  "city": "string",
  "state": "string",
  "photos": ["url1", "url2"],
  "status": "available | adopted | paused",
  "health": {
    "vaccinated": "true | false | null",
    "neutered": "true | false | null",
    "dewormed": "true | false | null"
  },
  "createdAt": "timestamp"
}
```

### `chats/{chatId}`

```json
{
  "requesterId": "string",
  "requesterName": "string",
  "ownerId": "string",
  "ownerName": "string",
  "petId": "string",
  "petName": "string",
  "petPhoto": "string",
  "lastMessage": "string",
  "lastMessageTime": "timestamp",
  "createdAt": "timestamp"
}
```

### `chats/{chatId}/messages/{messageId}`

```json
{
  "senderId": "string",
  "text": "string",
  "timestamp": "timestamp",
  "read": false
}
```

---

## 9. Arquivos sensíveis — resumo do .gitignore

Os seguintes arquivos **nunca devem ser commitados**:

| Arquivo | Motivo |
|---|---|
| `android/app/google-services.json` | Credenciais Android |
| `ios/Runner/GoogleService-Info.plist` | Credenciais iOS |
| `lib/firebase_options.dart` | Gerado pelo FlutterFire CLI com API keys |
| `*.env` | Variáveis de ambiente locais |
| `.env.local` | Variáveis de ambiente locais |

Use os arquivos `.template` correspondentes como documentação da estrutura esperada.

---

## 10. Variáveis de ambiente para CI/CD

Para pipelines de CI/CD (GitHub Actions, Bitrise, etc.), injete as credenciais como secrets:

```yaml
# .github/workflows/build.yml (exemplo)
- name: Decode google-services.json
  run: echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 -d > android/app/google-services.json

- name: Decode GoogleService-Info.plist
  run: echo "${{ secrets.GOOGLE_SERVICE_INFO_PLIST }}" | base64 -d > ios/Runner/GoogleService-Info.plist

- name: Create firebase_options.dart
  run: echo "${{ secrets.FIREBASE_OPTIONS_DART }}" | base64 -d > lib/firebase_options.dart
```

Para gerar os valores base64:
```bash
base64 -i android/app/google-services.json | tr -d '\n'
base64 -i ios/Runner/GoogleService-Info.plist | tr -d '\n'
base64 -i lib/firebase_options.dart | tr -d '\n'
```

---

## Suporte

Em caso de dúvidas, consulte a [documentação oficial do Firebase para Flutter](https://firebase.google.com/docs/flutter/setup).
