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

test "json parse null value" {
  match json_parse(ParseInput::new("null")) {
    Some((_, val)) => match val {
      JsonValue::Null => assert_eq!(true, true)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse bool true" {
  match json_parse(ParseInput::new("true")) {
    Some((_, val)) => match val {
      JsonValue::Bool(b) => assert_eq!(b, true)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse bool false" {
  match json_parse(ParseInput::new("false")) {
    Some((_, val)) => match val {
      JsonValue::Bool(b) => assert_eq!(b, false)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse number" {
  match json_parse(ParseInput::new("3.14")) {
    Some((_, val)) => match val {
      JsonValue::Number(_) => assert_eq!(true, true)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse string" {
  match json_parse(ParseInput::new("\"hello\"")) {
    Some((_, val)) => match val {
      JsonValue::String(s) => assert_eq!(s, "hello")
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse empty array" {
  match json_parse(ParseInput::new("[]")) {
    Some((_, val)) => match val {
      JsonValue::Array(arr) => assert_eq!(arr.length(), 0)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse simple array" {
  match json_parse(ParseInput::new("[1, 2, 3]")) {
    Some((_, val)) => match val {
      JsonValue::Array(arr) => assert_eq!(arr.length(), 3)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse empty object" {
  match json_parse(ParseInput::new("{}")) {
    Some((_, val)) => match val {
      JsonValue::Object(pairs) => assert_eq!(pairs.length(), 0)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse simple object" {
  match json_parse(ParseInput::new("{\"key\": \"val\"}")) {
    Some((_, val)) => match val {
      JsonValue::Object(pairs) => {
        assert_eq!(pairs.length(), 1)
        assert_eq!(pairs[0].0, "key")
      }
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse nested object" {
  let src = "{\"a\": {\"b\": 1}}"
  match json_parse(ParseInput::new(src)) {
    Some((_, val)) => match val {
      JsonValue::Object(pairs) => assert_eq!(pairs.length(), 1)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "toml key bare" {
  match toml_bare_key(ParseInput::new("hello = 1")) {
    Some((rest, key)) => {
      assert_eq!(key, "hello")
      assert_eq!(rest.current(), " ")
    }
    None => assert_eq!(true, false)
  }
}

test "toml dotted key" {
  match toml_dotted_key(ParseInput::new("a.b.c = 1")) {
    Some((rest, key)) => {
      assert_eq!(key, "a.b.c")
    }
    None => assert_eq!(true, false)
  }
}

test "toml comment" {
  match toml_comment(ParseInput::new("# comment\n")) {
    Some((_, content)) => assert_eq!(content.contains("comment"), true)
    None => assert_eq!(true, false)
  }
}

test "toml string basic" {
  match toml_string(ParseInput::new("\"hello\"")) {
    Some((_, s)) => assert_eq!(s, "hello")
    None => assert_eq!(true, false)
  }
}

test "toml boolean" {
  match toml_bool(ParseInput::new("true")) {
    Some((_, b)) => assert_eq!(b, true)
    None => assert_eq!(true, false)
  }
}

test "toml integer" {
  match toml_integer(ParseInput::new("42")) {
    Some((_, v)) => assert_eq!(v, 42)
    None => assert_eq!(true, false)
  }
}

test "toml table header" {
  match toml_table_header(ParseInput::new("[database]")) {
    Some((_, name)) => assert_eq!(name, "database")
    None => assert_eq!(true, false)
  }
}

test "toml array table header" {
  match toml_array_table_header(ParseInput::new("[[servers]]")) {
    Some((_, name)) => assert_eq!(name, "servers")
    None => assert_eq!(true, false)
  }
}

test "toml dotted key deep" {
  match toml_dotted_key(ParseInput::new("database.mysql.port = 3306")) {
    Some((rest, key)) => assert_eq!(key, "database.mysql.port")
    None => assert_eq!(true, false)
  }
}

test "toml integer negative" {
  match toml_integer(ParseInput::new("-99")) {
    Some((_, v)) => assert_eq!(v, -99)
    None => assert_eq!(true, false)
  }
}

test "toml false" {
  match toml_bool(ParseInput::new("false")) {
    Some((_, b)) => assert_eq!(b, false)
    None => assert_eq!(true, false)
  }
}

test "json parse integer" {
  match json_parse(ParseInput::new("42")) {
    Some((_, val)) => match val {
      JsonValue::Number(_) => assert_eq!(true, true)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse negative number" {
  match json_parse(ParseInput::new("-3.14")) {
    Some((_, val)) => match val {
      JsonValue::Number(_) => assert_eq!(true, true)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json parse string array" {
  match json_parse(ParseInput::new("[\"a\", \"b\"]")) {
    Some((_, val)) => match val {
      JsonValue::Array(arr) => assert_eq!(arr.length(), 2)
      _ => assert_eq!(true, false)
    }
    None => assert_eq!(true, false)
  }
}

test "json value to string null" {
  assert_eq!(json_value_to_string(JsonValue::Null), "null")
}

test "json value to string bool" {
  assert_eq!(json_value_to_string(JsonValue::Bool(true)), "true")
}

test "json value to string number" {
  let s = json_value_to_string(JsonValue::Number(3.14))
  assert_eq!(s.contains("3.14"), true)
}

test "json value to string array" {
  let val = JsonValue::Array([JsonValue::Null, JsonValue::Bool(false)])
  let s = json_value_to_string(val)
  assert_eq!(s.contains("null"), true)
  assert_eq!(s.contains("false"), true)
}

test "hex to int boundary" {
  match parse_hex_int(ParseInput::new("0x0")) {
    Some((_, v)) => assert_eq!(v, 0)
    None => assert_eq!(true, false)
  }
}

test "hex to int max byte" {
  match parse_hex_int(ParseInput::new("0xFF")) {
    Some((_, v)) => assert_eq!(v, 255)
    None => assert_eq!(true, false)
  }
}

test "identifier with digits" {
  match identifier(ParseInput::new("abc123def")) {
    Some((_, v)) => assert_eq!(v, "abc123def")
    None => assert_eq!(true, false)
  }
}

test "keyword followed by space" {
  match keyword("if", ParseInput::new("if x > 0")) {
    Some((_, v)) => assert_eq!(v, "if")
    None => assert_eq!(true, false)
  }
}

test "keyword not followed by identifier char" {
  match keyword("if", ParseInput::new("ifx")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "multispace0 preserves pos when no whitespace" {
  let i = multispace0(ParseInput::new("text"))
  assert_eq!(i.pos, 0)
}

test "space0 handles empty input" {
  let i = space0(ParseInput::new(""))
  assert_eq!(i.is_eof(), true)
}

test "many_n insufficient count" {
  match many_n(digit, 5, ParseInput::new("12ab")) {
    Some(_) => assert_eq!(true, false)
    None => assert_eq!(true, true)
  }
}

test "many_n zero" {
  match many_n(digit, 0, ParseInput::new("abc")) {
    Some((_, vals)) => assert_eq!(vals.length(), 0)
    None => assert_eq!(true, false)
  }
}

test "http version parse" {
  match http_version(ParseInput::new("HTTP/1.1 200 OK")) {
    Some((_, ver)) => assert_eq!(ver, "1.1")
    None => assert_eq!(true, false)
  }
}

test "url separator" {
  match url_separator(ParseInput::new("://example.com")) {
    Some((_, _)) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "sql star" {
  match sql_star(ParseInput::new("* FROM users")) {
    Some((_, _)) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "sql string value" {
  match sql_string_value(ParseInput::new("'hello'")) {
    Some((_, s)) => assert_eq!(s, "hello")
    None => assert_eq!(true, false)
  }
}

test "sql number value" {
  match sql_number_value(ParseInput::new("3.14")) {
    Some((_, _)) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "whitespace line newline" {
  match whitespace_line(ParseInput::new("\n")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "whitespace line spaces then newline" {
  match whitespace_line(ParseInput::new("  \t\n")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "config comment double slash" {
  match config_comment(ParseInput::new("// comment\n")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "counted string" {
  match counted_string(ParseInput::new("\x00\x00\x00\x05hello")) {
    Some(_) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "leb128 unsigned small value" {
  match leb128_u(ParseInput::new("\x01")) {
    Some((_, v)) => assert_eq!(v, 1)
    None => assert_eq!(true, false)
  }
}

test "many_till collects until end marker" {
  let i = ParseInput::new("abc;")
  match many_till(alpha, tag_fn(";"), i) {
    Some((_, (vals, _))) => assert_eq!(vals.length(), 3)
    None => assert_eq!(true, false)
  }
}

