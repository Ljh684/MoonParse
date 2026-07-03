// Primitive parsers — the basic building blocks

pub fn tag(expected : String, input : ParseInput) -> (ParseInput, String)? {
  let len = expected.length()
  if input.pos + len > input.source.length() { return None }
  if input.source.substring(start=input.pos, end=input.pos + len) == expected {
    Some((input.advance_by(len), expected))
  } else {
    None
  }
}

pub fn tag_ci(expected : String, input : ParseInput) -> (ParseInput, String)? {
  let len = expected.length()
  if input.pos + len > input.source.length() { return None }
  let actual = input.source.substring(start=input.pos, end=input.pos + len)
  if actual.to_lower() == expected.to_lower() {
    Some((input.advance_by(len), actual))
  } else {
    None
  }
}

pub fn any_char(input : ParseInput) -> (ParseInput, String)? {
  if input.is_eof() { return None }
  let ch = input.current()
  Some((input.advance(), ch))
}

pub fn satisfy(pred : (String) -> Bool, input : ParseInput) -> (ParseInput, String)? {
  if input.is_eof() { return None }
  let ch = input.current()
  if pred(ch) { Some((input.advance(), ch)) } else { None }
}

pub fn one_of(chars : String, input : ParseInput) -> (ParseInput, String)? {
  satisfy(fn(ch : String) -> Bool { chars.contains(ch) }, input)
}

pub fn none_of(chars : String, input : ParseInput) -> (ParseInput, String)? {
  satisfy(fn(ch : String) -> Bool { chars.contains(ch) == false }, input)
}

pub fn digit(input : ParseInput) -> (ParseInput, String)? {
  satisfy(is_digit, input)
}

pub fn hex_digit(input : ParseInput) -> (ParseInput, String)? {
  satisfy(is_hex, input)
}

pub fn alpha(input : ParseInput) -> (ParseInput, String)? {
  satisfy(is_alpha, input)
}

pub fn alphanumeric(input : ParseInput) -> (ParseInput, String)? {
  satisfy(fn(ch : String) -> Bool { is_alpha(ch) || is_digit(ch) }, input)
}

pub fn space(input : ParseInput) -> (ParseInput, String)? {
  satisfy(is_space, input)
}

pub fn space0(input : ParseInput) -> ParseInput {
  skip_while(is_space, input)
}

pub fn space1(input : ParseInput) -> (ParseInput, String)? {
  many1_space(input, 0, "")
}

fn many1_space(input : ParseInput, count : Int, result : String) -> (ParseInput, String)? {
  if input.is_eof() { if count > 0 { Some((input, result)) } else { None } }
  else {
    let ch = input.current()
    if is_space(ch) { many1_space(input.advance(), count + 1, result + ch) }
    else { if count > 0 { Some((input, result)) } else { None } }
  }
}

pub fn multispace0(input : ParseInput) -> ParseInput {
  skip_while(is_multispace, input)
}

pub fn multispace1(input : ParseInput) -> (ParseInput, String)? {
  many1_multispace(input, 0, "")
}

fn many1_multispace(input : ParseInput, count : Int, result : String) -> (ParseInput, String)? {
  if input.is_eof() { if count > 0 { Some((input, result)) } else { None } }
  else {
    let ch = input.current()
    if is_multispace(ch) { many1_multispace(input.advance(), count + 1, result + ch) }
    else { if count > 0 { Some((input, result)) } else { None } }
  }
}

pub fn newline(input : ParseInput) -> (ParseInput, String)? {
  alt(tag_fn("\r\n"), tag_fn("\n"), input)
}

pub fn eof(input : ParseInput) -> (ParseInput, String)? {
  if input.is_eof() { Some((input, "")) } else { None }
}

pub fn take_while(pred : (String) -> Bool, input : ParseInput) -> (ParseInput, String) {
  take_while_acc(pred, input, input.pos, "")
}

fn take_while_acc(pred : (String) -> Bool, input : ParseInput, start : Int, result : String) -> (ParseInput, String) {
  if input.is_eof() { (input, result) }
  else {
    let ch = input.current()
    if pred(ch) { take_while_acc(pred, input.advance(), start, result + ch) }
    else { (input, result) }
  }
}

pub fn take_while1(pred : (String) -> Bool, input : ParseInput) -> (ParseInput, String)? {
  let (rest, result) = take_while(pred, input)
  if result == "" { None } else { Some((rest, result)) }
}

pub fn take_until(tag_str : String, input : ParseInput) -> (ParseInput, String)? {
  take_until_acc(tag_str, input, input.pos, "")
}

fn take_until_acc(tag_str : String, input : ParseInput, start : Int, result : String) -> (ParseInput, String)? {
  if input.is_eof() { None }
  else if input.source.substring(start=input.pos, end=input.pos + tag_str.length()) == tag_str {
    Some((input, result))
  } else {
    let ch = input.current()
    take_until_acc(tag_str, input.advance(), start, result + ch)
  }
}

pub fn peek[T](parser : (ParseInput) -> (ParseInput, T)?, input : ParseInput) -> (ParseInput, T)? {
  parser(input)
}

pub fn rest(input : ParseInput) -> (ParseInput, String)? {
  let remaining = input.remaining()
  if remaining == "" { None } else { Some((ParseInput::{ ..input, pos: input.source.length() }, remaining)) }
}

// Helper functions
fn tag_fn(expected : String) -> (ParseInput) -> (ParseInput, String)? {
  fn(input : ParseInput) -> (ParseInput, String)? { tag(expected, input) }
}

fn is_digit(ch : String) -> Bool {
  ch >= "0" && ch <= "9"
}

fn is_hex(ch : String) -> Bool {
  is_digit(ch) || (ch >= "a" && ch <= "f") || (ch >= "A" && ch <= "F")
}

fn is_alpha(ch : String) -> Bool {
  (ch >= "a" && ch <= "z") || (ch >= "A" && ch <= "Z")
}

fn is_space(ch : String) -> Bool {
  ch == " " || ch == "\t"
}

fn is_multispace(ch : String) -> Bool {
  is_space(ch) || ch == "\n" || ch == "\r"
}

pub fn skip_while(pred : (String) -> Bool, input : ParseInput) -> ParseInput {
  if input.is_eof() { input }
  else {
    let ch = input.current()
    if pred(ch) { skip_while(pred, input.advance()) }
    else { input }
  }
}

pub fn alt[T](p1 : (ParseInput) -> (ParseInput, T)?, p2 : (ParseInput) -> (ParseInput, T)?, input : ParseInput) -> (ParseInput, T)? {
  match p1(input) {
    Some((rest, val)) => Some((rest, val))
    None => p2(input)
  }
}

pub fn opt[T](parser : (ParseInput) -> (ParseInput, T)?, input : ParseInput) -> (ParseInput, String)? {
  match parser(input) {
    Some((rest, _)) => Some((rest, ""))
    None => Some((input, ""))
  }
}
