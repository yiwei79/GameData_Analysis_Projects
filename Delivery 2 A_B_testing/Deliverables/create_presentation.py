#!/usr/bin/env python3
"""
Create PowerPoint Presentation with Bright Minimalistic Startup Style
"""

from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE
import os

# Paths
BASE_DIR = "/Users/yiwei/GithubRepos/GameData_Analysis_Projects/Delivery 2 A_B_testing"
VIZ_DIR = os.path.join(BASE_DIR, "Analysis/Visualization")
OUTPUT_PATH = os.path.join(BASE_DIR, "Deliverables/Presentation.pptx")

# Color scheme - bright minimalistic
WHITE_BG = RGBColor(255, 255, 255)
DARK_TEXT = RGBColor(33, 33, 33)
ACCENT_BLUE = RGBColor(66, 133, 244)
ACCENT_GREEN = RGBColor(15, 157, 88)
ACCENT_RED = RGBColor(219, 68, 55)
ACCENT_YELLOW = RGBColor(244, 180, 0)
GRAY = RGBColor(117, 117, 117)
LIGHT_GRAY = RGBColor(245, 245, 245)
MEDIUM_GRAY = RGBColor(189, 189, 189)

# Create presentation (16:9)
prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)

def add_title_text(slide, text, top, font_size=44, bold=True, color=DARK_TEXT):
    """Add centered title text"""
    left = Inches(0.5)
    width = prs.slide_width - Inches(1)
    height = Inches(1)

    textbox = slide.shapes.add_textbox(left, top, width, height)
    tf = textbox.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    run = p.add_run()
    run.text = text
    run.font.size = Pt(font_size)
    run.font.bold = bold
    run.font.color.rgb = color
    run.font.name = "Calibri"
    return textbox

def add_body_text(slide, text, left, top, width, font_size=24, color=DARK_TEXT, bold=False, align=PP_ALIGN.LEFT):
    """Add body text"""
    textbox = slide.shapes.add_textbox(left, top, width, Inches(1))
    tf = textbox.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.alignment = align
    run = p.add_run()
    run.text = text
    run.font.size = Pt(font_size)
    run.font.color.rgb = color
    run.font.bold = bold
    run.font.name = "Calibri"
    return textbox

def add_circle_icon(slide, left, top, size, color, text="", text_color=WHITE_BG):
    """Add a circle with optional text inside"""
    circle = slide.shapes.add_shape(MSO_SHAPE.OVAL, left, top, size, size)
    circle.fill.solid()
    circle.fill.fore_color.rgb = color
    circle.line.fill.background()

    if text:
        circle.text_frame.paragraphs[0].alignment = PP_ALIGN.CENTER
        circle.text_frame.paragraphs[0].space_before = Pt(0)
        run = circle.text_frame.paragraphs[0].add_run()
        run.text = text
        run.font.size = Pt(int(size.inches * 28))
        run.font.color.rgb = text_color
        run.font.bold = True
    return circle

def add_arrow(slide, left, top, width, color):
    """Add a right-pointing arrow"""
    arrow = slide.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW, left, top, width, Inches(0.4))
    arrow.fill.solid()
    arrow.fill.fore_color.rgb = color
    arrow.line.fill.background()
    return arrow

def add_rounded_rect(slide, left, top, width, height, color, border_color=None):
    """Add a rounded rectangle"""
    rect = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
    rect.fill.solid()
    rect.fill.fore_color.rgb = color
    if border_color:
        rect.line.color.rgb = border_color
        rect.line.width = Pt(2)
    else:
        rect.line.fill.background()
    return rect

# =============================================================================
# SLIDE 1: Title
# =============================================================================
slide1 = prs.slides.add_slide(prs.slide_layouts[6])  # Blank

# Decorative top bar
top_bar = slide1.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, Inches(0.15))
top_bar.fill.solid()
top_bar.fill.fore_color.rgb = ACCENT_BLUE
top_bar.line.fill.background()

# Title
add_title_text(slide1, "Should We Roll Out", Inches(2.2), font_size=32, bold=False, color=GRAY)
add_title_text(slide1, "The Stronger Boost?", Inches(2.7), font_size=52, bold=True, color=DARK_TEXT)

