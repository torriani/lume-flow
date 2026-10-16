# Documentação do LumeFlow

LumeFlow é um aplicativo independente de ditado para macOS. Você fala, o áudio é preservado localmente, o motor produz texto e o aplicativo tenta inseri-lo no campo escolhido. O código é MIT; os modelos e dependências têm suas próprias atribuições em [NOTICE](../../NOTICE.md).

**Referência: 15/10/2026.** Esta documentação diferencia a release pública `v0.2.0-preview.1` das alterações 0.2.1 em desenvolvimento. Não representa certificação de segurança, compatibilidade universal ou equivalência funcional ao Wispr Flow.

## Por onde começar

| Documento | Conteúdo |
|---|---|
| [Estado das versões](VERSOES.md) | O que está publicado, instalado localmente ou apenas preparado |
| [Manual de uso](MANUAL.md) | Atalhos, indicador, histórico, estilos e Insights |
| [Como funciona](FUNCIONAMENTO.md) | Captura, transcrição, foco, memória e estados |
| [Importação e dados](DADOS.md) | Migração do Wispr, banco, áudios, backup e privacidade |
| [Limitações e diagnóstico](LIMITACOES.md) | O que não faz e como investigar falhas |
| [Desenvolvimento e distribuição](DESENVOLVIMENTO.md) | Estrutura, build, testes, publicação e próximos passos |
| [Instalação para alunos](../INSTALACAO.md) | Requisitos e permissões no Mac de destino |
| [Checklist de release](../RELEASE-CHECKLIST.md) | Evidências e pendências antes de uma versão estável |

## Objetivo e público

Para quem dita mensagens, prompts, e-mails e anotações em campos de outros aplicativos. A entrada principal é o teclado com Fn/Globo. O produto não depende de LIA Reuniões, REA, Hopper, Claude ou Codex para funcionar. Não é um gravador de reuniões nem um assistente que executa os comandos ditados.

## Fluxo principal

1. Autorizar microfone, Acessibilidade e Monitoração de Entrada no próprio Mac.
2. Iniciar o ditado com Fn ou Fn + Espaço.
3. Falar e selecionar o campo de destino antes de finalizar.
4. Encerrar, aguardar a transcrição e conferir o texto inserido.
5. Se necessário, abrir o histórico para ouvir, copiar, editar ou recuperar.

Cada pessoa começa com um perfil vazio. Os instaladores públicos não carregam dados pessoais de desenvolvimento.
