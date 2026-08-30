# Project structure

Flutter Instagram-style, offline-first application with feature modules and local Dart packages.

```text
GI-Daily/
├── lib/                         # Application source
│   ├── app/                     # App shell, routing, configuration
│   ├── auth/                    # Authentication flow
│   ├── chats/                   # Conversations and messaging UI
│   ├── comments/                # Comment experiences
│   ├── feed/                    # Main feed
│   ├── home/                    # Home screen composition
│   ├── l10n/                    # Localized strings
│   ├── navigation/              # Navigation state and UI
│   ├── network_error/           # Offline/error presentation
│   ├── reels/                   # Short-video experience
│   ├── search/                  # Search screens
│   ├── selector/                # Theme and locale selectors
│   ├── stories/                 # Stories viewing and creation
│   ├── timeline/                # Timeline state and screens
│   ├── user_profile/            # User profile and editing
│   ├── bootstrap.dart           # Shared startup logic
│   └── main_{development,staging,production}.dart
├── packages/                    # Reusable Dart packages
│   ├── app_ui/                  # Shared app design primitives
│   ├── authentication_client/   # Authentication service client
│   ├── chats_repository/        # Chat data access
│   ├── database_client/         # Database integration
│   ├── env/                     # Environment configuration
│   ├── firebase_remote_config_repository/
│   ├── form_fields/             # Reusable form controls
│   ├── gallery_media_picker/    # Gallery selection
│   ├── image_picker_plus/       # Image picker extensions
│   ├── insta_blocks/            # Domain-level building blocks
│   ├── instagram_blocks_ui/     # Shared Instagram UI widgets
│   ├── notifications_client/    # Notification service client
│   ├── notifications_repository/
│   ├── posts_repository/        # Post data access
│   ├── powersync_repository/    # Offline synchronization
│   ├── search_repository/       # Search data access
│   ├── shared/                  # Cross-package utilities
│   ├── storage/                 # Local/persistent storage
│   ├── stories_editor/          # Story-editing components
│   ├── stories_repository/      # Story data access
│   └── user_repository/         # User data access
├── test/                        # App and widget tests
├── android/                     # Android runner and Gradle configuration
├── ios/                         # iOS runner and Xcode configuration
├── web/                         # Web entry point, manifest, icons
├── windows/                     # Windows runner and CMake configuration
├── scripts/                     # Setup, build, and APK helper scripts
├── tool/                        # Development utilities (including coverage)
├── screenshots/                 # UI reference screenshots and videos
├── claude/output-styles/        # Local output-style reference
├── .idea/ .mason/ .vscode/      # IDE and generator settings
├── pubspec.yaml                 # Root Flutter dependencies and configuration
├── analysis_options.yaml        # Dart lint configuration
├── build.yaml                   # Code-generation configuration
├── l10n.yaml                    # Localization generation configuration
├── README.md                    # Project documentation
└── MIGRATION.md                 # Migration notes
```

Git-specific project identifiers (`.git`, `.github`, and `.gitignore`) have been removed.