# Decorative circles
add_circle_icon(slide1, Inches(2), Inches(4), Inches(0.8), ACCENT_BLUE)
add_circle_icon(slide1, Inches(6.2), Inches(4), Inches(0.8), ACCENT_GREEN)
add_circle_icon(slide1, Inches(10.4), Inches(4), Inches(0.8), ACCENT_YELLOW)

add_body_text(slide1, "A/B Test", Inches(1.5), Inches(4.9), Inches(2), font_size=14, color=GRAY, align=PP_ALIGN.CENTER)
add_body_text(slide1, "Analysis", Inches(5.7), Inches(4.9), Inches(2), font_size=14, color=GRAY, align=PP_ALIGN.CENTER)
add_body_text(slide1, "Results", Inches(9.9), Inches(4.9), Inches(2), font_size=14, color=GRAY, align=PP_ALIGN.CENTER)

add_title_text(slide1, "Game Data Analysis  |  December 2024", Inches(6.3), font_size=14, bold=False, color=GRAY)

# =============================================================================
# SLIDE 2: The Problem
# =============================================================================
slide2 = prs.slides.add_slide(prs.slide_layouts[6])

# Top accent bar
top_bar = slide2.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, Inches(0.1))
top_bar.fill.solid()
top_bar.fill.fore_color.rgb = ACCENT_RED
top_bar.line.fill.background()

add_title_text(slide2, "The Problem", Inches(0.4), font_size=36)

# Quote box
quote_box = add_rounded_rect(slide2, Inches(2), Inches(1.4), Inches(9.3), Inches(1.2), LIGHT_GRAY)
add_body_text(slide2, '"Some levels are too hard."', Inches(2), Inches(1.6), Inches(9.3),
              font_size=28, color=DARK_TEXT, bold=False, align=PP_ALIGN.CENTER)
add_body_text(slide2, "— Player Feedback", Inches(2), Inches(2.15), Inches(9.3),
              font_size=14, color=GRAY, align=PP_ALIGN.CENTER)

# Flow diagram: Problem -> Frustration -> Churn
y_flow = Inches(3.2)
# Icon 1: Angry face
add_circle_icon(slide2, Inches(2.5), y_flow, Inches(1), ACCENT_RED, ":(")
add_body_text(slide2, "Frustration", Inches(2), Inches(4.3), Inches(2), font_size=14, color=GRAY, align=PP_ALIGN.CENTER)

add_arrow(slide2, Inches(4), Inches(3.5), Inches(1.2), MEDIUM_GRAY)

# Icon 2: Exit
add_circle_icon(slide2, Inches(5.8), y_flow, Inches(1), ACCENT_YELLOW, "→")
add_body_text(slide2, "Potential Churn", Inches(5.3), Inches(4.3), Inches(2), font_size=14, color=GRAY, align=PP_ALIGN.CENTER)

add_arrow(slide2, Inches(7.3), Inches(3.5), Inches(1.2), MEDIUM_GRAY)

# Icon 3: Solution
add_circle_icon(slide2, Inches(9.1), y_flow, Inches(1), ACCENT_GREEN, "?")
add_body_text(slide2, "Solution?", Inches(8.6), Inches(4.3), Inches(2), font_size=14, color=GRAY, align=PP_ALIGN.CENTER)

# Hypothesis box
hyp_box = add_rounded_rect(slide2, Inches(2), Inches(5.2), Inches(9.3), Inches(1.5), RGBColor(232, 245, 233), ACCENT_GREEN)
add_body_text(slide2, "Hypothesis", Inches(2), Inches(5.35), Inches(9.3), font_size=14, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide2, "A stronger boost will help players succeed", Inches(2), Inches(5.7), Inches(9.3),
              font_size=22, color=DARK_TEXT, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide2, "without breaking the game", Inches(2), Inches(6.15), Inches(9.3),
              font_size=18, color=GRAY, align=PP_ALIGN.CENTER)

# =============================================================================
# SLIDE 3: Test Design
# =============================================================================
slide3 = prs.slides.add_slide(prs.slide_layouts[6])

top_bar = slide3.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, Inches(0.1))
top_bar.fill.solid()
top_bar.fill.fore_color.rgb = ACCENT_BLUE
top_bar.line.fill.background()

