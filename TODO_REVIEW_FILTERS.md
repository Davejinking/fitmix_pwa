# IronLog Review Filters - TODO List

## ✅ Completed
- [x] 1️⃣ Date Range Selector
  - Preset ranges (Last 7/30 days, This month/year)
  - Custom range calendar with visual range selection
  - Immediate application, no confirmation buttons
  
- [x] 2️⃣ Exercise Selector
  - List of exercises with usage counts
  - Multi-selection support
  - Search functionality
  - Visual selection indicator (left blue bar)
  - Immediate application on close

## 🚧 In Progress / TODO

### 3️⃣ Condition (Meta-Sensing) Selector
**Design a condition-based review selector using only visual states.**

When the user taps "Condition":
- Show exactly three options:
  - Good (green)
  - Okay (yellow)
  - Low (red)

**Interaction rules:**
- Single selection only
- Tapping an option immediately applies the filter and closes the selector
- No text labels required beyond the option name
- No explanations, scales, or tooltips

**Filtering behavior:**
- Show only sessions that include the selected condition
- Calendar and log views should reflect the color pattern quietly
- Do not display any message explaining the meaning of the color

---

### 4️⃣ Decision (Meta-Cognition) Selector
**Design a decision-based review selector using symbolic choices.**

When the user taps "Decision":
- Show exactly three symbols:
  - ⭕ (Appropriate)
  - △ (Borderline)
  - ✕ (Too much)

**Interaction rules:**
- Single selection only
- Tapping a symbol immediately applies the filter and closes the selector
- Do not display explanatory text or judgment language

**Filtering behavior:**
- Show only sessions that include the selected decision
- Do not prompt the user to reflect or explain
- The symbol itself is the only indicator

---

### 5️⃣ Notes Filter
**Design a notes-based review toggle.**

When the user taps "Notes":
- Show a single option:
  - Has notes

**Interaction rules:**
- Single toggle-like selection
- Tapping applies immediately and returns to the log view
- No preview of note content
- No keyword or text search

**Filtering behavior:**
- Show only sessions that have at least one attached note
- Do not highlight or expand notes automatically

---

## 🔚 Overall Behavior (Critical)

**After any filter is applied:**
- Return to the existing Log View layout
- Do not show banners, toasts, or confirmation text
- The only feedback should be:
  - Reduced session list
  - Changed calendar dot patterns
  - Altered visual rhythm

**The user should feel that something changed, without being told what changed.**

---

## Implementation Notes

### Filter State Management
- Need to add filter state to LogScreenV2:
  - `DateTime? filterStartDate`
  - `DateTime? filterEndDate`
  - `Set<String> filterExercises`
  - `String? filterCondition` (good/okay/low)
  - `String? filterDecision` (appropriate/borderline/toomuch)
  - `bool filterHasNotes`

### Data Filtering Logic
- Modify `_loadData()` to apply active filters
- Filter sessions based on:
  - Date range
  - Exercise names
  - Condition value
  - Decision value
  - Note existence

### Visual Feedback
- Calendar dots should reflect filtered data
- Session list should show only matching sessions
- No UI indicators that filters are active (silent filtering)
- User discovers the change through visual rhythm

### Reset Filters
- Need a way to clear all filters
- Could be a subtle "Reset" option in the review modal
- Or a gesture (shake to reset?)

---

## Design Philosophy

**IronLog Review Filters follow these principles:**
1. **Immediate application** - No confirmation buttons
2. **Visual feedback only** - No text explanations
3. **Silent filtering** - The data speaks for itself
4. **Minimal UI** - Options are self-explanatory
5. **Respectful** - Never judge or prompt reflection
6. **Fast** - No loading states or transitions
7. **Discoverable** - Users learn through interaction

The filters are tools for pattern recognition, not performance tracking.
