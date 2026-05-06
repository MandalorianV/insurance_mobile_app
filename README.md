# 🛡️ Insurance Mobile App

A Flutter MVP for managing active insurance policies and submitting damage claims — built as a case study for Crenno.

---

## 📁 Folder Structure

The project follows a **Feature-First** folder structure. Each feature is fully self-contained.

```
lib/
├── core/
│   ├── error/                  # AppError enum (noInternet, timeout, serverError, unknown)
│   ├── network/
│   │   ├── client/             # DioClient singleton
│   │   └── interceptor/        # MockInterceptor, ErrorInterceptor
│   ├── routes/                 # GoRouter configuration
│   └── widgets/                # Shared: shimmer skeletons, error widget, empty widget, no-internet view
├── features/
│   ├── insurance_dashboard/
│   │   ├── bloc/               # InsuranceBloc, InsuranceEvent, InsuranceState
│   │   ├── models/             # InsuranceModel (Freezed + json_serializable)
│   │   ├── repository/         # InsuranceRepository
│   │   ├── services/           # InsuranceServices (Dio calls)
│   │   ├── view/               # InsuranceView, InsuranceViewDetails
│   │   ├── view_mixin/         # InsuranceViewMixin, InsuranceViewDetailsMixin
│   │   └── widgets/            # InsuranceCard, ClaimRecordItem
│   ├── claim/
│   │   ├── bloc/               # ClaimBloc, ClaimEvent, ClaimState
│   │   ├── models/             # ClaimTypesModel, ClaimRecordModel (Freezed)
│   │   ├── repository/         # ClaimRepository
│   │   ├── services/           # ClaimServices
│   │   ├── view/               # ClaimView + ClaimViewMixin
│   │   └── widgets/            # ClaimHeader, ClaimStep1-3, ClaimStep2 variants,
│   │                           # ClaimBottomButton, ClaimSuccessScreen,
│   │                           # ClaimPhotoUpload, ClaimFormField, ClaimSummaryRow
│   └── settings/
│       └── view/               # SettingsView (theme + language switching)
├── theme/
│   ├── app_colors.dart         # AppColorTokens interface + ThemeLightColors / ThemeDarkColors
│   ├── theme_extension.dart    # BuildContext extensions: context.appColors, context.textTheme
│   ├── theme_manager.dart      # ThemeManager singleton (ChangeNotifier + SharedPreferences)
│   ├── theme_light.dart        # Full light ThemeData
│   └── theme_dark.dart         # Full dark ThemeData
└── main.dart
```

---

## 🧠 State Management — Flutter Bloc

**Bloc** (`flutter_bloc ^9.1.1`) was chosen for the following reasons:

- **Explicit state transitions** — every state change is driven by a typed event, making data flow easy to trace and debug.
- **Avoid unnecessary rebuilds** — `buildWhen` is used throughout so widgets only rebuild on the specific states they care about.
- **Listener / Builder separation** — `BlocListener` handles side effects (navigation, error dialogs); `BlocBuilder` handles UI rendering only.
- **Scalability** — the strict `Event → State` contract keeps complexity manageable as features grow.

### States use `sealed class` + `Equatable`

Both blocs define states as a `sealed class`, with each concrete state extending it. States implement **Equatable** so Bloc can skip re-emitting identical states and avoid redundant rebuilds.

```dart
@immutable
sealed class InsuranceState {}

final class GetInsuranceListState extends InsuranceState with EquatableMixin {
  final List<InsuranceModel> insuranceList;
  GetInsuranceListState({required this.insuranceList});

  @override
  List<Object?> get props => [insuranceList];
}
```

### RetryLastEvent pattern

Both `InsuranceBloc` and `ClaimBloc` implement a `RetryLastEvent` mechanism. The bloc stores a reference to the last dispatched event and re-dispatches it on retry — so error screens never need to know which operation failed.

```dart
InsuranceEvent? _lastEvent;

@override
void add(InsuranceEvent event) {
  if (event is! RetryLastEvent) _lastEvent = event;
  super.add(event);
}
```

### InsuranceBloc — Events & States

| Event | States emitted |
|---|---|
| `GetInsuranceListEvent` | `LoadingListState` → `GetInsuranceListState` / `InsuranceListEmptyState` / `InsuranceListErrorState` |
| `GetInsuranceRecordsEvent` | `LoadingRecordListState` → `GetInsuranceRecordsListState` / `InsuranceRecordsListEmptyState` / `InsuranceRecordsListErrorState` |
| `RetryLastEvent` | re-dispatches last event |

### ClaimBloc — Events & States

