import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'TSL Parivar'**
  String get appName;

  /// The tagline of the application
  ///
  /// In en, this message translates to:
  /// **'Heart of Building'**
  String get appTagline;

  /// Hero banner title text
  ///
  /// In en, this message translates to:
  /// **'Build Bold. Build Better. Build with TSL.'**
  String get heroBannerTitle;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Hindi language option
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get languageHindi;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// View all link text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get commonViewAll;

  /// View action text
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get commonView;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get commonNoResults;

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get commonGetStarted;

  /// Call button text
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get commonCall;

  /// Message button text
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get commonMessage;

  /// Navigate button text
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get commonNavigate;

  /// Assigned status
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get statusAssigned;

  /// In Progress status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Pending Approval status
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get statusPendingApproval;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Delivered status
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// Rejected status
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// Cancelled status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Onboarding screen 1 title
  ///
  /// In en, this message translates to:
  /// **'Welcome to TSL Parivar'**
  String get onboardingTitle1;

  /// Onboarding screen 1 description
  ///
  /// In en, this message translates to:
  /// **'Join the TSL family and be part of India\'s trusted construction material network.'**
  String get onboardingDesc1;

  /// Onboarding screen 2 title
  ///
  /// In en, this message translates to:
  /// **'Track & Deliver'**
  String get onboardingTitle2;

  /// Onboarding screen 2 description
  ///
  /// In en, this message translates to:
  /// **'Manage deliveries, track orders, and earn rewards for every successful delivery.'**
  String get onboardingDesc2;

  /// Onboarding screen 3 title
  ///
  /// In en, this message translates to:
  /// **'Grow Together'**
  String get onboardingTitle3;

  /// Onboarding screen 3 description
  ///
  /// In en, this message translates to:
  /// **'Build your career with TSL. More deliveries, more rewards, better future.'**
  String get onboardingDesc3;

  /// Role selection screen title
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get roleSelectionTitle;

  /// Role selection screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to use TSL Parivar'**
  String get roleSelectionSubtitle;

  /// Mistri role name
  ///
  /// In en, this message translates to:
  /// **'Mistri'**
  String get roleMistri;

  /// Mistri role description
  ///
  /// In en, this message translates to:
  /// **'Field worker delivering materials'**
  String get roleMistriDesc;

  /// Dealer role name
  ///
  /// In en, this message translates to:
  /// **'Dealer'**
  String get roleDealer;

  /// Dealer role description
  ///
  /// In en, this message translates to:
  /// **'Distributor managing orders & mistris'**
  String get roleDealerDesc;

  /// Architect role name
  ///
  /// In en, this message translates to:
  /// **'Architect'**
  String get roleArchitect;

  /// Architect role description
  ///
  /// In en, this message translates to:
  /// **'Engineer specifying materials for projects'**
  String get roleArchitectDesc;

  /// Role selection footer helper text
  ///
  /// In en, this message translates to:
  /// **'Select your role to continue'**
  String get roleSelectionFooter;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get loginSubtitle;

  /// Phone number input label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get loginPhoneLabel;

  /// Phone number input hint
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit mobile number'**
  String get loginPhoneHint;

  /// Send OTP button text
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get loginSendOtp;

  /// Phone validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit phone number'**
  String get loginPhoneError;

  /// Phone number required error
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get loginPhoneRequired;

  /// Fallback message when OTP send fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Please try again.'**
  String get loginSendOtpFailed;

  /// Country code picker informational message
  ///
  /// In en, this message translates to:
  /// **'Currently available in India only'**
  String get loginIndiaOnly;

  /// OTP screen title
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpTitle;

  /// OTP screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phoneNumber}'**
  String otpSubtitle(String phoneNumber);

  /// Verify OTP button text
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// Resend OTP button text
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get otpResend;

  /// Resend OTP countdown text
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds}s'**
  String otpResendIn(int seconds);

  /// OTP validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get otpError;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Deliveries navigation label
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get navDeliveries;

  /// Rewards navigation label
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get navRewards;

  /// Profile navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Orders navigation label
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// Mistris navigation label
  ///
  /// In en, this message translates to:
  /// **'Mistris'**
  String get navMistris;

  /// Projects navigation label
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

  /// Morning greeting (before 12 PM)
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greetingMorning;

  /// Afternoon greeting (12 PM - 5 PM)
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greetingAfternoon;

  /// Evening greeting (after 5 PM)
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greetingEvening;

  /// Greeting message on Mistri home
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String mistriHomeGreeting(String name);

  /// Reward points display
  ///
  /// In en, this message translates to:
  /// **'{points} Points'**
  String mistriHomeRewardPoints(int points);

  /// Approved points label
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get mistriHomeApprovedPoints;

  /// Pending points label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get mistriHomePendingPoints;

  /// Assigned dealer section title
  ///
  /// In en, this message translates to:
  /// **'Your Assigned Dealer'**
  String get mistriHomeAssignedDealer;

  /// Active deliveries section title
  ///
  /// In en, this message translates to:
  /// **'Active Deliveries'**
  String get mistriHomeActiveDeliveries;

  /// No deliveries message
  ///
  /// In en, this message translates to:
  /// **'No active deliveries'**
  String get mistriHomeNoDeliveries;

  /// Request order button text
  ///
  /// In en, this message translates to:
  /// **'Request New Order'**
  String get mistriHomeRequestOrder;

  /// Help button text
  ///
  /// In en, this message translates to:
  /// **'Help / Building Guide'**
  String get mistriHomeHelp;

  /// Expected delivery date
  ///
  /// In en, this message translates to:
  /// **'Expected: {date}'**
  String deliveryExpectedDate(String date);

  /// Distance to delivery location
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String deliveryDistance(String distance);

  /// View details button text
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get deliveryViewDetails;

  /// Mark reached button text
  ///
  /// In en, this message translates to:
  /// **'Mark Reached'**
  String get deliveryMarkReached;

  /// Submit proof button text
  ///
  /// In en, this message translates to:
  /// **'Submit Proof'**
  String get deliverySubmitProof;

  /// Message dealer button text
  ///
  /// In en, this message translates to:
  /// **'Message Dealer'**
  String get deliveryMessageDealer;

  /// POD screen title
  ///
  /// In en, this message translates to:
  /// **'Proof of Delivery'**
  String get podTitle;

  /// Delivery summary section title
  ///
  /// In en, this message translates to:
  /// **'Delivery Summary'**
  String get podDeliverySummary;

  /// Location verification section title
  ///
  /// In en, this message translates to:
  /// **'Location Verification'**
  String get podLocationVerification;

  /// Location verified status
  ///
  /// In en, this message translates to:
  /// **'Location verified'**
  String get podLocationVerified;

  /// Location warning message
  ///
  /// In en, this message translates to:
  /// **'You are {distance}m from delivery location'**
  String podLocationWarning(int distance);

  /// Photos section title
  ///
  /// In en, this message translates to:
  /// **'Photos (min. 2 required)'**
  String get podPhotos;

  /// Add photo button text
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get podAddPhoto;

  /// Assigned quantity label
  ///
  /// In en, this message translates to:
  /// **'Assigned Quantity'**
  String get podQuantityAssigned;

  /// Delivered quantity label
  ///
  /// In en, this message translates to:
  /// **'Delivered Quantity'**
  String get podQuantityDelivered;

  /// Issues section title
  ///
  /// In en, this message translates to:
  /// **'Report Issues (if any)'**
  String get podIssues;

  /// Notes section title
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get podNotes;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit Delivery Proof'**
  String get podSubmitDelivery;

  /// Rewards screen title
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsTitle;

  /// Reward balance section title
  ///
  /// In en, this message translates to:
  /// **'Reward Balance'**
  String get rewardsBalance;

  /// Rank section title
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get rewardsRank;

  /// Trusted mistri badge
  ///
  /// In en, this message translates to:
  /// **'TSL Trusted Mistri'**
  String get rewardsTrustedMistri;

  /// Earned tab label
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get rewardsTabEarned;

  /// Redeemed tab label
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get rewardsTabRedeemed;

  /// Pending tab label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get rewardsTabPending;

  /// Redeem button text
  ///
  /// In en, this message translates to:
  /// **'Redeem Points'**
  String get rewardsRedeem;

  /// No transactions message
  ///
  /// In en, this message translates to:
  /// **'No reward transactions yet'**
  String get rewardsNoTransactions;

  /// Request order screen title
  ///
  /// In en, this message translates to:
  /// **'Request New Order'**
  String get requestOrderTitle;

  /// Material type field label
  ///
  /// In en, this message translates to:
  /// **'Material Type'**
  String get requestOrderMaterial;

  /// Quantity field label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get requestOrderQuantity;

  /// Unit field label
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get requestOrderUnit;

  /// Location field label
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get requestOrderLocation;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Expected Delivery Date'**
  String get requestOrderDate;

  /// Urgency field label
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get requestOrderUrgency;

  /// Normal urgency option
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get requestOrderUrgencyNormal;

  /// Urgent urgency option
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get requestOrderUrgencyUrgent;

  /// ASAP urgency option
  ///
  /// In en, this message translates to:
  /// **'ASAP'**
  String get requestOrderUrgencyAsap;

  /// Customer name field label
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get requestOrderCustomerName;

  /// Customer phone field label
  ///
  /// In en, this message translates to:
  /// **'Customer Phone'**
  String get requestOrderCustomerPhone;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get requestOrderNotes;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get requestOrderSubmit;

  /// KPI label for mistris count
  ///
  /// In en, this message translates to:
  /// **'Total Mistris'**
  String get dealerHomeKpiMistris;

  /// KPI label for active deliveries
  ///
  /// In en, this message translates to:
  /// **'Active Deliveries'**
  String get dealerHomeKpiDeliveries;

  /// KPI label for pending approvals
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get dealerHomeKpiPending;

  /// KPI label for weekly volume
  ///
  /// In en, this message translates to:
  /// **'Weekly Volume'**
  String get dealerHomeKpiVolume;

  /// Loyalty points label
  ///
  /// In en, this message translates to:
  /// **'Loyalty Points'**
  String get dealerHomeLoyaltyPoints;

  /// Mistri pool label
  ///
  /// In en, this message translates to:
  /// **'Mistri Pool'**
  String get dealerHomeMistriPool;

  /// Top mistri section title
  ///
  /// In en, this message translates to:
  /// **'Top Performing Mistri'**
  String get dealerHomeTopMistri;

  /// Add mistri button text
  ///
  /// In en, this message translates to:
  /// **'Add Mistri'**
  String get dealerHomeAddMistri;

  /// Assign delivery button text
  ///
  /// In en, this message translates to:
  /// **'Assign Delivery'**
  String get dealerHomeAssignDelivery;

  /// Mistri management screen title
  ///
  /// In en, this message translates to:
  /// **'Mistri Management'**
  String get mistriMgmtTitle;

  /// Add new mistri button
  ///
  /// In en, this message translates to:
  /// **'Add New Mistri'**
  String get mistriMgmtAddNew;

  /// Active filter option
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get mistriMgmtFilterActive;

  /// Inactive filter option
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get mistriMgmtFilterInactive;

  /// Delivery count
  ///
  /// In en, this message translates to:
  /// **'{count} deliveries'**
  String mistriMgmtDeliveries(int count);

  /// Success rate
  ///
  /// In en, this message translates to:
  /// **'{rate}% success'**
  String mistriMgmtSuccessRate(int rate);

  /// Assign button text
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get mistriMgmtAssign;

  /// Order requests screen title
  ///
  /// In en, this message translates to:
  /// **'Order Requests'**
  String get orderRequestsTitle;

  /// New requests tab
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get orderRequestsTabNew;

  /// All requests tab
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get orderRequestsTabAll;

  /// History tab
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get orderRequestsTabHistory;

  /// Approve button
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get orderRequestsApprove;

  /// Reject button
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get orderRequestsReject;

  /// Request info button
  ///
  /// In en, this message translates to:
  /// **'Request Info'**
  String get orderRequestsRequestInfo;

  /// Rejection reason title
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get orderRequestsRejectReason;

  /// No requests message
  ///
  /// In en, this message translates to:
  /// **'No order requests'**
  String get orderRequestsNoRequests;

  /// Pending approvals screen title
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get pendingApprovalsTitle;

  /// Photo gallery section
  ///
  /// In en, this message translates to:
  /// **'Photo Gallery'**
  String get pendingApprovalsPhotoGallery;

  /// Map view section
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get pendingApprovalsMapView;

  /// Assigned location label
  ///
  /// In en, this message translates to:
  /// **'Assigned Location'**
  String get pendingApprovalsAssignedLocation;

  /// Submitted location label
  ///
  /// In en, this message translates to:
  /// **'Submitted Location'**
  String get pendingApprovalsSubmittedLocation;

  /// Distance label
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance}m'**
  String pendingApprovalsDistance(int distance);

  /// Mistri notes section
  ///
  /// In en, this message translates to:
  /// **'Mistri Notes'**
  String get pendingApprovalsMistriNotes;

  /// Issues reported section
  ///
  /// In en, this message translates to:
  /// **'Issues Reported'**
  String get pendingApprovalsIssuesReported;

  /// Reward calculation section
  ///
  /// In en, this message translates to:
  /// **'Reward Calculation'**
  String get pendingApprovalsRewardCalc;

  /// Base points label
  ///
  /// In en, this message translates to:
  /// **'Base Points'**
  String get pendingApprovalsBasePoints;

  /// Bonus points label
  ///
  /// In en, this message translates to:
  /// **'Bonus Points'**
  String get pendingApprovalsBonusPoints;

  /// Total points label
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get pendingApprovalsTotalPoints;

  /// Approve button
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get pendingApprovalsApprove;

  /// No approvals message
  ///
  /// In en, this message translates to:
  /// **'No pending approvals'**
  String get pendingApprovalsNoApprovals;

  /// Active projects KPI
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get architectHomeProjects;

  /// Specifications KPI
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get architectHomeSpecs;

  /// Connected dealers section
  ///
  /// In en, this message translates to:
  /// **'Connected Dealers'**
  String get architectHomeConnectedDealers;

  /// Recent specs section
  ///
  /// In en, this message translates to:
  /// **'Recent Specifications'**
  String get architectHomeRecentSpecs;

  /// Create spec button
  ///
  /// In en, this message translates to:
  /// **'Create Specification'**
  String get architectHomeCreateSpec;

  /// New project button
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get architectHomeNewProject;

  /// Create spec screen title
  ///
  /// In en, this message translates to:
  /// **'Create Specification'**
  String get createSpecTitle;

  /// Project name field
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get createSpecProjectName;

  /// Project type field
  ///
  /// In en, this message translates to:
  /// **'Project Type'**
  String get createSpecProjectType;

  /// Housing project type
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get createSpecTypeHousing;

  /// Commercial project type
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get createSpecTypeCommercial;

  /// Industrial project type
  ///
  /// In en, this message translates to:
  /// **'Industrial'**
  String get createSpecTypeIndustrial;

  /// Railways project type
  ///
  /// In en, this message translates to:
  /// **'Railways'**
  String get createSpecTypeRailways;

  /// Material field
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get createSpecMaterial;

  /// Grade field
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get createSpecGrade;

  /// Dealers field
  ///
  /// In en, this message translates to:
  /// **'Associated Dealers'**
  String get createSpecDealers;

  /// Location field
  ///
  /// In en, this message translates to:
  /// **'Project Location'**
  String get createSpecLocation;

  /// Timeline field
  ///
  /// In en, this message translates to:
  /// **'Expected Timeline'**
  String get createSpecTimeline;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create Specification'**
  String get createSpecCreate;

  /// Save draft button
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get createSpecSaveDraft;

  /// Projects screen title
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// No projects message
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get projectsNoProjects;

  /// Notifications screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// All filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsFilterAll;

  /// Delivery filter
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get notificationsFilterDelivery;

  /// Reward filter
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get notificationsFilterReward;

  /// Order filter
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get notificationsFilterOrder;

  /// System filter
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notificationsFilterSystem;

  /// Mark as read option
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get notificationsMarkRead;

  /// Mark as unread option
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get notificationsMarkUnread;

  /// No notifications message
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsNoNotifications;

  /// No description provided for @notificationsFilterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by type'**
  String get notificationsFilterByType;

  /// No notifications for selected filter
  ///
  /// In en, this message translates to:
  /// **'No {type} notifications'**
  String notificationsNoFiltered(String type);

  /// No description provided for @notificationsAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get notificationsAllCaughtUp;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String notificationsSelectedCount(int count);

  /// No description provided for @notificationsUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String notificationsUnreadCount(int count);

  /// No description provided for @notificationsTotalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String notificationsTotalCount(int count);

  /// No description provided for @notificationsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Notifications'**
  String get notificationsDeleteTitle;

  /// No description provided for @notificationsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected notifications?'**
  String notificationsDeleteConfirm(int count);

  /// No description provided for @notificationsRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notificationsRead;

  /// No description provided for @notificationsJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationsJustNow;

  /// No description provided for @notificationsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get notificationsOpen;

  /// No description provided for @notificationsSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationsSettings;

  /// No description provided for @notificationsTypes.
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationsTypes;

  /// No description provided for @notificationsDeliveryUpdates.
  ///
  /// In en, this message translates to:
  /// **'Delivery Updates'**
  String get notificationsDeliveryUpdates;

  /// No description provided for @notificationsRewardsPoints.
  ///
  /// In en, this message translates to:
  /// **'Rewards & Points'**
  String get notificationsRewardsPoints;

  /// No description provided for @notificationsSystemAlerts.
  ///
  /// In en, this message translates to:
  /// **'System Alerts'**
  String get notificationsSystemAlerts;

  /// No description provided for @notificationsSoundVibration.
  ///
  /// In en, this message translates to:
  /// **'Sound & Vibration'**
  String get notificationsSoundVibration;

  /// No description provided for @notificationsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get notificationsSound;

  /// No description provided for @notificationsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get notificationsVibration;

  /// No description provided for @notificationsSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get notificationsSettingsSaved;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// Notifications setting
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// Privacy setting
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get profilePrivacy;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// Logout confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profileLogoutConfirm;

  /// Version display
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String profileVersion(String version);

  /// TSL 550 SD material
  ///
  /// In en, this message translates to:
  /// **'TSL 550 SD'**
  String get materialTsl550sd;

  /// Girders material
  ///
  /// In en, this message translates to:
  /// **'Girders'**
  String get materialGirders;

  /// Angles material
  ///
  /// In en, this message translates to:
  /// **'Angles'**
  String get materialAngles;

  /// Channels material
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get materialChannels;

  /// Pipes material
  ///
  /// In en, this message translates to:
  /// **'Pipes'**
  String get materialPipes;

  /// Wires material
  ///
  /// In en, this message translates to:
  /// **'Wires'**
  String get materialWires;

  /// Colour Sheets material
  ///
  /// In en, this message translates to:
  /// **'Colour Sheets'**
  String get materialColourSheets;

  /// Tons unit
  ///
  /// In en, this message translates to:
  /// **'Tons'**
  String get unitTons;

  /// Kg unit
  ///
  /// In en, this message translates to:
  /// **'Kg'**
  String get unitKg;

  /// Pieces unit
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get unitPieces;

  /// Bundles unit
  ///
  /// In en, this message translates to:
  /// **'Bundles'**
  String get unitBundles;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateTitle;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'Check back later for updates'**
  String get emptyStateMessage;

  /// Network error title
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get errorNetworkTitle;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again'**
  String get errorNetworkMessage;

  /// Server error title
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get errorServerTitle;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Please try again later.'**
  String get errorServerMessage;

  /// Unknown error title
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get errorUnknownTitle;

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened. Please try again.'**
  String get errorUnknownMessage;

  /// App version display
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// Select language prompt
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Call dealer dialog title
  ///
  /// In en, this message translates to:
  /// **'Call Dealer'**
  String get callDealer;

  /// Call confirmation message
  ///
  /// In en, this message translates to:
  /// **'Call {phone}?'**
  String callConfirm(String phone);

  /// Navigate dialog title
  ///
  /// In en, this message translates to:
  /// **'Navigate to Dealer'**
  String get navigateToDealer;

  /// Navigate confirmation
  ///
  /// In en, this message translates to:
  /// **'Open maps to navigate to:\n{address}'**
  String navigateConfirm(String address);

  /// Deliveries screen title
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveriesTitle;

  /// Search deliveries placeholder
  ///
  /// In en, this message translates to:
  /// **'Search deliveries...'**
  String get searchDeliveries;

  /// Search projects placeholder
  ///
  /// In en, this message translates to:
  /// **'Search projects...'**
  String get searchProjects;

  /// Search mistris placeholder
  ///
  /// In en, this message translates to:
  /// **'Search mistris...'**
  String get searchMistris;

  /// No deliveries empty state
  ///
  /// In en, this message translates to:
  /// **'No Deliveries Found'**
  String get noDeliveriesFound;

  /// Delivery details title
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get deliveryDetails;

  /// Customer details section
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// Delivery progress section
  ///
  /// In en, this message translates to:
  /// **'Delivery Progress'**
  String get deliveryProgress;

  /// Product details section
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// All status filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// New status
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// Active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// On hold status
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get statusOnHold;

  /// Draft status
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// Inactive status
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// History tab label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No projects empty state
  ///
  /// In en, this message translates to:
  /// **'No Projects Found'**
  String get noProjectsFound;

  /// Create project button
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get createProject;

  /// New project button
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// Clear search button
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// My projects title
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get myProjects;

  /// Location label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Material specifications section
  ///
  /// In en, this message translates to:
  /// **'Material Specifications'**
  String get materialSpecifications;

  /// No specifications message
  ///
  /// In en, this message translates to:
  /// **'No specifications yet'**
  String get noSpecificationsYet;

  /// Associated dealers section
  ///
  /// In en, this message translates to:
  /// **'Associated Dealers'**
  String get associatedDealers;

  /// No dealers message
  ///
  /// In en, this message translates to:
  /// **'No dealers associated'**
  String get noDealersAssociated;

  /// Points earned label
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get pointsEarned;

  /// Add specification button
  ///
  /// In en, this message translates to:
  /// **'Add Spec'**
  String get addSpec;

  /// Empty notifications
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// This week label
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Earlier label
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// Chat/messaging title
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatTitle;

  /// Conversation search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get chatSearchConversations;

  /// No conversations empty title
  ///
  /// In en, this message translates to:
  /// **'No Conversations'**
  String get chatNoConversations;

  /// Unread chats count
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String chatNewCount(int count);

  /// Total chat conversations count
  ///
  /// In en, this message translates to:
  /// **'{count} conversations'**
  String chatConversationCount(int count);

  /// New conversation button
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get newConversation;

  /// Type message placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// Online status
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Offline status
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No messages empty state
  ///
  /// In en, this message translates to:
  /// **'No Messages Yet'**
  String get noMessages;

  /// Start conversation prompt
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startConversation;

  /// Edit profile title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Fallback when profile field is unset
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileNotSet;

  /// Member since label
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get profileMemberSince;

  /// Unknown fallback label
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get profileUnknown;

  /// Success stat label
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get profileSuccess;

  /// Volume stat label
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get profileVolume;

  /// ID card quick action title
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get profileIdCard;

  /// ID card quick action subtitle
  ///
  /// In en, this message translates to:
  /// **'View your TSL ID'**
  String get profileViewTslId;

  /// Activity quick action title
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get profileActivity;

  /// Enabled value
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get profileEnabled;

  /// Disabled value
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get profileDisabled;

  /// On value
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get profileOn;

  /// Off value
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get profileOff;

  /// Profile support contact row
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get profileContactSupport;

  /// Rate app row
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get profileRateApp;

  /// Share app row
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get profileShareApp;

  /// Profile version text
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 (Build 1)'**
  String get profileBuildVersion;

  /// Profile copyright text
  ///
  /// In en, this message translates to:
  /// **'© 2024 TSL Steel. All rights reserved.'**
  String get profileCopyright;

  /// QR dialog title
  ///
  /// In en, this message translates to:
  /// **'Your TSL QR Code'**
  String get profileYourQrCode;

  /// ID field prefix
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get profileIdPrefix;

  /// Share QR code button
  ///
  /// In en, this message translates to:
  /// **'Share QR Code'**
  String get profileShareQrCode;

  /// Share ID card button
  ///
  /// In en, this message translates to:
  /// **'Share ID Card'**
  String get profileShareIdCard;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// City field label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profileCity;

  /// Full address field label
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get profileFullAddress;

  /// Save profile changes button
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSaveChanges;

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Dark mode toggle
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Biometric auth toggle
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuth;

  /// Terms of service
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// About app
  ///
  /// In en, this message translates to:
  /// **'About TSL Parivar'**
  String get aboutApp;

  /// Logout confirmation title
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// Assign delivery button
  ///
  /// In en, this message translates to:
  /// **'Assign Delivery'**
  String get assignDelivery;

  /// Add mistri button
  ///
  /// In en, this message translates to:
  /// **'Add Mistri'**
  String get addMistri;

  /// Mistri name field
  ///
  /// In en, this message translates to:
  /// **'Mistri Name'**
  String get mistriName;

  /// Phone number field
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Specialization field
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// Added successfully message
  ///
  /// In en, this message translates to:
  /// **'Added successfully!'**
  String get addedSuccessfully;

  /// Review PODs button
  ///
  /// In en, this message translates to:
  /// **'Review PODs'**
  String get reviewPods;

  /// Building guide button
  ///
  /// In en, this message translates to:
  /// **'Building Guide'**
  String get buildingGuide;

  /// Help and support
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Messages notification filter
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notificationsFilterMessage;

  /// Redeem points button
  ///
  /// In en, this message translates to:
  /// **'Redeem Points'**
  String get redeemPoints;

  /// Distribute points button
  ///
  /// In en, this message translates to:
  /// **'Distribute Points'**
  String get distributePoints;

  /// Dealer rewards title
  ///
  /// In en, this message translates to:
  /// **'Dealer Rewards'**
  String get dealerRewardsTitle;

  /// Architect rewards title
  ///
  /// In en, this message translates to:
  /// **'Architect Rewards'**
  String get architectRewardsTitle;

  /// Distributed tab
  ///
  /// In en, this message translates to:
  /// **'Distributed'**
  String get tabDistributed;

  /// All tab
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// How it works button
  ///
  /// In en, this message translates to:
  /// **'How it Works'**
  String get howItWorks;

  /// Refer friend button
  ///
  /// In en, this message translates to:
  /// **'Refer a Friend'**
  String get referFriend;

  /// Order requests description
  ///
  /// In en, this message translates to:
  /// **'Select a mistri to assign a new delivery'**
  String get orderRequestsDescription;

  /// Terms agreement prefix
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get byPhoneAuth;

  /// And conjunction
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andText;

  /// OTP sent confirmation
  ///
  /// In en, this message translates to:
  /// **'OTP sent to {phone}'**
  String otpSentTo(String phone);

  /// Resend OTP countdown
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds}s'**
  String resendOtpIn(int seconds);

  /// Wrong number link
  ///
  /// In en, this message translates to:
  /// **'Wrong number?'**
  String get wrongNumber;

  /// Change number link
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeNumber;

  /// Verifying OTP state
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// Project name hint
  ///
  /// In en, this message translates to:
  /// **'Enter project name'**
  String get projectNameHint;

  /// Select dealers label
  ///
  /// In en, this message translates to:
  /// **'Select Dealers'**
  String get selectDealers;

  /// Project location hint
  ///
  /// In en, this message translates to:
  /// **'Enter project location'**
  String get projectLocationHint;

  /// Expected delivery date
  ///
  /// In en, this message translates to:
  /// **'Expected Delivery'**
  String get expectedDelivery;

  /// Summary section
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// Step label
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String step(int number);

  /// Minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String agoMinutes(int minutes);

  /// Hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String agoHours(int hours);

  /// Days ago
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String agoDays(int days);

  /// Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Quantity with unit
  ///
  /// In en, this message translates to:
  /// **'{quantity} {unit}'**
  String quantityUnit(String quantity, String unit);

  /// No search results
  ///
  /// In en, this message translates to:
  /// **'No results match your search'**
  String get noMatchSearch;

  /// Create first project hint
  ///
  /// In en, this message translates to:
  /// **'Start by creating a new project'**
  String get startByCreating;

  /// Approve order button
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveOrder;

  /// Reject order button
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectOrder;

  /// More info button
  ///
  /// In en, this message translates to:
  /// **'More Info'**
  String get moreInfo;

  /// Order approved snackbar
  ///
  /// In en, this message translates to:
  /// **'Order approved!'**
  String get orderApproved;

  /// Order rejected snackbar
  ///
  /// In en, this message translates to:
  /// **'Order rejected'**
  String get orderRejected;

  /// POD approved message
  ///
  /// In en, this message translates to:
  /// **'POD approved and rewards distributed!'**
  String get podApproved;

  /// No order requests empty state
  ///
  /// In en, this message translates to:
  /// **'No order requests'**
  String get noOrderRequests;

  /// Rejection reason dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Rejection Reason'**
  String get selectRejectReason;

  /// OTP didn't receive prompt
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otpDidntReceive;

  /// OTP verifying state text
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get otpVerifying;

  /// Clear OTP fields button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get otpClear;

  /// OTP resend countdown
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} s'**
  String otpResendCountdown(int seconds);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
