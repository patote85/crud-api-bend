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
| `GET` | `/items` | `200` lista JSON | — |
| `GET` | `/items/{id}` | `200` item | `404` |
| `PUT` | `/items/{id}` | `200` item | `400` nome vazio; `404` |
| `DELETE` | `/items/{id}` | `204` | `404` |
| `OPTIONS` | qualquer rota conhecida | `200` | — |
| outro | — | — | `404` |

Item:

```json
{"id":0,"name":"Api","description":"x","price":10}
```

- `id` é `Nat` (contador, não UUID).
- `price` é `Nat` (inteiro, não decimal).
- `name` é obrigatório e não vazio.
- `description` e `price` são opcionais no body (`""` e `0` por omissão).

O body JSON pode trazer `"name"`, `"description"` e `"price"`. O nome também pode ir no path: `POST /items/Api`.

---

## Linguagem: Bend 2

Bend 2 (é Taelin / Higher-Order Company) é uma linguagem de tipos dependentes e afinidade:

- Affine por omissão; `+` torna Data reutilizável.
- Sem `if`: controlo é `match`.
- Handles (`File`, `Socket`, `Chan`) são opacos e afinais.
- Recursão tem de terminar ou o def leva `@unsafe`.
- Efeitos em `do IO<A>`.
- Contrato humano/agente: `LAWS.bend` + `PROOF.bend`. Gate: `bend PROOF.bend`.

```bash
curl -fsSL https://bend-lang.com/install.sh | sh
export PATH="$HOME/.bend/bin:$PATH"
export BEND_NO_TELEMETRY=1
```

Versão alvo: Bend 2.0.16+ (desenvolvido até 2.0.18). Guia: `bend guide`. Site: https://bend-lang.com

---

## Arquitetura

```
TCP :8080
    |
    v
server.bend     accept + spawn por socket; Chan<Store> tamanho 1
    v
http.bend       parse da linha + scan JSON no raw
    v
api.bend        Method x Route -> Status + Store + body
    v
store.bend      List<Item> + next Nat
    v
persist.bend    File.open/read/write store.json
```

O núcleo (`store` + `api` + extractores HTTP) é puro. IO fica na borda.

Estado: `Chan(Store)` capacidade 1. Pedido: recv, handle, save, send.

TLS não entra no Bend. Proxy (Caddy/nginx) -> `127.0.0.1:8080`.

---

## Engenharia

1. Contrato antes da runtime (rotas AWS, zero Lambda/Dynamo).
2. Leis antes do merge. Não se enfraquece lei para o proof passar.
3. `@unsafe` só nos walkers da lista (terminação).
4. Parser mínimo: linha HTTP + `"name"` / `"description"` / `"price"` / `"id"`.
5. Persistência best-effort em `store.json`.
6. Um processo, um ficheiro, um canal.

```bash
bend PROOF.bend          # gate
bend main.bend           # demo in-process
bend main.bend serve     # TCP :8080
curl http://127.0.0.1:8080/items
curl -X POST http://127.0.0.1:8080/items -d '{"name":"Api","description":"x","price":10}'
```

---

## Layout

```
AGENTS.md LAWS.bend PROOF.bend README.md
api.bend http.bend main.bend persist.bend server.bend store.bend
```

## Fora de âmbito

HTTP completo, TLS nativo, auth, price decimal, UUID, timestamps, Dynamo.