| Event | States emitted |
|---|---|
| `GetClaimTypesEvent` | `ClaimTypesLoading` → `GetClaimTypesState` / `ClaimTypesError` |
| `SelectDamageTypeEvent` | `SelectedDamageTypeState` |
| `ClaimStepUpEvent` | `ClaimStepUpState` |
| `SubmitClaimEvent` | `ClaimSubmitting` → `ClaimSubmissionSuccess` / `ClaimSubmissionError` |
| `GetClaimRecordsEvent` | `ClaimRecordsLoading` → `GetClaimRecords` / `ClaimRecordsError` |
| `GetClaimDetailEvent` | `ClaimDetailLoading` → `GetClaimDetail` / `ClaimDetailError` |
| `RetryLastEvent` | re-dispatches last event |

---

## 🏗️ Architecture Highlights

### View / Mixin Split
Every `StatefulWidget` is paired with a `mixin` that owns all controllers, state variables, and user interaction logic (e.g. `ClaimViewMixin`, `InsuranceViewMixin`). The `build` method stays focused purely on UI composition.

### Widget Decomposition
The claim flow is broken into focused, single-responsibility widgets under `features/claim/widgets/`:

- **`ClaimHeader`** — back button, policy title, 3-step progress bar
- **`ClaimStep1`** — damage type selector with `BlocBuilder` + validation error
- **`ClaimStep2Vehicle/Health/Home/Travel`** — per-category dynamic form fields
- **`ClaimStep3`** — contact info + pre-submission summary card
- **`ClaimBottomButton`** — gradient CTA with loading state
- **`ClaimSuccessScreen`** — post-submission confirmation with ref number
- **`ClaimPhotoUpload`** — photo grid with add/remove via `ValueNotifier`
- **`ClaimFormField`** — reusable validated text field
- **`ClaimSummaryRow`** — label/value row used in the summary card

### Repository Pattern
Each feature has a `Repository` that abstracts data access from the Bloc. The Bloc depends on the repository, not the service — keeping networking details isolated and swappable.

### Error Normalization
All Dio errors are mapped to a typed `AppError` enum (`noInternet`, `timeout`, `serverError`, `unknown`) in the `ErrorInterceptor`. Blocs always emit a typed `AppError`, never a raw exception.

---

## 🌐 Networking — Dio + MockInterceptor

**Dio** (`^5.9.2`) is used for all HTTP calls via a singleton `DioClient`.

Since this is an MVP, a `MockInterceptor` intercepts all requests before they hit the network and returns responses from local assets / device storage:

| Endpoint | Method | Data source |
|---|---|---|
| `/api/insurances` | GET | `assets/mock_data/{locale}/mock_insurance_dashboard.json` |
| `/api/claim-types` | GET | `assets/mock_data/{locale}/mock_data_claim_types.json` |
| `/api/claims` | POST | Writes to `mock_claim_records.json` in app documents dir |
| `/api/claims` | GET | Reads from `mock_claim_records.json` |
| `/api/insurance-records` | POST | Filters from `mock_claim_records.json` by `policyNo` |

All mock endpoints simulate real network latency with `Future.delayed`. The interceptor also reads the `Accept-Language` header to serve the correct locale's data.

> **Test scenarios built into MockInterceptor:**
> - Insurance `id: 2` (Health) → triggers `ClaimTypesError` (unknown error)
> - Insurance `id: 3` (Home) → triggers `ClaimSubmissionError` (server error)

---

## 🧭 Routing — GoRouter

**GoRouter** (`^17.0.0`) manages all navigation declaratively. The full route tree:

```
/                         → InsuranceView (dashboard)
├── /settings             → SettingsView
├── /insuranceDetails     → InsuranceViewDetails (extra: InsuranceModel)
│   └── /claim            → ClaimView (extra: InsuranceModel)
└── /noInternet           → NoInternetView (extra: AppError?)
```

Route definitions are centralized in `core/routes/router.dart`. Navigation logic never lives in widgets — views use `context.push` / `context.go` only.

---

## 🎨 Theming

The app uses a fully custom theme system built on top of Flutter's `ThemeData`:

- **`AppColorTokens`** — abstract interface defining all color tokens (`bg`, `card`, `accent`, `success`, `danger`, `textPrimary`, etc.)
- **`ThemeLightColors` / `ThemeDarkColors`** — concrete implementations of the interface
- **`ThemeExtension`** — exposes `context.appColors` and `context.textTheme` as `BuildContext` extensions for clean, type-safe access anywhere in the widget tree. No hardcoded `Color(...)` values in widgets.
- **`ThemeManager`** — a `ChangeNotifier` singleton that persists the selected theme to `SharedPreferences` and restores it on app launch

Switching theme at runtime (from `SettingsView`) calls `ThemeManager.changeTheme()`, which notifies the root `Consumer<ThemeManager>` and rebuilds `MaterialApp.router` with the new `ThemeData`.

---

## 🌍 Localization

Localization is handled by **easy_localization** (`^3.0.7`).

```
assets/
├── translations/
│   ├── en.json
│   └── tr.json
└── mock_data/
    ├── en/
    │   ├── mock_insurance_dashboard.json
    │   └── mock_data_claim_types.json
    └── tr/
        ├── mock_insurance_dashboard.json
        └── mock_data_claim_types.json
```

