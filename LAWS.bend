import Base
import ./store.bend as S
import ./api.bend as A
import ./http.bend as H
import ./persist.bend as P

def Reply.status(+r: A.Reply) -> A.Status:
  match r:
    case A.Reply{st, s, b}:
      st

def Reply.store(+r: A.Reply) -> S.Store:
  match r:
    case A.Reply{st, s, b}:
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

law create_rejects_empty_name:
  {Status.is(Reply.status(A.Api.create(S.Store.empty(), SNil{})), A.S400{}) == True{} : Bool}

law create_empty_name_preserves_count:
  {S.Store.count(Reply.store(A.Api.create(S.Store.empty(), SNil{}))) == 0n : Nat}

law create_accepts_name:
  {Status.is(Reply.status(A.Api.create(S.Store.empty(), SCon{'A', SNil{}})), A.S201{}) == True{} : Bool}

law create_increments_count:
  {S.Store.count(Reply.store(A.Api.create(S.Store.empty(), SCon{'A', SNil{}}))) == 1n : Nat}

law get_missing_is_404:
  {Status.is(Reply.status(A.Api.get(S.Store.empty(), 0n)), A.S404{}) == True{} : Bool}

law get_after_create_is_200:
  {Status.is(Reply.status(A.Api.get(Reply.store(A.Api.create(S.Store.empty(), SCon{'A', SNil{}})), 0n)), A.S200{}) == True{} : Bool}

law delete_missing_is_404:
  {Status.is(Reply.status(A.Api.delete(S.Store.empty(), 0n)), A.S404{}) == True{} : Bool}

law unknown_route_is_404:
  {Status.is(Reply.status(A.Api.handle(S.Store.empty(), A.GET{}, A.Unknown{}, SNil{})), A.S404{}) == True{} : Bool}

law options_ok:
  {Status.is(Reply.status(A.Api.handle(S.Store.empty(), A.OPTIONS{}, A.Items{}, SNil{})), A.S200{}) == True{} : Bool}

law two_creates_count:
  {S.Store.count(Reply.store(A.Api.create(Reply.store(A.Api.create(S.Store.empty(), SCon{'A', SNil{}})), SCon{'B', SNil{}}))) == 2n : Nat}

law two_creates_keeps_first:
  {Status.is(Reply.status(A.Api.get(Reply.store(A.Api.create(Reply.store(A.Api.create(S.Store.empty(), SCon{'A', SNil{}})), SCon{'B', SNil{}})), 0n)), A.S200{}) == True{} : Bool}

law two_creates_keeps_second:
  {Status.is(Reply.status(A.Api.get(Reply.store(A.Api.create(Reply.store(A.Api.create(S.Store.empty(), SCon{'A', SNil{}})), SCon{'B', SNil{}})), 1n)), A.S200{}) == True{} : Bool}

law json_name_extracts_api:
  {H.Http.json_name("{\"name\":\"Api\"}") == "Api" : String}

law post_json_body_is_201:
  {Status.is(Reply.status(H.Http.dispatch(S.Store.empty(), H.Http.parse_request("POST /items HTTP/1.1\n\n{\"name\":\"Api\"}"))), A.S201{}) == True{} : Bool}

law json_price_reads_ten:
  {H.Http.json_price("{\"price\":10}") == 10n : Nat}

law json_desc_reads_x:
  {H.Http.json_desc("{\"description\":\"X\"}") == "X" : String}

law json_id_reads_zero:
  {H.Http.json_id("{\"id\":0}") == 0n : Nat}

law persist_reads_one:
  {S.Store.count(P.Persist.parse("[{\"id\":0,\"name\":\"A\",\"description\":\"\",\"price\":1}]", S.Store.empty())) == 1n : Nat}
