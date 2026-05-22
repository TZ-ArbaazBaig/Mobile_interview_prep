# mobile_interview_prep

---

## 📱 Project Overview

**mobile_interview_prep** is a Flutter‑based mobile application that helps developers practice technical interview questions.  It features:

- A mock interview flow with configurable question categories (Technical, Behavioral, System Design)
- Real‑time answer drafting with auto‑save
- Instant evaluation feedback and scoring
- A polished dark‑theme UI that follows the custom violet color palette you defined

---

## ✨ Features

- **Dynamic interview screen** – shows progress, category badge, and a multi‑line answer input.
- **Result dashboard** – displays a summary of scores and per‑question evaluation.
- **Local draft persistence** – answers are saved every few seconds, so you never lose work.
- **Theming** – custom `AppColors` (dark background, violet accents) for a premium look.

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (>=3.19) – install from [flutter.dev](https://flutter.dev)
- **Android Studio** or **Xcode** for device emulators
- **Git** for version control

### Installation

```bash
# Clone the repository
git clone https://github.com/TZ-ArbaazBaig/Mobile_interview_prep.git
cd Mobile_interview_prep

# Install Dart/Flutter dependencies
flutter pub get
```

### Running the App

```bash
# Run on an attached device or emulator
flutter run
```

> The app defaults to the dark theme defined in `app_colors.dart`.  You can toggle the theme in `main.dart` if desired.

---

## 🔧 Environment Variables

Create a `.env` file at the project root (it is already ignored by Git) and add the following keys:

```dotenv
VITE_CLERK_PUBLISHABLE_KEY=pk_test_cHJvLXRyb3V0LTUzLmNsZXJrLmFjY291bnRzLmRldiQ
VITE_API_URL=http://localhost:3005
```

These values are used by the interview service to communicate with the backend.

---

## 📂 Repository Structure

```
mobile_interview_prep/
├─ lib/
│  ├─ features/
│  │   ├─ dashboard/       # Results dashboard UI
│  │   ├─ interview/       # Interview flow screens & widgets
│  │   └─ new_session/     # Session creation UI
│  ├─ providers/           # State management (Riverpod/Provider)
│  └─ services/            # API client and business logic
├─ .gitignore              # Sensitive files like .env are ignored
└─ README.md               # ⇐ you are reading this file
```

---

## 📦 Deploying / Publishing

The app can be built for Android or iOS:

```bash
# Android APK
flutter build apk --release

# iOS bundle (macOS required)
flutter build ios --release
```

---

## 🙏 Contributing

Contributions are welcome!  Fork the repo, create a feature branch, and submit a pull request.  Please keep the dark‑theme styling consistent with the existing color palette.

---

## 📫 Contact

Feel free to open an issue on GitHub or reach out via the repository’s **Discussions** tab.

---

*Happy coding!*