add_title_text(slide3, "The Experiment", Inches(0.3), font_size=36)

# Two group boxes
# Group A
box_a = add_rounded_rect(slide3, Inches(1.5), Inches(1.2), Inches(4.5), Inches(2), RGBColor(227, 242, 253), ACCENT_BLUE)
add_circle_icon(slide3, Inches(3.35), Inches(1.5), Inches(0.8), ACCENT_BLUE, "A", WHITE_BG)
add_body_text(slide3, "GROUP A", Inches(1.5), Inches(2.4), Inches(4.5), font_size=18, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide3, "Stronger Boost", Inches(1.5), Inches(2.75), Inches(4.5), font_size=16, color=DARK_TEXT, align=PP_ALIGN.CENTER)

# VS circle
add_circle_icon(slide3, Inches(6.1), Inches(1.7), Inches(0.6), MEDIUM_GRAY, "vs", DARK_TEXT)

# Group B
box_b = add_rounded_rect(slide3, Inches(7.3), Inches(1.2), Inches(4.5), Inches(2), RGBColor(255, 235, 238), ACCENT_RED)
add_circle_icon(slide3, Inches(9.15), Inches(1.5), Inches(0.8), ACCENT_RED, "B", WHITE_BG)
add_body_text(slide3, "GROUP B", Inches(7.3), Inches(2.4), Inches(4.5), font_size=18, color=ACCENT_RED, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide3, "Original Boost", Inches(7.3), Inches(2.75), Inches(4.5), font_size=16, color=DARK_TEXT, align=PP_ALIGN.CENTER)

# Timeline
add_body_text(slide3, "Timeline", Inches(0.5), Inches(3.5), Inches(12), font_size=16, color=GRAY, bold=True)

timeline_y = Inches(4)
box_height = Inches(0.9)

# Pre-test box
pre_box = add_rounded_rect(slide3, Inches(1), timeline_y, Inches(3.2), box_height, LIGHT_GRAY)
add_body_text(slide3, "Jan - May 2020", Inches(1), Inches(4.05), Inches(3.2), font_size=13, color=DARK_TEXT, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide3, "Baseline", Inches(1), Inches(4.35), Inches(3.2), font_size=11, color=GRAY, align=PP_ALIGN.CENTER)

# Test period box (highlighted)
test_box = add_rounded_rect(slide3, Inches(4.4), timeline_y, Inches(4), box_height, RGBColor(227, 242, 253), ACCENT_BLUE)
add_body_text(slide3, "June - Sept 2020", Inches(4.4), Inches(4.05), Inches(4), font_size=13, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide3, "A/B TEST", Inches(4.4), Inches(4.35), Inches(4), font_size=11, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)

# Post-test box
post_box = add_rounded_rect(slide3, Inches(8.6), timeline_y, Inches(3.2), box_height, LIGHT_GRAY)
add_body_text(slide3, "Oct - Dec 2020", Inches(8.6), Inches(4.05), Inches(3.2), font_size=13, color=DARK_TEXT, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide3, "Reset & Monitor", Inches(8.6), Inches(4.35), Inches(3.2), font_size=11, color=GRAY, align=PP_ALIGN.CENTER)

# Key metrics row
metrics_y = Inches(5.3)
metrics = [
    ("14K", "Players", ACCENT_BLUE),
    ("1.5M", "Level Attempts", ACCENT_GREEN),
    ("4 mo", "Test Duration", ACCENT_YELLOW)
]
x_start = Inches(2)
for val, label, color in metrics:
    add_circle_icon(slide3, x_start, metrics_y, Inches(1.2), color, val, WHITE_BG)
    add_body_text(slide3, label, x_start - Inches(0.3), Inches(6.6), Inches(1.8), font_size=12, color=GRAY, align=PP_ALIGN.CENTER)
    x_start += Inches(3.8)

# =============================================================================
# SLIDE 4: Key Result - Success Rate (with Chart 1)
# =============================================================================
slide4 = prs.slides.add_slide(prs.slide_layouts[6])

top_bar = slide4.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, Inches(0.1))
top_bar.fill.solid()
top_bar.fill.fore_color.rgb = ACCENT_GREEN
top_bar.line.fill.background()

