# crud-api-bend

Bend 2 port of the **contract** in [patote85/aws-crud-api-lambda-dynamodb](https://github.com/patote85/aws-crud-api-lambda-dynamodb). Not a port of Lambda, DynamoDB, or API Gateway.

Requires Bend 2.0.16+: `curl -fsSL https://bend-lang.com/install.sh | sh`

## Contract

| HTTP | Route | Status |
|---|---|---|
| POST | `/items` | 201 name non-empty; 400 empty name |
| GET | `/items` | 200 JSON list |
| GET | `/items/{id}` | 200 JSON item; 404 missing |
| PUT | `/items/{id}` | 200 JSON item; 400 empty name; 404 missing |
| DELETE | `/items/{id}` | 204 found; 404 missing |
| OPTIONS | any | 200 |
| other | | 404 |

Item JSON: `{"id":0,"name":"Api","description":"...","price":0}`. `price` is `Nat`.

```
bend PROOF.bend
bend main.bend
bend main.bend serve
curl -X POST http://127.0.0.1:8080/items -d '{"name":"Api","description":"x","price":10}'
```
