import Base
import ./store.bend as S
import ./api.bend as A

type Parsed is Data:
  Parsed{method: A.Method, route: A.Route, name: String}
  Bad{}

type MethodRest is Data:
  MR{method: A.Method, rest: String}

type RouteRest is Data:
  RR{route: A.Route, rest: String}

def Http.skip_spaces(+s: String) -> String:
  match s:
    case SNil{}:
      SNil{}
    case SCon{' ', t}:
      Http.skip_spaces(t)
    case SCon{'\t', t}:
      Http.skip_spaces(t)
    case SCon{'\n', t}:
      Http.skip_spaces(t)
    case SCon{'\r', t}:
      Http.skip_spaces(t)
    case SCon{h, t}:
      SCon{h, t}

def Http.take_method(+s: String) -> MethodRest:
  match s:
    case SCon{'G', SCon{'E', SCon{'T', rest}}}:
      MR{A.GET{}, Http.skip_spaces(rest)}
    case SCon{'P', SCon{'U', SCon{'T', rest}}}:
      MR{A.PUT{}, Http.skip_spaces(rest)}
    case SCon{'P', SCon{'O', SCon{'S', SCon{'T', rest}}}}:
      MR{A.POST{}, Http.skip_spaces(rest)}
    case SCon{'D', SCon{'E', SCon{'L', SCon{'E', SCon{'T', SCon{'E', rest}}}}}}:
      MR{A.DELETE{}, Http.skip_spaces(rest)}
    case SCon{'O', SCon{'P', SCon{'T', SCon{'I', SCon{'O', SCon{'N', SCon{'S', rest}}}}}}}:
      MR{A.OPTIONS{}, Http.skip_spaces(rest)}
    case SNil{}:
      MR{A.GET{}, SNil{}}
    case SCon{h, t}:
      MR{A.GET{}, SNil{}}

def Http.read_id(+s: String, +acc: Nat) -> RouteRest:
  match s:
    case SNil{}:
      RR{A.ItemId{acc}, SNil{}}
    case SCon{' ', t}:
      RR{A.ItemId{acc}, SNil{}}
    case SCon{'\n', t}:
      RR{A.ItemId{acc}, SNil{}}
    case SCon{'\r', t}:
      RR{A.ItemId{acc}, SNil{}}
    case SCon{'/', t}:
      RR{A.ItemId{acc}, t}
    case SCon{'0', t}:
      Http.read_id(t, Nat.mul(acc, 10n))
    case SCon{'1', t}:
      Http.read_id(t, Nat.add(Nat.mul(acc, 10n), 1n))
    case SCon{'2', t}:
      Http.read_id(t, Nat.add(Nat.mul(acc, 10n), 2n))
    case SCon{'3', t}:
      Http.read_id(t, Nat.add(Nat.mul(acc, 10n), 3n))
    case SCon{'4', t}:
      Http.read_id(t, Nat.add(Nat.mul(acc, 10n), 4n))
    case SCon{'5', t}:
      Http.read_id(t, Nat.add(Nat.mul(acc, 10n), 5n))
    case SCon{'6', t}:
      Http.read_id(t, Nat.add(Nat.mul(acc, 10n), 6n))
    case SCon{'7', t}:
      Http.read_id(t, Nat.add(Nat.mul(acc, 10n), 7n))
    case SCon{'8', t}:
      Http.read_id(t, Nat.add(Nat.mul(acc, 10n), 8n))
    case SCon{'9', t}:
      Http.read_id(t, Nat.add(Nat.mul(acc, 10n), 9n))
    case SCon{h, t}:
      RR{A.Unknown{}, SNil{}}

def Http.after_items.tail(+s: String) -> RouteRest:
  match s:
    case SNil{}:
      RR{A.Items{}, SNil{}}
    case SCon{' ', t}:
      RR{A.Items{}, SNil{}}
    case SCon{'\n', t}:
      RR{A.Items{}, SNil{}}
    case SCon{'\r', t}:
      RR{A.Items{}, SNil{}}
    case SCon{'/', t}:
      Http.read_id(t, 0n)
    case SCon{h, t}:
      RR{A.Unknown{}, SNil{}}

def Http.after_items(+s: String) -> RouteRest:
  match s:
    case SCon{'/', SCon{'i', SCon{'t', SCon{'e', SCon{'m', SCon{'s', rest}}}}}}:
      Http.after_items.tail(Http.skip_spaces(rest))
    case SNil{}:
      RR{A.Unknown{}, SNil{}}
    case SCon{h, t}:
      RR{A.Unknown{}, SNil{}}

def Http.take_name(+s: String) -> String:
  match s:
    case SNil{}:
      SNil{}
    case SCon{' ', t}:
      SNil{}
    case SCon{'\n', t}:
      SNil{}
    case SCon{'\r', t}:
      SNil{}
    case SCon{h, t}:
      SCon{h, Http.take_name(t)}

def Http.parse_from.route(+m: A.Method, +p: RouteRest) -> Parsed:
  match p:
    case RR{r, rest}:
      Parsed{m, r, Http.take_name(rest)}

def Http.parse_from.path(+m: A.Method, +path: String) -> Parsed:
  Http.parse_from.route(m, Http.after_items(path))

def Http.parse_from(+p: MethodRest) -> Parsed:
  match p:
    case MR{m, path}:
      Http.parse_from.path(m, path)

def Http.parse_line(+line: String) -> Parsed:
  Http.parse_from(Http.take_method(line))

def Http.status_text(+st: A.Status) -> String:
  match st:
    case A.S200{}:
      "200 OK"
    case A.S201{}:
      "201 Created"
    case A.S204{}:
      "204 No Content"
    case A.S400{}:
      "400 Bad Request"
    case A.S404{}:
      "404 Not Found"

def Http.response(+st: A.Status, +body: String) -> String:
  "HTTP/1.1 " ++ Http.status_text(st) ++ "\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\n" ++ body

def Http.dispatch(+s: S.Store, +p: Parsed) -> A.Reply:
  match p:
    case Bad{}:
      A.Reply{A.S404{}, s}
    case Parsed{m, r, name}:
      A.Api.handle(s, m, r, name)
