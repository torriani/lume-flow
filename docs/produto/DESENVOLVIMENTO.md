# Desenvolvimento e distribuição

## Estrutura do código público

| Caminho | Responsabilidade |
|---|---|
| `src/main.cjs` | Ciclo Electron, IPC, sessão, janelas e coordenação |
| `src/engine.cjs` | Processo do motor e requisições de reconhecimento |
| `src/core.cjs` | WAV incremental, correção, formatação, proteção de sessão |
| `src/store.cjs` | SQLite, migrações aditivas, histórico e preferências |
| `src/hotkeys.cjs` | Máquina de estados Fn/Fn + Espaço |
| `src/recovery.cjs` | Conversão e nova transcrição de áudio salvo |
| `src/insights.cjs` | Contagem, classificação e agregação |
| `src/import-history.cjs` | Importação local idempotente de histórico |
| `src/import-wispr.cjs` | Dicionário, estilos e metadados de uso |
| `src/sounds.cjs` | Sons por evento e preferência |
| `src/preload.cjs` | Ponte IPC limitada |
| `native/` | Helper Objective-C e predicado do atalho |
| `ui/` | Interface, overlay, captura e AudioWorklet |
| `scripts/` | Build nativo, motor, modelos, empacotamento e exportação |
| `tests/` | Testes Node e teste C do atalho |

O assistente de importação local acrescenta `import-onboarding.cjs` e `import-worker.cjs`; esses arquivos estão no código de desenvolvimento, mas ainda não fazem parte dos instaladores públicos. Consulte [versões](VERSOES.md).

## Requisitos para desenvolver

macOS 14+, Xcode Command Line Tools, Node 22.13+, npm, Git, CMake e Python 3 para ferramentas auxiliares. Os alunos não precisam instalar essas dependências ao usar o pacote pronto.

```sh
git clone https://github.com/torriani/lume-flow.git
cd lume-flow
npm ci
npm test
npm run native
sh scripts/build-engine.sh
npm run models
npm run package
```

Para Intel, defina `export LUME_ARCH=x64` antes de compilar helper, motor e pacote. O build normaliza para `x86_64` no compilador e verifica a arquitetura dos binários. Não reaproveite silenciosamente um motor arm64 num pacote x64. A saída é `build/releases/LumeFlow-darwin-<arquitetura>/LumeFlow.app`.

`LUME_SDKROOT` permite escolher SDK compatível quando houver conflito local de Command Line Tools. `LUME_CMAKE` permite especificar o executável CMake. São opções de build, não dependências pessoais necessárias ao usuário final.

## Dependências e integridade

Electron 44.7.2 e dependências npm são resolvidos pelo lockfile. whisper.cpp usa v1.8.7, commit `48f628a84833905ee4a0658ee6d4a5c915ce1997`. Os modelos são obtidos pelo script de download com SHA-256 esperado. Caminhos pessoais do ambiente de compilação são remapeados por `-ffile-prefix-map`. A receita é repetível, mas binários não são garantidos idênticos entre SDKs.

Os pesos e o Electron explicam a maior parte dos cerca de 660 MB de cada ZIP público. Há dois downloads separados; cada pessoa baixa somente a arquitetura do seu Mac. Não são dois componentes obrigatórios da instalação.

## Isolamento para testes

Use um perfil sintético separado via `LUME_DATA_DIR`. Não rode importação ou testes de escrita contra dados reais. `LUME_TEST_FIXTURE` permite injetar PCM de um WAV somente em execução não empacotada. Essa injeção não comprova microfone nem interação física com Fn.

```sh
npm test
clang tests/native-shortcut.c -o /tmp/lumeflow-shortcut-test
/tmp/lumeflow-shortcut-test
```

`scripts/smoke-engine.cjs` recebe WAV PCM16 mono 16 kHz com frase sintética contendo “teste”; verifica reconhecimento e silêncio. Gera resultados em `.local`, que não devem ser publicados como histórico de usuário. Para execução de desenvolvimento, compile os componentes e use `npm start`.

## Segurança do runtime

Renderers usam `contextIsolation`, sandbox e `nodeIntegration: false`. O main valida a janela e o frame chamadores. O overlay só pode invocar a ação de parar. Novas janelas e navegação são bloqueadas. O renderer de captura recebe mídia somente com a permissão de microfone concedida. Essas medidas reduzem superfície de ataque; não equivalem a uma auditoria independente.

## Publicar uma nova prévia

1. Conferir WIP e decidir o conjunto exato de código que será entregue.
2. Atualizar versão, lockfile, documentação e matriz de evidências.
3. Rodar testes e validar fluxo físico em Mac limpo; registrar o que continua pendente.
4. Compilar separadamente as arquiteturas e conferir dependências com `otool`/`lipo`.
5. Gerar app por lista permitida; conferir assinatura com `codesign --verify --deep --strict`.
6. Revisar fonte e ZIPs: nenhum perfil, banco, gravação, chave, log pessoal ou caminho privado.
7. Criar hashes dos arquivos finais; publicar código e criar release como **pre-release**.
8. Anexar ZIPs de aplicativo, fonte e arquivo SHA-256. Comparar tamanho/hash local com os ativos recebidos pelo GitHub antes de divulgar.

`npm run source` gera ZIP de código por lista permitida. `build`, `.local`, `node_modules` e arquivos pessoais não pertencem ao commit. A licença MIT do código não substitui as atribuições de Whisper, Silero, Electron e fontes.

A assinatura ad-hoc permite verificar integridade local, mas não equivale a Developer ID/notarização. Uma release estável exige esse trabalho, incluindo hardened runtime e entitlements adequados, além da matriz de compatibilidade. Não anunciar aprovação de CI quando os jobs sequer começaram.

## Prioridades abertas

- Validar o primeiro ditado após repouso, incluindo primeiras sílabas e latência.
- Concluir teste visual do Stop exclusivo do modo fixo.
- Validar assistente de importação em instalação limpa e esquemas diferentes.
- Reunir histórico/dicionário/estilos numa migração opcional com escopo claro.
- Testar Intel físico, outro Apple Silicon e versões do macOS.
- Assinar/notarizar e definir atualização de aplicativo.
- Melhorar segmentação com sobreposição e calibração de volume.
- Avaliar retenção/exclusão de áudio e preferências de memória.

São itens de evolução, não funcionalidades já entregues. Contribuições: [CONTRIBUTING](../../CONTRIBUTING.md). Vulnerabilidades: [SECURITY](../../SECURITY.md).
