# Fitmix PWA - Smart Workout Planner

A Flutter-based progressive web app for workout planning and tempo training.

## 🏋️ Key Features

### 1. Workout Planning
- **Weekly Calendar**: Easily manage workout sessions by date.
- **Exercise Library**: Select exercises by body part.
- **Set Management**: Track weight, reps, and completion status.

### 2. 🎵 Tempo Training (Tempo Engine)
Audio-guided resistance training with precise timing and natural voice guidance.

#### **Features**
- ✅ **Precise Timing**: ±100ms accuracy using Stopwatch-based control
- ✅ **Natural Voice Guidance**: English TTS with smooth transitions
- ✅ **Visual Feedback**: Real-time phase display with color-coded stages
- ✅ **Haptic Feedback**: Vibration cues for each phase
- ✅ **Flexible Control**: Start/stop anytime during training

#### **How to use Tempo Training**
1. Go to **Workout Page** -> Start your workout
2. Complete a set and check the checkbox
3. Tap the **headphone icon** to start tempo guidance
4. Follow the audio cues:
   - **Countdown**: "3, 2, 1, GO"
   - **Eccentric (Down)**: "DOWN" + countdown
   - **Concentric (Up)**: "UP"
   - **Rep Announcement**: "ONE", "TWO", etc.
   - **Completion**: "SET COMPLETE"

#### **Configuration**
Set tempo parameters in **Tempo Settings Modal**:
- **Eccentric Time**: Duration for lowering (e.g., 3 seconds)
- **Concentric Time**: Duration for lifting (e.g., 1 second)
- **Enable/Disable**: Toggle tempo mode on/off per exercise

---

## 🛠️ Project Structure

```
lib/
├── main.dart                           # Entry point
├── pages/
│   ├── workout_page.dart               # Workout execution (Main UI)
│   ├── plan_page.dart                  # Workout planner
│   └── ...
├── services/
│   ├── tempo_engine.dart               # Tempo Engine (Core)
│   ├── rhythm_engine.dart              # Legacy rhythm engine
│   └── ...
├── widgets/
│   ├── workout/
│   │   ├── set_tile.dart               # Set item with tempo button
│   │   ├── tempo_display_overlay.dart  # Real-time phase display
│   │   └── ...
│   ├── tempo_settings_modal.dart       # Tempo configuration
│   └── ...
└── models/                             # Hive Data Models
```

---

## 📱 Tempo Engine Architecture

### Core Components

1. **TempoEngine** (`lib/services/tempo_engine.dart`)
   - Manages workout phases (countdown, eccentric, concentric, etc.)
   - Provides TTS voice guidance
   - Handles haptic feedback
   - Tracks timing with Stopwatch

2. **SetTile** (`lib/widgets/workout/set_tile.dart`)
   - Displays set information (weight × reps)
   - Headphone button to start tempo guidance
   - Loading indicator during tempo execution

3. **TempoDisplayOverlay** (`lib/widgets/workout/tempo_display_overlay.dart`)
   - Full-screen overlay showing current phase
   - Color-coded phase indicators
   - Pulse animation for visual feedback
   - Real-time rep counter

4. **WorkoutPage** (`lib/pages/workout_page.dart`)
   - Initializes TempoEngine
   - Manages tempo lifecycle
   - Displays overlay during training

### Phase Sequence

```
Countdown (3s)
  ↓
Rep Loop (for each rep):
  ├─ Eccentric Phase (DOWN + countdown)
  ├─ Concentric Phase (UP)
  └─ Rep Announcement (ONE, TWO, etc.)
  ↓
Completion (SET COMPLETE)
```

### Color Coding

- 🟠 **Countdown**: Orange
- 🔵 **Eccentric (Down)**: Blue
- 🟢 **Concentric (Up)**: Green
- 🟣 **Rep Announcement**: Purple
- 🔷 **Completion**: Cyan

---

## 📖 Documentation

For detailed information, see:
- [Tempo Engine Guide](doc/tempo_engine_guide.md) - Complete implementation guide
- [Project Status](doc/project_status.md) - Current progress and roadmap
