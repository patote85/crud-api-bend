# crud-api-bend

Bend 2 port of the **contract** in [patote85/aws-crud-api-lambda-dynamodb](https://github.com/patote85/aws-crud-api-lambda-dynamodb). Not a port of Lambda, DynamoDB, or API Gateway.

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

In Bend the route is `Items{}` / `ItemId{id}` / `Unknown{}`, not a parsed URL. `id` is `Nat`. Store is **one slot in memory** (enough to prove the contract on empty → create → get). Multi-item + TCP HTTP is the next slice.

## Gate

```
bend PROOF.bend
```

Must print `All terms check.`

```
bend main.bend
```

Prints four sample replies.

Requires Bend 2.0.16+: `curl -fsSL https://bend-lang.com/install.sh | sh`
