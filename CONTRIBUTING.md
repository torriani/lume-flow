# Como contribuir com o LumeFlow

O LumeFlow é um projeto aberto sob licença MIT. Você pode estudar, modificar, distribuir e criar sua própria versão, respeitando a licença e os avisos das dependências.

## Propor uma mudança

1. Abra uma issue em português explicando o problema ou a ideia. Para alterações grandes, discuta o escopo antes de implementar.
2. Faça um fork do repositório para a sua conta.
3. Crie uma branch para a alteração e siga o [guia de desenvolvimento](docs/produto/DESENVOLVIMENTO.md).
4. Implemente e execute `npm test`. Para atalhos, foco, áudio e permissões, teste também no macOS real.
5. Abra um pull request para `main`, descrevendo o problema, a mudança e como foi validada. Inclua capturas para mudanças visuais, usando apenas dados sintéticos.
6. Aguarde a revisão do mantenedor **@torriani**, responda às observações e ajuste quando necessário. Abrir um PR não significa aprovação ou integração automática.

## Critérios de revisão

- Escopo claro, comportamento explicado e compatibilidade documentada.
- Preservação do histórico e áudio do usuário; nenhuma migração destrutiva silenciosa.
- Processamento local e verificação do foco antes da colagem preservados.
- Testes de regressão para atalhos, persistência, recuperação e concorrência.
- Interface com os tokens semânticos existentes; textos e documentação em português.
- Sem código, sons ou assets proprietários de terceiros sem licença de distribuição.

Não envie bancos, gravações pessoais, chaves, credenciais, exportações ou `.local`. Use fixtures sintéticas em pasta temporária. Uma captura não deve revelar dados reais.

## Testes e documentação

Use Node.js 22.13+, `npm ci` e `npm test`. Compile os componentes nativos conforme o README. Eventos simulados não comprovam Fn físico, microfone nem colagem em outro aplicativo. Informe o que foi testado e o que permanece pendente. Atualize documentação e capturas quando mudar a interface.

## Segurança

Não publique vulnerabilidades ou dados sensíveis em uma issue pública. Use o [reporte privado de segurança](https://github.com/torriani/lume-flow/security/advisories/new).

## Idioma e licenças

Documentação do produto, propostas e explicações de mudanças devem ser preferencialmente em português. Identificadores de código e termos técnicos podem permanecer em inglês. Os textos oficiais das licenças de terceiros são preservados no idioma original para manter sua integridade.