- Supports **Turkish** (default) and **English**
- All UI strings use `.tr()` — e.g. `'dashboard.error_title'.tr()`
- Mock API data is also localized — the `MockInterceptor` reads the `Accept-Language` header to serve the correct locale's JSON

Language can be switched at runtime from `SettingsView` via `context.setLocale(...)`.

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | `>=3.29.0` (built & tested on `3.29.0`) |
| Dart SDK | `^3.8.1` |

### Run the project

```bash
git clone https://github.com/your-username/insurance-mobile-app.git
cd insurance-mobile-app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

> `build_runner` generates the `.freezed.dart` and `.g.dart` files for Freezed models and json_serializable. Run this once after cloning, or whenever a model changes.

### Run on a specific device

```bash
flutter run -d ios
flutter run -d android
```

---

## 📦 Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `connectivity_plus` | `^7.1.1` | Network connectivity detection |
| `dio` | `^5.9.2` | HTTP client |
| `easy_localization` | `^3.0.7` | i18n / localization |
| `equatable` | `^2.0.8` | Value equality for Bloc states |
| `flutter_bloc` | `^9.1.1` | State management |
| `freezed_annotation` | `^3.1.0` | Annotations for Freezed |
| `go_router` | `^17.0.0` | Declarative routing |
| `image_picker` | `^1.2.1` | Photo upload in claim form |
| `json_annotation` | `^4.9.0` | Annotations for json_serializable |
| `path_provider` | `^2.1.5` | Local file storage for mock claim records |
| `provider` | `^6.1.5+1` | ThemeManager reactive propagation |
| `shimmer` | `^3.0.0` | Loading skeleton animations |

**Dev dependencies**

| Package | Version | Purpose |
|---|---|---|
| `bloc` | `^9.2.0` | Core bloc library (transitive, pinned for test consistency) |
| `bloc_test` | `^10.0.0` | `blocTest` helper for unit testing blocs |
| `build_runner` | `^2.7.1` | Code generation runner |
| `freezed` | `^3.2.3` | Immutable model & union type code generator |
| `json_serializable` | `^6.11.2` | JSON code generator |
| `mocktail` | `^1.0.5` | Mock & stub library for unit and repository tests |

---

## 🧪 Testing

The project has three layers of tests covering business logic, data access, and end-to-end user flows.

```
test/
└── features/
    └── claim/
        ├── claim_bloc_test.dart         # ClaimBloc unit tests
        └── claim_repository_test.dart   # ClaimRepository unit tests

integration_test/
└── app_test.dart                        # Full end-to-end claim submission flow
```

### Test layers

**Bloc tests** (`test/features/claim/claim_bloc_test.dart`) verify every event → state transition in isolation. The repository is replaced with a mock (`mocktail`) so no real I/O happens. Each test uses `bloc_test`'s `blocTest` helper to assert the exact sequence of emitted states.

**Repository tests** (`test/features/claim/claim_repository_test.dart`) verify that raw service responses are correctly mapped to domain models and that `DioException`s are normalized to the right `AppError` variant. The service is mocked so no network calls are made.

**Integration tests** (`integration_test/`) run the full app on a real device or emulator with `MockInterceptor` active. They drive the UI through complete user journeys — tapping, entering text, and asserting visible widgets — without any mocking at the widget level.

### Test isolation design

Each integration test starts a completely fresh app instance:

- A new `DioClient` (with `useMockInterceptor: true`) is created per test, so interceptor state never leaks between runs.
- A new `InsuranceBloc` is injected into `MainApp` via constructor, bypassing any previously accumulated bloc state.
- `GoRouter` is instantiated inside `_MainAppState` (via `createRouter()`) rather than as a global singleton, so route history is reset to `initialLocation: '/'` at the start of every test.
- `addTearDown(bloc.close)` guarantees the bloc is closed even if the test fails mid-way.

### Run the tests

**All unit tests:**

```bash
flutter test
```

**Bloc tests only:**

```bash
flutter test test/features/claim/claim_bloc_test.dart
```

**Repository tests only:**

```bash
flutter test test/features/claim/claim_repository_test.dart
```

**Integration tests** (requires a connected device or running emulator):

```bash
flutter test integration_test/app_test.dart
```

To run on a specific device:

```bash
flutter test integration_test/app_test.dart -d <device-id>
```

> Get available device IDs with `flutter devices`.

### Integration test coverage

| Test | Description |
|---|---|
| Full claim flow | Dashboard → policy detail → Step 1 (damage type) → Step 2 (date, location, description) → Step 3 (phone, summary) → success screen → back to dashboard |
| Step 1 validation | Tapping Next without selecting a damage type shows a validation error and stays on Step 1 |
| Step 2 validation | Tapping Next with empty required fields shows per-field validation errors and stays on Step 2 |

---

## 👤 Author
**MEHMET AKİF SAYRIM**

Built with ❤️ as a case study submission for **Crenno**.