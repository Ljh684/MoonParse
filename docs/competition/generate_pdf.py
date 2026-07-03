"""Generate MoonParse proposal PDF — clean modern style."""
from fpdf import FPDF
import os, shutil

script_dir = os.path.dirname(os.path.abspath(__file__))
local_font = os.path.join(script_dir, "font.ttc")
if not os.path.exists(local_font):
    for fp in ["C:/Windows/Fonts/msyh.ttc","C:/Windows/Fonts/msyhbd.ttc","C:/Windows/Fonts/simsun.ttc","C:/Windows/Fonts/simhei.ttf"]:
        if os.path.exists(fp): shutil.copy(fp, local_font); break
if not os.path.exists(local_font): print("ERROR: No Chinese font!"); exit(1)

ACCENT = (180, 130, 30)    # warm gold
DARK  = (45, 42, 38)       # near black
MID   = (120, 115, 110)    # gray
LIGHT = (245, 243, 240)    # warm white

class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("F", fname=local_font)
        self.add_font("F", "B", fname=local_font)
    def header(self): pass
    def footer(self): pass

    # --- layout helpers ---
    def dot(self):  # small gold dot
        self.set_fill_color(*ACCENT)
        self.circle(self.get_x()+1.5, self.get_y()+1.8, 0.7)
        self.set_fill_color(255,255,255)

    def rule(self):  # thin separator
        self.ln(1)
        self.set_draw_color(220,218,215)
        self.set_line_width(0.15)
        self.line(self.l_margin, self.get_y(), self.w-self.r_margin, self.get_y())
        self.ln(2)
        self.set_draw_color(0,0,0); self.set_line_width(0.2)

    def heading(self, text):
        self.ln(2)
        self.set_text_color(*DARK)
        self.set_font("F", "B", 14)
        w = self.get_string_width(text)
        self.cell(w+2, 7, text, new_x="LMARGIN", new_y="NEXT")
        # gold underline
        self.set_draw_color(*ACCENT)
        self.set_line_width(0.6)
        y = self.get_y()
        self.line(self.l_margin, y, self.l_margin+w+2, y)
        self.set_draw_color(0,0,0); self.set_line_width(0.2)
        self.ln(3)

    def info_pair(self, key, val):
        self.set_font("F", "B", 8); self.set_text_color(*MID)
        w = self.get_string_width(key+"  ")+2
        self.cell(w, 4, key)
        self.set_font("F", "", 8); self.set_text_color(*DARK)
        self.cell(0, 4, val, new_x="LMARGIN", new_y="NEXT")

    def p(self, text):
        self.set_font("F", "", 7.5); self.set_text_color(*MID)
        self.multi_cell(0, 4, text, align="L")

    def subt(self, text):
        self.set_font("F", "B", 8.5); self.set_text_color(*DARK)
        self.cell(0, 5, text, new_x="LMARGIN", new_y="NEXT")
        self.ln(1)

    def tbl_head(self, cells, widths):
        self.set_draw_color(220,218,215)
        self.set_font("F", "B", 7); self.set_text_color(*DARK)
        h = 5
        for cell, w in zip(cells, widths):
            self.rect(self.get_x(), self.get_y(), w, h, style="D")
            self.set_fill_color(*LIGHT)
            self.rect(self.get_x()+0.3, self.get_y()+0.3, w-0.6, h-0.6, style="F")
            self.cell(w, h, " "+cell)
        self.ln(h)

    def tbl_row(self, cells, widths, highlight=False):
        self.set_font("F", "B", 7) if highlight else self.set_font("F", "", 7)
        self.set_text_color(*DARK); h = 4.8
        self.set_draw_color(220,218,215)
        for cell, w in zip(cells, widths):
            self.rect(self.get_x(), self.get_y(), w, h, style="D")
            self.cell(w, h, " "+cell)
        self.ln(h)


# === BUILD ===
pdf = PDF(); pdf.set_auto_page_break(auto=False); pdf.add_page()

# Header area
pdf.set_fill_color(*DARK)
pdf.rect(pdf.l_margin, 0, pdf.w-pdf.l_margin-pdf.r_margin, 28, style="F")
pdf.set_y(6)
pdf.set_font("F", "B", 16); pdf.set_text_color(255,255,255)
pdf.cell(0, 8, "MoonParse", align="C", new_x="LMARGIN", new_y="NEXT")
pdf.set_font("F", "", 7.5); pdf.set_text_color(180,175,168)
pdf.cell(0, 5, "2026 MoonBit 国产开源生态竞赛 · 个人赛", align="C", new_x="LMARGIN", new_y="NEXT")
pdf.set_y(31)

