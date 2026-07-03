// Blackbox tests for MoonParse public API

test "tag parses prefix" {
  match @MoonParse.tag("hello", @MoonParse.ParseInput::new("hello world")) {
    Some((rest, val)) => {
      assert_eq!(val, "hello")
      assert_eq!(rest.pos, 5)
    }
    None => assert_eq!(true, false)
  }
}

test "digit parses single digit" {
  match @MoonParse.digit(@MoonParse.ParseInput::new("123")) {
    Some((_, ch)) => assert_eq!(ch, "1")
    None => assert_eq!(true, false)
  }
}

test "many0 with digit" {
  let i = @MoonParse.ParseInput::new("123abc")
  let (_, vals) = @MoonParse.many0(@MoonParse.digit, i)
  assert_eq!(vals.length(), 3)
}

test "parse_int full" {
  match @MoonParse.parse_int(@MoonParse.ParseInput::new("-42")) {
    Some((_, v)) => assert_eq!(v, -42)
    None => assert_eq!(true, false)
  }
}

test "quoted_string public" {
  match @MoonParse.quoted_string(@MoonParse.ParseInput::new("\"test\"")) {
    Some((_, s)) => assert_eq!(s, "test")
    None => assert_eq!(true, false)
  }
}

test "separated_list public" {
  let i = @MoonParse.ParseInput::new("x,y,z")
  let (_, vals) = @MoonParse.separated_list(@MoonParse.alpha, fn(input) -> (ParseInput, String)? { @MoonParse.tag(",", input) }, i)
  assert_eq!(vals.length(), 3)
}

test "json parse null" {
  match @MoonParse.json_parse(@MoonParse.ParseInput::new("null")) {
    Some((_, _)) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "json parse empty object" {
  match @MoonParse.json_parse(@MoonParse.ParseInput::new("{}")) {
    Some((_, _)) => assert_eq!(true, true)
    None => assert_eq!(true, false)
  }
}

test "toml table header" {
  match @MoonParse.toml_table_header(@MoonParse.ParseInput::new("[section]")) {
    Some((_, name)) => assert_eq!(name, "section")
    None => assert_eq!(true, false)
  }
}

test "toml key parse" {
  match @MoonParse.toml_bare_key(@MoonParse.ParseInput::new("my_key = 1")) {
    Some((rest, key)) => {
      assert_eq!(key, "my_key")
    }
    None => assert_eq!(true, false)
  }
}
