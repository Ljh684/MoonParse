// Example parsers: JSON, CSV, INI, URL, HTTP, SQL

// --- JSON strings ---
pub fn json_string_parse(input : ParseInput) -> (ParseInput, String)? {
  quoted_string(input)
}

// --- JSON numbers ---
pub fn json_number_parse(input : ParseInput) -> (ParseInput, String)? {
  recognize(parse_float, input)
}

// --- JSON booleans ---
pub fn json_true_parse(input : ParseInput) -> (ParseInput, String)? {
  tag("true", input)
}

pub fn json_false_parse(input : ParseInput) -> (ParseInput, String)? {
  tag("false", input)
}

pub fn json_null_parse(input : ParseInput) -> (ParseInput, String)? {
  tag("null", input)
}

// --- CSV ---
pub fn csv_field(input : ParseInput) -> (ParseInput, String)? {
  match quoted_string(input) {
    Some((r, s)) => Some((r, s))
    None => {
      let (rest, result) = take_while(fn(ch : String) -> Bool { ch != "," && ch != "\n" && ch != "\r" }, input)
      if result == "" { None } else { Some((rest, result)) }
    }
  }
}

pub fn csv_comma(input : ParseInput) -> (ParseInput, String)? {
  tag(",", input)
}

pub fn csv_newline(input : ParseInput) -> (ParseInput, String)? {
  alt(tag_fn("\r\n"), tag_fn("\n"), input)
}

// --- INI ---
pub fn ini_section_name(input : ParseInput) -> (ParseInput, String)? {
  match tag("[", input) {
    Some((r1, _)) => {
      match take_while1(fn(ch : String) -> Bool { ch != "]" && ch != "\n" }, r1) {
        Some((r2, name)) => {
          match tag("]", r2) {
            Some((r3, _)) => Some((r3, name))
            None => None
          }
        }
        None => None
      }
    }
    None => None
  }
}

pub fn ini_key(input : ParseInput) -> (ParseInput, String)? {
  take_while1(fn(ch : String) -> Bool { ch != "=" && ch != "\n" }, input)
}

pub fn ini_value(input : ParseInput) -> (ParseInput, String)? {
  let (rest, result) = take_while(fn(ch : String) -> Bool { ch != "\n" && ch != "\r" }, input)
  Some((rest, result))
}

// --- URL ---
pub fn url_scheme(input : ParseInput) -> (ParseInput, String)? {
  take_while1(fn(ch : String) -> Bool { is_alpha(ch) }, input)
}

pub fn url_separator(input : ParseInput) -> (ParseInput, String)? {
  tag("://", input)
}

pub fn url_host(input : ParseInput) -> (ParseInput, String)? {
  take_while1(fn(ch : String) -> Bool { ch != "/" && ch != "?" && ch != "#" }, input)
}

pub fn url_path(input : ParseInput) -> (ParseInput, String)? {
  let (rest, result) = take_while(fn(ch : String) -> Bool { ch != "?" && ch != "#" }, input)
  Some((rest, result))
}

pub fn url_query(input : ParseInput) -> (ParseInput, String)? {
  let (rest, result) = take_while(fn(ch : String) -> Bool { ch != "#" }, input)
  Some((rest, result))
}

pub fn url_fragment(input : ParseInput) -> (ParseInput, String)? {
  let (rest, result) = take_while(fn(ch : String) -> Bool { ch != " " && ch != "\n" }, input)
  Some((rest, result))
}

// --- HTTP headers ---
pub fn http_header_name(input : ParseInput) -> (ParseInput, String)? {
  take_while1(fn(ch : String) -> Bool { ch != ":" }, input)
}

pub fn http_header_value(input : ParseInput) -> (ParseInput, String)? {
  let i = space0(input)
  let (rest, result) = take_while(fn(ch : String) -> Bool { ch != "\n" && ch != "\r" }, i)
  Some((rest, result))
}

pub fn http_version(input : ParseInput) -> (ParseInput, String)? {
  match tag("HTTP/", input) {
    Some((r1, _)) => {
      let (r2, ver) = take_while(fn(ch : String) -> Bool { ch != " " && ch != "\n" && ch != "\r" }, r1)
      Some((r2, ver))
    }
    None => None
  }
}

// --- Simple SQL ---
pub fn sql_keyword_select(input : ParseInput) -> (ParseInput, String)? {
  tag("SELECT", input)
}

pub fn sql_keyword_from(input : ParseInput) -> (ParseInput, String)? {
  tag("FROM", input)
}

pub fn sql_keyword_where(input : ParseInput) -> (ParseInput, String)? {
  tag("WHERE", input)
}

pub fn sql_star(input : ParseInput) -> (ParseInput, String)? {
  tag("*", input)
}

pub fn sql_identifier(input : ParseInput) -> (ParseInput, String)? {
  identifier(input)
}

pub fn sql_string_value(input : ParseInput) -> (ParseInput, String)? {
  quoted_string(input)
}

pub fn sql_number_value(input : ParseInput) -> (ParseInput, String)? {
  recognize(parse_float, input)
}

// --- Config format ---
pub fn config_comment(input : ParseInput) -> (ParseInput, String)? {
  match tag("#", input) {
    Some((r1, _)) => Some((r1, take_while(fn(ch : String) -> Bool { ch != "\n" && ch != "\r" }, r1).1))
    None => match tag("//", input) {
      Some((r1, _)) => Some((r1, take_while(fn(ch : String) -> Bool { ch != "\n" && ch != "\r" }, r1).1))
      None => None
    }
  }
}

pub fn whitespace_line(input : ParseInput) -> (ParseInput, String)? {
  let i = space0(input)
  if i.is_eof() { return Some((i, "")) }
  match tag("\n", i) {
    Some((r1, _)) => Some((r1, ""))
    None => match tag("\r\n", i) {
      Some((r1, _)) => Some((r1, ""))
      None => None
    }
  }
}
