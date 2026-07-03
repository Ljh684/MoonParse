// Error types and formatting for parse failures

pub(all) struct ParseError {
  message : String
  input : ParseInput
}

pub fn ParseError::new(msg : String, input : ParseInput) -> ParseError {
  ParseError::{ message: msg, input }
}

pub fn ParseError::format(self : ParseError) -> String {
  "Parse error at " + self.input.position() + ": " + self.message
}

// Error context — accumulate multiple expectations
pub(all) struct ErrorContext {
  expected : Array[String]
  errors : Array[ParseError]
}

pub fn ErrorContext::new() -> ErrorContext {
  ErrorContext::{ expected: [], errors: [] }
}

pub fn ErrorContext::add_expected(self : ErrorContext, label : String) -> ErrorContext {
  let new_exp = self.expected
  new_exp.push(label)
  ErrorContext::{ ..self, expected: new_exp }
}

pub fn ErrorContext::add_error(self : ErrorContext, err : ParseError) -> ErrorContext {
  let new_errs = self.errors
  new_errs.push(err)
  ErrorContext::{ ..self, errors: new_errs }
}

pub fn ErrorContext::format(self : ErrorContext) -> String {
  let result = "expected: " + format_expected(self.expected, 0, "")
  if self.errors.length() > 0 {
    result + " | " + format_errors(self.errors, 0, "")
  } else {
    result
  }
}

fn format_expected(expected : Array[String], idx : Int, result : String) -> String {
  if idx >= expected.length() { result }
  else {
    let sep = if idx > 0 { ", " } else { "" }
    format_expected(expected, idx + 1, result + sep + expected[idx])
  }
}

fn format_errors(errors : Array[ParseError], idx : Int, result : String) -> String {
  if idx >= errors.length() { result }
  else {
    let sep = if idx > 0 { "; " } else { "" }
    format_errors(errors, idx + 1, result + sep + errors[idx].message)
  }
}