add_title_text(slide4, "The Result", Inches(0.3), font_size=36)

# Left side: Big number + stats
add_body_text(slide4, "+2.6%", Inches(0.5), Inches(1.2), Inches(5), font_size=72, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide4, "higher success rate", Inches(0.5), Inches(2.5), Inches(5), font_size=22, color=DARK_TEXT, align=PP_ALIGN.CENTER)

# Comparison boxes
comp_y = Inches(3.3)
box_a = add_rounded_rect(slide4, Inches(0.8), comp_y, Inches(2), Inches(1), RGBColor(227, 242, 253), ACCENT_BLUE)
add_body_text(slide4, "Group A", Inches(0.8), Inches(3.4), Inches(2), font_size=12, color=ACCENT_BLUE, align=PP_ALIGN.CENTER)
add_body_text(slide4, "25.1%", Inches(0.8), Inches(3.7), Inches(2), font_size=24, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)

box_b = add_rounded_rect(slide4, Inches(3), comp_y, Inches(2), Inches(1), RGBColor(255, 235, 238), ACCENT_RED)
add_body_text(slide4, "Group B", Inches(3), Inches(3.4), Inches(2), font_size=12, color=ACCENT_RED, align=PP_ALIGN.CENTER)
add_body_text(slide4, "22.5%", Inches(3), Inches(3.7), Inches(2), font_size=24, color=ACCENT_RED, bold=True, align=PP_ALIGN.CENTER)

# Statistical significance badge
sig_box = add_rounded_rect(slide4, Inches(0.8), Inches(4.6), Inches(4.2), Inches(0.6), RGBColor(232, 245, 233), ACCENT_GREEN)
add_body_text(slide4, "p < 0.001 — Statistically Significant", Inches(0.8), Inches(4.7), Inches(4.2), font_size=14, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)

# Right side: Chart
viz_path = os.path.join(VIZ_DIR, "Success Rate by Group.png")
if os.path.exists(viz_path):
    slide4.shapes.add_picture(viz_path, Inches(5.8), Inches(1), width=Inches(7))

# =============================================================================
# SLIDE 5: Time Series (with Chart 2)
# =============================================================================
slide5 = prs.slides.add_slide(prs.slide_layouts[6])

top_bar = slide5.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, Inches(0.1))
top_bar.fill.solid()
top_bar.fill.fore_color.rgb = ACCENT_BLUE
top_bar.line.fill.background()

add_title_text(slide5, "The Effect Over Time", Inches(0.3), font_size=36)

# Chart (larger, centered)
viz_path = os.path.join(VIZ_DIR, "Success Rate Over Time.png")
if os.path.exists(viz_path):
    slide5.shapes.add_picture(viz_path, Inches(0.5), Inches(1), width=Inches(9))

# Key insights on the right
insight_box = add_rounded_rect(slide5, Inches(9.8), Inches(1.2), Inches(3), Inches(4), LIGHT_GRAY)
add_body_text(slide5, "Key Observations", Inches(9.8), Inches(1.4), Inches(3), font_size=14, color=DARK_TEXT, bold=True, align=PP_ALIGN.CENTER)

# Three insight items with icons
insights = [
    ("Before", "Groups similar", GRAY),
    ("During", "Clear separation", ACCENT_BLUE),
    ("After", "Effect persists!", ACCENT_GREEN)
]
y_pos = Inches(2)
for label, text, color in insights:
    add_circle_icon(slide5, Inches(10.1), y_pos, Inches(0.5), color, "", WHITE_BG)
    add_body_text(slide5, label, Inches(10.7), y_pos, Inches(1.8), font_size=12, color=GRAY, bold=True)
    add_body_text(slide5, text, Inches(10.7), y_pos + Inches(0.3), Inches(1.8), font_size=11, color=color)
    y_pos += Inches(0.9)

# Bottom callout
callout = add_rounded_rect(slide5, Inches(2), Inches(5.8), Inches(9.3), Inches(0.8), RGBColor(232, 245, 233), ACCENT_GREEN)
add_body_text(slide5, "The effect persisted even after the boost was reset!", Inches(2), Inches(5.95), Inches(9.3), font_size=18, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)

