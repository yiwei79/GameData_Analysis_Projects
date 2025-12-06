#!/usr/bin/env python3
"""
Create PowerPoint Presentation with Minimalistic Startup Style
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

# Color scheme - minimalistic dark
DARK_BG = RGBColor(30, 30, 35)
WHITE = RGBColor(255, 255, 255)
ACCENT_BLUE = RGBColor(66, 133, 244)
ACCENT_GREEN = RGBColor(52, 168, 83)
ACCENT_RED = RGBColor(234, 67, 53)
GRAY = RGBColor(150, 150, 150)
LIGHT_GRAY = RGBColor(200, 200, 200)

# Create presentation (16:9)
prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)

def add_dark_background(slide):
    """Add dark background to slide"""
    background = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, prs.slide_height
    )
    background.fill.solid()
    background.fill.fore_color.rgb = DARK_BG
    background.line.fill.background()
    # Send to back
    spTree = slide.shapes._spTree
    sp = background._element
    spTree.remove(sp)
    spTree.insert(2, sp)

def add_title_text(slide, text, top, font_size=44, bold=True, color=WHITE):
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

def add_body_text(slide, text, left, top, width, font_size=24, color=WHITE, bold=False, align=PP_ALIGN.LEFT):
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

def add_metric_box(slide, value, label, left, top, width=Inches(2.5), value_color=ACCENT_BLUE):
    """Add a metric display box"""
    # Value
    textbox = slide.shapes.add_textbox(left, top, width, Inches(1))
    tf = textbox.text_frame
    p = tf.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    run = p.add_run()
    run.text = value
    run.font.size = Pt(48)
    run.font.bold = True
    run.font.color.rgb = value_color
    run.font.name = "Calibri"

    # Label
    textbox2 = slide.shapes.add_textbox(left, top + Inches(0.8), width, Inches(0.5))
    tf2 = textbox2.text_frame
    p2 = tf2.paragraphs[0]
    p2.alignment = PP_ALIGN.CENTER
    run2 = p2.add_run()
    run2.text = label
    run2.font.size = Pt(16)
    run2.font.color.rgb = GRAY
    run2.font.name = "Calibri"

# =============================================================================
# SLIDE 1: Title
# =============================================================================
slide1 = prs.slides.add_slide(prs.slide_layouts[6])  # Blank
add_dark_background(slide1)

add_title_text(slide1, "Should We Roll Out", Inches(2.2), font_size=36, bold=False, color=GRAY)
add_title_text(slide1, "The Stronger Boost?", Inches(2.8), font_size=56, bold=True, color=WHITE)
add_title_text(slide1, "A/B Test Analysis Results", Inches(4.2), font_size=24, bold=False, color=ACCENT_BLUE)
add_title_text(slide1, "Game Data Analysis  |  December 2024", Inches(6.5), font_size=14, bold=False, color=GRAY)

# =============================================================================
# SLIDE 2: The Problem
# =============================================================================
slide2 = prs.slides.add_slide(prs.slide_layouts[6])
add_dark_background(slide2)

add_title_text(slide2, "The Problem", Inches(0.5), font_size=40)

# Problem statement
add_body_text(slide2, '"Some levels are too hard."', Inches(1), Inches(1.8), Inches(11),
              font_size=32, color=LIGHT_GRAY, bold=False, align=PP_ALIGN.CENTER)
add_body_text(slide2, "— Player Feedback", Inches(1), Inches(2.5), Inches(11),
              font_size=18, color=GRAY, align=PP_ALIGN.CENTER)

# Visual: Frustration arrow down, then question
add_body_text(slide2, "Player frustration → Potential churn", Inches(1), Inches(3.5), Inches(11),
              font_size=24, color=ACCENT_RED, align=PP_ALIGN.CENTER)

add_body_text(slide2, "Hypothesis:", Inches(1), Inches(4.8), Inches(11),
              font_size=20, color=GRAY, align=PP_ALIGN.CENTER)
add_body_text(slide2, "A stronger boost will help players succeed", Inches(1), Inches(5.3), Inches(11),
              font_size=28, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide2, "without breaking the game", Inches(1), Inches(5.9), Inches(11),
              font_size=28, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)

# =============================================================================
# SLIDE 3: Test Design
# =============================================================================
slide3 = prs.slides.add_slide(prs.slide_layouts[6])
add_dark_background(slide3)

add_title_text(slide3, "The Experiment", Inches(0.3), font_size=40)

# Two columns for A vs B
add_body_text(slide3, "GROUP A", Inches(2), Inches(1.5), Inches(4),
              font_size=24, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide3, "Stronger Boost", Inches(2), Inches(2.1), Inches(4),
              font_size=20, color=WHITE, align=PP_ALIGN.CENTER)
add_body_text(slide3, "6,923 players", Inches(2), Inches(2.6), Inches(4),
              font_size=16, color=GRAY, align=PP_ALIGN.CENTER)

add_body_text(slide3, "vs", Inches(5.5), Inches(2), Inches(2),
              font_size=32, color=GRAY, bold=True, align=PP_ALIGN.CENTER)

add_body_text(slide3, "GROUP B", Inches(7.5), Inches(1.5), Inches(4),
              font_size=24, color=ACCENT_RED, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide3, "Original Boost", Inches(7.5), Inches(2.1), Inches(4),
              font_size=20, color=WHITE, align=PP_ALIGN.CENTER)
add_body_text(slide3, "7,017 players", Inches(7.5), Inches(2.6), Inches(4),
              font_size=16, color=GRAY, align=PP_ALIGN.CENTER)

# Timeline
add_body_text(slide3, "Timeline", Inches(0.5), Inches(3.8), Inches(12),
              font_size=20, color=GRAY, bold=True)

# Timeline visual - simple boxes
timeline_y = Inches(4.5)
box_height = Inches(0.8)

# Pre-test box
pre_box = slide3.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(1), timeline_y, Inches(3), box_height)
pre_box.fill.solid()
pre_box.fill.fore_color.rgb = RGBColor(60, 60, 65)
pre_box.line.fill.background()
add_body_text(slide3, "Jan - May", Inches(1), Inches(4.5), Inches(3), font_size=14, color=WHITE, align=PP_ALIGN.CENTER)
add_body_text(slide3, "Baseline", Inches(1), Inches(4.85), Inches(3), font_size=12, color=GRAY, align=PP_ALIGN.CENTER)

# Test period box
test_box = slide3.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(4.2), timeline_y, Inches(3.5), box_height)
test_box.fill.solid()
test_box.fill.fore_color.rgb = ACCENT_BLUE
test_box.line.fill.background()
add_body_text(slide3, "June - Sept", Inches(4.2), Inches(4.5), Inches(3.5), font_size=14, color=WHITE, align=PP_ALIGN.CENTER)
add_body_text(slide3, "A/B TEST", Inches(4.2), Inches(4.85), Inches(3.5), font_size=12, color=WHITE, bold=True, align=PP_ALIGN.CENTER)

# Post-test box
post_box = slide3.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(7.9), timeline_y, Inches(3), box_height)
post_box.fill.solid()
post_box.fill.fore_color.rgb = RGBColor(60, 60, 65)
post_box.line.fill.background()
add_body_text(slide3, "Oct - Dec", Inches(7.9), Inches(4.5), Inches(3), font_size=14, color=WHITE, align=PP_ALIGN.CENTER)
add_body_text(slide3, "Reset", Inches(7.9), Inches(4.85), Inches(3), font_size=12, color=GRAY, align=PP_ALIGN.CENTER)

# Key numbers at bottom
add_metric_box(slide3, "14K", "Players", Inches(2), Inches(5.8))
add_metric_box(slide3, "1.5M", "Level Attempts", Inches(5.5), Inches(5.8))
add_metric_box(slide3, "4 mo", "Test Duration", Inches(9), Inches(5.8))

# =============================================================================
# SLIDE 4: Key Result - Success Rate
# =============================================================================
slide4 = prs.slides.add_slide(prs.slide_layouts[6])
add_dark_background(slide4)

add_title_text(slide4, "The Result", Inches(0.3), font_size=40)

# Big impact number
add_title_text(slide4, "+2.6%", Inches(1.3), font_size=96, bold=True, color=ACCENT_GREEN)
add_body_text(slide4, "higher success rate", Inches(0.5), Inches(3), Inches(12),
              font_size=28, color=WHITE, align=PP_ALIGN.CENTER)

# Comparison
add_body_text(slide4, "Group A: 25.1%", Inches(3), Inches(4), Inches(3),
              font_size=24, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide4, "Group B: 22.5%", Inches(7), Inches(4), Inches(3),
              font_size=24, color=ACCENT_RED, bold=True, align=PP_ALIGN.CENTER)

# Statistical significance badge
add_body_text(slide4, "p < 0.001  •  Statistically Significant", Inches(0.5), Inches(5), Inches(12),
              font_size=18, color=ACCENT_GREEN, align=PP_ALIGN.CENTER)

# Add the chart if exists
viz_path = os.path.join(VIZ_DIR, "Success Rate by Group.png")
if os.path.exists(viz_path):
    slide4.shapes.add_picture(viz_path, Inches(8.5), Inches(1.5), width=Inches(4.3))

# =============================================================================
# SLIDE 5: Time Series
# =============================================================================
slide5 = prs.slides.add_slide(prs.slide_layouts[6])
add_dark_background(slide5)

add_title_text(slide5, "The Effect Over Time", Inches(0.3), font_size=40)

# Add the chart
viz_path = os.path.join(VIZ_DIR, "Success Rate Over Time.png")
if os.path.exists(viz_path):
    slide5.shapes.add_picture(viz_path, Inches(0.8), Inches(1.3), width=Inches(8))

# Key insights on the right
add_body_text(slide5, "Key Observations", Inches(9.2), Inches(1.5), Inches(3.5),
              font_size=18, color=GRAY, bold=True)

insights = [
    ("Before:", "Groups similar", GRAY),
    ("During:", "Clear separation", ACCENT_BLUE),
    ("After:", "Effect persists!", ACCENT_GREEN)
]
y_pos = Inches(2.2)
for label, text, color in insights:
    add_body_text(slide5, label, Inches(9.2), y_pos, Inches(1.2), font_size=14, color=GRAY)
    add_body_text(slide5, text, Inches(10.2), y_pos, Inches(2.5), font_size=14, color=color, bold=True)
    y_pos += Inches(0.5)

# Bottom insight
add_body_text(slide5, "The effect persisted even after the boost was reset",
              Inches(0.5), Inches(6.5), Inches(12), font_size=20, color=ACCENT_GREEN, align=PP_ALIGN.CENTER)

# =============================================================================
# SLIDE 6: Engagement
# =============================================================================
slide6 = prs.slides.add_slide(prs.slide_layouts[6])
add_dark_background(slide6)

add_title_text(slide6, "Players Love It", Inches(0.3), font_size=40)

# Big engagement number
add_title_text(slide6, "+51%", Inches(1.3), font_size=96, bold=True, color=ACCENT_BLUE)
add_body_text(slide6, "more boost usage", Inches(0.5), Inches(3), Inches(12),
              font_size=28, color=WHITE, align=PP_ALIGN.CENTER)

# Comparison
add_body_text(slide6, "Group A: 15.6%", Inches(3), Inches(4), Inches(3),
              font_size=24, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)
add_body_text(slide6, "Group B: 10.3%", Inches(7), Inches(4), Inches(3),
              font_size=24, color=ACCENT_RED, bold=True, align=PP_ALIGN.CENTER)

# What this means
add_body_text(slide6, "Players recognize the value and actively use the feature more",
              Inches(0.5), Inches(5.2), Inches(12), font_size=18, color=GRAY, align=PP_ALIGN.CENTER)

# Add the chart if exists
viz_path = os.path.join(VIZ_DIR, "Boost Usage Rate.png")
if os.path.exists(viz_path):
    slide6.shapes.add_picture(viz_path, Inches(8.5), Inches(1.5), width=Inches(4.3))

# =============================================================================
# SLIDE 7: Before/During/After
# =============================================================================
slide7 = prs.slides.add_slide(prs.slide_layouts[6])
add_dark_background(slide7)

add_title_text(slide7, "The Full Picture", Inches(0.3), font_size=40)

# Three period comparison - visual bars
periods = [
    ("PRE-TEST", "29.1%", "30.1%", "-1.0 pp", RGBColor(80, 80, 85)),
    ("DURING TEST", "25.1%", "22.5%", "+2.6 pp", ACCENT_BLUE),
    ("POST-TEST", "22.3%", "19.7%", "+2.6 pp", ACCENT_GREEN)
]

x_start = Inches(1.5)
for i, (period, a_val, b_val, diff, color) in enumerate(periods):
    x = x_start + Inches(i * 3.8)

    # Period label
    add_body_text(slide7, period, x, Inches(1.4), Inches(3), font_size=16, color=color, bold=True, align=PP_ALIGN.CENTER)

    # Box
    box = slide7.shapes.add_shape(MSO_SHAPE.RECTANGLE, x, Inches(1.9), Inches(3), Inches(3.5))
    box.fill.solid()
    box.fill.fore_color.rgb = RGBColor(45, 45, 50)
    box.line.color.rgb = color
    box.line.width = Pt(2)

    # Values inside
    add_body_text(slide7, f"A: {a_val}", x, Inches(2.3), Inches(3), font_size=24, color=ACCENT_BLUE, bold=True, align=PP_ALIGN.CENTER)
    add_body_text(slide7, f"B: {b_val}", x, Inches(3), Inches(3), font_size=24, color=ACCENT_RED, bold=True, align=PP_ALIGN.CENTER)
    add_body_text(slide7, diff, x, Inches(4), Inches(3), font_size=32, color=color, bold=True, align=PP_ALIGN.CENTER)

# Key insight
add_body_text(slide7, "Effect persists = Learned behavior / Habit formation",
              Inches(0.5), Inches(6), Inches(12), font_size=20, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)

# =============================================================================
# SLIDE 8: For & Against
# =============================================================================
slide8 = prs.slides.add_slide(prs.slide_layouts[6])
add_dark_background(slide8)

add_title_text(slide8, "The Trade-offs", Inches(0.3), font_size=40)

# Two columns
# FOR column
add_body_text(slide8, "FOR", Inches(1.5), Inches(1.3), Inches(5), font_size=28, color=ACCENT_GREEN, bold=True)

for_items = [
    "+2.6% success rate",
    "Statistically proven",
    "Higher engagement",
    "Lasting positive effect"
]
y = Inches(2)
for item in for_items:
    add_body_text(slide8, f"✓  {item}", Inches(1.5), y, Inches(5), font_size=20, color=WHITE)
    y += Inches(0.6)

# AGAINST column
add_body_text(slide8, "AGAINST", Inches(7.5), Inches(1.3), Inches(5), font_size=28, color=ACCENT_RED, bold=True)

against_items = [
    "May reduce challenge",
    "Boost dependency risk",
    "Unknown monetization",
    "Imperfect baseline"
]
y = Inches(2)
for item in against_items:
    add_body_text(slide8, f"✗  {item}", Inches(7.5), y, Inches(5), font_size=20, color=WHITE)
    y += Inches(0.6)

# Divider line
line = slide8.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(6.5), Inches(1.3), Pt(2), Inches(3.5))
line.fill.solid()
line.fill.fore_color.rgb = RGBColor(80, 80, 85)
line.line.fill.background()

# Bottom note
add_body_text(slide8, "Benefits outweigh risks with proper monitoring",
              Inches(0.5), Inches(5.5), Inches(12), font_size=18, color=GRAY, align=PP_ALIGN.CENTER)

# =============================================================================
# SLIDE 9: Recommendation
# =============================================================================
slide9 = prs.slides.add_slide(prs.slide_layouts[6])
add_dark_background(slide9)

add_title_text(slide9, "Recommendation", Inches(0.5), font_size=32, color=GRAY)
add_title_text(slide9, "ROLL IT OUT", Inches(1.5), font_size=72, bold=True, color=ACCENT_GREEN)

# Key reasons
reasons = [
    "Proven improvement in player success",
    "Higher engagement with boost feature",
    "Lasting positive behavioral effects"
]
y = Inches(3.5)
for reason in reasons:
    add_body_text(slide9, f"→  {reason}", Inches(2.5), y, Inches(8), font_size=22, color=WHITE)
    y += Inches(0.6)

# Monitor section
add_body_text(slide9, "With Monitoring:", Inches(2.5), Inches(5.5), Inches(8), font_size=18, color=GRAY, bold=True)
add_body_text(slide9, "Long-term retention  •  Monetization metrics  •  Difficulty balance",
              Inches(2.5), Inches(6), Inches(8), font_size=16, color=GRAY)

# =============================================================================
# SLIDE 10: Thank You / Questions
# =============================================================================
slide10 = prs.slides.add_slide(prs.slide_layouts[6])
add_dark_background(slide10)

add_title_text(slide10, "Questions?", Inches(2.5), font_size=56, color=WHITE)

# Summary metrics
add_body_text(slide10, "Summary", Inches(0.5), Inches(4), Inches(12), font_size=18, color=GRAY, align=PP_ALIGN.CENTER)

metrics = [
    ("+2.6%", "Success"),
    ("+51%", "Engagement"),
    ("✓", "Significant")
]
x_start = Inches(3)
for val, label in metrics:
    add_body_text(slide10, val, x_start, Inches(4.5), Inches(2.5), font_size=36, color=ACCENT_GREEN, bold=True, align=PP_ALIGN.CENTER)
    add_body_text(slide10, label, x_start, Inches(5.2), Inches(2.5), font_size=14, color=GRAY, align=PP_ALIGN.CENTER)
    x_start += Inches(2.5)

add_body_text(slide10, "Thank you!", Inches(0.5), Inches(6.5), Inches(12), font_size=20, color=GRAY, align=PP_ALIGN.CENTER)

# Save presentation
prs.save(OUTPUT_PATH)
print(f"Presentation saved to: {OUTPUT_PATH}")
