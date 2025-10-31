#!/usr/bin/env python3
"""
Game Analytics Pipeline - Professional Presentation Generator
Creates a modern PowerPoint presentation with liquid glass aesthetics
Author: Yiwei Ye
"""

from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
import os

# ===== COLOR SCHEME =====
# Modern liquid glass color palette
PRIMARY_BLUE = RGBColor(52, 152, 219)      # #3498db
SUCCESS_GREEN = RGBColor(46, 204, 113)      # #2ecc71
ACCENT_ORANGE = RGBColor(230, 126, 34)      # #e67e22
DARK_GRAY = RGBColor(44, 62, 80)            # #2c3e50
LIGHT_BG = RGBColor(248, 249, 250)          # #f8f9fa
WHITE = RGBColor(255, 255, 255)
SOFT_GRAY = RGBColor(236, 240, 241)         # #ecf0f1
TEXT_DARK = RGBColor(33, 33, 33)            # #212121
TEXT_LIGHT = RGBColor(127, 140, 141)        # #7f8c8d

# ===== DIMENSIONS =====
SLIDE_WIDTH = Inches(10)
SLIDE_HEIGHT = Inches(7.5)
MARGIN = Inches(0.5)

# ===== HELPER FUNCTIONS =====

def add_gradient_background(slide, color1=PRIMARY_BLUE, color2=WHITE):
    """Add a subtle gradient background to slide (liquid glass effect)"""
    background = slide.background
    fill = background.fill
    fill.gradient()
    fill.gradient_angle = 45.0
    fill.gradient_stops[0].color.rgb = color1
    fill.gradient_stops[1].color.rgb = color2

def add_glass_card(slide, left, top, width, height, fill_color=WHITE):
    """Add a glassmorphic card (rounded rectangle with subtle shadow effect)"""
    shape = slide.shapes.add_shape(
        MSO_SHAPE.ROUNDED_RECTANGLE,
        left, top, width, height
    )
    shape.fill.solid()
    shape.fill.fore_color.rgb = fill_color
    shape.line.color.rgb = SOFT_GRAY
    shape.line.width = Pt(0.5)
    shape.shadow.inherit = False
    return shape

def add_title_text(slide, text, top=Inches(0.5), font_size=44, bold=True, color=DARK_GRAY):
    """Add large title text with proper formatting"""
    textbox = slide.shapes.add_textbox(
        MARGIN, top, SLIDE_WIDTH - 2*MARGIN, Inches(1)
    )
    text_frame = textbox.text_frame
    text_frame.text = text
    text_frame.word_wrap = True
    
    p = text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(font_size)
    p.font.bold = bold
    p.font.color.rgb = color
    p.font.name = 'Calibri'
    
    return textbox

def add_body_text(slide, text, left, top, width, height, font_size=20, 
                  color=TEXT_DARK, align=PP_ALIGN.LEFT, bold=False):
    """Add body text with clean typography"""
    textbox = slide.shapes.add_textbox(left, top, width, height)
    text_frame = textbox.text_frame
    text_frame.text = text
    text_frame.word_wrap = True
    text_frame.vertical_anchor = MSO_ANCHOR.TOP
    
    for paragraph in text_frame.paragraphs:
        paragraph.alignment = align
        paragraph.font.size = Pt(font_size)
        paragraph.font.color.rgb = color
        paragraph.font.name = 'Calibri'
        paragraph.font.bold = bold
    
    return textbox

def add_bullet_text(slide, bullet_items, left, top, width, height, font_size=20):
    """Add bullet points with clean formatting"""
    textbox = slide.shapes.add_textbox(left, top, width, height)
    text_frame = textbox.text_frame
    text_frame.word_wrap = True
    
    for i, item in enumerate(bullet_items):
        if i == 0:
            p = text_frame.paragraphs[0]
        else:
            p = text_frame.add_paragraph()
        
        p.text = item
        p.level = 0
        p.font.size = Pt(font_size)
        p.font.color.rgb = TEXT_DARK
        p.font.name = 'Calibri'
        p.space_before = Pt(8)
        p.space_after = Pt(8)
    
    return textbox

