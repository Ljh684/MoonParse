// Binary/byte-level parsing utilities.

///|
pub fn take_bytes(n : Int, input : ParseInput) -> (ParseInput, String)? {
  if input.pos + n > input.source.length() {
    return None
  }
  let bytes = input.source[input.pos:input.pos + n].to_owned()
  Some((input.advance_by(n), bytes))
}

///|
/// Read a single unsigned byte.
pub fn u8(input : ParseInput) -> (ParseInput, Int)? {
  match take_bytes(1, input) {
    Some((rest, bytes)) => Some((rest, bytes[0].to_int()))
    None => None
  }
}

///|
/// Read an unsigned 16-bit integer in little-endian byte order.
pub fn u16_le(input : ParseInput) -> (ParseInput, Int)? {
  match take_bytes(2, input) {
    Some((rest, bytes)) => {
      let lo = bytes[0].to_int()
      let hi = bytes[1].to_int()
      Some((rest, lo | (hi << 8)))
    }
    None => None
  }
}

///|
/// Read an unsigned 32-bit integer in little-endian byte order.
pub fn u32_le(input : ParseInput) -> (ParseInput, Int)? {
  match take_bytes(4, input) {
    Some((rest, bytes)) => {
      let mut v : UInt = 0
      for i in 0..<4 {
        v = v | (bytes[i].to_uint() << (i * 8))
      }
      Some((rest, v.reinterpret_as_int()))
    }
    None => None
  }
}

///|
/// Read an unsigned 64-bit integer in little-endian byte order.
pub fn u64_le(input : ParseInput) -> (ParseInput, Int)? {
  match take_bytes(8, input) {
    Some((rest, bytes)) => {
      let mut v : UInt64 = 0
      for i in 0..<8 {
        v = v | (bytes[i].to_uint64() << (i * 8))
      }
      Some((rest, v.reinterpret_as_int64().to_int()))
    }
    None => None
  }
}

// LEB128 variable-length encoding (unsigned)

///|
pub fn leb128_u(input : ParseInput) -> (ParseInput, Int)? {
  leb128_u_acc(input, 0, 0)
}

///|
fn leb128_u_acc(
  input : ParseInput,
  shift : Int,
  acc : Int,
) -> (ParseInput, Int)? {
  if input.is_eof() || shift >= 64 {
    return None
  }
  match u8(input) {
    None => None
    Some((rest, val)) => {
      let new_acc = acc + ((val & 0x7F) << shift)
      if (val & 0x80) == 0 {
        Some((rest, new_acc))
      } else {
        leb128_u_acc(rest, shift + 7, new_acc)
      }
    }
  }
}

// LEB128 variable-length encoding (signed)

///|
pub fn leb128_s(input : ParseInput) -> (ParseInput, Int)? {
  leb128_s_acc(input, 0, 0)
}

///|
fn leb128_s_acc(
  input : ParseInput,
  shift : Int,
  acc : Int,
) -> (ParseInput, Int)? {
  if input.is_eof() || shift >= 64 {
    return None
  }
  match u8(input) {
    None => None
    Some((rest, val)) => {
      let new_acc = acc + ((val & 0x7F) << shift)
      if (val & 0x80) == 0 {
        let sign_bit = 1 << (shift + 6)
        let result = if (val & 0x40) != 0 {
          new_acc | -sign_bit
        } else {
          new_acc
        }
        Some((rest, result))
      } else {
        leb128_s_acc(rest, shift + 7, new_acc)
      }
    }
  }
}

// IEEE 754 float parsing from bytes

///|
pub fn f32_le(input : ParseInput) -> (ParseInput, Float)? {
  match take_bytes(4, input) {
    Some((rest, bytes)) => {
      let mut bits : UInt = 0
      for i in 0..<4 {
        bits = bits | (bytes[i].to_uint() << (i * 8))
      }
      Some((rest, Float::reinterpret_from_uint(bits)))
    }
    None => None
  }
}

///|
pub fn f64_le(input : ParseInput) -> (ParseInput, Double)? {
  match take_bytes(8, input) {
    Some((rest, bytes)) => {
      let mut bits : UInt64 = 0
      for i in 0..<8 {
        bits = bits | (bytes[i].to_uint64() << (i * 8))
      }
      Some((rest, bits.reinterpret_as_double()))
    }
    None => None
  }
}

// Counted string: [length: u32_le] [payload: length bytes]

///|
pub fn counted_string(input : ParseInput) -> (ParseInput, String)? {
  match u32_le(input) {
    Some((r1, len)) => {
      if len < 0 || len > 1048576 {
        return None
      }
      take_bytes(len, r1)
    }
    None => None
  }
}

// Null-terminated string

///|
pub fn c_string(input : ParseInput) -> (ParseInput, String)? {
  let (rest, result) = take_while(fn(ch) -> Bool { ch != "\x00" }, input)
  if result == "" && input.is_eof() {
    None
  } else {
    Some((rest.advance(), result))
  }
}
