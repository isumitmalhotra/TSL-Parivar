# TSL Parivar - Subtasks Summary

## Quick Overview

The main task has been divided into **9 Phases** with **153 Total Subtasks**.

---

## Phase Breakdown

### 📦 Phase 1: Design System & Foundation (14 tasks)
**Priority: CRITICAL - Build First**

1. **Project Structure Setup (3 tasks)**
   - Create folder structure
   - Set up dependencies in pubspec.yaml
   - Configure analysis options

2. **Design Tokens & Theme (6 tasks)**
   - Color palette (app_colors.dart)
   - Typography system (app_typography.dart)
   - Spacing constants (app_spacing.dart)
   - Border radius constants (app_radius.dart)
   - Theme configuration (app_theme.dart)
   - Shadows/elevation constants

3. **Localization Setup (5 tasks)**
   - Configure Flutter intl
   - Create English .arb file
   - Create Hindi .arb file
   - Set up localization delegate
   - Dynamic language switching

---

### 🧩 Phase 2: Shared Components Library (16 tasks)
**Priority: HIGH - Foundation for all screens**

1. **Core UI Components (10 tasks)**
   - TslAppBar
   - TslCard
   - TslStatusPill
   - TslPrimaryButton
   - TslSecondaryButton
   - TslSectionHeader
   - TslTag
   - TslEmptyState
   - TslLoadingState
   - TslLanguageToggle

2. **Form Components (6 tasks)**
   - TslTextField
   - TslDropdown
   - TslDatePicker
   - TslQuantityInput
   - TslPhotoCapture
   - TslLocationPicker

---

### 🔐 Phase 3: Authentication & Navigation (9 tasks)
**Priority: HIGH**

1. **Authentication Screens (5 tasks)**
   - Splash Screen
   - Onboarding Screen (3 slides)
   - Role Selection Screen
   - Login Screen
   - OTP Verification Screen

2. **Navigation Setup (4 tasks)**
   - Configure routing
   - Role-based navigation
   - Deep linking
   - Navigation guards

---

### 👷 Phase 4: Mistri (Field Worker) Screens (29 tasks)
**Priority: HIGH**

| Screen | Tasks |
|--------|-------|
| Mistri Home | 5 tasks |
| Mistri Deliveries | 4 tasks |
| Delivery Details | 6 tasks |
| POD Submission | 7 tasks |
| Mistri Rewards | 6 tasks |
| Request New Order | 8 tasks |

---

### 🏪 Phase 5: Dealer (Distributor) Screens (25 tasks)
**Priority: HIGH - Especially Pending Approvals**

| Screen | Tasks |
|--------|-------|
| Dealer Home | 6 tasks |
| Mistri Management | 5 tasks |
| Order Requests | 5 tasks |
| Pending Approvals ⚠️ CRITICAL | 8 tasks |
| Dealer Rewards | 5 tasks |

---

### 📐 Phase 6: Architect (Engineer) Screens (14 tasks)
**Priority: MEDIUM**

| Screen | Tasks |
|--------|-------|
| Architect Home | 6 tasks |
| Create Specification | 8 tasks |
| Projects List | 4 tasks |

---

### 🔄 Phase 7: Shared Features (16 tasks)
**Priority: MEDIUM**

| Feature | Tasks |
|---------|-------|
| Notification Center | 6 tasks |
| In-App Messaging | 5 tasks |
| Profile Screen | 6 tasks |

---

### 📊 Phase 8: State Management & Data (17 tasks)
**Priority: Can be built alongside screens**

| Category | Tasks |
|----------|-------|
| State Management Setup | 7 tasks |
| Mock Data | 6 tasks |
| Data Models | 7 tasks |

---

### ✨ Phase 9: Polish & Testing (13 tasks)
**Priority: Final phase**

| Category | Tasks |
|----------|-------|
| Error/Loading/Empty States | 3 tasks |
| Accessibility | 4 tasks |
| Performance Optimization | 4 tasks |
| Testing | 5 tasks |

---

## Recommended Build Order

