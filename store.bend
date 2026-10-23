import Base

type Item is Data:
  Item{id: Nat, name: String, desc: String, price: Nat}

type Store is Data:
  Store{items: List<&2, Item>, next: Nat}

type Walk is Data:
  WalkLook{}
  WalkHit{eq: Bool, it: Item}

def Store.empty() -> Store:
  Store{Nil{}, 0n}

def Store.count(+s: Store) -> Nat:
  match s:
    case Store{xs, n}:
      List.length(&2, Item, xs)

def String.nonempty(+s: String) -> Bool:
  match s:
    case SNil{}:
      False{}
    case SCon{h, t}:
      True{}

def Item.json(+it: Item) -> String:
  match it:
    case Item{id, name, desc, price}:
      "{\"id\":" ++ Nat.show(id) ++ ",\"name\":\"" ++ name ++ "\",\"description\":\"" ++ desc ++ "\",\"price\":" ++ Nat.show(price) ++ "}"

def Store.list_json.rest(+xs: List<&2, Item>) -> String:
  match xs:
    case Nil{}:
      "]"
    case h <> t:
      "," ++ Item.json(h) ++ Store.list_json.rest(t)

def Store.list_json(+xs: List<&2, Item>) -> String:
  match xs:
    case Nil{}:
      "[]"
    case h <> t:
      "[" ++ Item.json(h) ++ Store.list_json.rest(t)

def Store.json(+s: Store) -> String:
  match s:
    case Store{xs, n}:
      Store.list_json(xs)

def Store.head_json(+s: Store) -> String:
  match s:
    case Store{Nil{}, n}:
      "{}"
    case Store{h <> t, n}:
      Item.json(h)

def Store.insert(+s: Store, +name: String, +desc: String, +price: Nat) -> Store:
  match s:
    case Store{xs, n}:
      Store{Item{n, name, desc, price} <> xs, 1n+n}

def Store.put(+s: Store, +it: Item) -> Store:
  match s:
    case Store{xs, n}:
      match it:
        case Item{id, name, desc, price}:
          Store{Item{id, name, desc, price} <> xs, Nat.max(n, Nat.add(id, 1n))}

def Store.find.go(+xs: List<&2, Item>, +id: Nat, +phase: Walk) -> Maybe<&2, Item>:
  match xs phase:
    case Nil{} WalkLook{}:
      None{}
    case Item{+i, name, desc, price} <> t WalkLook{}:
      Store.find.go(t, id, WalkHit{Nat.is_eq(i, id), Item{i, name, desc, price}})
    case _ WalkHit{True{}, it}:
      Some{it}
    case Nil{} WalkHit{False{}, it}:
      None{}
    case Item{+i, name, desc, price} <> t WalkHit{False{}, it}:
      Store.find.go(t, id, WalkHit{Nat.is_eq(i, id), Item{i, name, desc, price}})

def Store.find(+s: Store, +id: Nat) -> Maybe<&2, Item>:
  match s:
    case Store{xs, n}:
      Store.find.go(xs, id, WalkLook{})

def Store.has.from(+m: Maybe<&2, Item>) -> Bool:
  match m:
    case None{}:
      False{}
    case Some{it}:
      True{}

def Store.has(+s: Store, +id: Nat) -> Bool:
  Store.has.from(Store.find(s, id))

def Store.found_json(+m: Maybe<&2, Item>) -> String:
  match m:
    case None{}:
      "{\"error\":\"not found\"}"
    case Some{it}:
      Item.json(it)

def Store.get_json(+s: Store, +id: Nat) -> String:
  Store.found_json(Store.find(s, id))

def Store.drop.go(+xs: List<&2, Item>, +id: Nat, +phase: Walk) -> List<&2, Item>:
  match xs phase:
    case Nil{} WalkLook{}:
      Nil{}
    case Item{+i, name, desc, price} <> t WalkLook{}:
      Store.drop.go(t, id, WalkHit{Nat.is_eq(i, id), Item{i, name, desc, price}})
    case rest WalkHit{True{}, it}:
      rest
    case Nil{} WalkHit{False{}, it}:
      it <> Nil{}
    case Item{+i, name, desc, price} <> t WalkHit{False{}, it}:
      it <> Store.drop.go(t, id, WalkHit{Nat.is_eq(i, id), Item{i, name, desc, price}})

def Store.drop(+s: Store, +id: Nat) -> Store:
  match s:
    case Store{xs, n}:
      Store{Store.drop.go(xs, id, WalkLook{}), n}

def Store.replace.go(+xs: List<&2, Item>, +id: Nat, +name: String, +desc: String, +price: Nat, +phase: Walk) -> List<&2, Item>:
  match xs phase:
    case Nil{} WalkLook{}:
      Nil{}
    case Item{+i, on, od, op} <> t WalkLook{}:
      Store.replace.go(t, id, name, desc, price, WalkHit{Nat.is_eq(i, id), Item{i, on, od, op}})
    case rest WalkHit{True{}, Item{i, on, od, op}}:
      Item{i, name, desc, price} <> rest
    case Nil{} WalkHit{False{}, it}:
      it <> Nil{}
    case Item{+i, on, od, op} <> t WalkHit{False{}, it}:
      it <> Store.replace.go(t, id, name, desc, price, WalkHit{Nat.is_eq(i, id), Item{i, on, od, op}})

def Store.replace(+s: Store, +id: Nat, +name: String, +desc: String, +price: Nat) -> Store:
  match s:
    case Store{xs, n}:
      Store{Store.replace.go(xs, id, name, desc, price, WalkLook{}), n}