# =============================================================================
# SLIDE 6: Engagement (with Chart 3)
# =============================================================================
slide6 = prs.slides.add_slide(prs.slide_layouts[6])

top_bar = slide6.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, Inches(0.1))
top_bar.fill.solid()
top_bar.fill.fore_color.rgb = ACCENT_YELLOW
top_bar.line.fill.background()

add_title_text(slide6, "Players Love It", Inches(0.3), font_size=36)

# Left side: Stats
add_body_text(slide6, "+51%", Inches(0.5), Inches(1.2), Inches(5), font_size=72, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide6, "more boost usage", Inches(0.5), Inches(2.5), Inches(5), font_size=22, color=DARK_TEXT, align=PP_ALIGN.CENTER)

# Comparison boxes
comp_y = Inches(3.3)
box_a = add_rounded_rect(slide6, Inches(0.8), comp_y, Inches(2), Inches(1), RGBColor(227, 242, 253), ACCENT_BLUE)
add_body_text(slide6, "Group A", Inches(0.8), Inches(3.4), Inches(2), font_size=12, color=ACCENT_BLUE, align=PP_ALIGN.CENTER)
add_body_text(slide6, "15.6%", Inches(0.8), Inches(3.7), Inches(2), font_size=24, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)

box_b = add_rounded_rect(slide6, Inches(3), comp_y, Inches(2), Inches(1), RGBColor(255, 235, 238), ACCENT_RED)
add_body_text(slide6, "Group B", Inches(3), Inches(3.4), Inches(2), font_size=12, color=ACCENT_RED, align=PP_ALIGN.CENTER)
add_body_text(slide6, "10.3%", Inches(3), Inches(3.7), Inches(2), font_size=24, color=ACCENT_RED, bold=True, align=PP_ALIGN.CENTER)

# Insight
insight_box = add_rounded_rect(slide6, Inches(0.8), Inches(4.6), Inches(4.2), Inches(0.8), LIGHT_GRAY)
add_body_text(slide6, "Players recognize value and", Inches(0.8), Inches(4.7), Inches(4.2), font_size=13, color=DARK_TEXT, align=PP_ALIGN.CENTER)
add_body_text(slide6, "actively use the feature more", Inches(0.8), Inches(5), Inches(4.2), font_size=13, color=DARK_TEXT, align=PP_ALIGN.CENTER)

# Right side: Chart
viz_path = os.path.join(VIZ_DIR, "Boost Usage Rate.png")
if os.path.exists(viz_path):
    slide6.shapes.add_picture(viz_path, Inches(5.8), Inches(1), width=Inches(7))

# =============================================================================
# SLIDE 7: Before/During/After (with Chart 4)
# =============================================================================
slide7 = prs.slides.add_slide(prs.slide_layouts[6])

top_bar = slide7.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, Inches(0.1))
top_bar.fill.solid()
top_bar.fill.fore_color.rgb = ACCENT_GREEN
top_bar.line.fill.background()

add_title_text(slide7, "The Full Picture", Inches(0.3), font_size=36)

# Chart 4: Success Rate by Test Period (main visual)
viz_path = os.path.join(VIZ_DIR, "Success Rate by Test Period.png")
if os.path.exists(viz_path):
    slide7.shapes.add_picture(viz_path, Inches(0.5), Inches(1), width=Inches(8))

# Right side: Summary cards
card_x = Inches(9)
card_width = Inches(3.8)

# Pre-test card
pre_card = add_rounded_rect(slide7, card_x, Inches(1.2), card_width, Inches(1.3), LIGHT_GRAY)
add_body_text(slide7, "PRE-TEST", Inches(9), Inches(1.3), card_width, font_size=12, color=GRAY, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide7, "A: 29.1%  vs  B: 30.1%", Inches(9), Inches(1.7), card_width, font_size=14, color=DARK_TEXT, align=PP_ALIGN.CENTER)
add_body_text(slide7, "-1.0 pp (similar baseline)", Inches(9), Inches(2.05), card_width, font_size=11, color=GRAY, align=PP_ALIGN.CENTER)

