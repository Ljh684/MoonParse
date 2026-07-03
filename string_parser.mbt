// String parsing utilities — quoted strings, escapes, identifiers

pub fn quoted_string(input : ParseInput) -> (ParseInput, String)? {
  match tag("\"", input) {
    Some((r1, _)) => quoted_content(r1, "")
    None => match tag("'", input) {
      Some((r1, _)) => single_content(r1, "")
      None => None
    }
  }
}

fn quoted_content(input : ParseInput, acc : String) -> (ParseInput, String)? {
  if input.is_eof() { return None }
  let ch = input.current()
  if ch == "\"" {
    Some((input.advance(), acc))
  } else if ch == "\\" {
    parse_dq_escape(input.advance(), acc)
  } else {
    quoted_content(input.advance(), acc + ch)
  }
}

fn single_content(input : ParseInput, acc : String) -> (ParseInput, String)? {
  if input.is_eof() { return None }
  let ch = input.current()
  if ch == "'" {
    Some((input.advance(), acc))
  } else if ch == "\\" {
    parse_sq_escape(input.advance(), acc)
  } else {
    single_content(input.advance(), acc + ch)
  }
}

fn parse_dq_escape(input : ParseInput, acc : String) -> (ParseInput, String)? {
  if input.is_eof() { return None }
  let ch = input.current()
  let rest = input.advance()
  let escaped = match ch {
    "n" => "\n"
    "t" => "\t"
    "r" => "\r"
    "\\" => "\\"
    "\"" => "\""
    "/" => "/"
    _ => ch
  }
  quoted_content(rest, acc + escaped)
}

fn parse_sq_escape(input : ParseInput, acc : String) -> (ParseInput, String)? {
  if input.is_eof() { return None }
  let ch = input.current()
  let rest = input.advance()
  let escaped = match ch {
    "n" => "\n"
    "t" => "\t"
    "r" => "\r"
    "\\" => "\\"
    "'" => "'"
    _ => ch
  }
  single_content(rest, acc + escaped)
}

pub fn triple_quoted_string(input : ParseInput) -> (ParseInput, String)? {
  match tag("\"\"\"", input) {
    Some((r1, _)) => triple_content(r1, "")
    None => None
  }
}

fn triple_content(input : ParseInput, acc : String) -> (ParseInput, String)? {
  if input.is_eof() { return None }
  if input.source.substring(start=input.pos, end=input.pos + 3) == "\"\"\"" {
    Some((input.advance_by(3), acc))
  } else {
    let ch = input.current()
    triple_content(input.advance(), acc + ch)
  }
}

pub fn identifier(input : ParseInput) -> (ParseInput, String)? {
  match alpha(input) {
    Some((r1, first)) => {
      let (rest, rest_str) = take_while(fn(ch : String) -> Bool { is_alpha(ch) || is_digit(ch) || ch == "_" }, r1)
      Some((rest, first + rest_str))
    }
    None => match tag("_", input) {
      Some((r1, u)) => {
        let (rest, rest_str) = take_while(fn(ch : String) -> Bool { is_alpha(ch) || is_digit(ch) || ch == "_" }, r1)
        Some((rest, u + rest_str))
      }
      None => None
    }
  }
}

pub fn keyword(kw : String, input : ParseInput) -> (ParseInput, String)? {
  match tag(kw, input) {
    Some((r1, val)) => {
      if r1.is_eof() { return Some((r1, val)) }
      let ch = r1.current()
      if is_alpha(ch) || is_digit(ch) || ch == "_" { None }
      else { Some((r1, val)) }
    }
    None => None
  }
}
