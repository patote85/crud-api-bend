import Base
import ./store.bend as S
import ./api.bend as A
import ./http.bend as H
import ./persist.bend as P

def Server.reply_text(+r: A.Reply) -> String:
  match r:
    case A.Reply{st, s, body}:
      H.Http.response(st, body)

def Server.reply_store(+r: A.Reply) -> S.Store:
  match r:
    case A.Reply{st, s, body}:
      s

def Server.sent(m: Socket & Result<&1, &1, (U32 & String) & String, Unit>) -> IO(Unit):
  (s, r) = m
  Socket.close(s)

def Server.sent_store(r: Result<&1, &1, S.Store, Unit>) -> Unit:
  match r:
    case Done{value}:
      value
    case Fail{error}:
      Unit{}

def Server.apply.line(+ch: Chan(S.Store), sock: Socket, +line: String, +store: S.Store) -> IO(Unit):
  do IO<Unit>:
    +rep : A.Reply = H.Http.dispatch(store, H.Http.parse_request(line))
    txt : String = Server.reply_text(rep)
    +s2 : S.Store = Server.reply_store(rep)
    _u : Unit <- P.Persist.save(s2)
    put : Result<&1, &1, S.Store, Unit> <- Chan.send(S.Store, ch, s2)
    _d : Unit = Server.sent_store(put)
    sent : Socket & Result<&1, &1, (U32 & String) & String, Unit> <- TCP.send(sock, txt)
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

def Server.reply.body(sock: Socket, req: Maybe<&1, String>, +ch: Chan(S.Store)) -> IO(Unit):
  match req:
    case Some{line}:
      Server.apply(ch, sock, line)
    case None{}:
      Socket.close(sock)

def Server.reply(m: Socket & Result<&1, &1, U32 & String, Maybe<&1, String>>, +ch: Chan(S.Store)) -> IO(Unit):
  (s, r) = m
  match r:
    case Done{req}:
      Server.reply.body(s, req, ch)
    case Fail{e}:
      Socket.close(s)

def Server.talk(sock: Socket, +ch: Chan(S.Store)) -> IO(Unit):
  do IO<Unit>:
    read : Socket & Result<&1, &1, U32 & String, Maybe<&1, String>> <- TCP.recv(sock, 8192)
    Server.reply(read, ch)

def Server.conn(m: Listener & Result<&1, &1, U32 & String, Socket>, +ch: Chan(S.Store)) -> IO(Listener):
  (l, r) = m
  do IO<Listener>:
    s : Socket <- IO.pass(Socket, r)
    IO.spawn(Unit, Server.talk(s, ch))
    return l

def Server.serve.go(+fuel: Nat, l: Listener, +ch: Chan(S.Store)) -> IO(Unit):
  match fuel:
    case 0n:
      Listener.close(l)
    case 1n+f:
      do IO<Unit>:
        m : Listener & Result<&1, &1, U32 & String, Socket> <- TCP.accept(l)
        l2 : Listener <- Server.conn(m, ch)
        Server.serve.go(f, l2, ch)

def Server.serve(l: Listener, +ch: Chan(S.Store)) -> IO(Unit):
  Server.serve.go(4294967295n, l, ch)
