// Full JSON parser built on MoonParse combinators

pub(all) enum JsonValue {
  Null
  Bool(Bool)
  Number(Float)
  String(String)
  Array(Array[JsonValue])
  Object(Array[(String, JsonValue)])
}

// Forward declaration helpers
fn parse_json_value(input : ParseInput) -> (ParseInput, JsonValue)? {
  let i = multispace0(input)
  if i.is_eof() { return None }
  match parse_json_string(i) {
    Some((r, v)) => Some((r, JsonValue::String(v)))
    None => match parse_json_number_val(i) {
      Some((r, v)) => Some((r, JsonValue::Number(v)))
      None => match parse_json_bool_val(i) {
        Some((r, v)) => Some((r, JsonValue::Bool(v)))
        None => match parse_json_null_val(i) {
          Some((r, _)) => Some((r, JsonValue::Null))
          None => match parse_json_array(i) {
            Some((r, v)) => Some((r, JsonValue::Array(v)))
            None => match parse_json_object(i) {
              Some((r, v)) => Some((r, JsonValue::Object(v)))
              None => None
            }
          }
        }
      }
    }
  }
}

fn parse_json_string(input : ParseInput) -> (ParseInput, String)? {
  quoted_string(input)
}

fn parse_json_number_val(input : ParseInput) -> (ParseInput, Float)? {
  parse_float(input)
}

fn parse_json_bool_val(input : ParseInput) -> (ParseInput, Bool)? {
  match tag("true", input) {
    Some((r, _)) => Some((r, true))
    None => match tag("false", input) {
      Some((r, _)) => Some((r, false))
      None => None
    }
  }
}

fn parse_json_null_val(input : ParseInput) -> (ParseInput, String)? {
  tag("null", input)
}

fn parse_json_array(input : ParseInput) -> (ParseInput, Array[JsonValue])? {
  let i = multispace0(input)
  match tag("[", i) {
    Some((r1, _)) => {
      let r2 = multispace0(r1)
      match tag("]", r2) {
        Some((r3, _)) => Some((r3, []))
        None => parse_json_array_elements(r2, [])
      }
    }
    None => None
  }
}

fn parse_json_array_elements(input : ParseInput, acc : Array[JsonValue]) -> (ParseInput, Array[JsonValue])? {
  let i = multispace0(input)
  match parse_json_value(i) {
    Some((r1, val)) => {
      acc.push(val)
      let r2 = multispace0(r1)
      match tag(",", r2) {
        Some((r3, _)) => parse_json_array_elements(r3, acc)
        None => {
          let r3 = multispace0(r2)
          match tag("]", r3) {
            Some((r4, _)) => Some((r4, acc))
            None => None
          }
        }
      }
    }
    None => None
  }
}

fn parse_json_object(input : ParseInput) -> (ParseInput, Array[(String, JsonValue)])? {
  let i = multispace0(input)
  match tag("{", i) {
    Some((r1, _)) => {
      let r2 = multispace0(r1)
      match tag("}", r2) {
        Some((r3, _)) => Some((r3, []))
        None => parse_json_object_pairs(r2, [])
      }
    }
    None => None
  }
}

fn parse_json_object_pairs(input : ParseInput, acc : Array[(String, JsonValue)]) -> (ParseInput, Array[(String, JsonValue)])? {
  let i = multispace0(input)
  match quoted_string(i) {
    Some((r1, key)) => {
      let r2 = multispace0(r1)
      match tag(":", r2) {
        Some((r3, _)) => {
          let r4 = multispace0(r3)
          match parse_json_value(r4) {
            Some((r5, val)) => {
              acc.push((key, val))
              let r6 = multispace0(r5)
              match tag(",", r6) {
                Some((r7, _)) => parse_json_object_pairs(r7, acc)
                None => {
                  let r7 = multispace0(r6)
                  match tag("}", r7) {
                    Some((r8, _)) => Some((r8, acc))
                    None => None
                  }
                }
              }
            }
            None => None
          }
        }
        None => None
      }
    }
    None => None
  }
}

// Public API
pub fn json_parse(input : ParseInput) -> (ParseInput, JsonValue)? {
  let i = multispace0(input)
  parse_json_value(i)
}

// Helper: format JsonValue back to string
pub fn json_value_to_string(val : JsonValue) -> String {
  match val {
    JsonValue::Null => "null"
    JsonValue::Bool(b) => if b { "true" } else { "false" }
    JsonValue::Number(f) => f.to_string()
    JsonValue::String(s) => "\"" + s + "\""
    JsonValue::Array(arr) => json_array_to_string(arr, 0, "[")
    JsonValue::Object(pairs) => json_object_to_string(pairs, 0, "{")
  }
}

fn json_array_to_string(arr : Array[JsonValue], idx : Int, result : String) -> String {
  if idx >= arr.length() { result + "]" }
  else {
    let sep = if idx > 0 { "," } else { "" }
    json_array_to_string(arr, idx + 1, result + sep + json_value_to_string(arr[idx]))
  }
}

fn json_object_to_string(pairs : Array[(String, JsonValue)], idx : Int, result : String) -> String {
  if idx >= pairs.length() { result + "}" }
  else {
    let (k, v) = pairs[idx]
    let sep = if idx > 0 { "," } else { "" }
    json_object_to_string(pairs, idx + 1, result + sep + "\"" + k + "\":" + json_value_to_string(v))
  }
}
