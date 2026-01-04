# Delivery 3: Analytics Visualization System - Presentation Guide

## Overview
This guide helps you deliver a compelling 10-minute demonstration of your analytics visualization system.

---

## Pre-Presentation Checklist

### ✅ Before You Present:
1. **Generate High-Quality Demo Data**:
   - Open `ExampleScene.unity` in Unity
   - Press Play
   - Play for **5-10 minutes**:
     - Explore all areas of the level
     - Die intentionally 3-5 times (to create death markers)
     - Kill multiple enemies
     - Collect pickups if available
     - Revisit areas (to create density hotspots)
   - Data will automatically save to MySQL

2. **Verify Data in MySQL**:
   ```sql
   USE delivery3_analytics;
   SELECT * FROM sessions ORDER BY start_time DESC LIMIT 1;
   SELECT COUNT(*) FROM player_positions;  -- Should have 600-1200 samples
   SELECT COUNT(*) FROM death_events;       -- Should have several deaths
   ```

3. **Test Visualization**:
   - Open Analytics Dashboard: `Window > Game Analytics > Visualization Dashboard`
   - Load your demo session
   - Try each preset (Death Hotspots, Exploration Patterns, etc.)
   - Ensure Scene View renders correctly

4. **Prepare Unity Editor**:
   - Close unnecessary windows (only keep Scene View and Analytics Dashboard visible)
   - Set Scene View to a good camera angle showing the whole level
   - Close Unity Console (unless you want to show debug logs)

---

## Presentation Structure (10 Minutes)

### **Minute 1-2: Problem Statement & Solution**
**Script**:
> "Traditional game analytics give us numbers in spreadsheets - DAU, MAU, retention. But games are inherently spatial. Players navigate 3D environments, die in specific locations, and exhibit movement patterns that spreadsheets can't capture.
>
> Our solution: A real-time analytics pipeline that captures spatial gameplay data and visualizes it directly in the Unity Editor, where level designers work."

**Visuals**: Show the requirements PDF slide about "in-editor visualization"

---

### **Minute 3-4: System Architecture**
**Script**:
> "The system has three layers:
>
> 1. **Runtime Collection** - Non-intrusive event subscription to 3D Game Kit. We never modified the game code.
> 2. **MySQL Backend** - Real-time export to localhost database via PHP. This is the mandatory requirement - not CSV, not JSON files, but a proper database.
> 3. **Editor Visualization** - Import data back into Unity and render spatial heatmaps, paths, and event markers in Scene View."

