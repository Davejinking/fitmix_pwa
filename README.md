# Fitmix PWA - Smart Workout Planner

A Flutter-based progressive web app for workout planning and tempo training.

## 🏋️ Key Features

### 1. Workout Planning
- **Weekly Calendar**: Easily manage workout sessions by date.
- **Exercise Library**: Select exercises by body part.
- **Set Management**: Track weight, reps, and completion status.

### 2. 🎵 Tempo Training (Rhythm Engine)
Audio-guided resistance training to maintain perfect time under tension (TUT).

#### **Supported Modes**
1.  **TTS (English)**: Standard voice guide ("Up", "Down", "3, 2, 1, Go").
2.  **SFX (Sound Effects)**: Clean, generated chime/ding sounds for focus.
3.  **Voice (Custom Recording)**: **[New]** Record your own voice cues directly in the app!
4.  **Beep**: Tactile feedback and simple beeps.

#### **How to use Voice Recording**
1.  Go to **Plan Page** -> Tap **Tempo (Note Icon)** on an exercise card.
2.  Select **Voice** mode.
3.  Tap **"Record Voice"** (목소리 녹음하기).
4.  Record your cues for "3", "2", "1", "GO", "UP", "DOWN", etc.

---

## 🛠️ Project Structure

```
lib/
├── main.dart                  # Entry point
├── pages/
│   ├── plan_page.dart         # Workout planner (Main UI)
│   ├── voice_recorder_page.dart # Custom voice recording UI
│   └── ...
├── services/
│   ├── rhythm_engine.dart     # Audio engine (TTS/SFX/Voice/Beep logic)
│   ├── audio_recorder_service.dart # Microphone recording service
│   └── ...
├── utils/
│   └── sound_generator.dart   # Generates WAV assets (Beeps) at runtime
├── widgets/
│   ├── tempo_settings_modal.dart # Tempo configuration popup
│   └── ...
└── models/                    # Hive Data Models
```

---

## ⚠️ Configuration Requirements

To use the **Voice Recording** feature, you must configure microphone permissions in your native files.

### **Android** (`android/app/src/main/AndroidManifest.xml`)
Add the following permission inside the `<manifest>` tag:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### **iOS** (`ios/Runner/Info.plist`)
Add the following key-value pair inside the `<dict>` tag:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need access to the microphone to record your custom tempo cues.</string>
```
