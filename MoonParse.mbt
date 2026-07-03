// MoonParse — Parser Combinator Library for MoonBit
//
// A composable parser combinator library inspired by Rust's nom.
// Build complex parsers from small, reusable building blocks.
//
// Usage:
//   let input = ParseInput::new("hello 123")
//   match tag("hello", input) { ... }
//   let (rest, vals) = many0(digit, rest)
//
// Features:
//   - String-level primitives: tag, digit, alpha, space, eof, satisfy
//   - Combinators: many0, many1, alt, opt, separated_list, tuple, preceded, delimited
//   - Numbers: integers, floats, hex, scientific notation
//   - Strings: quoted strings (escapes), identifiers, keywords
//   - Binary: u8-u64, LEB128, counted strings
//   - Examples: JSON parser, TOML parser, CSV, URL, HTTP headers, SQL tokenizer
//   - Error tracking: position (line/col), error context with expected labels
