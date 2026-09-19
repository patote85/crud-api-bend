import Base
import ./store.bend as S

type Method is Data:
  GET{}
  POST{}
  PUT{}
  DELETE{}
  OPTIONS{}

type Route is Data:
  Items{}
  ItemId{id: Nat}
  Unknown{}

type Status is Data:
  S200{}
  S201{}
  S204{}
  S400{}
  S404{}

type Reply is Data:
  Reply{status: Status, store: S.Store, body: String}

def Api.err(+st: Status, +s: S.Store, +msg: String) -> Reply:
  Reply{st, s, "{\"error\":" ++ "\"" ++ msg ++ "\"}"}

def Api.create.step(+ok: Bool, +s: S.Store, +name: String, +desc: String, +price: Nat) -> Reply:
  match ok:
    case False{}:
      Api.err(S400{}, s, "name required")
    case True{}:
      +s2 = S.Store.insert(s, name, desc, price)
      Reply{S201{}, s2, S.Store.head_json(s2)}

def Api.create.full(+s: S.Store, +name: String, +desc: String, +price: Nat) -> Reply:
  Api.create.step(S.String.nonempty(name), s, name, desc, price)

def Api.create(+s: S.Store, +name: String) -> Reply:
  Api.create.full(s, name, SNil{}, 0n)

def Api.list(+s: S.Store) -> Reply:
  Reply{S200{}, s, S.Store.json(s)}

def Api.get.step(+ok: Bool, +s: S.Store, +id: Nat) -> Reply:
  match ok:
    case False{}:
      Api.err(S404{}, s, "not found")
    case True{}:
      Reply{S200{}, s, S.Store.get_json(s, id)}

def Api.get(+s: S.Store, +id: Nat) -> Reply:
  Api.get.step(S.Store.has(s, id), s, id)

def Api.update.found(+ok: Bool, +s: S.Store, +id: Nat, +name: String, +desc: String, +price: Nat) -> Reply:
  match ok:
    case False{}:
      Api.err(S404{}, s, "not found")
    case True{}:
      +s2 = S.Store.replace(s, id, name, desc, price)
      Reply{S200{}, s2, S.Store.get_json(s2, id)}

def Api.update.step(+ok: Bool, +s: S.Store, +id: Nat, +name: String, +desc: String, +price: Nat) -> Reply:
  match ok:
    case False{}:
      Api.err(S400{}, s, "name required")
    case True{}:
      Api.update.found(S.Store.has(s, id), s, id, name, desc, price)

def Api.update.full(+s: S.Store, +id: Nat, +name: String, +desc: String, +price: Nat) -> Reply:
  Api.update.step(S.String.nonempty(name), s, id, name, desc, price)

def Api.update(+s: S.Store, +id: Nat, +name: String) -> Reply:
  Api.update.full(s, id, name, SNil{}, 0n)

def Api.delete.step(+ok: Bool, +s: S.Store, +id: Nat) -> Reply:
  match ok:
    case False{}:
      Api.err(S404{}, s, "not found")
    case True{}:
      Reply{S204{}, S.Store.drop(s, id), SNil{}}

def Api.delete(+s: S.Store, +id: Nat) -> Reply:
  Api.delete.step(S.Store.has(s, id), s, id)

def Api.handle.full(+s: S.Store, +m: Method, +r: Route, +name: String, +desc: String, +price: Nat) -> Reply:
  match m r:
    case OPTIONS{} Items{}:
      Reply{S200{}, s, SNil{}}
    case OPTIONS{} ItemId{id}:
      Reply{S200{}, s, SNil{}}
    case OPTIONS{} Unknown{}:
      Reply{S200{}, s, SNil{}}
    case POST{} Items{}:
      Api.create.full(s, name, desc, price)
    case GET{} Items{}:
      Api.list(s)
    case GET{} ItemId{id}:
      Api.get(s, id)
    case PUT{} ItemId{id}:
      Api.update.full(s, id, name, desc, price)
    case DELETE{} ItemId{id}:
      Api.delete(s, id)
    case GET{} Unknown{}:
      Api.err(S404{}, s, "route not found")
    case POST{} Unknown{}:
      Api.err(S404{}, s, "route not found")
    case PUT{} Unknown{}:
      Api.err(S404{}, s, "route not found")
    case DELETE{} Unknown{}:
      Api.err(S404{}, s, "route not found")
    case POST{} ItemId{id}:
      Api.err(S404{}, s, "route not found")
    case PUT{} Items{}:
      Api.err(S404{}, s, "route not found")
    case DELETE{} Items{}:
      Api.err(S404{}, s, "route not found")

def Api.handle(+s: S.Store, +m: Method, +r: Route, +name: String) -> Reply:
  Api.handle.full(s, m, r, name, SNil{}, 0n)