def add_metric_card(slide, left, top, width, height, metric_value, metric_label, 
                    color=PRIMARY_BLUE):
    """Add a metric card with large number and label"""
    # Background card
    card = add_glass_card(slide, left, top, width, height, LIGHT_BG)
    
    # Metric value (large)
    value_box = slide.shapes.add_textbox(left, top + Inches(0.3), width, Inches(0.8))
    value_frame = value_box.text_frame
    value_frame.text = metric_value
    p = value_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(36)
    p.font.bold = True
    p.font.color.rgb = color
    p.font.name = 'Calibri'
    
    # Metric label (smaller)
    label_box = slide.shapes.add_textbox(left, top + Inches(1.2), width, Inches(0.4))
    label_frame = label_box.text_frame
    label_frame.text = metric_label
    p = label_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(14)
    p.font.color.rgb = TEXT_LIGHT
    p.font.name = 'Calibri'
    
    return card

def add_image(slide, image_path, left, top, width=None, height=None):
    """Add image to slide"""
    if os.path.exists(image_path):
        pic = slide.shapes.add_picture(image_path, left, top, width=width, height=height)
        return pic
    else:
        print(f"Warning: Image not found: {image_path}")
        return None

def add_footer(slide, slide_number, total_slides):
    """Add consistent footer with slide number"""
    footer_text = f"{slide_number}/{total_slides}"
    textbox = slide.shapes.add_textbox(
        SLIDE_WIDTH - Inches(1), SLIDE_HEIGHT - Inches(0.4),
        Inches(0.8), Inches(0.3)
    )
    text_frame = textbox.text_frame
    text_frame.text = footer_text
    p = text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.RIGHT
    p.font.size = Pt(10)
    p.font.color.rgb = TEXT_LIGHT
    p.font.name = 'Calibri'

# ===== SLIDE BUILDERS =====

def create_slide_1_title(prs):
    """Slide 1: Title Slide"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])  # Blank layout
    
    # Gradient background
    add_gradient_background(slide, LIGHT_BG, WHITE)
    
    # Main title
    title_box = slide.shapes.add_textbox(
        Inches(1), Inches(2.5), Inches(8), Inches(1.2)
    )
    text_frame = title_box.text_frame
    text_frame.text = "Game Analytics Pipeline"
    p = text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(54)
    p.font.bold = True
    p.font.color.rgb = DARK_GRAY
    p.font.name = 'Calibri'
    
    # Subtitle
    subtitle_box = slide.shapes.add_textbox(
        Inches(1), Inches(3.8), Inches(8), Inches(0.6)
    )
    text_frame = subtitle_box.text_frame
    text_frame.text = "KPI Analysis"
    p = text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(32)
    p.font.color.rgb = PRIMARY_BLUE
    p.font.name = 'Calibri'
    
    # Author
    author_box = slide.shapes.add_textbox(
        Inches(1), Inches(5), Inches(8), Inches(0.4)
    )
    text_frame = author_box.text_frame
    text_frame.text = "Yiwei Ye"
    p = text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(24)
    p.font.color.rgb = TEXT_DARK
    p.font.name = 'Calibri'
    
    # Course
    course_box = slide.shapes.add_textbox(
        Inches(1), Inches(5.5), Inches(8), Inches(0.4)
    )
    text_frame = course_box.text_frame
    text_frame.text = "KPIs Analysis"
    p = text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(18)
    p.font.color.rgb = TEXT_LIGHT
    p.font.name = 'Calibri'

def create_slide_2_architecture(prs):
    """Slide 2: Pipeline Architecture"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    add_gradient_background(slide, WHITE, LIGHT_BG)
    
    # Title
    add_title_text(slide, "Pipeline Architecture", Inches(0.5), 40)
    
    # Pipeline components
    components = [
        ("Unity\nSimulator", Inches(0.8)),
        ("Analytics\nManager", Inches(2.3)),
        ("PHP\nBackend", Inches(3.8)),
        ("MySQL\nDatabase", Inches(5.3)),
        ("R\nAnalysis", Inches(6.8))
    ]
    
    card_width = Inches(1.3)
    card_height = Inches(1.0)
    card_top = Inches(2.5)
    
    for i, (comp_name, left_pos) in enumerate(components):
        # Card
        add_glass_card(slide, left_pos, card_top, card_width, card_height, WHITE)
        
        # Text
        textbox = slide.shapes.add_textbox(left_pos, card_top + Inches(0.25), 
                                          card_width, card_height - Inches(0.5))
        text_frame = textbox.text_frame
        text_frame.text = comp_name
        text_frame.vertical_anchor = MSO_ANCHOR.MIDDLE
        p = text_frame.paragraphs[0]
        p.alignment = PP_ALIGN.CENTER
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = PRIMARY_BLUE
        p.font.name = 'Calibri'
        
        # Arrow (except for last component)
        if i < len(components) - 1:
            arrow_left = left_pos + card_width + Inches(0.05)
            arrow_top = card_top + card_height / 2 - Inches(0.05)
            arrow = slide.shapes.add_shape(
                MSO_SHAPE.RIGHT_ARROW,
                arrow_left, arrow_top, Inches(0.35), Inches(0.1)
            )
            arrow.fill.solid()
            arrow.fill.fore_color.rgb = ACCENT_ORANGE
            arrow.line.fill.background()
    
    # Key points
    key_points = [
        "Non-intrusive event subscription",
        "Async coroutines (Unity → PHP)",
        "Prepared statements (SQL injection prevention)",
        "Normalized database schema"
    ]
    
    add_bullet_text(slide, key_points, 
                   Inches(1), Inches(4.5), Inches(8), Inches(2), 18)
    
    add_footer(slide, 2, 10)

