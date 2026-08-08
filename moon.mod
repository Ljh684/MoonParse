name = "Ljh684/MoonParse"

version = "0.1.3"

readme = "README.mbt.md"

repository = "https://gitlink.org.cn/a678b789/MoonParse"

license = "Apache-2.0"

keywords = [
  "parser",
  "combinator",
  "parsing",
  "json",
  "toml",
  "csv",
  "binary",
  "leb128",
  "protobuf",
]

description = "MoonBit 解析器组合子库 — 与生态中其他 combinator 不同：(1)内置完整 JSON 解析器（JsonValue 枚举+双向序列化）和 TOML 解析器，开箱即用；(2)支持二进制解析（u8-u64/LEB128/计数字符串），覆盖 Protobuf 等场景；(3)11 种格式化输出（ANSI/Syslog RFC5424/GELF/JSON/XML）；(4)行列号位置追踪+ErrorContext 累积错误上下文。零依赖"
