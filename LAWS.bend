import Base
import ./store.bend as S
import ./api.bend as A

def Reply.status(+r: A.Reply) -> A.Status:
  match r:
    case A.Reply{st, s}:
      st

def Reply.store(+r: A.Reply) -> S.Store:
  match r:
    case A.Reply{st, s}:
      s

def Status.is(+st: A.Status, +want: A.Status) -> Bool:
  match st want:
    case A.S200{} A.S200{}:
      True{}
    case A.S201{} A.S201{}:
      True{}
    case A.S204{} A.S204{}:
      True{}
    case A.S400{} A.S400{}:
      True{}
    case A.S404{} A.S404{}:
      True{}
    case A.S200{} A.S201{}:
      False{}
    case A.S200{} A.S204{}:
      False{}
    case A.S200{} A.S400{}:
      False{}
    case A.S200{} A.S404{}:
      False{}
    case A.S201{} A.S200{}:
      False{}
    case A.S201{} A.S204{}:
      False{}
    case A.S201{} A.S400{}:
      False{}
    case A.S201{} A.S404{}:
      False{}
    case A.S204{} A.S200{}:
      False{}
    case A.S204{} A.S201{}:
      False{}
    case A.S204{} A.S400{}:
      False{}
    case A.S204{} A.S404{}:
      False{}
    case A.S400{} A.S200{}:
      False{}
    case A.S400{} A.S201{}:
      False{}
    case A.S400{} A.S204{}:
      False{}
    case A.S400{} A.S404{}:
      False{}
    case A.S404{} A.S200{}:
      False{}
    case A.S404{} A.S201{}:
      False{}
    case A.S404{} A.S204{}:
      False{}
    case A.S404{} A.S400{}:
      False{}

# POST /items with empty name is 400 and does not grow the store.
law create_rejects_empty_name:
  {Status.is(Reply.status(A.Api.create(S.Store.empty(), SNil{})), A.S400{}) == True{} : Bool}

law create_empty_name_preserves_count:
  {S.Store.count(Reply.store(A.Api.create(S.Store.empty(), SNil{}))) == 0n : Nat}

# POST /items with a non-empty name is 201 and count becomes 1.
law create_accepts_name:
  {Status.is(Reply.status(A.Api.create(S.Store.empty(), SCon{'A', SNil{}})), A.S201{}) == True{} : Bool}

law create_increments_count:
  {S.Store.count(Reply.store(A.Api.create(S.Store.empty(), SCon{'A', SNil{}}))) == 1n : Nat}

# GET /items/{id} on an empty store is 404.
law get_missing_is_404:
  {Status.is(Reply.status(A.Api.get(S.Store.empty(), 0n)), A.S404{}) == True{} : Bool}

# GET after create finds id 0.
law get_after_create_is_200:
  {Status.is(Reply.status(A.Api.get(Reply.store(A.Api.create(S.Store.empty(), SCon{'A', SNil{}})), 0n)), A.S200{}) == True{} : Bool}

# DELETE missing is 404.
law delete_missing_is_404:
  {Status.is(Reply.status(A.Api.delete(S.Store.empty(), 0n)), A.S404{}) == True{} : Bool}

# Unknown route is 404.
law unknown_route_is_404:
  {Status.is(Reply.status(A.Api.handle(S.Store.empty(), A.GET{}, A.Unknown{}, SNil{})), A.S404{}) == True{} : Bool}

# OPTIONS never mutates the empty store.
law options_ok:
  {Status.is(Reply.status(A.Api.handle(S.Store.empty(), A.OPTIONS{}, A.Items{}, SNil{})), A.S200{}) == True{} : Bool}
