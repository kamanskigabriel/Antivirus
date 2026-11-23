# antivirus-node

Scanner antivírus pessoal em Node.js, **sem dependências externas** (só precisa do Node 18+).

## O que ele faz

| Recurso | Como funciona |
|---|---|
| **Assinaturas** | Calcula o SHA-256 de cada arquivo e compara com uma base local (`data/signatures.txt`) |
| **Teste EICAR** | Reconhece o arquivo de teste padrão da indústria |
| **Heurísticas** | Dupla extensão (`foto.jpg.exe`), executável disfarçado de imagem/documento (magic bytes), truque RTLO, nomes com espaços, macros escondidas, entropia alta, scripts com comportamento de malware (PowerShell codificado, `certutil` baixando arquivo, apagar cópias de sombra, desativar o Defender, persistência no registro etc.) |
| **VirusTotal** | Consulta só o **hash** (o arquivo nunca sai do seu PC), só para arquivos suspeitos |
| **Quarentena** | Move (nunca apaga), remove permissão de execução, guarda o motivo, permite restaurar |
| **Tempo real** | `watch` analisa arquivos novos assim que terminam de ser gravados |
| **Cache** | Arquivos limpos e inalterados não são reanalisados |
| **Relatórios** | JSON + TXT em `~/.antivirus-node/reports` |

## Como usar

```bash
# 1) Confirme que o motor funciona (cria arquivos de teste inofensivos)
node src/cli.js selftest

# 2) Varredura rápida (Downloads, Desktop, Documents, Temp, pasta de inicialização)
node src/cli.js scan

# 3) Varredura de uma pasta específica, isolando ameaças
node src/cli.js scan C:\Users\SeuNome\Downloads --quarantine

# 4) Varredura completa da sua pasta de usuário
node src/cli.js scan --full

# 5) Proteção em tempo real (Downloads e Desktop por padrão)
node src/cli.js watch

# 6) Com VirusTotal (chave gratuita em virustotal.com)
#    PowerShell:  $env:VT_API_KEY="sua_chave"
#    Linux/Mac:   export VT_API_KEY=sua_chave
node src/cli.js scan --vt

# Quarentena
node src/cli.js quarantine list
node src/cli.js quarantine restore <id>
node src/cli.js quarantine delete <id>

# Importar mais hashes para a base local (um SHA-256 por linha, arquivo ou URL)
node src/cli.js import-db lista.txt
```

O código de saída é `0` quando nada foi encontrado e `2` quando há ameaças (útil para scripts).

## Limpeza interativa e atalhos para o CMD

```bash
node src/cli.js clean            # ou: npm run clean
```

Varre as pastas e, para cada arquivo malicioso/suspeito, pergunta o que fazer:

- **Q** quarentena (move para um cofre, dá para restaurar) — é o padrão para arquivos maliciosos
- **I** ignorar — é o padrão para suspeitos (pode ser falso positivo)
- **D** apagar definitivamente (pede para digitar `APAGAR`)
- **T** manda todos os restantes para a quarentena
- **S** sair

Opções: `--yes` (tudo vai para a quarentena sem perguntar), `--all` (inclui nível "atenção"), `--full`, e as demais do `scan`.
Se o arquivo estiver em uso, ele avisa e segue para o próximo; feche o programa que o usa ou abra o CMD como administrador.

Atalhos para Windows (dê dois cliques ou rode no CMD):

| Arquivo | O que faz |
|---|---|
| `limpar.bat` | Varredura + limpeza interativa |
| `vigiar.bat` | Proteção em tempo real; ameaças novas vão direto para a quarentena |
| `instalar-global.bat` | Roda `npm link` para você usar `antivirus-node clean` em qualquer pasta do CMD |

## Interpretando os resultados

- **MALICIOSO**: hash conhecido na base, EICAR ou VirusTotal com 3+ detecções.
- **SUSPEITO**: pontuação de heurísticas ≥ 60 (ex.: executável disfarçado de imagem).
- **ATENÇÃO**: pontuação 30–59. Merece uma olhada, mas pode ser falso positivo.
- Heurísticas podem errar. Por isso a quarentena só acontece com `--quarantine` e sempre dá para restaurar.

## Limites (leia isto)

Este projeto é um scanner sob demanda com monitoramento de pastas, **não substitui** o Windows Defender
(ou outro antivírus comercial). Ele **não** tem:

- Driver de kernel para bloquear um arquivo *antes* de ser executado
- Base de assinaturas com milhões de amostras atualizada a cada hora
- Análise de comportamento de processos em execução, sandbox, proteção de navegador/rede
- Desempacotamento de `.zip`/`.rar` ou análise profunda de PDFs/Office

Mantenha o antivírus do sistema ligado e use este projeto como camada extra e para aprender.

## Observações

- A string do teste EICAR é montada em partes no código para o seu antivírus real não acusar o próprio projeto.
- Rodar como usuário normal já cobre suas pastas. Para varrer pastas do sistema, abra o terminal como administrador.
- Dados do programa ficam em `~/.antivirus-node` (quarentena, cache, relatórios).

## Estrutura

```
limpar.bat / vigiar.bat / instalar-global.bat   atalhos para o CMD do Windows
src/cli.js         comandos (scan, clean, watch, quarantine, import-db, selftest)
src/scanner.js     varredura, hash, pool de workers, veredito
src/heuristics.js  regras de detecção
src/signatures.js  base de assinaturas + EICAR
src/quarantine.js  isolar/restaurar/apagar
src/virustotal.js  consulta por hash com limitador de taxa
src/watcher.js     monitoramento em tempo real
src/report.js      saída no terminal e relatórios
src/cache.js       cache de arquivos limpos
data/signatures.txt  hashes conhecidos
```
