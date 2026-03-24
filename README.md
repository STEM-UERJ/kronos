# Kronos

> App Flutter **offline-first** para rastrear hábitos de estudo e foco. Construído com Clean Architecture e Riverpod, salva sessões localmente via Sqflite e sincroniza relatórios na API do GitHub Gists usando Dio.

---

## Sumário

1. [Domínio: Entidades e Casos de Uso](#1-domínio-entidades-e-casos-de-uso)
2. [Fluxo Git: Criando e Empurrando Branches](#2-fluxo-git-criando-e-empurrando-branches)
3. [Integração com a API do GitHub Gists](#3-integração-com-a-api-do-github-gists)

---

## 1. Domínio: Entidades e Casos de Uso

Seguindo os princípios da Clean Architecture, a camada de domínio é o coração do app — totalmente isolada de bibliotecas externas como Dio ou pacotes de persistência.

### Entidades (Entities)

As entidades representam as regras de negócio centrais.

```dart
// entity: study_session.dart
class StudySession {
  final String id;
  final String subject; // ex: 'Inglês', 'Flutter', 'LLMs'
  final DateTime startTime;
  final DateTime endTime;
  final bool isSynced; // Flag para controle de persistência local vs remota
  final String? notes;

  StudySession({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.isSynced = false,
    this.notes,
  });

  Duration get duration => endTime.difference(startTime);
}
```

### Casos de Uso (Use Cases)

Os casos de uso orquestram o que o usuário pode fazer com essas entidades.

| Caso de Uso | Descrição |
|---|---|
| `StartStudySessionUseCase` | Inicia o cronômetro para uma nova sessão |
| `FinishAndSaveSessionLocallyUseCase` | Finaliza a sessão e salva no banco local com `isSynced: false` |
| `GetLocalStudyHistoryUseCase` | Recupera o histórico de estudos armazenado localmente |
| `SyncSessionsWithRemoteUseCase` *(futuro)* | Busca sessões com `isSynced: false` e envia para a API; atualiza a flag para `true` após sucesso |

---

## 2. Fluxo Git: Criando e Empurrando Branches

Manter um padrão de versionamento limpo é essencial. O fluxo padrão parte da branch principal de desenvolvimento (`dev`).

### Passo 1 — Atualize sua branch base

Antes de criar qualquer coisa, garanta que sua `dev` está atualizada com o remoto.

```bash
git checkout dev
git pull origin dev
```

### Passo 2 — Crie a branch seguindo o padrão

Utilize prefixos semânticos:

- `feat/` — novas funcionalidades (ex: tela de cronômetro)
- `fix/` — correção de bugs
- `refactor/` — reestruturações sem alterar comportamento

```bash
git checkout -b feat/timer-study-session
```

### Passo 3 — Salve suas alterações (Commit)

```bash
git add .
git commit -m "feat: implementa entidade e caso de uso para a sessao de estudos"
```

### Passo 4 — Envie para o repositório remoto (Push)

Como a branch só existe localmente por enquanto, vincule-a ao remoto no primeiro push.

```bash
git push -u origin feat/timer-study-session
```

---

## 3. Integração com a API do GitHub Gists

 Você pode usar os Gists do GitHub como um "banco de dados" remoto para salvar relatórios semanais em formato JSON ou Markdown. A comunicação é feita via `dio`.

### Como criar um TOKEN para modificar o Gist?

#### Passo 1 — Acesse as configurações de token

1. GitHub → clique na sua **foto de perfil** (canto superior direito)
2. **Settings**
3. Menu lateral → **Developer settings**
4. **Personal access tokens** → **Fine-grained tokens** *(recomendado)* ou **Tokens (classic)**

#### Opção A — Fine-grained token *(mais seguro)*

1. Clique em **Generate new token**
2. Dê um nome (ex: `kronos-gist-token`)
3. Em **Expiration**, defina um prazo (ex: 90 dias)
4. Em **Repository access** → não precisa selecionar repositório
5. Em **Permissions** → **Account permissions** → **Gists** → selecione **Read and write**
6. Clique em **Generate token**

#### Opção B — Token classic *(mais simples)*

1. Clique em **Generate new token (classic)**
2. Dê um nome e prazo de expiração
3. Marque o escopo **`gist`**
4. Clique em **Generate token**

#### Passo 2 — Salve o token

> ⚠️ Copie o token gerado imediatamente — **ele não será exibido novamente**.

#### Passo 3 — Usando no app com segurança

Nunca coloque o token diretamente no código. Use `flutter_secure_storage`:

```dart
// Armazenar o token com segurança
final storage = FlutterSecureStorage();
await storage.write(key: 'github_token', value: 'SEU_TOKEN');

// Recuperar para uso no Dio
final token = await storage.read(key: 'github_token');
dio.options.headers['Authorization'] = 'Bearer $token';
```

---

### Referência de Endpoints *(requer autenticação)*

A documentação oficial da API do GitHub (REST API v3) mapeia os métodos HTTP da seguinte forma:

#### `POST` — Criar um novo Gist

Usado para enviar um novo relatório de estudos para a nuvem.

- **Endpoint:** `POST https://api.github.com/gists`
- **Header:** `Authorization: Bearer SEU_TOKEN`

```json
{
  "description": "Relatório de Estudos - Semana 1",
  "public": false,
  "files": {
    "relatorio.json": {
      "content": "{\"ingles_horas\": 5, \"flutter_horas\": 12}"
    }
  }
}
```

#### `GET` — Ler Gists

Usado para buscar o histórico de relatórios já salvos na nuvem.

- **Listar todos:** `GET https://api.github.com/gists`
- **Buscar específico:** `GET https://api.github.com/gists/{gist_id}`

#### `PATCH` — Atualizar um Gist existente

Na API do GitHub, usa-se `PATCH` (não `PUT`) para atualizar o conteúdo. Ideal para adicionar mais horas de estudo a um relatório já criado.

- **Endpoint:** `PATCH https://api.github.com/gists/{gist_id}`

```json
{
  "description": "Relatório de Estudos - Semana 1 (Atualizado)",
  "files": {
    "relatorio.json": {
      "content": "{\"ingles_horas\": 7, \"flutter_horas\": 12}"
    }
  }
}
```

#### `PUT` — Adicionar uma estrela (Star) ao Gist

O método `PUT` na API de Gists tem uma função específica: **favoritar** um gist.

- **Endpoint:** `PUT https://api.github.com/gists/{gist_id}/star`
- **Retorno:** `204 No Content` em caso de sucesso
- Para checar se tem estrela use `GET`, e para remover use `DELETE` na mesma URL.