```
Week 1-2: Phase 1 + Phase 2 (Design System + Components)
    ↓
Week 2-3: Phase 3 (Authentication & Navigation)
    ↓
Week 3-4: Phase 4 (All Mistri Screens)
    ↓
Week 4-5: Phase 5 (All Dealer Screens)
    ↓
Week 5-6: Phase 6 (All Architect Screens)
    ↓
Week 6-7: Phase 7 + Phase 8 (Shared Features + State)
    ↓
Week 7-8: Phase 9 (Polish & Testing)
```

---

## Key Dependencies

```
Phase 1 (Design System)
    └── Phase 2 (Components) [needs design tokens]
        └── Phase 3 (Auth) [needs components]
            └── Phases 4, 5, 6 (Role Screens) [needs navigation]
                └── Phase 7 (Shared Features) [needs screens]
                    └── Phase 9 (Polish) [needs all features]

Phase 8 (State/Data) can be built in parallel with Phases 3-7
```

---

## Files to Create

### lib/ Structure
```
lib/
├── main.dart
├── app.dart
├── design_system/
│   ├── app_colors.dart
│   ├── app_typography.dart
│   ├── app_spacing.dart
│   ├── app_radius.dart
│   ├── app_theme.dart
│   └── app_shadows.dart
├── widgets/
│   ├── tsl_app_bar.dart
│   ├── tsl_card.dart
│   ├── tsl_status_pill.dart
│   ├── tsl_primary_button.dart
│   ├── tsl_secondary_button.dart
│   ├── tsl_section_header.dart
│   ├── tsl_tag.dart
│   ├── tsl_empty_state.dart
│   ├── tsl_loading_state.dart
│   ├── tsl_language_toggle.dart
│   ├── tsl_text_field.dart
│   ├── tsl_dropdown.dart
│   ├── tsl_date_picker.dart
│   ├── tsl_quantity_input.dart
│   ├── tsl_photo_capture.dart
│   ├── tsl_location_picker.dart
│   ├── tsl_bottom_nav_bar.dart
│   └── tsl_tab_bar.dart
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── role_selection_screen.dart
│   │   ├── login_screen.dart
│   │   └── otp_screen.dart
│   ├── mistri/
│   │   ├── mistri_home_screen.dart
│   │   ├── mistri_deliveries_screen.dart
│   │   ├── delivery_details_screen.dart
│   │   ├── pod_submission_screen.dart
│   │   ├── mistri_rewards_screen.dart
│   │   └── request_order_screen.dart
│   ├── dealer/
│   │   ├── dealer_home_screen.dart
│   │   ├── mistri_management_screen.dart
│   │   ├── order_requests_screen.dart
│   │   ├── pending_approvals_screen.dart
│   │   └── dealer_rewards_screen.dart
│   ├── architect/
│   │   ├── architect_home_screen.dart
│   │   ├── create_specification_screen.dart
│   │   └── projects_list_screen.dart
│   └── shared/
│       ├── notifications_screen.dart
│       ├── messaging_screen.dart
│       └── profile_screen.dart
├── navigation/
│   ├── app_router.dart
│   └── route_names.dart
├── l10n/
│   ├── app_en.arb
│   ├── app_hi.arb
│   └── l10n.dart
├── providers/
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── delivery_provider.dart
│   ├── rewards_provider.dart
│   ├── notification_provider.dart
│   └── language_provider.dart
├── models/
│   ├── user_model.dart
│   ├── delivery_model.dart
│   ├── reward_model.dart
│   ├── order_model.dart
│   ├── notification_model.dart
│   ├── project_model.dart
│   └── message_model.dart
├── utils/
│   └── constants.dart
└── data/
    └── mock_data.dart
```

---

## How to Use This Task Tracker

1. **Start with Phase 1** - Complete all design system tasks first
2. **Update TASK_TRACKER.md** - Change ⬜ to 🔄 when starting, ✅ when done
3. **Work phase by phase** - Don't skip ahead unless tasks are independent
4. **Track blockers** - Note any issues in the tracker
5. **Update progress** - Keep the summary table current

---

## Getting Started Command

To begin development, let me know and I'll start with:
1. Creating the folder structure
2. Updating pubspec.yaml with dependencies
3. Building the design system files
4. Creating the first components

Just say **"Start Phase 1"** to begin!

