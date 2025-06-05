# 📱 Productivity Tracker App

![Flutter](https://img.shields.io/badge/Flutter-3.19-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-integrated-yellow?logo=firebase)
![Provider](https://img.shields.io/badge/State%20Management-Provider-green)
![MVVM](https://img.shields.io/badge/Architecture-MVVM-informational)

A modern productivity tracking app built with Flutter and Firebase. Designed to help users build better habits through daily tasks, long-term goals, stats, and social motivation.

---

## 🚀 Features

### 📅 Tasks & Notes
- Add, edit, complete, and delete daily tasks with intuitive UI
- Transfer tasks to the next day when not completed
- Attach personal notes to any day, and view/edit/delete/filter them easily
- Interactive calendar with swipe and tap gestures

### 📊 Productivity & Stats
- Track your **daily** and **average** productivity based on task completion
- Visualize progress with **dynamic charts** (daily, weekly, monthly)
- Realtime productivity updates and summaries

### 🎯 Goals & Achievements
- Define long-term goals split into smaller steps
- Mark steps as completed to auto-track goal progress
- Earn points and unlock achievements based on consistency
- Level up through a rank system tied to performance

### 👥 Social Features
- Add friends via email and manage friend requests
- View friends’ productivity and ranks
- Compete on a **ranking leaderboard** with your friends

### 🔐 Account Management
- Secure sign up, log in, and password reset via Firebase
- Push notifications for daily motivation and task reminders
- Settings panel to manage notifications, logout, or delete account

---

## 🛠 Tech Stack

* Dart: Programming language
* Flutter: UI development
* Firebase Auth: Authentication
* Cloud Firestore: Real-time data storage
* Firebase Messaging: Push notifications
* Provider: State management
* MVVM Architecture – Clean separation of UI, logic, and services

---

## 📂 Folder Structure

```
├── ui/               # UI widgets and pages
├── view_models/      # State management (Provider-based)
├── services/         # Firebase-related logic
├── domain/models/    # Data models
└── main.dart         # Entry point
```


---

## 📹 Video Previews

| Authentication                               | Daily Tasks                               | Global Goals                               | Profile                               |
| -------------------------------------------- | ----------------------------------------- | ------------------------------------------ | ------------------------------------- |
| [▶️ Watch](assets/videos/authentication.MOV) | [▶️ Watch](assets/videos/daily_tasks.MOV) | [▶️ Watch](assets/videos/global_goals.MOV) | [▶️ Watch](assets/videos/profile.MOV) |
> Note: Video playback depends on browser support for `.MOV` files. If video doesn't play, right-click and choose **Download**.

---

## 🎥 Video of Productivity Tracker App

Watch the full video of my App on Youtube.

[![Watch the full video of my App on Youtube](https://img.youtube.com/vi/WLHnAG0ZQ2U/0.jpg)](https://www.youtube.com/watch?v=WLHnAG0ZQ2U)


---

## 🚀 Getting Started

```bash
# Clone the repo
git clone https://github.com/romzesick/flutter_firebase_university_app.git
cd flutter_firebase_university_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

Make sure you have Flutter set up: [Flutter Setup Guide](https://flutter.dev/docs/get-started/install)

---

## 🔐 Firebase Setup (if needed)

If you fork the project and want to use Firebase:

1. Create a new Firebase project
2. Enable Email/Password authentication
3. Add your `google-services.json` and `GoogleService-Info.plist` to the appropriate directories
4. Use `flutterfire configure` if preferred

---

## 👨‍💻 Author

**Roman Harbatski**  
[GitHub](https://github.com/romzesick)
Feel free to open issues or suggest improvements!

---
