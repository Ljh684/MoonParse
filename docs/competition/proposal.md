# MoonParse 项目申报书

## 基本信息

| 项目 | 内容 |
|------|------|
| **项目名称** | MoonParse：纯 MoonBit 解析器组合子库 |
| **GitHub** | https://github.com/Ljh684/MoonParse |
| **GitLink** | https://gitlink.org.cn/a678b789/MoonParse |
| **项目方向** | MoonBit 基础库 / 解析器框架 |
| **是否为移植项目** | 否（原创项目，设计参考 Rust nom） |
| **许可证** | Apache-2.0 |

## 项目简介

MoonParse 是一个纯 MoonBit 实现的解析器组合子库。通过组合小解析器构建复杂解析逻辑，支持字符串原语、组合子、数字解析、字符串解析、二进制解析和完整的 JSON/TOML 解析器。零外部依赖，位置追踪，错误上下文。

MoonBit 生态缺乏通用解析框架，本项目填补了这一空白，使开发者能够快速构建自定义解析器。

## 核心功能范围

### 解析原语（13种）
tag、tag_ci、any_char、digit、hex_digit、alpha、alphanumeric、space、space0、space1、multispace0、multispace1、eof、satisfy、one_of、none_of、take_while、take_while1、take_until、newline、rest、peek

### 组合子（16种）
many0、many1、many_n、many_till、separated_list、separated_list1、alt、opt、tuple2、tuple3、preceded、terminated、delimited、map、recognize、success、fail、cond、not_parser

### 数字解析（6种）
整数（含负数）、无符号整数、浮点数、16进制、科学计数法、布尔值

### 字符串解析（5种）
双引号/单引号字符串（含转义）、三引号、标识符、关键字

### 二进制解析（9种）
u8、u16_le、u32_le、u64_le、f32_le、f64_le、leb128_u、leb128_s、counted_string

### 完整解析器示例
- JSON 解析器（JsonValue 枚举 + 序列化回字符串）
- TOML 解析器（键/值/表头/数组表）
- CSV、INI、URL、HTTP Header、SQL tokenizer 示例

### 解析状态管理
- ParseInput 位置追踪（行号/列号）
- ParseError + ErrorContext 错误格式化

## 差异化价值

| 对比维度 | MoonParse | MoonBit 生态现状 |
|---------|----------|----------------|
| 解析原语 | 13种字符串级原语 | 无可对标项目 |
| 组合子 | 16种组合器 | 无可对标项目 |
| 数字/字符串解析 | 11种内置解析器 | 无可对标项目 |
| JSON 解析 | 完整 JsonValue 枚举 + 序列化 | 无可对标项目 |
| TOML 解析 | 表头/键值/数组表 | 无可对标项目 |
| 位置追踪 | 行号列号 + 错误上下文 | 无可对标项目 |
| 依赖 | 零外部依赖 | — |

## 项目规模

| 类别 | 行数 | 文件数 |
|------|------|--------|
| 核心引擎（input/error） | 125 | 2 |
| 解析原语 | 193 | 1 |
| 组合子 | 224 | 1 |
| 数字解析 | 194 | 1 |
| 字符串解析 | 122 | 1 |
| 二进制解析 | 183 | 1 |
| 示例解析器 | 257 | 1 |
| JSON 解析器 | 182 | 1 |
| TOML 解析器 | 196 | 1 |
| 测试（白盒+黑盒） | 1,153 | 2 |
| **合计** | **~2,829** | **12** |

14 次有效提交，166 个测试全部通过。

## 适用场景

- 配置文件解析（TOML/YAML/INI）
- 数据格式解析（JSON/CSV/XML）
- 网络协议解析（HTTP/URL/SQL）
- 二进制格式（Protobuf/LEB128）
- DSL 解释器
- MoonBit 生态解析基础设施
