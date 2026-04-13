# How Build a Feature (Kronos)

Este guia descreve o passo a passo para criar uma feature neste projeto, seguindo o padrão atual de arquitetura, DI, rotas e testes.

## 1) Criar a estrutura de pastas da feature

Dentro de `lib/features/<feature_name>/`, use a estrutura:

- `data/`
  - `source/`
  - `repositories/`
- `domain/`
  - `entities/`
  - `repositories/`
  - `usecases/`
- `presenter/`
  - `logic/`
  - `page/`
  - `components/`
- `di/`
- `route/`

## 2) Definir entidades da feature

Crie as entidades em `domain/entities/<feature>_entities.dart`.

Regras:
- Entidades devem representar o domínio (não modelo de banco/API).
- Prefira classes imutáveis com construtor `const` quando possível.

## 3) Definir contratos da camada data

### 3.1 Source contract

Crie `data/source/<feature>_source.dart` com interface de acesso ao dado bruto.

Exemplo de assinatura:
- `Future<T> ...`

### 3.2 Repository contract

Crie `domain/repositories/<feature>_repository.dart`.

Regra do projeto:
- Método assíncrono: usar `AsyncResult<T>` (alias de `Future<T>`).
- Método síncrono: usar `Result<T>` (alias direto).

Base em `lib/core/contracts/use_case_contract.dart`.

## 4) Criar implementação do repository

Crie `data/repositories/<feature>_repository_impl.dart`.

Padrão atual:
- Recebe o source por construtor.
- Implementa o contrato do repository.
- Se a feature ainda não for implementada, deixar esqueleto com `throw UnimplementedError();`.

Observação:
- Quando houver regra de anticorrupção de erro (exemplo da config), mapear exceções genéricas para erro de domínio.

## 5) Definir contratos de use case

Crie `domain/usecases/<feature>_usecase_contracts.dart`.

Padrão:
- Params com `UseCaseParams`.
- Use case com `UseCase<TOutput, TParams>`.
- Use `NoParams` quando aplicável.

## 6) Criar implementação dos use cases

Crie `domain/usecases/<feature>_usecases.dart`.

Padrão:
- Receber repository no construtor.
- Delegar para repository quando já houver implementação.
- Se ainda não houver regra pronta, manter esqueleto com `throw UnimplementedError();`.

## 7) Criar BLoC da feature

Arquivos em `presenter/logic/`:
- `<feature>_event.dart`
- `<feature>_state.dart`
- `<feature>_bloc.dart`

Padrão:
- BLoC recebe use cases no construtor.
- Registra handlers com `on<Event>(handler)`.
- Pode iniciar em estado `Initial`.
- Em estágio de esqueleto, handlers podem lançar `UnimplementedError()`.

## 8) Criar página da feature

Crie `presenter/page/<feature>_page.dart` com a tela inicial.

## 9) Criar rota da feature

Crie `route/<feature>_route.dart`.

Padrão atual:
- `GoRoute` da feature.
- `BlocProvider` no `builder`.
- Disparo de evento inicial no `create`.

Exemplo do padrão do projeto:
- `create: (_) => sl<FeatureBloc>()..add(const FeatureStarted())`

## 10) Registrar DI da feature

Crie/atualize `di/<feature>_di.dart`.

Padrão:
1. Registrar source (se existir).
2. Registrar repository.
3. Registrar use cases.
4. Registrar bloc.

Use `GetIt` com verificações `isRegistered` para evitar dupla inscrição.

## 11) Conectar no DI global

Atualize `lib/core/di/getit.dart`:
- Import da DI da feature.
- Chamada `setup<Feature>FeatureDI(sl);` em `setupLocator()`.

## 12) Conectar no roteador

Atualize:
- `lib/core/router/routes.dart` (constante de path, se nova rota).
- `lib/core/router/router.dart` (adicionar branch/route da feature).

## 13) Testes obrigatórios por camada

Pasta de testes: `test/features/<feature>/...`

### 13.1 Repository tests

Regra do projeto:
- Testar implementação real do repository (`<feature>_repository_impl.dart`).
- Mockar apenas o source (`<feature>_source.dart`) com Mockito.

Padrão Mockito recomendado:
- `@GenerateNiceMocks([MockSpec<FeatureSource>()])`
- Arquivo `.mocks.dart` gerado por build_runner.

Cenários mínimos:
- Sucesso.
- Erro propagado/mapeado.

### 13.2 Use case tests

Regra:
- Testar implementação real de use case.
- Mockar repository.

Cenários mínimos:
- Sucesso.
- Erro.

### 13.3 Bloc tests

Regra:
- Testar bloc real.
- Mockar use cases.
- Usar `bloc_test` + `mocktail`.

Cenários mínimos:
- Fluxo de sucesso (estados esperados).
- Fluxo de erro (estado de falha ou erro esperado).

## 14) Gerar mocks e validar

Gerar mocks Mockito:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Rodar testes:

```bash
flutter test test/features/<nome_da_feature>
```

## 15) Checklist rápido

- Estrutura da feature criada.
- Entidades de domínio criadas.
- Contrato de source criado.
- Contrato de repository com AsyncResult/Result.
- Repository impl criado (ou esqueleto com UnimplementedError).
- Contratos de use case criados.
- Use cases impl criados (ou esqueleto com UnimplementedError).
- Bloc/Event/State criados.
- Page criada.
- Rota criada.
- DI da feature registrada.
- DI global atualizado.
- Router global atualizado.
- Testes de repository/usecase/bloc criados.
- Mocks gerados com build_runner.

---

Se você seguir esta sequência, consegue criar qualquer feature no Kronos com consistência arquitetural e facilidade de manutenção.