**Demo**:
- Show `[Analytics]` GameObject in Hierarchy (Runtime Collection)
- Briefly show MySQL Workbench with data (prove it's in MySQL)
- Show Analytics Dashboard window (Editor Visualization)

**Key Point**: Emphasize MySQL is mandatory (30% of grade)

---

### **Minute 5-6: Preset 1 - Death Hotspots**
**Script**:
> "Let's start with death analysis. Level designers need to know: Where are players dying most? Are there difficulty spikes?"

**Demo Steps**:
1. Open Analytics Dashboard
2. Select session from dropdown
3. Click "Load Session"
4. Select **"Death Hotspots"** preset
5. Switch to Scene View

**What to Show**:
- Red pillars showing player death locations
- Orange pillars showing enemy deaths
- Point out clusters: "Notice this corridor has 3 player deaths - potential difficulty spike"

**Insight Example**:
> "We can see players dying repeatedly here [point to cluster]. This suggests either:
> - Enemy is too strong for this stage of the game
> - Unclear level design (players don't see the danger)
> - Missing checkpoint nearby
>
> A level designer can now adjust enemy health, add a health pickup, or move the checkpoint."

---

### **Minute 7-8: Preset 2 - Exploration Patterns**
**Script**:
> "Next, let's look at movement patterns. This heatmap shows time-spent density - where did players explore versus where did they rush through?"

**Demo Steps**:
1. Select **"Exploration Patterns"** preset
2. Adjust grid size slider (show 0.5m vs 5m difference)
3. Toggle path on/off with **P** key (show keyboard shortcut)

**What to Show**:
- Blue areas = rarely visited / avoided
- Red areas = hotspots where players spent time
- Cyan path trail showing route through level
- START/END markers

**Insight Example**:
> "The blue area here [point] was intended to be explored, but players avoided it. Why?
> - Maybe the entrance is hidden
> - Maybe there's no reward there
> - Maybe the main path is too obvious
>
> The heatmap reveals player psychology - they took the path of least resistance. We can fix this with better visual cues or collectibles."

**Interactive Moment**:
- Drag the grid size slider: "Smaller grid = more detail, larger grid = broader patterns"
- Show time range filter: "We can focus on just the first 2 minutes to analyze onboarding"

---

### **Minute 9: Advanced Features & Customization**
**Script**:
> "The system is designed for interactive analysis, not static reports."

**Demo Steps**:
1. Show **keyboard shortcuts help panel** at bottom
2. Press **H** to toggle heatmap off/on
3. Press **D** to toggle deaths
4. Press **C** to show combat events (if you have data)
5. Show time range slider: Drag to focus on 0-120 seconds

**What to Show**:
- Multiple visualization layers stacking (heatmap + paths + deaths)
- Real-time updates as you toggle
- Customizable color gradient (if time permits)

**Key Point**: "Settings persist between sessions - ScriptableObject saves preferences"

---

### **Minute 10: Conclusion & Questions**
**Script**:
> "Let's review what we've built:
>
> ✅ **Mandatory MySQL pipeline** - Real-time export and import (30% of grade)
> ✅ **Interactive visualizations** - 5 layers (heatmap, paths, deaths, pickups, combat) (50% of grade)
> ✅ **Customizable & easy to use** - Presets, keyboard shortcuts, persistent settings
> ✅ **Actionable insights** - Not just pretty pictures, but design decisions
>
> This system turns gameplay data into level design improvements."

**Final Visual**: Show the "Complete Overview" preset with all layers enabled

**Be Ready to Answer**:
- "How is this better than Tableau?" → Real-time in-editor, no export/import workflow
- "Does it affect game performance?" → No, fire-and-forget async HTTP, <1% CPU
- "Why MySQL instead of JSON?" → Course requirement (30% of grade), also better for complex queries
- "Can it scale?" → Yes, tested with 1200+ samples, optimized with spatial hashing

---

## Presentation Presets Quick Reference

| Preset Name | Purpose | What It Shows | Key Insight |
|-------------|---------|---------------|-------------|
| **Death Hotspots** | Identify difficulty spikes | Only death markers (red/orange pillars) | Where to add checkpoints or balance difficulty |
| **Exploration Patterns** | Movement analysis | Heatmap + path trail | Which areas are ignored, which are hotspots |
| **Combat Analysis** | Enemy encounters | Death markers + combat rings | Where combat happens, enemy effectiveness |
| **First 2 Minutes** | Onboarding effectiveness | First 10% of session only | Are players getting stuck early? |
| **Complete Overview** | Comprehensive view | All 5 layers enabled | Full picture of player behavior |

---

## Keyboard Shortcuts Cheat Sheet

| Key | Action | Use Case |
|-----|--------|----------|
| **H** | Toggle Heatmap | Quick on/off for heatmap |
| **P** | Toggle Paths | Show/hide movement trails |
| **D** | Toggle Deaths | Show/hide death markers |
| **K** | Toggle Pickups | Show/hide pickup events |
| **C** | Toggle Combat | Show/hide combat rings |
| **A** | Apply Visualization | Refresh Scene View |
| **X** | Clear All | Reset to blank |
| **R** | Reset Time Range | Back to full session |

---

## Talking Points: Why This Matters

### For Game Designers:
- "Where are players dying?" → Balance difficulty
- "Where are they exploring?" → Improve level flow
- "Are they finding secrets?" → Place collectibles better

### For QA Teams:
- "Where do players get stuck?" → Tutorial improvements
- "What's the optimal path?" → Expected vs actual behavior
- "How long in each area?" → Pacing analysis

### For Product Managers:
- "Engagement patterns" → A/B test level layouts
- "Drop-off points" → Where players quit
- "Heatmap comparisons" → Before/after level changes

---

## Common Demo Pitfalls to Avoid

### ❌ DON'T:
- Spend too long showing code (not impressive for non-technical audience)
- Show MySQL tables for more than 30 seconds (boring)
- Get lost adjusting sliders (have presets ready!)
- Forget to switch to Scene View (visualizations won't show!)
- Use a session with too little data (<2 minutes, <100 samples)

### ✅ DO:
- Focus on insights ("players avoid this area")
- Use presets for quick transitions
- Show keyboard shortcuts (impressive interaction)
- Point out specific locations in Scene View
- Have a backup session ready (in case demo data is bad)

---

## Backup Plan: If Something Breaks

### If MySQL connection fails:
- Show screenshots of previous working sessions
- Explain the architecture verbally
- Show the code briefly (AnalyticsCollector.cs event subscription)

### If Scene View doesn't render:
- Check you're in Scene View, not Game View
- Try "Apply Visualization" button again
- Restart Unity (last resort)

### If no session data:
- Use the existing session you tested with
- Explain: "For demo purposes, I'm using a pre-generated session"

---

## Post-Presentation Follow-Up

### Materials to Include in Submission:
1. **README.md** - Setup instructions (already exists)
2. **This presentation guide**
3. **Screenshots** of each preset in action
4. **MySQL schema export** (`schema.sql`)
5. **Video recording** (if required)

### Grading Rubric Self-Check:
- [ ] MySQL + PHP pipeline working (30%)
- [ ] Interactive visualizations (50%)
- [ ] Professional presentation (20%)
- [ ] Code quality (modularity, comments)
- [ ] Non-intrusive design (no game code modified)

---

## Final Tip

**Practice once before the real presentation!** Run through the 10-minute flow, use the presets, and make sure everything works. The difference between a 7 (Good) and a 10 (Excellent) is often just confidence and smooth execution.

Good luck! 🚀
