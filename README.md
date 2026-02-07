# 📝 Mini TaskHub - Personal Task Tracker

A modern, feature-rich Flutter task management application built with **GetX** state management, **Supabase** backend, and **Hive** for offline caching. This project demonstrates clean architecture, responsive design, and real-time collaboration features.

![Flutter](https://img.shields.io/badge/Flutter-3.11.0-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11.0-blue?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-2.12.0-green?logo=supabase)
![GetX](https://img.shields.io/badge/GetX-4.7.3-purple)

---

## 🎯 Project Overview

**Mini TaskHub** is a comprehensive task tracking application that goes beyond basic CRUD operations. It includes:

- ✅ **Authentication** - Email/Password & Google Sign-In via Supabase
- ✅ **Task Management** - Create, Read, Update, Delete tasks with status tracking
- ✅ **Real-time Chat** - Group messaging and direct messages using Supabase Realtime
- ✅ **Offline Support** - Hive-based local caching for offline task access
- ✅ **Responsive UI** - Adaptive layouts for mobile, tablet, and desktop
- ✅ **Theme Support** - Light/Dark mode toggle with persistent preferences
- ✅ **Notifications** - Real-time task and message notifications
- ✅ **Calendar View** - Schedule and visualize tasks by date
- ✅ **Subtasks** - Break down tasks into manageable subtasks
- ✅ **Animations** - Smooth transitions and micro-interactions using `flutter_animate`

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point with theme configuration
├── app/
│   ├── core/                    # Core utilities and constants
│   ├── data/
│   │   ├── models/              # Data models (Task, Notification, Message, etc.)
│   │   │   ├── task_model.dart
│   │   │   ├── subtask_model.dart
│   │   │   ├── notification_model.dart
│   │   │   ├── message_model.dart
│   │   │   └── direct_message_model.dart
│   │   └── services/            # Data services
│   ├── modules/                 # Feature modules (GetX pattern)
│   │   ├── splash/              # Splash screen with animations
│   │   ├── signin/              # Login screen
│   │   ├── signup/              # Registration screen
│   │   ├── home/                # Main navigation container
│   │   ├── dashboard/           # Task dashboard
│   │   ├── new_task/            # Task creation
│   │   ├── task_details/        # Task details & editing
│   │   ├── task_list/           # Task list view
│   │   ├── schedule/            # Calendar view
│   │   ├── chat/                # Group chat
│   │   ├── direct_chat/         # Direct messaging
│   │   ├── messages/            # Message list
│   │   ├── notifications/       # Notifications center
│   │   └── profile/             # User profile & settings
│   ├── routes/
│   │   ├── app_pages.dart       # Route definitions
│   │   └── app_routes.dart      # Route constants
│   └── services/
│       ├── supabase_service.dart    # Supabase client & auth
│       ├── storage_service.dart     # Hive local storage
│       └── realtime_service.dart    # Realtime subscriptions
├── supabase/
│   └── migrations/              # Database schema migrations
│       ├── 20260205105930_initial_schema.sql
│       ├── 20260205_chat_tables.sql
│       ├── add_direct_messages.sql
│       └── add_messages_notifications.sql
└── test/
    └── models/                  # Model tests
```

---

## 🚀 Features Breakdown

### 1️⃣ Authentication System
- **Email/Password Authentication** using Supabase Auth
- **Google Sign-In** integration with proper OAuth flow
- **Session Management** with automatic token refresh
- **Session Validation** - Handles expired sessions gracefully
- **Auto-navigation** based on auth state

**Implementation:** `lib/app/services/supabase_service.dart`

### 2️⃣ Task Management
- **Create Tasks** with title, description, due date, and status
- **Update Tasks** - Edit task details and track progress
- **Delete Tasks** - Remove tasks with confirmation
- **Status Tracking** - Pending, In Progress, Completed
- **Progress Tracking** - Visual progress indicators (0-100%)
- **Subtasks** - Break tasks into smaller actionable items
- **Task Members** - Assign tasks to team members

**Models:** `lib/app/data/models/task_model.dart`, `lib/app/data/models/subtask_model.dart`

### 3️⃣ Real-time Features
- **Group Chat** - Create and join chat groups
- **Direct Messages** - One-on-one messaging
- **Real-time Updates** - Instant message delivery using Supabase Realtime
- **Typing Indicators** - See when others are typing
- **Message Notifications** - Get notified of new messages

**Implementation:** `lib/app/services/realtime_service.dart`

### 4️⃣ Offline Support
- **Hive Database** - Local caching of tasks and user data
- **Offline Access** - View cached tasks without internet
- **Sync on Reconnect** - Automatic data synchronization

**Implementation:** `lib/app/services/storage_service.dart`

### 5️⃣ UI/UX Excellence
- **Responsive Design** - Adaptive layouts for all screen sizes
- **Navigation Rail** - Desktop-optimized sidebar navigation
- **Bottom Navigation** - Mobile-friendly bottom bar
- **Smooth Animations** - Page transitions, button effects, and micro-interactions
- **Custom Theme** - Yellow accent (#FED36A) with dark/light modes
- **Google Fonts** - Poppins typography for modern aesthetics
- **Shimmer Loading** - Skeleton screens during data fetch

### 6️⃣ Additional Features
- **Calendar View** - Visualize tasks by date
- **Notifications Center** - Track task updates and mentions
- **Profile Management** - Update user info and preferences
- **Theme Toggle** - Switch between light and dark modes
- **Search & Filter** - Find tasks quickly

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.11.0 |
| **Language** | Dart 3.11.0 |
| **State Management** | GetX 4.7.3 |
| **Backend** | Supabase 2.12.0 |
| **Authentication** | Supabase Auth + Google Sign-In |
| **Database** | PostgreSQL (Supabase) |
| **Local Storage** | Hive Flutter 1.1.0 |
| **Real-time** | Supabase Realtime |
| **Animations** | flutter_animate 4.5.2 |
| **Fonts** | Google Fonts (Poppins) |
| **Icons** | Material Icons + Flutter SVG |
| **Image Caching** | cached_network_image 3.4.1 |
| **Loading Effects** | shimmer 3.0.0 |

---

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK 3.11.0 or higher
- Dart SDK 3.11.0 or higher
- Android Studio / VS Code with Flutter extensions
- A Supabase account (free tier works)

### Step 1: Clone the Repository
```bash
git clone <your-repo-url>
cd day_task
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Supabase Setup

#### 3.1 Create a Supabase Project
1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note your **Project URL** and **Anon Key** from Project Settings > API

#### 3.2 Run Database Migrations
Execute the SQL files in `supabase/migrations/` in order:

1. **Initial Schema** (`20260205105930_initial_schema.sql`)
   - Creates `profiles`, `tasks`, `subtasks`, `task_members` tables
   - Sets up Row Level Security (RLS) policies

2. **Chat Tables** (`20260205_chat_tables.sql`)
   - Creates `chat_groups`, `group_members`, `group_messages` tables
   - Configures RLS for chat features

3. **Direct Messages** (`add_direct_messages.sql`)
   - Creates `direct_messages` table
   - Sets up RLS for private messaging

4. **Notifications** (`add_messages_notifications.sql`)
   - Creates `notifications` table
   - Configures notification triggers

**How to run:**
- Go to Supabase Dashboard > SQL Editor
- Copy and paste each migration file
- Click "Run" for each file

#### 3.3 Configure Google Sign-In (Optional)
1. In Supabase Dashboard, go to **Authentication > Providers**
2. Enable **Google** provider
3. Add your OAuth credentials from Google Cloud Console
4. Add authorized redirect URIs

#### 3.4 Update Supabase Credentials
Open `lib/app/services/supabase_service.dart` and replace:

```dart
await Supabase.initialize(
  url: 'SUPABASE_URL',
  anonKey: 'SUPABASE_ANON_KEY',
);
```

### Step 4: Run the App
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome

# For Desktop (Linux/macOS/Windows)
flutter run -d linux
flutter run -d macos
flutter run -d windows
```

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Test Coverage
The project includes unit tests for:
- ✅ Task model serialization/deserialization
- ✅ Profile model data handling
- ✅ Subtask model validation

**Test Location:** `test/models/`

---

## 🎨 Design & UI

### Color Scheme
```dart
Primary Yellow: #FED36A
Dark Background: #212832
Dark Surface: #263238
Light Text: #FFFFFF
Dark Text: #191D21
Grey Text: #8CAAB9
```

### Typography
- **Font Family:** Poppins (Google Fonts)
- **Weights:** Regular (400), SemiBold (600), Bold (700)

### Responsive Breakpoints
- **Mobile:** < 600px (Bottom Navigation)
- **Tablet/Desktop:** ≥ 600px (Navigation Rail)

---

## 🔥 Hot Reload vs Hot Restart

### Hot Reload (⚡ Fast)
- **Shortcut:** `r` in terminal or `Ctrl+S` in IDE
- **Use Case:** UI changes, widget updates, styling tweaks
- **Speed:** ~1-2 seconds
- **Preserves State:** Yes

**Example:** Changing button color, text, or layout

### Hot Restart (🔄 Slower)
- **Shortcut:** `R` in terminal or `Ctrl+Shift+F5` in IDE
- **Use Case:** State changes, new dependencies, model updates
- **Speed:** ~5-10 seconds
- **Preserves State:** No (full app restart)

**Example:** Adding new packages, changing state management logic

### Full Restart (🔴 Slowest)
- **Shortcut:** Stop and run again
- **Use Case:** Native code changes, asset updates, platform-specific changes
- **Speed:** ~30-60 seconds

**Example:** Updating `pubspec.yaml` assets, Android/iOS native code

---

## 🏗️ Architecture & Design Patterns

### GetX Pattern (MVC)
Each feature module follows the GetX pattern:
```
feature/
├── bindings/          # Dependency injection
├── controllers/       # Business logic
└── views/            # UI components
```

### State Management
- **Reactive State:** `.obs` observables with `Obx()` widgets
- **Controllers:** Extend `GetxController` for lifecycle management
- **Services:** Singleton services using `Get.put()` and `Get.find()`

### Data Flow
```
View → Controller → Service → Supabase/Hive → Controller → View
```

---

## 🔐 Security Features

### Row Level Security (RLS)
All Supabase tables use RLS policies to ensure:
- Users can only access their own data
- Task members can view shared tasks
- Chat participants can only see their messages

### Authentication
- Secure token-based authentication
- Automatic session refresh
- Expired session handling
- OAuth 2.0 for Google Sign-In

---

## 🚧 Known Issues & Future Enhancements

### Current Limitations
- No task editing in offline mode (sync required)
- Limited file attachment support
- No push notifications (only in-app)

### Planned Features
- 🔔 Push notifications using FCM
- 📎 File attachments for tasks
- 🔍 Advanced search and filtering
- 📊 Analytics dashboard
- 🌐 Multi-language support
- 🎯 Task priorities and labels
- 📅 Recurring tasks

---

## 🤝 Contributing

This is an internship assignment project. Contributions are not currently required, but feedback is welcome!

---

## 📄 License

This project is created for educational purposes as part of a Flutter internship assignment.

---

## 👨‍💻 Developer

**Satyendra**  
📧 Email: satya@satyendra.in  
🔗 GitHub: [@s4tyendra](https://github.com/s4tyendra)  
💼 LinkedIn: [Your Name](https://linkedin.com/in/s4tyendra)

---

## 🙏 Acknowledgments

- **Supabase** for the amazing backend platform
- **GetX** for elegant state management
- **Flutter** team for the incredible framework
- **Techstax** for the opportunity to build this project

---

## 📞 Support

For questions or issues related to this assignment:
- Create an issue in the repository
- Contact via email: satya@satyendra.in

---

**Built with ❤️ using Flutter & Supabase**
