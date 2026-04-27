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
| `flutter_bloc` | `^9.1.1` | State management |
| `bloc` | `^9.2.0` | Core bloc library |
| `equatable` | `^2.0.8` | Value equality for Bloc states |
| `dio` | `^5.9.2` | HTTP client |
| `go_router` | `^17.0.0` | Declarative routing |
| `easy_localization` | `^3.0.7` | i18n / localization |
| `freezed` | `^3.2.3` | Immutable model & union type generation |
| `freezed_annotation` | `^3.1.0` | Annotations for Freezed |
| `json_annotation` | `^4.9.0` | Annotations for json_serializable |
| `image_picker` | `^1.2.1` | Photo upload in claim form |
| `shimmer` | `^3.0.0` | Loading skeleton animations |
| `connectivity_plus` | `^7.1.1` | Network connectivity detection |
| `provider` | `^6.1.5+1` | ThemeManager reactive propagation |
| `path_provider` | `^2.1.5` | Local file storage for mock claim records |

---

## 👤 Author
**MEHMET AKİF SAYRIM**

Built with ❤️ as a case study submission for **Crenno**.