def create_slide_3_database(prs):
    """Slide 3: Database Design"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    add_gradient_background(slide, WHITE, LIGHT_BG)
    
    # Title
    add_title_text(slide, "Database Design", Inches(0.5), 40)
    
    # Tables with relationships
    tables = [
        ("users", Inches(1), Inches(2.2), ["user_id (PK)", "username", "country", "age", "gender"]),
        ("sessions", Inches(3.5), Inches(2.2), ["session_id (PK)", "user_id (FK)", "start_time", "end_time"]),
        ("purchases", Inches(6), Inches(2.2), ["purchase_id (PK)", "user_id (FK)", "item_id (FK)", "amount"]),
        ("items", Inches(6), Inches(4.8), ["item_id (PK)", "item_name", "price", "category"])
    ]
    
    for table_name, left, top, fields in tables:
        # Table card
        card_height = Inches(0.3 + len(fields) * 0.25)
        add_glass_card(slide, left, top, Inches(2), card_height, WHITE)
        
        # Table name
        name_box = slide.shapes.add_textbox(left, top + Inches(0.05), Inches(2), Inches(0.3))
        text_frame = name_box.text_frame
        text_frame.text = table_name
        p = text_frame.paragraphs[0]
        p.alignment = PP_ALIGN.CENTER
        p.font.size = Pt(16)
        p.font.bold = True
        p.font.color.rgb = PRIMARY_BLUE
        p.font.name = 'Calibri'
        
        # Fields
        field_text = "\n".join(fields)
        field_box = slide.shapes.add_textbox(left + Inches(0.1), top + Inches(0.4), 
                                            Inches(1.8), card_height - Inches(0.5))
        text_frame = field_box.text_frame
        text_frame.text = field_text
        for p in text_frame.paragraphs:
            p.font.size = Pt(11)
            p.font.color.rgb = TEXT_DARK
            p.font.name = 'Courier New'
    
    # Highlight banner
    banner = add_glass_card(slide, Inches(1.5), Inches(6.2), Inches(7), Inches(0.6), LIGHT_BG)
    banner_text = add_body_text(slide, 
                                "4 Tables | 3 Foreign Keys | 5 Indexes | 99.99% Data Quality",
                                Inches(1.5), Inches(6.3), Inches(7), Inches(0.5),
                                20, SUCCESS_GREEN, PP_ALIGN.CENTER, True)
    
    add_footer(slide, 3, 10)

def create_slide_4_data_quality(prs):
    """Slide 4: Data Quality Metrics"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    add_gradient_background(slide, WHITE, LIGHT_BG)
    
    # Title
    add_title_text(slide, "Data Quality Metrics", Inches(0.5), 40)
    
    # Metric cards
    metrics = [
        ("1,007", "Total Users", Inches(1)),
        ("12,611", "Total Sessions", Inches(3.3)),
        ("1,272", "Purchases", Inches(5.6))
    ]
    
    for value, label, left in metrics:
        add_metric_card(slide, left, Inches(2), Inches(2), Inches(1.8), 
                       value, label, PRIMARY_BLUE)
    
    # Additional stats banner
    stats_text = "364 days coverage  |  51 countries  |  Zero orphaned records"
    add_body_text(slide, stats_text, Inches(1.5), Inches(4.2), Inches(7), Inches(0.5),
                 18, SUCCESS_GREEN, PP_ALIGN.CENTER, True)
    
    # Key stats
    quality_points = [
        "Full Year 2022 - Complete temporal coverage",
        "5/5 Data Quality Score - Perfect referential integrity",
        "99.99% Complete Sessions - Robust data collection",
        "Global Reach - 51 countries represented"
    ]
    
    add_bullet_text(slide, quality_points,
                   Inches(1.5), Inches(5), Inches(7), Inches(2), 18)
    
    add_footer(slide, 4, 10)

