# Hmax

Launcher (Python) + automacao AutoHotkey para PDV / Selfie / Vale Troca.

- `launcher/` - codigo, recursos e `dados.json` (licenca e usuarios)
- `azure-pipelines.yml` - valida o `dados.json` e gera o `Hmax.exe` (artefato `Hmax-exe`)
- `tools/validar_dados.py` - checagem do `dados.json`

**Repositorio privado:** o `dados.json` contem logins e chapas de colaboradores.

## Subir para o Azure DevOps
```
git init -b main
git add .
git commit -m "Hmax: versao inicial"
git remote add origin https://dev.azure.com/<ORG>/<PROJETO>/_git/Hmax
git push -u origin main
```
Depois: Pipelines > New pipeline > Azure Repos Git > Existing YAML > `/azure-pipelines.yml`.

## Fazer o app ler o banco do Azure DevOps
1. Azure DevOps > User settings > Personal access tokens > New token: escopo **Code (Read)**, validade maxima, so este projeto.
2. Pipelines > a pipeline > Edit > Variables > New variable `DEVOPS_PAT` = o token, marcando **Keep this value secret**.
3. Rode a pipeline. O `Hmax.exe` sai configurado para ler `launcher/dados.json` da branch `main`.
4. Para mudar usuarios: edite `launcher/dados.json` no Repos e faca commit. O app atualiza sozinho em ~1 min, sem gerar exe novo.

O token fica dentro do exe (so leitura). Renove antes de vencer e gere um exe novo.
Teste local: copie `launcher/fonte_banco.exemplo.ini` para `fonte_banco.ini` e preencha.
