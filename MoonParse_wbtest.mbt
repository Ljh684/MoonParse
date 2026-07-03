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

test "tag at eof" {
  match tag("hello", ParseInput::new("hel")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "tag_ci matches" {
  match tag_ci("hello", ParseInput::new("Hello")) {
    Some((_, v)) => assert_eq!(v, "Hello")
    None => assert_eq!(true, false)
  }
}

test "tag_ci no match" {
  match tag_ci("world", ParseInput::new("Hello")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "any_char gets first" {
  match any_char(ParseInput::new("abc")) {
    Some((_, ch)) => assert_eq!(ch, "a")
    None => assert_eq!(true, false)
  }
}

test "any_char at eof" {
  match any_char(ParseInput::new("")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "one_of matches" {
  match one_of("ab", ParseInput::new("abc")) {
    Some((_, ch)) => assert_eq!(ch, "a")
    None => assert_eq!(true, false)
  }
}

test "none_of blocks" {
  match none_of("ab", ParseInput::new("xyz")) {
    Some((_, ch)) => assert_eq!(ch, "x")
    None => assert_eq!(true, false)
  }
}

test "space parses" {
  match space(ParseInput::new("  text")) {
    Some((_, ch)) => assert_eq!(ch, " ")
    None => assert_eq!(true, false)
  }
}

test "space1 requires" {
  match space1(ParseInput::new("  text")) {
    Some((rest, _)) => assert_eq!(rest.current(), "t")
    None => assert_eq!(true, false)
  }
}

test "space1 none" {
  match space1(ParseInput::new("text")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "take_while1 match" {
  match take_while1(is_digit, ParseInput::new("123abc")) {
    Some((_, s)) => assert_eq!(s, "123")
    None => assert_eq!(true, false)
  }
}

test "take_while1 none" {
  match take_while1(is_digit, ParseInput::new("abc")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "take_while empty" {
  let (_, result) = take_while(is_digit, ParseInput::new("abc"))
  assert_eq!(result, "")
}

test "many1 match" {
  match many1(digit, ParseInput::new("111b")) {
    Some((_, vals)) => assert_eq!(vals.length(), 3)
    None => assert_eq!(true, false)
  }
}

test "many1 none" {
  match many1(digit, ParseInput::new("abc")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "separated_list1 match" {
  match separated_list1(alpha, tag_fn(","), ParseInput::new("a,b,c")) {
    Some((_, vals)) => assert_eq!(vals.length(), 3)
    None => assert_eq!(true, false)
  }
}

test "separated_list1 none" {
  match separated_list1(alpha, tag_fn(","), ParseInput::new("")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "separated_list single" {
  let (_, vals) = separated_list(alpha, tag_fn(","), ParseInput::new("a"))
  assert_eq!(vals.length(), 1)
}

test "separated_list empty" {
  let (_, vals) = separated_list(alpha, tag_fn(","), ParseInput::new(""))
  assert_eq!(vals.length(), 0)
}

test "alt first match" {
  match alt(tag_fn("hello"), tag_fn("world"), ParseInput::new("hello")) {
    Some((_, v)) => assert_eq!(v, "hello")
    None => assert_eq!(true, false)
  }
}

test "alt second match" {
  match alt(tag_fn("hello"), tag_fn("world"), ParseInput::new("world")) {
    Some((_, v)) => assert_eq!(v, "world")
    None => assert_eq!(true, false)
  }
}

test "alt neither match" {
  match alt(tag_fn("hello"), tag_fn("world"), ParseInput::new("other")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "opt always some" {
  match opt(tag_fn("hello"), ParseInput::new("hello")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "opt still some on fail" {
  match opt(tag_fn("hello"), ParseInput::new("other")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "tuple2 works" {
  match tuple2(alpha, alpha, ParseInput::new("ab")) {
    Some((_, (a, b))) => assert_eq!(a + b, "ab")
    None => assert_eq!(true, false)
  }
}

test "tuple2 fails" {
  match tuple2(digit, alpha, ParseInput::new("ab")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "preceded skips" {
  match preceded(tag_fn("//"), tag_fn("comment"), ParseInput::new("//comment")) {
    Some((_, v)) => assert_eq!(v, "comment")
    None => assert_eq!(true, false)
  }
}

test "terminated needs suffix" {
  match terminated(tag_fn("ab"), tag_fn(";"), ParseInput::new("ab;")) {
    Some((_, v)) => assert_eq!(v, "ab")
    None => assert_eq!(true, false)
  }
}

test "delimited brackets" {
  match delimited(tag_fn("["), tag_fn("hi"), tag_fn("]"), ParseInput::new("[hi]")) {
    Some((_, v)) => assert_eq!(v, "hi")
    None => assert_eq!(true, false)
  }
}

test "recognize returns matched text via lambda" {
  let parser = fn(i : ParseInput) -> (ParseInput, String)? { take_while1(is_digit, i) }
  match recognize(parser, ParseInput::new("123abc")) {
    Some((rest, text)) => {
      assert_eq!(text, "123")
      assert_eq!(rest.current(), "a")
    }
    None => assert_eq!(true, false)
  }
}

test "parse_int zero" {
  match parse_int(ParseInput::new("0")) {
    Some((_, v)) => assert_eq!(v, 0)
    None => assert_eq!(true, false)
  }
}

test "parse_float integer" {
  match parse_float(ParseInput::new("42")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "parse_hex lowercase" {
  match parse_hex_int(ParseInput::new("0x1a")) {
    Some((_, v)) => assert_eq!(v, 26)
    None => assert_eq!(true, false)
  }
}

test "quoted_string single quotes" {
  match quoted_string(ParseInput::new("'world'")) {
    Some((_, v)) => assert_eq!(v, "world")
    None => assert_eq!(true, false)
  }
}

test "quoted_string with escape" {
  match quoted_string(ParseInput::new("\"hello\\nworld\"")) {
    Some((_, v)) => assert_eq!(v.contains("\n"), true)
    None => assert_eq!(true, false)
  }
}

test "identifier underscore start" {
  match identifier(ParseInput::new("_private")) {
    Some((_, v)) => assert_eq!(v, "_private")
    None => assert_eq!(true, false)
  }
}

test "identifier rejects digit start" {
  match identifier(ParseInput::new("123abc")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "sql select parses" {
  match sql_keyword_select(ParseInput::new("SELECT *")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "sql from parses" {
  match sql_keyword_from(ParseInput::new("FROM t")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "sql where parses" {
  match sql_keyword_where(ParseInput::new("WHERE x=1")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "config comment" {
  match config_comment(ParseInput::new("# comment\n")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "error context format" {
  let ctx = ErrorContext::new().add_expected("digit").add_expected("alpha")
  let formatted = ctx.format()
  assert_eq!(formatted.contains("expected"), true)
  assert_eq!(formatted.contains("digit"), true)
  assert_eq!(formatted.contains("alpha"), true)
}

test "parse_error format" {
  let err = ParseError::new("unexpected", ParseInput::new("test"))
  let formatted = err.format()
  assert_eq!(formatted.contains("unexpected"), true)
}

test "space0 no-op" {
  let i = space0(ParseInput::new("text"))
  assert_eq!(i.pos, 0)
}