def create_slide_5_engagement(prs, viz_path):
    """Slide 5: User Engagement (DAU/MAU)"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    add_gradient_background(slide, WHITE, LIGHT_BG)
    
    # Title
    add_title_text(slide, "User Engagement", Inches(0.5), 40)
    
    # Metric cards on the right
    metrics = [
        ("9.1", "Mean DAU\n[8.6-9.6]", Inches(7.2), Inches(1.8)),
        ("88.8", "Mean MAU\n[82.8-94.7]", Inches(7.2), Inches(3.4)),
        ("10.2%", "Stickiness\nRatio", Inches(7.2), Inches(5))
    ]
    
    for value, label, left, top in metrics:
        add_metric_card(slide, left, top, Inches(2.2), Inches(1.3),
                       value, label, PRIMARY_BLUE)
    
    # DAU trend chart
    dau_image = os.path.join(viz_path, "01_dau_trend.png")
    add_image(slide, dau_image, Inches(0.7), Inches(1.8), width=Inches(6))
    
    # Insight
    add_body_text(slide, "Stable engagement with 12.5 sessions per user throughout 2022",
                 Inches(1), Inches(6.8), Inches(8), Inches(0.5),
                 16, TEXT_LIGHT, PP_ALIGN.CENTER, False)
    
    add_footer(slide, 5, 10)

def create_slide_6_retention(prs, viz_path):
    """Slide 6: Retention Excellence"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    add_gradient_background(slide, WHITE, LIGHT_BG)
    
    # Title
    add_title_text(slide, "Retention Excellence", Inches(0.5), 40)
    
    # Big highlight
    highlight = add_glass_card(slide, Inches(2), Inches(1.5), Inches(6), Inches(0.9), 
                               RGBColor(46, 204, 113))  # Green background
    highlight_text = slide.shapes.add_textbox(Inches(2), Inches(1.65), Inches(6), Inches(0.6))
    text_frame = highlight_text.text_frame
    text_frame.text = "65.6% D7 Retention - 3-4x Industry Average"
    p = text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(28)
    p.font.bold = True
    p.font.color.rgb = WHITE
    p.font.name = 'Calibri'
    
    # Retention chart
    retention_image = os.path.join(viz_path, "03_retention_curve.png")
    add_image(slide, retention_image, Inches(1.5), Inches(2.8), width=Inches(7))
    
    # Insight
    add_body_text(slide, "Exceptional product-market fit - users who try, stay",
                 Inches(1), Inches(6.8), Inches(8), Inches(0.5),
                 16, TEXT_LIGHT, PP_ALIGN.CENTER, False)
    
    add_footer(slide, 6, 10)

