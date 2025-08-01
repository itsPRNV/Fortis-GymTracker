# Gym Tracker App

A comprehensive Flutter gym tracker app with all the essential features for fitness enthusiasts.

## Features

### 🏋️ Workout Logging
- Select from pre-defined exercises or add custom ones
- Log sets, reps, weight, and duration
- Save custom workout routines
- Real-time workout tracking

### 📊 Progress Tracking
- Weekly/monthly workout charts using fl_chart
- Body metrics tracking (weight, BMI, body fat)
- Achievement badges and streaks
- Visual progress indicators

### 👤 User Profiles
- Personal goals and preferences
- Profile photo support
- Body metrics management
- Optional health data sync (Google Fit/Apple Health)

### ⏱️ Session Timer
- Stopwatch for workout timing
- Rest countdown timer with vibration cues
- Quick preset rest intervals
- Visual progress indicators

### 🌙 Dark/Light Mode
- System-based theme switching
- Manual theme selection
- Optimized for gym lighting conditions

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd gym_tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Dependencies

- **sqflite**: Local database storage
- **fl_chart**: Beautiful charts and graphs
- **provider**: State management
- **shared_preferences**: Settings persistence
- **image_picker**: Profile photo selection
- **vibration**: Haptic feedback for timers
- **health**: Health data integration (optional)

## Database Schema

The app uses SQLite for local data storage with the following tables:
- `exercises`: Exercise definitions
- `workouts`: Workout sessions
- `workout_exercises`: Exercises in workouts
- `workout_sets`: Individual sets data
- `users`: User profiles
- `body_metrics`: Body measurement history
- `achievements`: Achievement tracking

## Architecture

The app follows a clean architecture pattern with:
- **Models**: Data structures
- **Providers**: State management with Provider pattern
- **Services**: Database and external service interactions
- **Screens**: UI components
- **Widgets**: Reusable UI components

## Features in Detail

### Workout Logging
- Start a new workout with a custom name
- Add exercises from categorized lists
- Log multiple sets with reps, weight, and duration
- Real-time workout duration tracking

### Progress Tracking
- Visual charts showing workout frequency
- Body weight progression over time
- BMI calculation and tracking
- Achievement system with unlockable badges

### Timer Features
- Stopwatch for exercise timing
- Countdown timer for rest periods
- Vibration alerts when rest time is complete
- Quick preset buttons for common rest intervals

### User Profile
- Personal information management
- Goal setting and tracking
- Theme preferences
- Data backup options (placeholder)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Future Enhancements

- Cloud data synchronization
- Social features and workout sharing
- Advanced analytics and insights
- Nutrition tracking integration
- Workout plan templates
- Exercise video demonstrations