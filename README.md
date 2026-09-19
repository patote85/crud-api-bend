# crud-api-bend

Bend 2 port of the **contract** in [patote85/aws-crud-api-lambda-dynamodb](https://github.com/patote85/aws-crud-api-lambda-dynamodb). Not a port of Lambda, DynamoDB, or API Gateway.

Requires Bend 2.0.16+: `curl -fsSL https://bend-lang.com/install.sh | sh`

## Contract

| HTTP | Route | Status |
|---|---|---|
| POST | `/items` | 201 name non-empty; 400 empty name |
| GET | `/items` | 200 |
| GET | `/items/{id}` | 200 found; 404 missing |
| PUT | `/items/{id}` | 200 found + name; 400 empty name; 404 missing |
| DELETE | `/items/{id}` | 204 found; 404 missing |
| OPTIONS | any | 200 |
| other | | 404 |

In the core, the route is `Items{}` / `ItemId{id}` / `Unknown{}`. `id` is `Nat`. Store is an in-memory list.

The HTTP wire format is a **request line only** (no JSON):

```
GET /items
GET /items/0
POST /items/Api
PUT /items/0/NewName
DELETE /items/0
OPTIONS /items
```

## Gate

```
bend PROOF.bend
```

Must print `All terms check.` List walkers are `@unsafe` (termination); the laws still close on concrete stores.

```
bend main.bend          # in-process demo
bend main.bend serve    # TCP :8080
curl http://127.0.0.1:8080/items
curl -X POST http://127.0.0.1:8080/items/Api
```

Accept loop follows `demos/io_http_server`: `@unsafe` + `IO.spawn` per socket. The store is a `Chan` of size 1.
