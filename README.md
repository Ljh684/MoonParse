# MoonParse

纯 MoonBit 解析器组合子库，通过组合小解析器构建复杂解析逻辑。

## 功能

- **基础原语**：tag、digit、alpha、space、eof、satisfy、one_of、take_while
- **组合子**：many0、many1、alt、opt、separated_list、tuple2、tuple3、preceded、terminated、delimited、map、recognize
- **数字解析**：整数、浮点、16进制、科学计数法
- **字符串解析**：引号字符串（含转义）、三引号、标识符、关键字
- **二进制解析**：u8~u64、LEB128、计数字符串
- **位置追踪**：行号/列号追踪，错误上下文
- **完整示例**：JSON 解析器、TOML 解析器、CSV、URL、INI、HTTP、SQL
- **零依赖**：纯 MoonBit 实现

## 安装

```
moon add a678b789/MoonParse
```

## 快速开始

```moonbit
let input = ParseInput::new("hello 42")

// 解析标签
match tag("hello", input) {
  Some((rest, _)) => {
    // 跳过空格，解析数字
    let rest2 = space0(rest)
    match parse_int(rest2) {
      Some((_, n)) => println("Got number: " + n.to_string())
      None => println("Expected number")
    }
  }
  None => println("Expected hello")
}
```

## API 参考

### ParseInput
| 方法 | 说明 |
|------|------|
| `ParseInput::new(source)` | 创建输入 |
| `.current()` | 当前字符 |
| `.advance()` | 前进一个字符 |
| `.advance_by(n)` | 前进 n 个字符 |
| `.is_eof()` | 是否到末尾 |
| `.remaining()` | 剩余字符串 |
| `.position()` | 当前行列号 |

### 基础原语
| 函数 | 说明 |
|------|------|
| `tag(str, input)` | 精确匹配字符串 |
| `tag_ci(str, input)` | 大小写不敏感匹配 |
| `any_char(input)` | 匹配任意字符 |
| `digit(input)` | 匹配数字 [0-9] |
| `hex_digit(input)` | 匹配16进制 [0-9a-fA-F] |
| `alpha(input)` | 匹配字母 [a-zA-Z] |
| `alphanumeric(input)` | 匹配字母或数字 |
| `space(input)` | 匹配空格或制表符 |
| `space0(input)` | 跳过零或多个空格 |
| `space1(input)` | 至少一个空格 |
| `multispace0(input)` | 跳过所有空白字符 |
| `eof(input)` | 匹配输入末尾 |
| `one_of(chars, input)` | 匹配指定字符集之一 |
| `none_of(chars, input)` | 匹配非指定字符集 |
| `take_while(pred, input)` | 收集匹配的字符 |
| `take_while1(pred, input)` | 至少一个匹配字符 |
| `take_until(pat, input)` | 收集直到匹配 |

### 组合子
| 函数 | 说明 |
|------|------|
| `many0(parser, input)` | 零次或多次 |
| `many1(parser, input)` | 一次或多次 |
| `many_n(parser, n, input)` | 恰好 n 次 |
| `many_till(parser, end, input)` | 直到 end 匹配 |
| `alt(p1, p2, input)` | 尝试两个解析器 |
| `opt(parser, input)` | 可选匹配 |
| `separated_list(parser, sep, input)` | 分隔列表 |
| `separated_list1(parser, sep, input)` | 至少一个元素 |
| `tuple2(p1, p2, input)` | 两个解析器组合 |
| `tuple3(p1, p2, p3, input)` | 三个解析器组合 |
| `preceded(prefix, parser, input)` | 跳过前缀 |
| `terminated(parser, suffix, input)` | 需要后缀 |
| `delimited(left, parser, right, input)` | 左右分界 |
| `map(parser, f, input)` | 转换结果 |
| `recognize(parser, input)` | 返回匹配文本 |
| `success(val, input)` | 始终成功 |
| `fail(input)` | 始终失败 |

### 数字解析
- `parse_int(input)` — 整数（含负数）
- `parse_u64(input)` — 无符号整数
- `parse_float(input)` — 浮点数
- `parse_hex_int(input)` — 16进制（0x前缀）
- `parse_scientific(input)` — 科学计数法
- `parse_bool(input)` — true/false

### 字符串解析
- `quoted_string(input)` — 双引号或单引号字符串
- `triple_quoted_string(input)` — 三引号字符串
- `identifier(input)` — 标识符
- `keyword(kw, input)` — 关键字（确保不是标识符前缀）

### 二进制解析
- `u8/u16_le/u32_le/u64_le(input)` — 整数
- `leb128_u/leb128_s(input)` — LEB128 变长编码
- `counted_string(input)` — 计数字符串

## 完整示例

### JSON 解析
```moonbit
match json_parse(ParseInput::new("{\"name\": \"MoonBit\", \"year\": 2026}")) {
  Some((_, JsonValue::Object(pairs))) => {
    for i = 0; i < pairs.length(); i = i + 1 {
      let (k, v) = pairs[i]
      println(k + " = " + json_value_to_string(v))
    }
  }
  _ => println("Invalid JSON")
}
```

### CSV 解析
```moonbit
let input = ParseInput::new("a,b,c\n1,2,3\n4,5,6")
let (_, rows) = many0(csv_row, input)
println("Parsed " + rows.length().to_string() + " rows")
```

### TOML 解析
```moonbit
match toml_table_header(ParseInput::new("[database]")) {
  Some((_, name)) => println("Table: " + name)
  None => println("Not a table header")
}
```

## 许可证

Apache-2.0
