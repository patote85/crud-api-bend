import Base

type Item is Data:
  Item{id: Nat, name: String}

type Store is Data:
  Empty{next: Nat}
  Hold{item: Item, next: Nat}

def Store.empty() -> Store:
  Empty{0n}

def Store.count(+s: Store) -> Nat:
  match s:
    case Empty{n}:
      0n
    case Hold{it, n}:
      1n

def String.nonempty(+s: String) -> Bool:
  match s:
    case SNil{}:
      False{}
    case SCon{h, t}:
      True{}

def Store.insert(+s: Store, +name: String) -> Store:
  match s:
    case Empty{n}:
      Hold{Item{n, name}, 1n+n}
    case Hold{old, n}:
      Hold{Item{n, name}, 1n+n}

def Store.has(+s: Store, +id: Nat) -> Bool:
  match s:
    case Empty{n}:
      False{}
    case Hold{Item{iid, name}, n}:
      Nat.is_eq(iid, id)

def Store.drop.eq(+hit: Bool, +it: Item, +n: Nat) -> Store:
  match hit:
    case True{}:
      Empty{n}
    case False{}:
      Hold{it, n}

def Store.drop(+s: Store, +id: Nat) -> Store:
  match s:
    case Empty{n}:
      Empty{n}
    case Hold{Item{iid, name}, n}:
      Store.drop.eq(Nat.is_eq(iid, id), Item{iid, name}, n)

def Store.replace.eq(+hit: Bool, +iid: Nat, +n: Nat, +name: String, +old: String) -> Store:
  match hit:
    case True{}:
      Hold{Item{iid, name}, n}
    case False{}:
      Hold{Item{iid, old}, n}

def Store.replace(+s: Store, +id: Nat, +name: String) -> Store:
  match s:
    case Empty{n}:
      Empty{n}
    case Hold{Item{iid, old}, n}:
      Store.replace.eq(Nat.is_eq(iid, id), iid, n, name, old)