# 01
pdf.heading("基本信息")
pdf.info_pair("项目名称", "MoonParse：纯 MoonBit 解析器组合子库")
pdf.info_pair("GitHub", "https://github.com/Ljh684/MoonParse")
pdf.info_pair("GitLink", "https://gitlink.org.cn/a678b789/MoonParse")
pdf.info_pair("方向 / 许可证", "MoonBit 基础库 · 解析器框架  /  Apache-2.0  ·  原创项目")
pdf.rule()

# 02
pdf.heading("项目简介")
pdf.p("MoonParse 是纯 MoonBit 实现的解析器组合子库，通过组合小型解析器构建复杂解析逻辑。提供 13 种解析原语、16 种组合子、11 种内置解析器、完整的 JSON 和 TOML 解析器。零外部依赖，位置追踪，错误上下文。MoonBit 生态缺乏通用解析框架，MoonParse 填补了这一空白 —— 开发者只需组合已有解析器即可快速构建 JSON / TOML / CSV / URL 等格式的解析逻辑。")
pdf.rule()

# 03
pdf.heading("核心功能")
pdf.tbl_head(["模块", "数量", "代表性函数"], [30, 14, 122])
for row in [
    ("解析原语",   "13", "tag / digit / alpha / space / eof / satisfy / take_while / one_of / none_of"),
    ("组合子",     "16", "many0 / many1 / alt / separated_list / tuple / map / recognize / preceded / delimited"),
    ("数字解析",   "6",  "parse_int / parse_float / parse_hex_int / parse_scientific / parse_bool"),
    ("字符串解析",  "5",  "quoted_string (含转义) / triple_quoted_string / identifier / keyword"),
    ("二进制",     "9",  "u8~u64 / leb128_u / leb128_s / f32_le / f64_le / counted_string / c_string"),
    ("完整解析器",  "7",  "JSON (JsonValue + 序列化) / TOML / CSV / INI / URL / HTTP Header / SQL"),
]:
    pdf.tbl_row(row, [30, 14, 122])
pdf.ln(2)

# 04
pdf.heading("差异化")
pdf.subt("对比 MoonBit 生态现状")
pdf.tbl_head(["维度", "MoonParse", "生态现状"], [32, 68, 66])
for row in [
    ("解析原语",  "13 种（tag / digit / satisfy / ...）",  "无可对标项目"),
    ("组合子",    "16 种（many / alt / tuple / ...）",     "无可对标项目"),
    ("JSON",      "完整 JsonValue 枚举 + 序列化输出",     "无可对标项目"),
    ("TOML",      "表头 / 键值对 / 数组表 / 注释",          "无可对标项目"),
    ("二进制",    "u8-u64 / LEB128 / IEEE 754",            "无可对标项目"),
]:
    pdf.tbl_row(row, [32, 68, 66])
pdf.ln(1)

pdf.p("MoonParse 是 MoonBit 生态中首个解析器框架。对比手写解析器，组合子模式让解析逻辑清晰、可测试、可复用。内置 JSON/TOML 解析器可直接使用，也可作为更复杂解析器的参考模板。")

# 05
pdf.heading("规模")
pdf.tbl_head(["类别", "行数", "文件", "说明"], [42, 20, 20, 84])
for row in [
    ("核心引擎",    "125", "2", "input / error — 位置追踪 + 错误系统"),
    ("原语+组合子",  "417", "2", "primitives / combinators — 29 种算子"),
    ("内置解析器",   "499", "3", "numbers / string_parser / binary"),
    ("完整解析器",   "635", "3", "json_parser / toml_parser / examples"),
    ("测试",        "1,153","2","166 个测试，全部通过"),
]:
    pdf.tbl_row(row, [42, 20, 20, 84])
pdf.ln(1)
pdf.p("CI 已配置 · README 含完整 API 参考 · 双向仓库推送 · 16 次有效提交。")

pdf.rule()

# 06
pdf.heading("适用场景")
pdf.p("配置文件解析（TOML / INI）   ·   数据格式解析（JSON / CSV）   ·   网络协议（HTTP / URL / SQL）   ·   二进制格式（Protobuf / LEB128）   ·   DSL 解释器   ·   MoonBit 生态解析基础设施")

output_path = os.path.join(script_dir, "MoonParse项目申报书.pdf")
pdf.output(output_path)
print(f"Done: {output_path}")
