import Base

type Item is Data:
  Item{id: Nat, name: String, desc: String, price: Nat}

type Store is Data:
  Store{items: List<&2, Item>, next: Nat}

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

@unsafe def Store.find.go(+xs: List<&2, Item>, +id: Nat) -> Maybe<&2, Item>:
  match xs id:
    case Nil{} 0n:
      None{}
    case Nil{} 1n+p:
      None{}
    case Item{0n, name, desc, price} <> t 0n:
      Some{Item{0n, name, desc, price}}
    case Item{0n, name, desc, price} <> t 1n+p:
      Store.find.go(t, 1n+p)
    case Item{1n+q, name, desc, price} <> t 0n:
      Store.find.go(t, 0n)
    case Item{1n+q, name, desc, price} <> t 1n+p:
      Store.find.go(Item{q, name, desc, price} <> t, p)

def Store.find(+s: Store, +id: Nat) -> Maybe<&2, Item>:
  match s:
    case Store{xs, n}:
      Store.find.go(xs, id)

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

@unsafe def Store.drop.go(+xs: List<&2, Item>, +id: Nat) -> List<&2, Item>:
  match xs id:
    case Nil{} 0n:
      Nil{}
    case Nil{} 1n+p:
      Nil{}
    case Item{0n, name, desc, price} <> t 0n:
      t
    case Item{0n, name, desc, price} <> t 1n+p:
      Item{0n, name, desc, price} <> Store.drop.go(t, 1n+p)
    case Item{1n+q, name, desc, price} <> t 0n:
      Item{1n+q, name, desc, price} <> Store.drop.go(t, 0n)
    case Item{1n+q, name, desc, price} <> t 1n+p:
      Store.drop.go(Item{q, name, desc, price} <> t, p)

def Store.drop(+s: Store, +id: Nat) -> Store:
  match s:
    case Store{xs, n}:
      Store{Store.drop.go(xs, id), n}

@unsafe def Store.replace.go(+xs: List<&2, Item>, +id: Nat, +name: String, +desc: String, +price: Nat) -> List<&2, Item>:
  match xs id:
    case Nil{} 0n:
      Nil{}
    case Nil{} 1n+p:
      Nil{}
    case Item{0n, old, od, op} <> t 0n:
      Item{0n, name, desc, price} <> t
    case Item{0n, old, od, op} <> t 1n+p:
      Item{0n, old, od, op} <> Store.replace.go(t, 1n+p, name, desc, price)
    case Item{1n+q, old, od, op} <> t 0n:
      Item{1n+q, old, od, op} <> Store.replace.go(t, 0n, name, desc, price)
    case Item{1n+q, old, od, op} <> t 1n+p:
      Store.replace.go(Item{q, old, od, op} <> t, p, name, desc, price)

def Store.replace(+s: Store, +id: Nat, +name: String, +desc: String, +price: Nat) -> Store:
  match s:
    case Store{xs, n}:
      Store{Store.replace.go(xs, id, name, desc, price), n}
