test "input advance" {
  let i = ParseInput::new("hello")
  assert_eq!(i.pos, 0)
  let i2 = i.advance()
  assert_eq!(i2.pos, 1)
}

test "input current" {
  let i = ParseInput::new("abc")
  assert_eq!(i.current(), "a")
}

test "input is_eof" {
  assert_eq!(ParseInput::new("").is_eof(), true)
}

test "input advance_by" {
  let i = ParseInput::new("hello")
  let i2 = i.advance_by(3)
  assert_eq!(i2.pos, 3)
}

test "input remaining" {
  let i = ParseInput::new("hello")
  let i2 = i.advance_by(2)
  assert_eq!(i2.remaining(), "llo")
}

test "tag matches" {
  match tag("hello", ParseInput::new("hello world")) {
    Some((rest, val)) => assert_eq!(val, "hello")
    None => assert_eq!(true, false)
  }
}

test "tag no match" {
  match tag("world", ParseInput::new("hello")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "digit parses" {
  match digit(ParseInput::new("42")) {
    Some((_, ch)) => assert_eq!(ch, "4")
    None => assert_eq!(true, false)
  }
}

test "digit rejects alpha" {
  match digit(ParseInput::new("abc")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "alpha parses" {
  match alpha(ParseInput::new("abc")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "space0 skips" {
  let i = space0(ParseInput::new("   x"))
  assert_eq!(i.current(), "x")
}

test "eof matches empty" {
  match eof(ParseInput::new("")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "eof rejects non-empty" {
  match eof(ParseInput::new("x")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "take_while collects" {
  let i = ParseInput::new("123abc")
  let (rest, result) = take_while(is_digit, i)
  assert_eq!(result, "123")
}

test "many0 collects" {
  let i = ParseInput::new("111b")
  let (_, vals) = many0(digit, i)
  assert_eq!(vals.length(), 3)
}

test "many0 empty" {
  let i = ParseInput::new("abc")
  let (_, vals) = many0(digit, i)
  assert_eq!(vals.length(), 0)
}

test "separated_list" {
  let i = ParseInput::new("a,b,c")
  let (_, vals) = separated_list(alpha, tag_fn(","), i)
  assert_eq!(vals.length(), 3)
}

test "parse_int positive" {
  match parse_int(ParseInput::new("42")) {
    Some((_, v)) => assert_eq!(v, 42)
    None => assert_eq!(true, false)
  }
}

test "parse_int negative" {
  match parse_int(ParseInput::new("-17")) {
    Some((_, v)) => assert_eq!(v, -17)
    None => assert_eq!(true, false)
  }
}

test "parse_float" {
  match parse_float(ParseInput::new("3.14")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "parse_hex" {
  match parse_hex_int(ParseInput::new("0xFF")) {
    Some((_, v)) => assert_eq!(v, 255)
    None => assert_eq!(true, false)
  }
}

test "quoted_string" {
  match quoted_string(ParseInput::new("\"hello\"")) {
    Some((_, v)) => assert_eq!(v, "hello")
    None => assert_eq!(true, false)
  }
}

test "quoted_string empty" {
  match quoted_string(ParseInput::new("\"\"")) {
    Some((_, v)) => assert_eq!(v, "")
    None => assert_eq!(true, false)
  }
}

test "identifier" {
  match identifier(ParseInput::new("foo_bar123")) {
    Some((_, v)) => assert_eq!(v, "foo_bar123")
    None => assert_eq!(true, false)
  }
}

test "json null" {
  match json_null_parse(ParseInput::new("null")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "json true" {
  match json_true_parse(ParseInput::new("true")) {
    Some((_, v)) => assert_eq!(v, "true")
    None => assert_eq!(true, false)
  }
}

test "json false" {
  match json_false_parse(ParseInput::new("false")) {
    Some((_, v)) => assert_eq!(v, "false")
    None => assert_eq!(true, false)
  }
}

test "csv field" {
  match csv_field(ParseInput::new("hello,")) {
    Some((_, v)) => assert_eq!(v, "hello")
    None => assert_eq!(true, false)
  }
}

test "url scheme" {
  match url_scheme(ParseInput::new("https://x.com")) {
    Some((_, v)) => assert_eq!(v, "https")
    None => assert_eq!(true, false)
  }
}

test "ini section" {
  match ini_section_name(ParseInput::new("[db]")) {
    Some((_, v)) => assert_eq!(v, "db")
    None => assert_eq!(true, false)
  }
}

test "http header name" {
  match http_header_name(ParseInput::new("X-Key: val")) {
    Some((_, v)) => assert_eq!(v, "X-Key")
    None => assert_eq!(true, false)
  }
}

test "multispace0 skips" {
  let i = multispace0(ParseInput::new("  \t\n x"))
  assert_eq!(i.current(), "x")
}

test "parse_u64" {
  match parse_u64(ParseInput::new("123")) {
    Some((_, v)) => assert_eq!(v, 123)
    None => assert_eq!(true, false)
  }
}
