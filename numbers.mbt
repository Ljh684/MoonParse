// Number parsing — integers and scientific notation

pub fn parse_int(input : ParseInput) -> (ParseInput, Int)? {
  let (rest, sign) = match tag("-", input) {
    Some((r, _)) => (r, true)
    None => (input, false)
  }
  match take_while1(is_digit, rest) {
    Some((rest2, digits)) => {
      let val = str_to_int(digits, 0, 0)
      let final_val = if sign { -val } else { val }
      Some((rest2, final_val))
    }
    None => None
  }
}

fn str_to_int(s : String, idx : Int, acc : Int) -> Int {
  if idx >= s.length() { acc }
  else {
    let ch = s.substring(start=idx, end=idx + 1)
    let digit = match ch {
      "0" => 0
      "1" => 1
      "2" => 2
      "3" => 3
      "4" => 4
      "5" => 5
      "6" => 6
      "7" => 7
      "8" => 8
      "9" => 9
      _ => 0
    }
    str_to_int(s, idx + 1, acc * 10 + digit)
  }
}

pub fn parse_u64(input : ParseInput) -> (ParseInput, Int)? {
  match take_while1(is_digit, input) {
    Some((rest, digits)) => Some((rest, str_to_int(digits, 0, 0)))
    None => None
  }
}

pub fn parse_float(input : ParseInput) -> (ParseInput, Float)? {
  let (rest, sign) = match tag("-", input) {
    Some((r, _)) => (r, true)
    None => (input, false)
  }
  let (r1, whole_str) = match take_while1(is_digit, rest) {
    Some((r, d)) => (r, d)
    None => return None
  }
  let whole = Float::from_int(str_to_int(whole_str, 0, 0))

  match tag(".", r1) {
    Some((r2, _)) => {
      match take_while1(is_digit, r2) {
        Some((r3, frac_str)) => {
          let frac_val = Float::from_int(str_to_int(frac_str, 0, 0))
          let div = pow10_float(frac_str.length())
          let result = whole + frac_val / div
          let final_val = if sign { -result } else { result }
          Some((r3, final_val))
        }
        None => {
          let final_val = if sign { -whole } else { whole }
          Some((r1, final_val))
        }
      }
    }
    None => {
      let final_val = if sign { -whole } else { whole }
      Some((r1, final_val))
    }
  }
}

fn pow10_float(n : Int) -> Float {
  if n <= 0 { 1.0 }
  else { 10.0 * pow10_float(n - 1) }
}

pub fn parse_hex_int(input : ParseInput) -> (ParseInput, Int)? {
  let (rest, _) = match tag("0x", input) {
    Some((r, _)) => (r, "")
    None => match tag("0X", input) {
      Some((r, _)) => (r, "")
      None => return None
    }
  }
  match take_while1(is_hex, rest) {
    Some((rest2, hex_str)) => Some((rest2, hex_to_int(hex_str, 0, 0)))
    None => None
  }
}

fn hex_to_int(s : String, idx : Int, acc : Int) -> Int {
  if idx >= s.length() { acc }
  else {
    let ch = s.substring(start=idx, end=idx + 1)
    let digit = match ch {
      "0" => 0; "1" => 1; "2" => 2; "3" => 3; "4" => 4
      "5" => 5; "6" => 6; "7" => 7; "8" => 8; "9" => 9
      "a" | "A" => 10; "b" | "B" => 11; "c" | "C" => 12
      "d" | "D" => 13; "e" | "E" => 14; "f" | "F" => 15
      _ => 0
    }
    hex_to_int(s, idx + 1, acc * 16 + digit)
  }
}

pub fn parse_scientific(input : ParseInput) -> (ParseInput, Float)? {
  match parse_float(input) {
    Some((r1, base)) => {
      match tag_ci("e", r1) {
        Some((r2, _)) => {
          let (r3, exp_sign) = match tag("+", r2) {
            Some((r4, _)) => (r4, 1)
            None => match tag("-", r2) {
              Some((r4, _)) => (r4, -1)
              None => (r2, 1)
            }
          }
          match parse_u64(r3) {
            Some((r5, exp)) => {
              let factor = pow10_float(exp)
              let result = if exp_sign == 1 { base * factor } else { base / factor }
              Some((r5, result))
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

pub fn parse_bool(input : ParseInput) -> (ParseInput, Bool)? {
  match tag("true", input) {
    Some((r, _)) => Some((r, true))
    None => match tag("false", input) {
      Some((r, _)) => Some((r, false))
      None => None
    }
  }
}
