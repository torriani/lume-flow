# Importação, dados e privacidade

## Dados locais

Pasta padrão por usuário macOS: `~/Library/Application Support/Lume Flow`.

| Item | Conteúdo |
|---|---|
| `lume.sqlite` | Ditados, correções, preferências, registros e métricas importados |
| `audio/` | WAVs próprios e áudios compatíveis importados |
| Arquivos auxiliares do Electron/SQLite | Cache, preferências de runtime e WAL/SHM quando presentes |

As tabelas principais são `recordings`, `corrections`, `settings`, `imported_history` e `imported_usage`. Registros guardam texto bruto/final/original, data, duração, nome do arquivo de áudio, categoria, aplicativo, contagem de palavras e diagnóstico de colagem. O PID usado no destino não é uma identidade persistente do aplicativo.

Áudio PCM16 mono a 16 kHz usa cerca de 32 KB por segundo, 1,92 MB por minuto, fora cabeçalho e metadados. Não há expiração automática: o histórico cresce conforme o uso. Cancelar também preserva o áudio recebido.

Banco e arquivos de áudio são criados com permissões locais restritas. Isso **não é criptografia própria do aplicativo**. Proteção do disco, backups e acesso à conta dependem do macOS e das configurações da pessoa. O aplicativo não oferece cofre, login, criptografia de ponta a ponta ou isolamento entre programas do mesmo usuário.

## Importar histórico do Wispr Flow

### Release pública 0.2.0

Inclui ferramentas de desenvolvimento para importação. Não apresenta a pergunta automática de primeira abertura. A importação realizada no ambiente do autor não é embarcada na release.

### Assistente 0.2.1 em desenvolvimento, disponível no código, ainda fora dos instaladores públicos

Na primeira abertura de um perfil elegível, apresenta “Importar histórico” e “Agora não”. Uma importação anterior registrada evita repetir o convite. Recusar não lê o banco do Wispr; a decisão é lembrada. O menu LumeFlow permite tentar depois.

Após confirmação, procura `~/Library/Application Support/Wispr Flow/flow.sqlite`. Se não encontrar, oferece selecionar um banco SQLite. Um worker executa a importação para não bloquear o event loop principal. Novos ditados e recuperação ficam impedidos durante a operação; sair normalmente também é bloqueado até concluir. Não há botão para cancelar uma importação em andamento nem percentual de progresso implementado.

### O que é transferido

Textos ditados disponíveis na tabela `History`, datas, duração, contagens, aplicativo, classificação e áudio WAV compatível. A escolha de texto prioriza versão editada, colada, formatada e por último transcrição bruta. O original é preservado separadamente quando disponível.

A leitura do banco de origem é somente leitura. Os registros usam identificadores do Wispr para evitar duplicação. Repetir pode atualizar métricas e preencher áudio que estava ausente; não substitui indiscriminadamente revisões locais do texto. Um relatório informa novos/existentes, áudios copiados/ausentes/não suportados e registros ignorados.

### O que não é transferido pelo assistente de histórico

- Dados existentes apenas na conta/nuvem do Wispr.
- Áudio que não esteja no banco local ou não seja RIFF/WAVE compatível.
- Screenshots, contexto de telas, credenciais, sessões de login ou cookies.
- Dicionário e estilos: existem ferramentas separadas no código para esses dados; o novo assistente de **histórico** ainda não as reúne.

As ferramentas separadas `scripts/extract-wispr.py` e `src/import-wispr.cjs` trabalham com dicionário, preferências e metadados de uso. São ferramentas para desenvolvimento e não representam um botão de migração completa disponível na interface publicada.

Mudanças no esquema do Wispr podem quebrar a leitura. Banco bloqueado/indisponível pode exigir fechar o Wispr e tentar novamente. Não há login ou chamada ao serviço do Wispr. O projeto é independente e não é afiliado ao produto de origem.

A transação protege os registros SQLite. Cópias de áudio são arquivos separados: em falha, podem restar arquivos sem referência até nova tentativa; não há garantia de atomicidade entre banco e filesystem. Não apague dados originais com base apenas em um total de importação.

## Backup e outro Mac

Preferências → Exportar backup gera uma pasta pessoal com uma cópia consistente de `lume.sqlite`, `audio/` e instruções. Esse backup contém dados privados; não o anexe à release ou a issues.

Para restaurar em instalação limpa: feche o aplicativo, preserve uma cópia do perfil de destino se houver dados, copie banco e pasta de áudio para o diretório de dados e reabra. Não é uma ferramenta de mesclagem de dois perfis. As permissões de Microfone/Acessibilidade/Monitoração precisam ser concedidas novamente no Mac destino; elas não são transportadas no backup.

## Distribuição e suporte

Releases incluem somente aplicativo, motor, modelos, assets próprios e licenças. `npm run source` usa lista permitida para excluir `.local`, `build`, dependências e perfis pessoais do ZIP de fonte. Ainda é necessária revisão dos artefatos finais antes de publicar.

Envie ao suporte passos, versão, arquitetura e mensagem de erro. Não envie banco, backup, gravações ou transcrições pessoais em issues públicas. Vulnerabilidades: [reporte privado](https://github.com/torriani/lume-flow/security/advisories/new).