def create_slide_7_monetization(prs, viz_path):
    """Slide 7: Monetization Success"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    add_gradient_background(slide, WHITE, LIGHT_BG)
    
    # Title
    add_title_text(slide, "Monetization Success", Inches(0.5), 40)
    
    # Top metrics row
    metrics = [
        ("$10.86", "ARPU", Inches(1)),
        ("$21.07", "ARPPU", Inches(3.3)),
        ("51.5%", "Conversion", Inches(5.6)),
        ("$10.9K", "Total Revenue", Inches(7.9))
    ]
    
    for value, label, left in metrics:
        add_metric_card(slide, left, Inches(1.6), Inches(1.8), Inches(1),
                       value, label, SUCCESS_GREEN)
    
    # Revenue by item chart
    revenue_image = os.path.join(viz_path, "04_revenue_by_item.png")
    add_image(slide, revenue_image, Inches(1.5), Inches(3.2), width=Inches(7))
    
    # Insight
    add_body_text(slide, "Diamond Pack ($49.99) drives 62% of revenue - premium monetization works",
                 Inches(1), Inches(6.8), Inches(8), Inches(0.5),
                 16, TEXT_LIGHT, PP_ALIGN.CENTER, False)
    
    add_footer(slide, 7, 10)

def create_slide_8_demographics(prs, viz_path):
    """Slide 8: High-Value Demographics"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    add_gradient_background(slide, WHITE, LIGHT_BG)
    
    # Title
    add_title_text(slide, "High-Value Demographics", Inches(0.5), 40)
    
    # Chart on left (use country heatmap for visual impact)
    heatmap_image = os.path.join(viz_path, "08_country_age_heatmap.png")
    add_image(slide, heatmap_image, Inches(0.7), Inches(1.8), width=Inches(5.5))
    
    # Key insights on right
    insights_card = add_glass_card(slide, Inches(6.5), Inches(1.8), 
                                   Inches(3), Inches(4.8), LIGHT_BG)
    
    insights = [
        "Top Markets:",
        "• Suriname: $39.19 ARPU",
        "• Ireland: $22.98 ARPU",
        "",
        "Best Age Group:",
        "• 18-25: $13.38 ARPU",
        "",
        "High-Value Profile:",
        "Ireland + 18-25 age"
    ]
    
    insight_text = slide.shapes.add_textbox(Inches(6.7), Inches(2), 
                                           Inches(2.6), Inches(4.3))
    text_frame = insight_text.text_frame
    text_frame.word_wrap = True
    
    for i, line in enumerate(insights):
        if i == 0:
            p = text_frame.paragraphs[0]
        else:
            p = text_frame.add_paragraph()
        
        p.text = line
        if line.endswith(":"):
            p.font.bold = True
            p.font.size = Pt(16)
            p.font.color.rgb = PRIMARY_BLUE
        else:
            p.font.size = Pt(14)
            p.font.color.rgb = TEXT_DARK
        p.font.name = 'Calibri'
        p.space_after = Pt(6)
    
    add_footer(slide, 8, 10)

