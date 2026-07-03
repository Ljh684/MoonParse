"""Generate MoonParse proposal PDF — card-style layout."""
from fpdf import FPDF
import os, shutil

script_dir = os.path.dirname(os.path.abspath(__file__))
local_font = os.path.join(script_dir, "font.ttc")
if not os.path.exists(local_font):
    for fp in ["C:/Windows/Fonts/msyh.ttc","C:/Windows/Fonts/msyhbd.ttc","C:/Windows/Fonts/simsun.ttc","C:/Windows/Fonts/simhei.ttf"]:
        if os.path.exists(fp): shutil.copy(fp, local_font); break
if not os.path.exists(local_font): print("ERROR: No Chinese font!"); exit(1)

P = (25, 90, 110)    # dark teal
P2 = (15, 70, 90)    # darker
LT = (240, 248, 250) # light bg
GR = (160, 190, 195) # gray accent
DK = (30, 40, 45)    # dark text
MD = (90, 100, 105)  # medium text

class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("F", fname=local_font)
        self.add_font("F", "B", fname=local_font)
    def header(self): pass
    def footer(self): pass
    def top_bar(self, title, sub):
        # Gradient-like bar at top
        self.set_fill_color(*P2)
        self.rect(self.l_margin, 0, self.w-self.l_margin-self.r_margin, 22, style="F")
        self.set_fill_color(*P)
        self.rect(self.l_margin, 0, self.w-self.l_margin-self.r_margin, 3, style="F")
        self.set_y(4)
        self.set_font("F", "B", 14); self.set_text_color(255,255,255)
        self.cell(0, 7, title, align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_font("F", "", 7); self.set_text_color(200,220,225)
        self.cell(0, 4, sub, align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_y(25)

    def card_begin(self, num, title):
        self.ln(2)
        y0 = self.get_y()
        # Card outline
        self.set_draw_color(*P)
        self.set_line_width(0.4)
        # Number badge
        self.set_fill_color(*P)
        self.set_text_color(255,255,255)
        self.set_font("F", "B", 8)
        bw = 12; bh = 5.5
        self.rect(self.l_margin, y0, bw, bh, style="F")
        self.set_xy(self.l_margin, y0+0.5)
        self.cell(bw, 4, num, align="C")
        # Title next to badge
        self.set_text_color(*P)
        self.set_font("F", "B", 10)
        self.set_xy(self.l_margin+bw+3, y0-0.5)
        self.cell(0, 6, title, new_x="LMARGIN", new_y="NEXT")
        self.ln(2)

    def info(self, label, value):
        self.set_font("F", "B", 7.5); self.set_text_color(*P)
        self.cell(24, 4.2, label)
        self.set_font("F", "", 7.5); self.set_text_color(*DK)
        self.cell(0, 4.2, value, new_x="LMARGIN", new_y="NEXT")

    def body(self, text):
        self.set_font("F", "", 7); self.set_text_color(*MD)
        self.multi_cell(0, 3.8, text, align="L")

    def t_header(self, cells, widths):
        self.set_fill_color(*P); self.set_text_color(255,255,255)
        self.set_font("F", "B", 7); h=5
        for cell, w in zip(cells, widths):
            self.rect(self.get_x(), self.get_y(), w, h, style="F")
            self.cell(w, h, " "+cell)
        self.ln(h)

    def t_row(self, cells, widths, bold=False):
        if bold: self.set_fill_color(*LT); self.set_font("F", "B", 7)
        else: self.set_fill_color(255,255,255); self.set_font("F", "", 7)
        self.set_text_color(*DK); h=4.8
        for cell, w in zip(cells, widths):
            self.rect(self.get_x(), self.get_y(), w, h, style="DF")
            self.cell(w, h, " "+cell)
        self.ln(h)

pdf = PDF(); pdf.set_auto_page_break(auto=False); pdf.add_page()
pdf.top_bar("MoonParse 项目申报书", "2026 MoonBit 国产开源生态竞赛 · 个人赛")

pdf.card_begin("01", "基本信息")
pdf.info("项目名称", "MoonParse：纯 MoonBit 解析器组合子库")
pdf.info("GitHub", "https://github.com/Ljh684/MoonParse")
pdf.info("GitLink", "https://gitlink.org.cn/a678b789/MoonParse")
pdf.info("项目方向", "MoonBit 基础库 / 解析器框架")
pdf.info("类型 / 许可证", "原创项目  /  Apache-2.0")

pdf.card_begin("02", "项目简介")
pdf.body("MoonParse 是一个纯 MoonBit 实现的解析器组合子库，通过组合小型解析器构建复杂解析逻辑。提供13种解析原语、16种组合子、11种内置解析器、完整的 JSON 和 TOML 解析器。零外部依赖，支持位置追踪和错误上下文。MoonBit 生态缺乏通用解析框架，本项目填补了这一空白。")

pdf.card_begin("03", "核心功能")
pdf.t_header(["模块", "数量", "典型函数"], [32, 16, 118])
for row in [
    ("解析原语", "13", "tag / digit / alpha / space / eof / satisfy / take_while / one_of"),
    ("组合子", "16", "many0 / many1 / alt / separated_list / tuple / map / recognize"),
    ("数字解析", "6", "parse_int / parse_float / parse_hex_int / parse_scientific / parse_bool"),
    ("字符串解析", "5", "quoted_string / triple_quoted_string / identifier / keyword"),
    ("二进制解析", "9", "u8-u64 / leb128_u / leb128_s / f32_le / f64_le / counted_string"),
    ("完整解析器", "7", "JSON(JsonValue+序列化) / TOML(表/键值) / CSV / INI / URL / HTTP / SQL"),
]:
    pdf.t_row(row, [32, 16, 118])
pdf.ln(1)

pdf.card_begin("04", "差异化定位")
pdf.body("MoonParse 是 MoonBit 生态中首个解析器组合子库。与手写解析器相比，组合子模式让解析逻辑清晰、可测试、可复用。内置的 JSON/TOML 解析器可直接用于项目，同时提供丰富的基础原语供开发者构建自定义解析器。")
pdf.t_header(["维度", "MoonParse", "MoonBit 生态现状"], [36, 65, 65])
for row in [
    ("解析原语", "13 种（tag/digit/satisfy/.）", "无可对标项目"),
    ("组合子", "16 种（many/alt/tuple/.）", "无可对标项目"),
    ("JSON 解析", "完整 JsonValue + 序列化", "无可对标项目"),
    ("TOML 解析", "表头/键值/数组表/注释", "无可对标项目"),
    ("二进制", "u8-u64 / LEB128 / IEEE754", "无可对标项目"),
    ("依赖", "零外部依赖，纯 MoonBit", "—"),
]:
    pdf.t_row(row, [36, 65, 65])
pdf.ln(1)

pdf.card_begin("05", "项目规模")
pdf.t_header(["类别", "行数", "文件", "说明"], [42, 22, 18, 84])
for row in [
    ("核心引擎", "125", "2", "input / error — 位置追踪 + 错误系统"),
    ("原语 + 组合子", "417", "2", "primitives / combinators — 29种算子"),
    ("内置解析器", "499", "3", "numbers / string_parser / binary"),
    ("完整解析器", "635", "3", "json_parser / toml_parser / examples"),
    ("测试代码", "1,153", "2", "166 个测试，全部通过"),
    ("合计", "2,829", "12", "16 次有效提交"),
]:
    pdf.t_row(row, [42, 22, 18, 84], bold=(row[0]=="合计"))
pdf.ln(1)
pdf.body("CI 已配置（GitHub Actions），README 含完整 API 参考，双向仓库推送。")

pdf.card_begin("06", "适用场景")
pdf.body("配置文件解析（TOML / INI）  ·  数据格式解析（JSON / CSV）  ·  网络协议解析（HTTP / URL / SQL）  ·  二进制格式（Protobuf / LEB128）  ·  DSL 解释器  ·  MoonBit 生态解析基础设施")

output_path = os.path.join(script_dir, "MoonParse项目申报书.pdf")
pdf.output(output_path)
print(f"Done: {output_path}")
