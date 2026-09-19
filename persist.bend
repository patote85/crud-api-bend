import Base
import ./store.bend as S
import ./http.bend as H

def Persist.take(+raw: String, +st: S.Store) -> S.Store:
  S.Store.put(st, S.Item{H.Http.json_id(raw), H.Http.json_name(raw), H.Http.json_desc(raw), H.Http.json_price(raw)})

def Persist.collect(+s: String, +acc: String, +on: Bool, +st: S.Store) -> S.Store:
  match s on:
    case SNil{} False{}:
      st
    case SNil{} True{}:
      Persist.take(acc, st)
    case SCon{'{', t} False{}:
      Persist.collect(t, "{", True{}, st)
    case SCon{'{', t} True{}:
      Persist.collect(t, acc ++ "{", True{}, st)
    case SCon{'}', t} True{}:
      Persist.collect(t, SNil{}, False{}, Persist.take(acc ++ "}", st))
    case SCon{'}', t} False{}:
      Persist.collect(t, SNil{}, False{}, st)
    case SCon{h, t} True{}:
      Persist.collect(t, acc ++ SCon{h, SNil{}}, True{}, st)
    case SCon{h, t} False{}:
      Persist.collect(t, SNil{}, False{}, st)

def Persist.parse(+s: String, +st: S.Store) -> S.Store:
  Persist.collect(s, SNil{}, False{}, st)

def Persist.saved(m: File & Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  (f, r) = m
  File.close(f)

def Persist.write_ok(f: File, +data: String) -> IO(Unit):
  do IO<Unit>:
    m : File & Result<&1, &1, U32 & String, Unit> <- File.write(f, data)
    Persist.saved(m)

def Persist.from_open(+st: S.Store, r: Result<&1, &1, U32 & String, File>) -> IO(Unit):
  match r:
    case Fail{e}:
      IO.print("persist: skip write")
    case Done{f}:
      Persist.write_ok(f, S.Store.json(st))

def Persist.save(+st: S.Store) -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, File> <- File.open("store.json", "w")
    Persist.from_open(st, r)

def Persist.decode(r: Result<&1, &1, U32 & String, String>, +st: S.Store) -> S.Store:
  match r:
    case Fail{e}:
      st
    case Done{txt}:
      Persist.parse(txt, st)

def Persist.after_read(m: File & Result<&1, &1, U32 & String, String>, +st: S.Store) -> IO(S.Store):
  (f, r) = m
  do IO<S.Store>:
    File.close(f)
    return Persist.decode(r, st)

def Persist.from_read(r: Result<&1, &1, U32 & String, File>, +st: S.Store) -> IO(S.Store):
  match r:
    case Fail{e}:
      IO.pure(S.Store, st)
    case Done{f}:
      do IO<S.Store>:
        m : File & Result<&1, &1, U32 & String, String> <- File.read(f, 65536)
        Persist.after_read(m, st)

def Persist.load() -> IO(S.Store):
  do IO<S.Store>:
    r : Result<&1, &1, U32 & String, File> <- File.open("store.json", "r")
    Persist.from_read(r, S.Store.empty())
