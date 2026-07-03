// Parser combinators — compose simple parsers into complex ones

pub fn many0[T](parser : (ParseInput) -> (ParseInput, T)?, input : ParseInput) -> (ParseInput, Array[T]) {
  many0_acc(parser, input, [])
}

fn many0_acc[T](parser : (ParseInput) -> (ParseInput, T)?, input : ParseInput, acc : Array[T]) -> (ParseInput, Array[T]) {
  match parser(input) {
    Some((rest, val)) => {
      let new_acc = acc
      new_acc.push(val)
      many0_acc(parser, rest, new_acc)
    }
    None => (input, acc)
  }
}

pub fn many1[T](parser : (ParseInput) -> (ParseInput, T)?, input : ParseInput) -> (ParseInput, Array[T])? {
  match parser(input) {
    Some((rest, first)) => {
      let new_acc : Array[T] = [first]
      let (final_rest, result) = many0_acc(parser, rest, new_acc)
      Some((final_rest, result))
    }
    None => None
  }
}

pub fn many_n[T](parser : (ParseInput) -> (ParseInput, T)?, n : Int, input : ParseInput) -> (ParseInput, Array[T])? {
  let (rest, result) = count(parser, n, input, [])
  if result.length() == n { Some((rest, result)) } else { None }
}

fn count[T](parser : (ParseInput) -> (ParseInput, T)?, n : Int, input : ParseInput, acc : Array[T]) -> (ParseInput, Array[T]) {
  if n <= 0 { (input, acc) }
  else {
    match parser(input) {
      Some((rest, val)) => {
        acc.push(val)
        count(parser, n - 1, rest, acc)
      }
      None => (input, acc)
    }
  }
}

pub fn many_till[T, U](parser : (ParseInput) -> (ParseInput, T)?, end : (ParseInput) -> (ParseInput, U)?, input : ParseInput) -> (ParseInput, (Array[T], U))? {
  match end(input) {
    Some((rest, e)) => Some((rest, ([], e)))
    None => {
      match parser(input) {
        Some((r1, val)) => {
          match many_till(parser, end, r1) {
            Some((r2, (vals, e))) => {
              let new_vals = vals
              new_vals.push(val)
              Some((r2, (new_vals, e)))
            }
            None => None
          }
        }
        None => None
      }
    }
  }
}

pub fn separated_list[T, S](parser : (ParseInput) -> (ParseInput, T)?, sep : (ParseInput) -> (ParseInput, S)?, input : ParseInput) -> (ParseInput, Array[T]) {
  match parser(input) {
    Some((r1, first)) => {
      let acc : Array[T] = [first]
      separated_more(parser, sep, r1, acc)
    }
    None => (input, [])
  }
}

fn separated_more[T, S](parser : (ParseInput) -> (ParseInput, T)?, sep : (ParseInput) -> (ParseInput, S)?, input : ParseInput, acc : Array[T]) -> (ParseInput, Array[T]) {
  match sep(input) {
    Some((r1, _)) => {
      match parser(r1) {
        Some((r2, val)) => {
          acc.push(val)
          separated_more(parser, sep, r2, acc)
        }
        None => (input, acc)
      }
    }
    None => (input, acc)
  }
}

pub fn separated_list1[T, S](parser : (ParseInput) -> (ParseInput, T)?, sep : (ParseInput) -> (ParseInput, S)?, input : ParseInput) -> (ParseInput, Array[T])? {
  match parser(input) {
    Some((r1, first)) => {
      let acc : Array[T] = [first]
      let (rest, result) = separated_more(parser, sep, r1, acc)
      Some((rest, result))
    }
    None => None
  }
}

pub fn tuple2[T, U](p1 : (ParseInput) -> (ParseInput, T)?, p2 : (ParseInput) -> (ParseInput, U)?, input : ParseInput) -> (ParseInput, (T, U))? {
  match p1(input) {
    Some((r1, v1)) => {
      match p2(r1) {
        Some((r2, v2)) => Some((r2, (v1, v2)))
        None => None
      }
    }
    None => None
  }
}

pub fn tuple3[T, U, V](p1 : (ParseInput) -> (ParseInput, T)?, p2 : (ParseInput) -> (ParseInput, U)?, p3 : (ParseInput) -> (ParseInput, V)?, input : ParseInput) -> (ParseInput, (T, U, V))? {
  match p1(input) {
    Some((r1, v1)) => {
      match p2(r1) {
        Some((r2, v2)) => {
          match p3(r2) {
            Some((r3, v3)) => Some((r3, (v1, v2, v3)))
            None => None
          }
        }
        None => None
      }
    }
    None => None
  }
}

pub fn preceded[T, U](prefix : (ParseInput) -> (ParseInput, T)?, parser : (ParseInput) -> (ParseInput, U)?, input : ParseInput) -> (ParseInput, U)? {
  match prefix(input) {
    Some((r1, _)) => parser(r1)
    None => None
  }
}

pub fn terminated[T, U](parser : (ParseInput) -> (ParseInput, T)?, suffix : (ParseInput) -> (ParseInput, U)?, input : ParseInput) -> (ParseInput, T)? {
  match parser(input) {
    Some((r1, val)) => {
      match suffix(r1) {
        Some((r2, _)) => Some((r2, val))
        None => None
      }
    }
    None => None
  }
}

pub fn delimited[T, U, V](left : (ParseInput) -> (ParseInput, T)?, parser : (ParseInput) -> (ParseInput, U)?, right : (ParseInput) -> (ParseInput, V)?, input : ParseInput) -> (ParseInput, U)? {
  match left(input) {
    Some((r1, _)) => {
      match parser(r1) {
        Some((r2, val)) => {
          match right(r2) {
            Some((r3, _)) => Some((r3, val))
            None => None
          }
        }
        None => None
      }
    }
    None => None
  }
}

pub fn map[T, U](parser : (ParseInput) -> (ParseInput, T)?, f : (T) -> U, input : ParseInput) -> (ParseInput, U)? {
  match parser(input) {
    Some((rest, val)) => Some((rest, f(val)))
    None => None
  }
}

pub fn recognize[T](parser : (ParseInput) -> (ParseInput, T)?, input : ParseInput) -> (ParseInput, String)? {
  let start = input.pos
  match parser(input) {
    Some((rest, _)) => {
      let end = rest.pos
      Some((rest, input.source.substring(start=start, end=end)))
    }
    None => None
  }
}

pub fn not_parser[T](parser : (ParseInput) -> (ParseInput, T)?, input : ParseInput) -> (ParseInput, String)? {
  match parser(input) {
    Some(_) => None
    None => Some((input, ""))
  }
}

pub fn success[T](val : T, input : ParseInput) -> (ParseInput, T)? {
  Some((input, val))
}

pub fn fail[T](input : ParseInput) -> (ParseInput, T)? {
  None
}

pub fn cond[T](b : Bool, parser : (ParseInput) -> (ParseInput, T)?, input : ParseInput) -> (ParseInput, T)? {
  if b { parser(input) } else { None }
}
