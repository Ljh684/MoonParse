"""Generate MoonParse proposal PDF."""
from fpdf import FPDF
import os, shutil

script_dir = os.path.dirname(os.path.abspath(__file__))
local_font = os.path.join(script_dir, "font.ttc")
if not os.path.exists(local_font):
    for fp in ["C:/Windows/Fonts/msyh.ttc","C:/Windows/Fonts/msyhbd.ttc","C:/Windows/Fonts/simsun.ttc","C:/Windows/Fonts/simhei.ttf"]:
        if os.path.exists(fp): shutil.copy(fp, local_font); break
if not os.path.exists(local_font): print("ERROR: No Chinese font!"); exit(1)

PRIMARY = (95, 55, 45)
LIGHT = (252, 245, 242)

class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("F", fname=local_font)
        self.add_font("F", "B", fname=local_font)
    def header(self): pass
    def footer(self): pass
    def banner(self, title, sub):
        self.set_fill_color(*PRIMARY)
        self.rect(self.l_margin, self.get_y(), self.w-self.l_margin-self.r_margin, 18, style="F")
        self.set_font("F", "B", 15); self.set_text_color(255,255,255)
        self.set_y(self.get_y()+2); self.cell(0, 7, title, align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_font("F", "", 7.5); self.set_y(self.get_y()-1)
        self.cell(0, 5, sub, align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_y(self.get_y()+20)
    def sec(self, text):
        self.ln(2); self.set_font("F", "B", 10.5); self.set_text_color(*PRIMARY)
        self.set_fill_color(*PRIMARY); self.rect(self.l_margin, self.get_y()+1, 2.5, 5, style="F")
        self.set_x(self.l_margin+5); self.cell(0, 6, text, new_x="LMARGIN", new_y="NEXT"); self.ln(2)
    def info(self, label, value):
        self.set_font("F", "B", 7.5); self.set_text_color(*PRIMARY)
        self.cell(26, 4.5, "  "+label)
        self.set_font("F", "", 7.5); self.set_text_color(50,35,25)
        self.cell(0, 4.5, value, new_x="LMARGIN", new_y="NEXT")
    def body(self, text):
        self.set_font("F", "", 7); self.set_text_color(80,70,60)
        self.set_x(self.l_margin+5)
        self.multi_cell(self.w-self.l_margin-self.r_margin-5, 3.6, text, align="L")
    def t_header(self, cells, widths):
        self.set_fill_color(*PRIMARY); self.set_text_color(255,255,255); self.set_font("F", "B", 7); h=5
        self.set_x(self.l_margin+5)
        for cell, w in zip(cells, widths):
            self.rect(self.get_x(), self.get_y(), w, h, style="F"); self.cell(w, h, " "+cell)
        self.ln(h)
    def t_row(self, cells, widths, bold=False):
        self.set_fill_color(*LIGHT) if bold else self.set_fill_color(255,255,255)
        self.set_font("F", "B", 7) if bold else self.set_font("F", "", 7)
        self.set_text_color(50,35,25); h=4.8
        self.set_x(self.l_margin+5)
        for i, (cell, w) in enumerate(zip(cells, widths)):
            self.rect(self.get_x(), self.get_y(), w, h, style="DF")
            if i == 0: self.set_fill_color(*PRIMARY); self.rect(self.get_x(), self.get_y(), 1.5, h, style="F")
            self.set_fill_color(*LIGHT) if bold else self.set_fill_color(255,255,255)
            self.cell(w, h, "  "+cell)
        self.ln(h)

pdf = PDF(); pdf.set_auto_page_break(auto=False); pdf.add_page()
pdf.banner("MoonParse 项目申报书", "2026 MoonBit 国产开源生态竞赛（个人赛）")

pdf.sec("基本信息")
pdf.info("项目名称", "MoonParse：纯 MoonBit 解析器组合子库")
pdf.info("GitHub", "https://github.com/Ljh684/MoonParse")
pdf.info("GitLink", "https://gitlink.org.cn/a678b789/MoonParse")
pdf.info("项目方向", "MoonBit 基础库 / 解析器框架")
pdf.info("类型/许可证", "原创项目  /  Apache-2.0")

pdf.sec("项目简介")
pdf.body("MoonParse 是一个纯 MoonBit 实现的解析器组合子库，通过组合小解析器构建复杂解析逻辑。提供13种解析原语、16种组合子、11种数字/字符串解析器、9种二进制解析器，以及完整的 JSON/TOML 解析器示例。零外部依赖，位置追踪，错误上下文。MoonBit 生态缺乏通用解析框架，本项目填补了这一空白。")

pdf.sec("核心功能")
pdf.t_header(["类别", "数量", "说明"], [36, 18, 115])
for row in [
    ("解析原语", "13", "tag/digit/alpha/space/eof/satisfy/one_of/take_while"),
    ("组合子", "16", "many0/many1/alt/separated_list/tuple/map/recognize"),
    ("数字解析", "6", "整数/浮点/16进制/科学计数/布尔"),
    ("字符串解析", "5", "双引号/单引号/三引号/标识符/关键字"),
    ("二进制解析", "9", "u8-u64/LEB128/f32/f64/counted_string"),
    ("完整解析器", "2", "JSON(JsonValue枚举+序列化) / TOML"),
    ("示例解析", "5", "CSV/INI/URL/HTTP/SQL tokenizer"),
]:
    pdf.t_row(row, [36, 18, 115])
pdf.ln(1)

pdf.sec("差异化定位")
pdf.body("MoonParse 是 MoonBit 生态中首个解析器组合子库。与手写解析器相比，MoonParse 通过组合子模式让解析逻辑更清晰、可测试、可复用。提供了完整的 JSON/TOML 解析器可直接使用，同时提供了丰富的基础原语供开发者构建自定义解析器。")
pdf.t_header(["维度", "MoonParse", "MoonBit 生态"], [36, 65, 65])
for row in [("原语", "13种", "无"),("组合子", "16种", "无"),("JSON", "完整+序列化", "无"),("TOML", "表头/键值/数组表", "无"),("位置追踪", "行列号+上下文", "无")]:
    pdf.t_row(row, [36, 65, 65])
pdf.ln(1)

pdf.sec("项目规模")
pdf.t_header(["类别", "行数", "说明"], [48, 24, 90])
for row in [
    ("核心+原语+组合子", "542", "input/error/primitives/combinators"),
    ("数字+字符串+二进制", "499", "numbers/string_parser/binary"),
    ("示例+JSON+TOML", "635", "examples/json_parser/toml_parser"),
    ("测试代码", "1,153", "166个测试全通过"),
    ("合计", "2,829", "14次有效提交"),
]:
    pdf.t_row(row, [48, 24, 90], bold=(row[0]=="合计"))
pdf.ln(1)
pdf.body("CI已配置，README完整（安装/快速开始/API参考），双向仓库推送。")

pdf.sec("适用场景")
pdf.body("配置文件解析（TOML/YAML/INI） / 数据格式解析（JSON/CSV） / 网络协议解析（HTTP/URL/SQL） / 二进制格式解析（Protobuf/LEB128） / DSL 解释器 / MoonBit 生态解析基础设施")

output_path = os.path.join(script_dir, "MoonParse项目申报书.pdf")
pdf.output(output_path)
print(f"Done: {output_path}")
