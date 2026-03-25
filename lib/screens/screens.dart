/// TSL Parivar Screens Library
///
/// This library exports all screen widgets organized by role and feature.
library;

// Authentication Screens
export 'auth/splash_screen.dart';
export 'auth/onboarding_screen.dart';
export 'auth/role_selection_screen.dart';
export 'auth/login_screen.dart';
export 'auth/otp_verification_screen.dart';

// Mistri (Field Worker) Screens
export 'mistri/mistri_shell_screen.dart';
export 'mistri/mistri_home_screen.dart';
export 'mistri/mistri_deliveries_screen.dart';
export 'mistri/mistri_delivery_details_screen.dart';
export 'mistri/mistri_pod_submission_screen.dart';
export 'mistri/mistri_rewards_screen.dart';
export 'mistri/mistri_request_order_screen.dart';

// Dealer (Distributor) Screens
export 'dealer/dealer_shell_screen.dart';
export 'dealer/dealer_home_screen.dart';
export 'dealer/dealer_mistris_screen.dart';
export 'dealer/dealer_orders_screen.dart';
export 'dealer/dealer_pending_approvals_screen.dart';
export 'dealer/dealer_rewards_screen.dart';

// Architect (Engineer) Screens
export 'architect/architect_shell_screen.dart';
export 'architect/architect_home_screen.dart';
export 'architect/architect_create_spec_screen.dart';
export 'architect/architect_projects_screen.dart';
export 'architect/architect_rewards_screen.dart';

// Shared Screens (All Roles)
export 'shared/notification_center_screen.dart';
export 'shared/chat_screen.dart';
export 'shared/profile_screen.dart';
export 'shared/product_catalog_screen.dart';
export 'shared/product_detail_screen.dart';