def create_slide_9_findings(prs):
    """Slide 9: Key Findings & Recommendations"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    add_gradient_background(slide, WHITE, LIGHT_BG)
    
    # Title
    add_title_text(slide, "Key Findings & Recommendations", Inches(0.5), 36)
    
    findings = [
        "65.6% retention → Protect core gameplay loop (3-4x industry avg)",
        "51.5% conversion → Focus on ARPPU growth, not conversion",
        "Diamond Pack dominance → Expand $50-$100 premium tier",
        "Geographic winners → Target Ireland, Suriname, Brazil for UA"
    ]
    
    add_bullet_text(slide, findings,
                   Inches(1.2), Inches(2), Inches(7.6), Inches(3.5), 20)
    
    # Action callout
    action_card = add_glass_card(slide, Inches(1.5), Inches(5.8), 
                                Inches(7), Inches(1), ACCENT_ORANGE)
    
    action_text = slide.shapes.add_textbox(Inches(1.5), Inches(6), 
                                          Inches(7), Inches(0.6))
    text_frame = action_text.text_frame
    text_frame.text = "Action: Scale premium monetization for +31% revenue potential"
    p = text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(22)
    p.font.bold = True
    p.font.color.rgb = WHITE
    p.font.name = 'Calibri'
    
    add_footer(slide, 9, 10)

def create_slide_10_conclusion(prs):
    """Slide 10: Evaluation & Conclusion"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    add_gradient_background(slide, WHITE, LIGHT_BG)
    
    # Title
    add_title_text(slide, "Evaluation & Conclusion", Inches(0.5), 40)
    
    # Evaluation checklist
    eval_items = [
        ("Gather & Store (50%)", [
            "✓ Normalized DB with proper indexes",
            "✓ Non-intrusive async data transmission",
            "✓ SOLID principles & modular code"
        ]),
        ("Analytics (30%)", [
            "✓ Correct KPI calculations with 95% CI",
            "✓ Statistical rigor & hypothesis testing",
            "✓ Efficient, reusable SQL queries"
        ]),
        ("Reporting (20%)", [
            "✓ Clear visualizations & insights",
            "✓ Professional presentation",
            "✓ Actionable business recommendations"
        ])
    ]
    
    current_top = Inches(1.8)
    for category, items in eval_items:
        # Category header
        cat_box = slide.shapes.add_textbox(Inches(1.2), current_top, 
                                          Inches(7.6), Inches(0.3))
        text_frame = cat_box.text_frame
        text_frame.text = category
        p = text_frame.paragraphs[0]
        p.font.size = Pt(18)
        p.font.bold = True
        p.font.color.rgb = PRIMARY_BLUE
        p.font.name = 'Calibri'
        
        current_top += Inches(0.4)
        
        # Items
        for item in items:
            item_box = slide.shapes.add_textbox(Inches(1.5), current_top,
                                               Inches(7), Inches(0.25))
            text_frame = item_box.text_frame
            text_frame.text = item
            p = text_frame.paragraphs[0]
            p.font.size = Pt(16)
            p.font.color.rgb = SUCCESS_GREEN
            p.font.name = 'Calibri'
            current_top += Inches(0.3)
        
        current_top += Inches(0.15)
    
    # Final highlight
    conclusion_card = add_glass_card(slide, Inches(1.5), Inches(6.2),
                                    Inches(7), Inches(0.7), LIGHT_BG)
    
    conclusion_text = slide.shapes.add_textbox(Inches(1.5), Inches(6.3),
                                              Inches(7), Inches(0.5))
    text_frame = conclusion_text.text_frame
    text_frame.text = "Production-ready analytics pipeline converting data into $3K+ revenue opportunities"
    p = text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(18)
    p.font.bold = True
    p.font.color.rgb = DARK_GRAY
    p.font.name = 'Calibri'
    
    # Thank you
    thanks_box = slide.shapes.add_textbox(Inches(3.5), Inches(7),
                                         Inches(3), Inches(0.3))
    text_frame = thanks_box.text_frame
    text_frame.text = "Thank you | Questions?"
    p = text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    p.font.size = Pt(20)
    p.font.color.rgb = TEXT_LIGHT
    p.font.name = 'Calibri'
    
    add_footer(slide, 10, 10)

# ===== MAIN FUNCTION =====

def create_presentation():
    """Main function to create the complete presentation"""
    print("Creating Game Analytics Presentation...")
    
    # Initialize presentation
    prs = Presentation()
    prs.slide_width = SLIDE_WIDTH
    prs.slide_height = SLIDE_HEIGHT
    
    # Path to visualizations
    base_path = os.path.dirname(os.path.abspath(__file__))
    viz_path = os.path.join(os.path.dirname(base_path), "Analysis", "visualizations")
    
    print("Building slides...")
    
    # Create all slides
    print("  [1/10] Title slide")
    create_slide_1_title(prs)
    
    print("  [2/10] Pipeline Architecture")
    create_slide_2_architecture(prs)
    
    print("  [3/10] Database Design")
    create_slide_3_database(prs)
    
    print("  [4/10] Data Quality")
    create_slide_4_data_quality(prs)
    
    print("  [5/10] User Engagement")
    create_slide_5_engagement(prs, viz_path)
    
    print("  [6/10] Retention")
    create_slide_6_retention(prs, viz_path)
    
    print("  [7/10] Monetization")
    create_slide_7_monetization(prs, viz_path)
    
    print("  [8/10] Demographics")
    create_slide_8_demographics(prs, viz_path)
    
    print("  [9/10] Findings & Recommendations")
    create_slide_9_findings(prs)
    
    print("  [10/10] Conclusion")
    create_slide_10_conclusion(prs)
    
    # Save presentation
    output_path = os.path.join(base_path, "Game_Analytics_Presentation.pptx")
    prs.save(output_path)
    print(f"\n✓ Presentation saved: {output_path}")
    
    return output_path

if __name__ == "__main__":
    try:
        presentation_path = create_presentation()
        print("\n✓ Success! Presentation created successfully.")
        print(f"  Location: {presentation_path}")
        print("\nNext steps:")
        print("  1. Open the .pptx file in PowerPoint")
        print("  2. Review all slides and adjust if needed")
        print("  3. Export as PDF for distribution")
    except Exception as e:
        print(f"\n✗ Error creating presentation: {e}")
        import traceback
        traceback.print_exc()

