// ParseInput — tracks position within the source string

pub(all) struct ParseInput {
  source : String
  pos : Int
  line : Int
  col : Int
}

pub fn ParseInput::new(source : String) -> ParseInput {
  ParseInput::{ source, pos: 0, line: 1, col: 1 }
}

pub fn ParseInput::current(self : ParseInput) -> String {
  if self.pos >= self.source.length() { "" }
  else { self.source.substring(start=self.pos, end=self.pos + 1) }
}

pub fn ParseInput::advance(self : ParseInput) -> ParseInput {
  if self.pos >= self.source.length() { self }
  else {
    let ch = self.current()
    let new_line = if ch == "\n" { self.line + 1 } else { self.line }
    let new_col = if ch == "\n" { 1 } else { self.col + 1 }
    ParseInput::{ ..self, pos: self.pos + 1, line: new_line, col: new_col }
  }
}

pub fn ParseInput::advance_by(self : ParseInput, n : Int) -> ParseInput {
  advance_n(self, n)
}

fn advance_n(input : ParseInput, n : Int) -> ParseInput {
  if n <= 0 { input }
  else { advance_n(input.advance(), n - 1) }
}

pub fn ParseInput::is_eof(self : ParseInput) -> Bool {
  self.pos >= self.source.length()
}

pub fn ParseInput::remaining(self : ParseInput) -> String {
  if self.pos >= self.source.length() { "" }
  else { self.source.substring(start=self.pos, end=self.source.length()) }
}

pub fn ParseInput::position(self : ParseInput) -> String {
  "line " + self.line.to_string() + ", col " + self.col.to_string()
}

pub fn ParseInput::slice(self : ParseInput, start_pos : Int, end_pos : Int) -> String {
  if start_pos >= self.source.length() { return "" }
  let end = if end_pos > self.source.length() { self.source.length() } else { end_pos }
  self.source.substring(start=start_pos, end=end)
}

pub fn ParseInput::source_len(self : ParseInput) -> Int {
  self.source.length()
}
