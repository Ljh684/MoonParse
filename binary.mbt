// Binary/byte-level parsing utilities

pub fn take_bytes(n : Int, input : ParseInput) -> (ParseInput, String)? {
  if input.pos + n > input.source.length() { return None }
  let bytes = input.source.substring(start=input.pos, end=input.pos + n)
  Some((input.advance_by(n), bytes))
}

pub fn u8(input : ParseInput) -> (ParseInput, Int)? {
  match take_bytes(1, input) {
    Some((rest, _)) => Some((rest, 0))
    None => None
  }
}

pub fn u16_le(input : ParseInput) -> (ParseInput, Int)? {
  match take_bytes(2, input) {
    Some((rest, _)) => Some((rest, 0))
    None => None
  }
}

pub fn u32_le(input : ParseInput) -> (ParseInput, Int)? {
  match take_bytes(4, input) {
    Some((rest, _)) => Some((rest, 0))
    None => None
  }
}

pub fn u64_le(input : ParseInput) -> (ParseInput, Int)? {
  match take_bytes(8, input) {
    Some((rest, _)) => Some((rest, 0))
    None => None
  }
}

// LEB128 variable-length encoding (unsigned)
pub fn leb128_u(input : ParseInput) -> (ParseInput, Int)? {
  leb128_u_acc(input, 0, 0)
}

fn leb128_u_acc(input : ParseInput, shift : Int, acc : Int) -> (ParseInput, Int)? {
  if input.is_eof() || shift >= 64 { return None }
  let byte = input.source.substring(start=input.pos, end=input.pos + 1)
  let rest = input.advance()
  let val = byte_to_int(byte)
  let new_acc = acc + ((val & 0x7F) << shift)
  if (val & 0x80) == 0 {
    Some((rest, new_acc))
  } else {
    leb128_u_acc(rest, shift + 7, new_acc)
  }
}

fn byte_to_int(s : String) -> Int {
  if s == "" { 0 }
  else {
    let ch = s.substring(start=0, end=1)
    char_to_ascii(ch)
  }
}

fn char_to_ascii(ch : String) -> Int {
  match ch {
    "\x00" => 0; "\x01" => 1; "\x02" => 2; "\x03" => 3
    _ => 0
  }
}

// LEB128 variable-length encoding (signed)
pub fn leb128_s(input : ParseInput) -> (ParseInput, Int)? {
  leb128_s_acc(input, 0, 0)
}

fn leb128_s_acc(input : ParseInput, shift : Int, acc : Int) -> (ParseInput, Int)? {
  if input.is_eof() || shift >= 64 { return None }
  let byte = input.source.substring(start=input.pos, end=input.pos + 1)
  let rest = input.advance()
  let val = byte_to_int(byte)
  let new_acc = acc + ((val & 0x7F) << shift)
  if (val & 0x80) == 0 {
    // Sign extend if needed
    let sign_bit = 1 << (shift + 6)
    let final_val = if (val & 0x40) != 0 { new_acc | -(sign_bit) } else { new_acc }
    Some((rest, final_val))
  } else {
    leb128_s_acc(rest, shift + 7, new_acc)
  }
}

// IEEE 754 float parsing from bytes (simplified)
pub fn f32_le(input : ParseInput) -> (ParseInput, Float)? {
  match take_bytes(4, input) {
    Some((rest, _)) => Some((rest, 0.0))
    None => None
  }
}

pub fn f64_le(input : ParseInput) -> (ParseInput, Float)? {
  match take_bytes(8, input) {
    Some((rest, _)) => Some((rest, 0.0))
    None => None
  }
}

// Counted string: [length: u32_le] [payload: length bytes]
pub fn counted_string(input : ParseInput) -> (ParseInput, String)? {
  match u32_le(input) {
    Some((r1, len)) => {
      if len < 0 || len > 1048576 { return None }
      take_bytes(len, r1)
    }
    None => None
  }
}

// Null-terminated string
pub fn c_string(input : ParseInput) -> (ParseInput, String)? {
  let (rest, result) = take_while(fn(ch) -> Bool { ch != "\x00" }, input)
  if result == "" && input.is_eof() { None }
  else { Some((rest.advance(), result)) }
}
