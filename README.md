# crud-api-bend

API HTTP CRUD de itens escrita em [Bend 2](https://bend-lang.com), com leis verificáveis e persistência em ficheiro.

Contrato extraído de [patote85/aws-crud-api-lambda-dynamodb](https://github.com/patote85/aws-crud-api-lambda-dynamodb). **Não** é um port de Lambda, DynamoDB ou API Gateway.

Repositório: https://github.com/patote85/crud-api-bend

---

## O que a aplicação faz

Processo único que:

1. Aceita TCP na porta `8080`.
2. Lê um pedido HTTP mínimo (linha de request + corpo cru).
3. Encaminha para um núcleo puro (`Api.handle` / `Api.handle.full`).
4. Responde JSON (`application/json`).
5. Guarda o store em `store.json` depois de cada pedido.

Rotas:

| Método | Caminho | Sucesso | Erro |
|---|---|---|---|
| `POST` | `/items` | `201` item criado | `400` se `name` vazio |
| `GET` | `/items` | `200` `{"items":[...],"count":N}` | — |
| `GET` | `/items/{id}` | `200` item | `404` |
| `PUT` | `/items/{id}` | `200` item (campo vazio mantém) | `404` |
| `DELETE` | `/items/{id}` | `204` | `404` |
| `OPTIONS` | qualquer rota conhecida | `200` | — |
| outro | — | — | `404` |

Item:

```json
{"id":0,"name":"Api","description":"x","price":10}
```

- `id` é `Nat` (contador, não UUID).
- `price` é `Nat` (inteiro, não decimal).
- `name` é obrigatório e não vazio no POST.
- `description` e `price` são opcionais no body (`""` e `0` por omissão).

---

## Linguagem: Bend 2

Bend 2 (Taelin / Higher-Order Company): tipos dependentes, affine, `match`, `LAWS.bend` + `PROOF.bend`.

```bash
curl -fsSL https://bend-lang.com/install.sh | sh
export PATH="$HOME/.bend/bin:$PATH"
export BEND_NO_TELEMETRY=1
```

---

## Arquitetura

TCP :8080 → server.bend (Chan tamanho 1) → http.bend → api.bend → store.bend → persist.bend (`store.json`).
Núcleo puro. TLS na borda.

---

## Engenharia

Contrato antes da runtime. Leis antes do merge. `@unsafe` só nos walkers. Um processo, um ficheiro, um canal.

```bash
bend PROOF.bend
bend main.bend
bend main.bend serve
```

## Testes

Em Bend não há pytest. A suíte unitária é `LAWS.bend` + `PROOF.bend` (18 leis: create/get/delete/options, dois items, JSON, persist, envelope da lista, PUT parcial).

```bash
sh test.sh
```

CI: `.github/workflows/proof.yml` instala Bend e corre `test.sh` em push/PR para `main`. Sem TCP no CI.

---

## Layout

```
AGENTS.md LAWS.bend PROOF.bend README.md test.sh
.github/workflows/proof.yml
api.bend http.bend main.bend persist.bend server.bend store.bend
```

## Fora de âmbito

HTTP completo, TLS nativo, auth, price decimal, UUID, timestamps, Dynamo.
