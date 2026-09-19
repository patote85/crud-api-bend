import Base
import ./store.bend as S
import ./api.bend as A
import ./http.bend as H

def Server.body(+st: A.Status, +n: Nat) -> String:
  match st:
    case A.S204{}:
      SNil{}
    case A.S200{}:
      "count=" ++ Nat.show(n)
    case A.S201{}:
      "count=" ++ Nat.show(n)
    case A.S400{}:
      "count=" ++ Nat.show(n)
    case A.S404{}:
      "count=" ++ Nat.show(n)

def Server.reply_text(+r: A.Reply) -> String:
  match r:
    case A.Reply{st, s}:
      H.Http.response(st, Server.body(st, S.Store.count(s)))

def Server.reply_store(+r: A.Reply) -> S.Store:
  match r:
    case A.Reply{st, s}:
      s

def Server.sent(m: Socket & Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  (s, r) = m
  Socket.close(s)

def Server.apply.line(+ch: Chan(S.Store), sock: Socket, +line: String, +store: S.Store) -> IO(Unit):
  do IO<Unit>:
    +rep : A.Reply = H.Http.dispatch(store, H.Http.parse_request(line))
    txt : String = Server.reply_text(rep)
    s2 : S.Store = Server.reply_store(rep)
    _b : Bool <- Chan.send(S.Store, ch, s2)
    sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(sock, txt)
    Server.sent(sent)

def Server.apply.got(+ch: Chan(S.Store), sock: Socket, +line: String, got: Maybe<&1, S.Store>) -> IO(Unit):
  match got:
    case None{}:
      Socket.close(sock)
    case Some{store}:
      Server.apply.line(ch, sock, line, store)

def Server.apply(+ch: Chan(S.Store), sock: Socket, +line: String) -> IO(Unit):
  do IO<Unit>:
    got : Maybe<&1, S.Store> <- Chan.recv(S.Store, ch)
    Server.apply.got(ch, sock, line, got)

def Server.reply(m: Socket & Result<&1, &1, U32 & String, String>, +ch: Chan(S.Store)) -> IO(Unit):
  (s, r) = m
  match r:
    case Done{req}:
      Server.apply(ch, s, req)
    case Fail{e}:
      Socket.close(s)

def Server.talk(sock: Socket, +ch: Chan(S.Store)) -> IO(Unit):
  do IO<Unit>:
    read : Socket & Result<&1, &1, U32 & String, String> <- TCP.recv(sock, 8192)
    Server.reply(read, ch)

def Server.conn(m: Listener & Result<&1, &1, U32 & String, Socket>, +ch: Chan(S.Store)) -> IO(Listener):
  (l, r) = m
  do IO<Listener>:
    s : Socket <- IO.pass(Socket, r)
    IO.spawn(Unit, Server.talk(s, ch))
    return l

@unsafe def Server.serve(l: Listener, +ch: Chan(S.Store)) -> IO(Unit):
  do IO<Unit>:
    m : Listener & Result<&1, &1, U32 & String, Socket> <- TCP.accept(l)
    l2 : Listener <- Server.conn(m, ch)
    Server.serve(l2, ch)
