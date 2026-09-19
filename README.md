# crud-api-bend

Bend 2 port of the contract in patote85/aws-crud-api-lambda-dynamodb. Not a port of Lambda, DynamoDB, or API Gateway.

Requires Bend 2.0.16+: `curl -fsSL https://bend-lang.com/install.sh | sh`

## Contract

POST /items 201|400; GET /items 200 list; GET/PUT/DELETE /items/{id}; OPTIONS 200.
Item JSON: {"id":0,"name":"Api","description":"...","price":0}. price is Nat.

## Gate

```
bend PROOF.bend
bend main.bend
bend main.bend serve
```

`serve` loads and writes `store.json` via File.*. TLS belongs at Caddy/nginx in front of :8080.
