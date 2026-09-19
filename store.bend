import Base

type Item is Data:
  Item{id: Nat, name: String}

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

def Store.insert(+s: Store, +name: String) -> Store:
  match s:
    case Store{xs, n}:
      Store{Item{n, name} <> xs, 1n+n}

@unsafe def Store.find.go(+xs: List<&2, Item>, +id: Nat) -> Maybe<&2, Item>:
  match xs id:
    case Nil{} 0n:
      None{}
    case Nil{} 1n+p:
      None{}
    case Item{0n, name} <> t 0n:
      Some{Item{0n, name}}
    case Item{0n, name} <> t 1n+p:
      Store.find.go(t, 1n+p)
    case Item{1n+q, name} <> t 0n:
      Store.find.go(t, 0n)
    case Item{1n+q, name} <> t 1n+p:
      Store.find.go(Item{q, name} <> t, p)

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

@unsafe def Store.drop.go(+xs: List<&2, Item>, +id: Nat) -> List<&2, Item>:
  match xs id:
    case Nil{} 0n:
      Nil{}
    case Nil{} 1n+p:
      Nil{}
    case Item{0n, name} <> t 0n:
      t
    case Item{0n, name} <> t 1n+p:
      Item{0n, name} <> Store.drop.go(t, 1n+p)
    case Item{1n+q, name} <> t 0n:
      Item{1n+q, name} <> Store.drop.go(t, 0n)
    case Item{1n+q, name} <> t 1n+p:
      Store.drop.go(Item{q, name} <> t, p)

def Store.drop(+s: Store, +id: Nat) -> Store:
  match s:
    case Store{xs, n}:
      Store{Store.drop.go(xs, id), n}

@unsafe def Store.replace.go(+xs: List<&2, Item>, +id: Nat, +name: String) -> List<&2, Item>:
  match xs id:
    case Nil{} 0n:
      Nil{}
    case Nil{} 1n+p:
      Nil{}
    case Item{0n, old} <> t 0n:
      Item{0n, name} <> t
    case Item{0n, old} <> t 1n+p:
      Item{0n, old} <> Store.replace.go(t, 1n+p, name)
    case Item{1n+q, old} <> t 0n:
      Item{1n+q, old} <> Store.replace.go(t, 0n, name)
    case Item{1n+q, old} <> t 1n+p:
      Store.replace.go(Item{q, old} <> t, p, name)

def Store.replace(+s: Store, +id: Nat, +name: String) -> Store:
  match s:
    case Store{xs, n}:
      Store{Store.replace.go(xs, id, name), n}
