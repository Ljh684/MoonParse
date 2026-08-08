// Parser combinators — compose simple parsers into complex ones

///|
pub fn[T] many0(
  parser : (ParseInput) -> (ParseInput, T)?,
  input : ParseInput,
) -> (ParseInput, Array[T]) {
  many0_acc(parser, input, [])
}

///|
fn[T] many0_acc(
  parser : (ParseInput) -> (ParseInput, T)?,
  input : ParseInput,
  acc : Array[T],
) -> (ParseInput, Array[T]) {
  match parser(input) {
    Some((rest, val)) => {
      let new_acc = acc
      new_acc.push(val)
      many0_acc(parser, rest, new_acc)
    }
    None => (input, acc)
  }
}

///|
pub fn[T] many1(
  parser : (ParseInput) -> (ParseInput, T)?,
  input : ParseInput,
) -> (ParseInput, Array[T])? {
  match parser(input) {
    Some((rest, first)) => {
      let new_acc : Array[T] = [first]
      let (final_rest, result) = many0_acc(parser, rest, new_acc)
      Some((final_rest, result))
    }
    None => None
  }
}

///|
pub fn[T] many_n(
  parser : (ParseInput) -> (ParseInput, T)?,
  n : Int,
  input : ParseInput,
) -> (ParseInput, Array[T])? {
  let (rest, result) = count(parser, n, input, [])
  if result.length() == n {
    Some((rest, result))
  } else {
    None
  }
}

///|
fn[T] count(
  parser : (ParseInput) -> (ParseInput, T)?,
  n : Int,
  input : ParseInput,
  acc : Array[T],
) -> (ParseInput, Array[T]) {
  if n <= 0 {
    (input, acc)
  } else {
    match parser(input) {
      Some((rest, val)) => {
        acc.push(val)
        count(parser, n - 1, rest, acc)
      }
      None => (input, acc)
    }
  }
}

///|
pub fn[T, U] many_till(
  parser : (ParseInput) -> (ParseInput, T)?,
  end : (ParseInput) -> (ParseInput, U)?,
  input : ParseInput,
) -> (ParseInput, (Array[T], U))? {
  match end(input) {
    Some((rest, e)) => Some((rest, ([], e)))
    None =>
      match parser(input) {
        Some((r1, val)) =>
          match many_till(parser, end, r1) {
            Some((r2, (vals, e))) => {
              let new_vals = vals
              new_vals.push(val)
              Some((r2, (new_vals, e)))
            }
            None => None
          }
        None => None
      }
  }
}

///|
pub fn[T, S] separated_list(
  parser : (ParseInput) -> (ParseInput, T)?,
  sep : (ParseInput) -> (ParseInput, S)?,
  input : ParseInput,
) -> (ParseInput, Array[T]) {
  match parser(input) {
    Some((r1, first)) => {
      let acc : Array[T] = [first]
      separated_more(parser, sep, r1, acc)
    }
    None => (input, [])
  }
}

///|
fn[T, S] separated_more(
  parser : (ParseInput) -> (ParseInput, T)?,
  sep : (ParseInput) -> (ParseInput, S)?,
  input : ParseInput,
  acc : Array[T],
) -> (ParseInput, Array[T]) {
  match sep(input) {
    Some((r1, _)) =>
      match parser(r1) {
        Some((r2, val)) => {
          acc.push(val)
          separated_more(parser, sep, r2, acc)
        }
        None => (input, acc)
      }
    None => (input, acc)
  }
}

///|
pub fn[T, S] separated_list1(
  parser : (ParseInput) -> (ParseInput, T)?,
  sep : (ParseInput) -> (ParseInput, S)?,
  input : ParseInput,
) -> (ParseInput, Array[T])? {
  match parser(input) {
    Some((r1, first)) => {
      let acc : Array[T] = [first]
      let (rest, result) = separated_more(parser, sep, r1, acc)
      Some((rest, result))
    }
    None => None
  }
}

///|
pub fn[T, U] tuple2(
  p1 : (ParseInput) -> (ParseInput, T)?,
  p2 : (ParseInput) -> (ParseInput, U)?,
  input : ParseInput,
) -> (ParseInput, (T, U))? {
  match p1(input) {
    Some((r1, v1)) =>
      match p2(r1) {
        Some((r2, v2)) => Some((r2, (v1, v2)))
        None => None
      }
    None => None
  }
}

///|
pub fn[T, U, V] tuple3(
  p1 : (ParseInput) -> (ParseInput, T)?,
  p2 : (ParseInput) -> (ParseInput, U)?,
  p3 : (ParseInput) -> (ParseInput, V)?,
  input : ParseInput,
) -> (ParseInput, (T, U, V))? {
  match p1(input) {
    Some((r1, v1)) =>
      match p2(r1) {
        Some((r2, v2)) =>
          match p3(r2) {
            Some((r3, v3)) => Some((r3, (v1, v2, v3)))
            None => None
          }
        None => None
      }
    None => None
  }
}

///|
pub fn[T, U] preceded(
  prefix : (ParseInput) -> (ParseInput, T)?,
  parser : (ParseInput) -> (ParseInput, U)?,
  input : ParseInput,
) -> (ParseInput, U)? {
  match prefix(input) {
    Some((r1, _)) => parser(r1)
    None => None
  }
}

///|
pub fn[T, U] terminated(
  parser : (ParseInput) -> (ParseInput, T)?,
  suffix : (ParseInput) -> (ParseInput, U)?,
  input : ParseInput,
) -> (ParseInput, T)? {
  match parser(input) {
    Some((r1, val)) =>
      match suffix(r1) {
        Some((r2, _)) => Some((r2, val))
        None => None
      }
    None => None
  }
}

///|
pub fn[T, U, V] delimited(
  left : (ParseInput) -> (ParseInput, T)?,
  parser : (ParseInput) -> (ParseInput, U)?,
  right : (ParseInput) -> (ParseInput, V)?,
  input : ParseInput,
) -> (ParseInput, U)? {
  match left(input) {
    Some((r1, _)) =>
      match parser(r1) {
        Some((r2, val)) =>
          match right(r2) {
            Some((r3, _)) => Some((r3, val))
            None => None
          }
        None => None
      }
    None => None
  }
}

///|
pub fn[T, U] map(
  parser : (ParseInput) -> (ParseInput, T)?,
  f : (T) -> U,
  input : ParseInput,
) -> (ParseInput, U)? {
  match parser(input) {
    Some((rest, val)) => Some((rest, f(val)))
    None => None
  }
}

///|
pub fn[T] recognize(
  parser : (ParseInput) -> (ParseInput, T)?,
  input : ParseInput,
) -> (ParseInput, String)? {
  let start = input.pos
  match parser(input) {
    Some((rest, _)) => {
      let end = rest.pos
      Some((rest, input.source.substring(start~, end~)))
    }
    None => None
  }
}

///|
pub fn[T] not_parser(
  parser : (ParseInput) -> (ParseInput, T)?,
  input : ParseInput,
) -> (ParseInput, String)? {
  match parser(input) {
    Some(_) => None
    None => Some((input, ""))
  }
}

///|
pub fn[T] success(val : T, input : ParseInput) -> (ParseInput, T)? {
  Some((input, val))
}

///|
pub fn[T] fail(input : ParseInput) -> (ParseInput, T)? {
  None
}

///|
pub fn[T] cond(
  b : Bool,
  parser : (ParseInput) -> (ParseInput, T)?,
  input : ParseInput,
) -> (ParseInput, T)? {
  if b {
    parser(input)
  } else {
    None
  }
}