# During test card
during_card = add_rounded_rect(slide7, card_x, Inches(2.7), card_width, Inches(1.3), RGBColor(227, 242, 253), ACCENT_BLUE)
add_body_text(slide7, "DURING TEST", Inches(9), Inches(2.8), card_width, font_size=12, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide7, "A: 25.1%  vs  B: 22.5%", Inches(9), Inches(3.2), card_width, font_size=14, color=DARK_TEXT, align=PP_ALIGN.CENTER)
add_body_text(slide7, "+2.6 pp improvement", Inches(9), Inches(3.55), card_width, font_size=11, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)

# Post-test card
post_card = add_rounded_rect(slide7, card_x, Inches(4.2), card_width, Inches(1.3), RGBColor(232, 245, 233), ACCENT_GREEN)
add_body_text(slide7, "POST-TEST", Inches(9), Inches(4.3), card_width, font_size=12, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide7, "A: 22.3%  vs  B: 19.7%", Inches(9), Inches(4.7), card_width, font_size=14, color=DARK_TEXT, align=PP_ALIGN.CENTER)
add_body_text(slide7, "+2.6 pp (effect persists!)", Inches(9), Inches(5.05), card_width, font_size=11, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)

# Bottom insight
insight = add_rounded_rect(slide7, Inches(2), Inches(5.8), Inches(9.3), Inches(0.8), RGBColor(255, 243, 224), ACCENT_YELLOW)
add_body_text(slide7, "Key Insight: Effect persists = Learned behavior / Habit formation", Inches(2), Inches(5.95), Inches(9.3), font_size=16, color=DARK_TEXT, bold=True, align=PP_ALIGN.CENTER)

# =============================================================================
# SLIDE 8: For & Against
# =============================================================================
slide8 = prs.slides.add_slide(prs.slide_layouts[6])

top_bar = slide8.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, Inches(0.1))
top_bar.fill.solid()
top_bar.fill.fore_color.rgb = GRAY
top_bar.line.fill.background()

add_title_text(slide8, "The Trade-offs", Inches(0.3), font_size=36)

# FOR box (left)
for_box = add_rounded_rect(slide8, Inches(0.8), Inches(1.2), Inches(5.5), Inches(4.5), RGBColor(232, 245, 233), ACCENT_GREEN)
add_circle_icon(slide8, Inches(3.1), Inches(1.4), Inches(0.7), ACCENT_GREEN, "✓", WHITE_BG)
add_body_text(slide8, "FOR ROLLOUT", Inches(0.8), Inches(2.2), Inches(5.5), font_size=20, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)

for_items = [
    "+2.6% success rate",
    "Statistically proven (p < 0.001)",
    "51% higher engagement",
    "Lasting positive effect"
]
y = Inches(2.8)
for item in for_items:
    add_body_text(slide8, f"→  {item}", Inches(1.3), y, Inches(4.5), font_size=16, color=DARK_TEXT)
    y += Inches(0.5)

# AGAINST box (right)
against_box = add_rounded_rect(slide8, Inches(7), Inches(1.2), Inches(5.5), Inches(4.5), RGBColor(255, 235, 238), ACCENT_RED)
add_circle_icon(slide8, Inches(9.3), Inches(1.4), Inches(0.7), ACCENT_RED, "✗", WHITE_BG)
add_body_text(slide8, "AGAINST ROLLOUT", Inches(7), Inches(2.2), Inches(5.5), font_size=20, color=ACCENT_RED, bold=True, align=PP_ALIGN.CENTER)

against_items = [
    "May reduce game challenge",
    "Boost dependency risk",
    "Unknown monetization impact",
    "Small baseline difference"
]
y = Inches(2.8)
for item in against_items:
    add_body_text(slide8, f"→  {item}", Inches(7.5), y, Inches(4.5), font_size=16, color=DARK_TEXT)
    y += Inches(0.5)

# Bottom verdict
verdict = add_rounded_rect(slide8, Inches(2), Inches(6), Inches(9.3), Inches(0.7), LIGHT_GRAY)
add_body_text(slide8, "Benefits significantly outweigh risks with proper monitoring", Inches(2), Inches(6.12), Inches(9.3), font_size=16, color=DARK_TEXT, align=PP_ALIGN.CENTER)

# =============================================================================
# SLIDE 9: Recommendation
# =============================================================================
slide9 = prs.slides.add_slide(prs.slide_layouts[6])

