# MoonParse — Competition Acceptance Checklist

## ParseInput & Error
- [x] ParseInput::new() with position tracking (line/col)
- [x] advance() / advance_by() / current() / is_eof() / remaining()
- [x] ParseError with position-aware format()
- [x] ErrorContext with expected labels and error accumulation

## Primitives (13 types)
- [x] tag / tag_ci — exact and case-insensitive string matching
- [x] any_char — matches any character
- [x] digit / hex_digit — numeric character matching
- [x] alpha / alphanumeric — alphabetic character matching
- [x] space / space0 / space1 — horizontal whitespace
- [x] multispace0 / multispace1 — all whitespace including newlines
- [x] eof — end of input detection
- [x] satisfy — predicate-based matching
- [x] one_of / none_of — character set matching
- [x] take_while / take_while1 — predicate-based collection
- [x] take_until — collect until pattern
- [x] newline — CRLF or LF matching
- [x] rest / peek — remaining text, non-consuming peek
- [x] skip_while — skip matching characters

## Combinators (16 types)
- [x] many0 / many1 — zero/more, one/more repetition
- [x] many_n — exact count repetition
- [x] many_till — repetition until end marker
- [x] separated_list / separated_list1 — delimiter-separated values
- [x] alt — try two alternatives
- [x] opt — optional parser (always succeeds)
- [x] tuple2 / tuple3 — sequential combination
- [x] preceded / terminated / delimited — prefix/suffix/both
- [x] map — transform parse result
- [x] recognize — return matched text
- [x] success / fail — constant results
- [x] cond — conditional execution
- [x] not_parser — negative lookahead

## Number Parsing (6 types)
- [x] parse_int — signed integer
- [x] parse_u64 — unsigned integer
- [x] parse_float — floating point (with integer fallback)
- [x] parse_hex_int — hexadecimal (0x prefix)
- [x] parse_scientific — scientific notation (e+/-)
- [x] parse_bool — true/false

## String Parsing (5 types)
- [x] quoted_string — double/single quotes with escape sequences
- [x] triple_quoted_string — """...""" or '''...'''
- [x] identifier — [_a-zA-Z][_a-zA-Z0-9]*
- [x] keyword — reserved word (non-identifier-char boundary)
- [x] Escape handling: \n \t \r \\ \" \' \/

## Binary Parsing (9 types)
- [x] u8 / u16_le / u32_le / u64_le — fixed-width integers
- [x] f32_le / f64_le — IEEE 754 floats
- [x] leb128_u / leb128_s — variable-length encoding
- [x] counted_string — length-prefixed string
- [x] c_string — null-terminated string

## Full Parsers
- [x] JSON parser — JsonValue enum (Null/Bool/Number/String/Array/Object)
- [x] JSON serializer — json_value_to_string()
- [x] TOML parser — keys, values, tables, array tables
- [x] CSV parser — fields (quoted/unquoted), rows
- [x] INI parser — sections, key-value pairs
- [x] URL parser — scheme, host, path, query, fragment
- [x] HTTP header parser
- [x] SQL tokenizer — SELECT/FROM/WHERE, identifiers, values

## Project Quality
- [x] moon check passes with 0 errors
- [x] moon test — 166 tests, all passing
- [x] CI (GitHub Actions)
- [x] README with installation, quick start, and full API reference
- [x] Apache-2.0 License
- [x] GitHub: https://github.com/Ljh684/MoonParse
- [x] GitLink: https://gitlink.org.cn/a678b789/MoonParse

## Code Statistics
- Core modules: 10 files
- Source: ~1,476 lines (.mbt)
- Tests: ~1,153 lines
- Total: ~2,629 lines
- Commits: 14

## Competition Submission
- [x] GitHub pushed (14 commits)
- [x] GitLink pushed
- [x] README with API reference
- [x] CI configured
- [x] Proposal PDF
- [x] Acceptance checklist (this file)
