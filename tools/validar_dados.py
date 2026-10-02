# -*- coding: utf-8 -*-
"""Valida launcher/dados.json antes do build (usado pelo Azure Pipelines)."""
import json, re, sys
from collections import Counter

CAMINHO = sys.argv[1] if len(sys.argv) > 1 else "launcher/dados.json"
erros, avisos = [], []

def sem_duplicadas(pares):
    chaves = [k for k, _ in pares]
    for k, n in Counter(chaves).items():
        if n > 1:
            erros.append("Chave duplicada no JSON: %s" % k)
    return dict(pares)

try:
    texto = open(CAMINHO, encoding="utf-8-sig").read()
    d = json.loads(texto, object_pairs_hook=sem_duplicadas)
except Exception as e:
    print("##vso[task.logissue type=error]JSON invalido: %s" % e)
    sys.exit(1)

lic = d.get("licenca", {})
for campo in ("status", "data_expiracao", "mensagem_bloqueio", "titulo_sistema"):
    if not lic.get(campo):
        erros.append("licenca.%s ausente ou vazio" % campo)
if not re.fullmatch(r"\d{2}/\d{2}/\d{4}", lic.get("data_expiracao", "")):
    erros.append("licenca.data_expiracao deve ser DD/MM/AAAA")

usuarios = d.get("usuarios", {})
if not usuarios:
    erros.append("Nenhum usuario em 'usuarios'")
for senha, v in usuarios.items():
    if not (isinstance(v, list) and len(v) == 3 and all(isinstance(x, str) and x.strip() for x in v)):
        erros.append("Usuario %s deve ser [nome, login, chapa] sem campos vazios" % senha)

for nome, idx in (("login", 1), ("chapa", 2)):
    c = Counter(v[idx] for v in usuarios.values() if isinstance(v, list) and len(v) == 3)
    for valor, n in c.items():
        if n > 1:
            msg = "%s repetido(a) em %d usuarios: %s" % (nome, n, valor)
            (erros if nome == "login" else avisos).append(msg)

for a in avisos:
    print("##vso[task.logissue type=warning]%s" % a)
for e in erros:
    print("##vso[task.logissue type=error]%s" % e)
if erros:
    sys.exit(1)
print("dados.json OK - %d usuarios, validade %s" % (len(usuarios), lic["data_expiracao"]))