top_bar = slide9.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, Inches(0.1))
top_bar.fill.solid()
top_bar.fill.fore_color.rgb = ACCENT_GREEN
top_bar.line.fill.background()

add_body_text(slide9, "Recommendation", Inches(0.5), Inches(0.5), Inches(12), font_size=24, color=GRAY, align=PP_ALIGN.CENTER)

# Big recommendation
rec_box = add_rounded_rect(slide9, Inches(2), Inches(1.3), Inches(9.3), Inches(1.5), RGBColor(232, 245, 233), ACCENT_GREEN)
add_body_text(slide9, "ROLL IT OUT", Inches(2), Inches(1.6), Inches(9.3), font_size=48, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)

# Three pillars
pillar_y = Inches(3.2)
pillars = [
    ("✓", "Proven\nImprovement", "+2.6% success"),
    ("✓", "Higher\nEngagement", "+51% boost use"),
    ("✓", "Lasting\nEffect", "Persists after reset")
]
x_pos = Inches(1.5)
for icon, title, detail in pillars:
    add_circle_icon(slide9, x_pos + Inches(1.1), pillar_y, Inches(0.8), ACCENT_GREEN, icon, WHITE_BG)
    add_body_text(slide9, title, x_pos, pillar_y + Inches(1), Inches(3), font_size=16, color=DARK_TEXT, bold=True, align=PP_ALIGN.CENTER)
    add_body_text(slide9, detail, x_pos, pillar_y + Inches(1.7), Inches(3), font_size=14, color=GRAY, align=PP_ALIGN.CENTER)
    x_pos += Inches(3.8)

# Monitor section
monitor_box = add_rounded_rect(slide9, Inches(1.5), Inches(5.5), Inches(10.3), Inches(1.2), LIGHT_GRAY)
add_body_text(slide9, "With Monitoring:", Inches(1.5), Inches(5.65), Inches(10.3), font_size=14, color=GRAY, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide9, "Long-term retention  •  Monetization metrics  •  Difficulty balance", Inches(1.5), Inches(6), Inches(10.3), font_size=16, color=DARK_TEXT, align=PP_ALIGN.CENTER)

# =============================================================================
# SLIDE 10: Thank You / Questions
# =============================================================================
slide10 = prs.slides.add_slide(prs.slide_layouts[6])

top_bar = slide10.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, Inches(0.1))
top_bar.fill.solid()
top_bar.fill.fore_color.rgb = ACCENT_BLUE
top_bar.line.fill.background()

add_title_text(slide10, "Questions?", Inches(1.5), font_size=52, color=DARK_TEXT)

# Summary metrics row
add_body_text(slide10, "Summary", Inches(0.5), Inches(3), Inches(12), font_size=16, color=GRAY, align=PP_ALIGN.CENTER)

metrics = [
    ("+2.6%", "Success Rate", ACCENT_GREEN),
    ("+51%", "Engagement", ACCENT_BLUE),
    ("✓", "Significant", ACCENT_GREEN)
]
x_pos = Inches(2.5)
for val, label, color in metrics:
    metric_box = add_rounded_rect(slide10, x_pos, Inches(3.5), Inches(2.5), Inches(1.8), LIGHT_GRAY)
    add_body_text(slide10, val, x_pos, Inches(3.7), Inches(2.5), font_size=36, color=color, bold=True, align=PP_ALIGN.CENTER)
    add_body_text(slide10, label, x_pos, Inches(4.5), Inches(2.5), font_size=14, color=GRAY, align=PP_ALIGN.CENTER)
    x_pos += Inches(3)

# Decorative circles at bottom
add_circle_icon(slide10, Inches(4), Inches(5.8), Inches(0.4), ACCENT_BLUE)
add_circle_icon(slide10, Inches(6.4), Inches(5.8), Inches(0.4), ACCENT_GREEN)
add_circle_icon(slide10, Inches(8.8), Inches(5.8), Inches(0.4), ACCENT_YELLOW)

add_title_text(slide10, "Thank you!", Inches(6.2), font_size=20, bold=False, color=GRAY)

# Save presentation
prs.save(OUTPUT_PATH)
print(f"Presentation saved to: {OUTPUT_PATH}")
