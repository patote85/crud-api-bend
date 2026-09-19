import Base
import ./store.bend as S
import ./api.bend as A

def show_status(+st: A.Status) -> String:
  match st:
    case A.S200{}:
      "200"
    case A.S201{}:
      "201"
    case A.S204{}:
      "204"
    case A.S400{}:
      "400"
    case A.S404{}:
      "404"

def show_reply(+r: A.Reply) -> String:
  match r:
    case A.Reply{st, s}:
      "status=" ++ show_status(st) ++ " count=" ++ Nat.show(S.Store.count(s))

def reply_store(+r: A.Reply) -> S.Store:
  match r:
    case A.Reply{st, s}:
      s

def main() -> IO(Unit):
  do IO<Unit>:
    +empty : S.Store = S.Store.empty()
    r0 : A.Reply = A.Api.handle(empty, A.POST{}, A.Items{}, SNil{})
    IO.print("POST empty name  " ++ show_reply(r0))
    +r1 : A.Reply = A.Api.handle(empty, A.POST{}, A.Items{}, SCon{'A', SCon{'p', SCon{'i', SNil{}}}})
    IO.print("POST Api         " ++ show_reply(r1))
    +s1 : S.Store = reply_store(r1)
    r2 : A.Reply = A.Api.handle(s1, A.GET{}, A.ItemId{0n}, SNil{})
    IO.print("GET /items/0     " ++ show_reply(r2))
    r3 : A.Reply = A.Api.handle(s1, A.GET{}, A.Unknown{}, SNil{})
    IO.print("GET unknown      " ++ show_reply(r3))
    return Unit{}
