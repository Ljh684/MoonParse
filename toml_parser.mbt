// TOML parser built on MoonParse combinators

pub fn toml_key(input : ParseInput) -> (ParseInput, String)? {
  match quoted_string(input) {
    Some((r, s)) => Some((r, s))
    None => take_while1(fn(ch : String) -> Bool { is_alpha(ch) || is_digit(ch) || ch == "_" || ch == "-" }, input)
  }
}

pub fn toml_comment(input : ParseInput) -> (ParseInput, String)? {
  match tag("#", input) {
    Some((r1, _)) => {
      let (r2, content) = take_while(fn(ch : String) -> Bool { ch != "\n" && ch != "\r" }, r1)
      Some((r2, content))
    }
    None => None
  }
}

pub fn toml_bare_key(input : ParseInput) -> (ParseInput, String)? {
  take_while1(fn(ch : String) -> Bool { is_alpha(ch) || is_digit(ch) || ch == "_" || ch == "-" }, input)
}

pub fn toml_dotted_key(input : ParseInput) -> (ParseInput, String)? {
  let (r1, first) = match toml_bare_key(input) {
    Some((r, k)) => (r, k)
    None => return None
  }
  toml_dotted_rest(r1, first, 0)
}

fn toml_dotted_rest(input : ParseInput, key : String, idx : Int) -> (ParseInput, String)? {
  match tag(".", input) {
    Some((r1, _)) => {
      match toml_bare_key(r1) {
        Some((r2, k)) => toml_dotted_rest(r2, key + "." + k, idx + 1)
        None => None
      }
    }
    None => Some((input, key))
  }
}

pub fn toml_string(input : ParseInput) -> (ParseInput, String)? {
  alt(quoted_string, toml_triple_quoted, input)
}

fn toml_triple_quoted(input : ParseInput) -> (ParseInput, String)? {
  match tag("\"\"\"", input) {
    Some((r1, _)) => {
      let (r2, content) = take_while(fn(ch : String) -> Bool { true }, r1)
      match tag("\"\"\"", r2) {
        Some((r3, _)) => Some((r3, content))
        None => None
      }
    }
    None => match tag("'''", input) {
      Some((r1, _)) => {
        let (r2, content) = take_while(fn(ch : String) -> Bool { true }, r1)
        match tag("'''", r2) {
          Some((r3, _)) => Some((r3, content))
          None => None
        }
      }
      None => None
    }
  }
}

pub fn toml_bool(input : ParseInput) -> (ParseInput, Bool)? {
  match tag("true", input) {
    Some((r, _)) => Some((r, true))
    None => match tag("false", input) {
      Some((r, _)) => Some((r, false))
      None => None
    }
  }
}

pub fn toml_integer(input : ParseInput) -> (ParseInput, Int)? {
  parse_int(input)
}

pub fn toml_float(input : ParseInput) -> (ParseInput, Float)? {
  parse_float(input)
}

pub fn toml_array(input : ParseInput) -> (ParseInput, Array[String])? {
  let i = multispace0(input)
  match tag("[", i) {
    Some((r1, _)) => {
      let r2 = multispace0(r1)
      match tag("]", r2) {
        Some((r3, _)) => Some((r3, []))
        None => {
          let (r3, vals) = separated_list(toml_value, tag_fn(","), r2)
          let r4 = multispace0(r3)
          match tag("]", r4) {
            Some((r5, _)) => Some((r5, vals))
            None => None
          }
        }
      }
    }
    None => None
  }
}

fn toml_value(input : ParseInput) -> (ParseInput, String)? {
  let i = multispace0(input)
  match toml_string(i) {
    Some((r, s)) => Some((r, s))
    None => match recognize(toml_float, i) {
      Some((r, s)) => Some((r, s))
      None => match recognize(toml_integer, i) {
        Some((r, s)) => Some((r, s))
        None => match recognize(toml_bool, i) {
          Some((r, s)) => Some((r, s))
          None => None
        }
      }
    }
  }
}

pub fn toml_table_header(input : ParseInput) -> (ParseInput, String)? {
  let i = multispace0(input)
  match tag("[", i) {
    Some((r1, _)) => {
      match toml_dotted_key(r1) {
        Some((r2, key)) => {
          match tag("]", r2) {
            Some((r3, _)) => Some((r3, key))
            None => None
          }
        }
        None => None
      }
    }
    None => None
  }
}

pub fn toml_array_table_header(input : ParseInput) -> (ParseInput, String)? {
  let i = multispace0(input)
  match tag("[[", i) {
    Some((r1, _)) => {
      match toml_dotted_key(r1) {
        Some((r2, key)) => {
          match tag("]]", r2) {
            Some((r3, _)) => Some((r3, key))
            None => None
          }
        }
        None => None
      }
    }
    None => None
  }
}
