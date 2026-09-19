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
  Reply{status: Status, store: S.Store}

def Api.create.step(+ok: Bool, +s: S.Store, +name: String) -> Reply:
  match ok:
    case False{}:
      Reply{S400{}, s}
    case True{}:
      Reply{S201{}, S.Store.insert(s, name)}

def Api.create(+s: S.Store, +name: String) -> Reply:
  Api.create.step(S.String.nonempty(name), s, name)

def Api.list(+s: S.Store) -> Reply:
  Reply{S200{}, s}

def Api.get.step(+ok: Bool, +s: S.Store) -> Reply:
  match ok:
    case False{}:
      Reply{S404{}, s}
    case True{}:
      Reply{S200{}, s}

def Api.get(+s: S.Store, +id: Nat) -> Reply:
  Api.get.step(S.Store.has(s, id), s)

def Api.update.found(+ok: Bool, +s: S.Store, +id: Nat, +name: String) -> Reply:
  match ok:
    case False{}:
      Reply{S404{}, s}
    case True{}:
      Reply{S200{}, S.Store.replace(s, id, name)}

def Api.update.step(+ok: Bool, +s: S.Store, +id: Nat, +name: String) -> Reply:
  match ok:
    case False{}:
      Reply{S400{}, s}
    case True{}:
      Api.update.found(S.Store.has(s, id), s, id, name)

def Api.update(+s: S.Store, +id: Nat, +name: String) -> Reply:
  Api.update.step(S.String.nonempty(name), s, id, name)

def Api.delete.step(+ok: Bool, +s: S.Store, +id: Nat) -> Reply:
  match ok:
    case False{}:
      Reply{S404{}, s}
    case True{}:
      Reply{S204{}, S.Store.drop(s, id)}

def Api.delete(+s: S.Store, +id: Nat) -> Reply:
  Api.delete.step(S.Store.has(s, id), s, id)

def Api.handle(+s: S.Store, +m: Method, +r: Route, +name: String) -> Reply:
  match m r:
    case OPTIONS{} Items{}:
      Reply{S200{}, s}
    case OPTIONS{} ItemId{id}:
      Reply{S200{}, s}
    case OPTIONS{} Unknown{}:
      Reply{S200{}, s}
    case POST{} Items{}:
      Api.create(s, name)
    case GET{} Items{}:
      Api.list(s)
    case GET{} ItemId{id}:
      Api.get(s, id)
    case PUT{} ItemId{id}:
      Api.update(s, id, name)
    case DELETE{} ItemId{id}:
      Api.delete(s, id)
    case GET{} Unknown{}:
      Reply{S404{}, s}
    case POST{} Unknown{}:
      Reply{S404{}, s}
    case PUT{} Unknown{}:
      Reply{S404{}, s}
    case DELETE{} Unknown{}:
      Reply{S404{}, s}
    case POST{} ItemId{id}:
      Reply{S404{}, s}
    case PUT{} Items{}:
      Reply{S404{}, s}
    case DELETE{} Items{}:
      Reply{S404{}, s}
