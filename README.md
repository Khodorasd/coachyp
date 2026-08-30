Coachy

A cross-platform Flutter app that connects clients with sports and fitness coaches — discover coaches nearby, follow their posts, book sessions and pay in-app.

Built with Flutter, Firebase and Stripe following Clean Architecture. Final-year Computer Science project,Beirut Arab University.

<img width="210" height="368" alt="Simulator Screenshot - iPhone 16 Pro Max - 2026-08-30 at 22 21 22" src="https://github.com/user-attachments/assets/9fe454f1-7668-4c0f-b52e-8cab953a6416" /> <img width="210" height="368" alt="Simulator Screenshot - iPhone 16 Pro Max - 2026-08-30 at 22 17 55" src="https://github.com/user-attachments/assets/e3ab2f1a-76b4-4c7a-9515-a8a0f4825775" /> <img width="210" height="368" alt="Simulator Screenshot - iPhone 16 Pro Max - 2026-08-30 at 22 20 16" src="https://github.com/user-attachments/assets/8ee1cbfe-dbcb-4d57-80e0-ee4d49ee1a35" />




Features
Authentication with email verification — Firebase Auth, with the app routing straight to the home screen for verified returning users and to login otherwise, driven by an authStateChanges listener rather than a manual session check.
Separate client and coach sign-up — different onboarding paths for the two sides of the marketplace.
Coach posts feed — coaches publish updates and clients browse them, backed by Cloud Firestore and Firebase Storage for media.
Location-aware discovery — Google Maps and device geolocation to find coaches by proximity.
In-app payments — Stripe via flutter_stripe.
Push notifications — Firebase Cloud Messaging for booking and message alerts.
Architecture

The app follows Clean Architecture, with each feature split into three layers:

lib/
├── features/
│   └── <feature>/
│       ├── data/          # remote data sources, repository implementations
│       ├── domain/        # entities, repository interfaces, use cases
│       └── presentation/  # screens, widgets, state
└── main.dart              # Firebase init, DI graph, auth-based routing

Dependencies are wired at the root with MultiProvider and ProxyProvider, composing each layer onto the one below it:

PostRemoteDataSource  →  PostRepository  →  FetchPosts / CreatePost  →  UI

Why this matters: the domain layer holds no Flutter or Firebase imports, so use cases like FetchPosts and CreatePost can be unit-tested without an emulator, and swapping Firestore for a different backend touches only the data layer.

Tech stack
Concern	Package
Framework	Flutter · Dart ^3.5.3
Auth	firebase_auth
Database	cloud_firestore
File storage	firebase_storage
Push notifications	firebase_messaging
Payments	flutter_stripe
Maps & location	google_maps_flutter, geolocator
State & DI	flutter_bloc, provider
UI	google_nav_bar, awesome_dialog, flutter_svg
Linting	flutter_lints

Platforms: Android · iOS · Web · Windows · macOS · Linux

Running locally
bash
git clone https://github.com/Khodorasd/coachyp.git
cd coachyp
flutter pub get

This project needs your own Firebase, Stripe and Google Maps credentials — none are committed.

1. Firebase

Create a project in the Firebase console
Enable Authentication (Email/Password), Cloud Firestore, Storage and Cloud Messaging
Generate the config: flutterfire configure
Add android/app/google-services.json and ios/Runner/GoogleService-Info.plist

2. Stripe

Add your publishable key where Stripe.publishableKey is set, and keep the secret key server-side — never in the client.

Run it

bash
flutter run
Status and known limitations

Active development · 31 commits.

Two state-management approaches coexist. provider handles dependency injection while flutter_bloc is used for feature state. Consolidating on one would simplify the codebase.
Payments run against Stripe test keys.
No automated test suite yet — the domain layer is structured for it, but the tests aren't written.
What I learned
Clean Architecture only pays off once you enforce the boundary. Wiring DataSource → Repository → UseCase through ProxyProvider forced the dependency direction to stay one-way, and made it obvious when a widget was reaching for Firestore directly.
Auth state is a stream, not a value. Reading the current user once at startup produced stale screens; listening to authStateChanges and gating on email verification fixed a class of bugs where signed-out users could still see cached content.
Integrating payments changes how you think about failure. With Stripe, a request that half-succeeds is a real state you have to design for, not an edge case to ignore.
Author

Khodor Assaad — MSc Artificial Intelligence (Robotics pathway), Berlin LinkedIn · Khoderassaad77@gmail.com
