// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TSL Parivar';

  @override
  String get appTagline => 'Heart of Building';

  @override
  String get heroBannerTitle => 'Build Bold. Build Better. Build with TSL.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonViewAll => 'View All';

  @override
  String get commonView => 'View';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonNoResults => 'No results found';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDone => 'Done';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonGetStarted => 'Get Started';

  @override
  String get commonCall => 'Call';

  @override
  String get commonMessage => 'Message';

  @override
  String get commonNavigate => 'Navigate';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusPendingApproval => 'Pending Approval';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get onboardingTitle1 => 'Welcome to TSL Parivar';

  @override
  String get onboardingDesc1 =>
      'Join the TSL family and be part of India\'s trusted construction material network.';

  @override
  String get onboardingTitle2 => 'Track & Deliver';

  @override
  String get onboardingDesc2 =>
      'Manage deliveries, track orders, and earn rewards for every successful delivery.';

  @override
  String get onboardingTitle3 => 'Grow Together';

  @override
  String get onboardingDesc3 =>
      'Build your career with TSL. More deliveries, more rewards, better future.';

  @override
  String get roleSelectionTitle => 'Select Your Role';

  @override
  String get roleSelectionSubtitle => 'Choose how you want to use TSL Parivar';

  @override
  String get roleMistri => 'Mistri';

  @override
  String get roleMistriDesc => 'Field worker delivering materials';

  @override
  String get roleDealer => 'Dealer';

  @override
  String get roleDealerDesc => 'Distributor managing orders & mistris';

  @override
  String get roleArchitect => 'Architect';

  @override
  String get roleArchitectDesc => 'Engineer specifying materials for projects';

  @override
  String get roleSelectionFooter => 'Select your role to continue';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Enter your phone number to continue';

  @override
  String get loginPhoneLabel => 'Phone Number';

  @override
  String get loginPhoneHint => 'Enter 10-digit mobile number';

  @override
  String get loginSendOtp => 'Send OTP';

  @override
  String get loginPhoneError => 'Please enter a valid 10-digit phone number';

  @override
  String get loginPhoneRequired => 'Please enter your phone number';

  @override
  String get loginSendOtpFailed => 'Failed to send OTP. Please try again.';

  @override
  String get loginIndiaOnly => 'Currently available in India only';

  @override
  String get otpTitle => 'Verify OTP';

  @override
  String otpSubtitle(String phoneNumber) {
    return 'Enter the 6-digit code sent to $phoneNumber';
  }

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpResend => 'Resend OTP';

  @override
  String otpResendIn(int seconds) {
    return 'Resend OTP in ${seconds}s';
  }

  @override
  String get otpError => 'Invalid OTP. Please try again.';

  @override
  String get navHome => 'Home';

  @override
  String get navDeliveries => 'Deliveries';

  @override
  String get navRewards => 'Rewards';

  @override
  String get navProfile => 'Profile';

  @override
  String get navOrders => 'Orders';

  @override
  String get navMistris => 'Mistris';

  @override
  String get navProjects => 'Projects';

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String mistriHomeGreeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String mistriHomeRewardPoints(int points) {
    return '$points Points';
  }

  @override
  String get mistriHomeApprovedPoints => 'Approved';

  @override
  String get mistriHomePendingPoints => 'Pending';

  @override
  String get mistriHomeAssignedDealer => 'Your Assigned Dealer';

  @override
  String get mistriHomeActiveDeliveries => 'Active Deliveries';

  @override
  String get mistriHomeNoDeliveries => 'No active deliveries';

  @override
  String get mistriHomeRequestOrder => 'Request New Order';

  @override
  String get mistriHomeHelp => 'Help / Building Guide';

  @override
  String deliveryExpectedDate(String date) {
    return 'Expected: $date';
  }

  @override
  String deliveryDistance(String distance) {
    return '$distance km away';
  }

  @override
  String get deliveryViewDetails => 'View Details';

  @override
  String get deliveryMarkReached => 'Mark Reached';

  @override
  String get deliverySubmitProof => 'Submit Proof';

  @override
  String get deliveryMessageDealer => 'Message Dealer';

  @override
  String get podTitle => 'Proof of Delivery';

  @override
  String get podDeliverySummary => 'Delivery Summary';

  @override
  String get podLocationVerification => 'Location Verification';

  @override
  String get podLocationVerified => 'Location verified';

  @override
  String podLocationWarning(int distance) {
    return 'You are ${distance}m from delivery location';
  }

  @override
  String get podPhotos => 'Photos (min. 2 required)';

  @override
  String get podAddPhoto => 'Add Photo';

  @override
  String get podQuantityAssigned => 'Assigned Quantity';

  @override
  String get podQuantityDelivered => 'Delivered Quantity';

  @override
  String get podIssues => 'Report Issues (if any)';

  @override
  String get podNotes => 'Additional Notes';

  @override
  String get podSubmitDelivery => 'Submit Delivery Proof';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get rewardsBalance => 'Reward Balance';

  @override
  String get rewardsRank => 'Your Rank';

  @override
  String get rewardsTrustedMistri => 'TSL Trusted Mistri';

  @override
  String get rewardsTabEarned => 'Earned';

  @override
  String get rewardsTabRedeemed => 'Redeemed';

  @override
  String get rewardsTabPending => 'Pending';

  @override
  String get rewardsRedeem => 'Redeem Points';

  @override
  String get rewardsNoTransactions => 'No reward transactions yet';

  @override
  String get requestOrderTitle => 'Request New Order';

  @override
  String get requestOrderMaterial => 'Material Type';

  @override
  String get requestOrderQuantity => 'Quantity';

  @override
  String get requestOrderUnit => 'Unit';

  @override
  String get requestOrderLocation => 'Delivery Location';

  @override
  String get requestOrderDate => 'Expected Delivery Date';

  @override
  String get requestOrderUrgency => 'Urgency';

  @override
  String get requestOrderUrgencyNormal => 'Normal';

  @override
  String get requestOrderUrgencyUrgent => 'Urgent';

  @override
  String get requestOrderUrgencyAsap => 'ASAP';

  @override
  String get requestOrderCustomerName => 'Customer Name';

  @override
  String get requestOrderCustomerPhone => 'Customer Phone';

  @override
  String get requestOrderNotes => 'Additional Notes';

  @override
  String get requestOrderSubmit => 'Submit Request';

  @override
  String get dealerHomeKpiMistris => 'Total Mistris';

  @override
  String get dealerHomeKpiDeliveries => 'Active Deliveries';

  @override
  String get dealerHomeKpiPending => 'Pending Approvals';

  @override
  String get dealerHomeKpiVolume => 'Weekly Volume';

  @override
  String get dealerHomeLoyaltyPoints => 'Loyalty Points';

  @override
  String get dealerHomeMistriPool => 'Mistri Pool';

  @override
  String get dealerHomeTopMistri => 'Top Performing Mistri';

  @override
  String get dealerHomeAddMistri => 'Add Mistri';

  @override
  String get dealerHomeAssignDelivery => 'Assign Delivery';

  @override
  String get mistriMgmtTitle => 'Mistri Management';

  @override
  String get mistriMgmtAddNew => 'Add New Mistri';

  @override
  String get mistriMgmtFilterActive => 'Active';

  @override
  String get mistriMgmtFilterInactive => 'Inactive';

  @override
  String mistriMgmtDeliveries(int count) {
    return '$count deliveries';
  }

  @override
  String mistriMgmtSuccessRate(int rate) {
    return '$rate% success';
  }

  @override
  String get mistriMgmtAssign => 'Assign';

  @override
  String get orderRequestsTitle => 'Order Requests';

  @override
  String get orderRequestsTabNew => 'New';

  @override
  String get orderRequestsTabAll => 'All';

  @override
  String get orderRequestsTabHistory => 'History';

  @override
  String get orderRequestsApprove => 'Approve';

  @override
  String get orderRequestsReject => 'Reject';

  @override
  String get orderRequestsRequestInfo => 'Request Info';

  @override
  String get orderRequestsRejectReason => 'Rejection Reason';

  @override
  String get orderRequestsNoRequests => 'No order requests';

  @override
  String get pendingApprovalsTitle => 'Pending Approvals';

  @override
  String get pendingApprovalsPhotoGallery => 'Photo Gallery';

  @override
  String get pendingApprovalsMapView => 'Map View';

  @override
  String get pendingApprovalsAssignedLocation => 'Assigned Location';

  @override
  String get pendingApprovalsSubmittedLocation => 'Submitted Location';

  @override
  String pendingApprovalsDistance(int distance) {
    return 'Distance: ${distance}m';
  }

  @override
  String get pendingApprovalsMistriNotes => 'Mistri Notes';

  @override
  String get pendingApprovalsIssuesReported => 'Issues Reported';

  @override
  String get pendingApprovalsRewardCalc => 'Reward Calculation';

  @override
  String get pendingApprovalsBasePoints => 'Base Points';

  @override
  String get pendingApprovalsBonusPoints => 'Bonus Points';

  @override
  String get pendingApprovalsTotalPoints => 'Total Points';

  @override
  String get pendingApprovalsApprove => 'Approve';

  @override
  String get pendingApprovalsNoApprovals => 'No pending approvals';

  @override
  String get architectHomeProjects => 'Active Projects';

  @override
  String get architectHomeSpecs => 'Specifications';

  @override
  String get architectHomeConnectedDealers => 'Connected Dealers';

  @override
  String get architectHomeRecentSpecs => 'Recent Specifications';

  @override
  String get architectHomeCreateSpec => 'Create Specification';

  @override
  String get architectHomeNewProject => 'New Project';

  @override
  String get createSpecTitle => 'Create Specification';

  @override
  String get createSpecProjectName => 'Project Name';

  @override
  String get createSpecProjectType => 'Project Type';

  @override
  String get createSpecTypeHousing => 'Housing';

  @override
  String get createSpecTypeCommercial => 'Commercial';

  @override
  String get createSpecTypeIndustrial => 'Industrial';

  @override
  String get createSpecTypeRailways => 'Railways';

  @override
  String get createSpecMaterial => 'Material';

  @override
  String get createSpecGrade => 'Grade';

  @override
  String get createSpecDealers => 'Associated Dealers';

  @override
  String get createSpecLocation => 'Project Location';

  @override
  String get createSpecTimeline => 'Expected Timeline';

  @override
  String get createSpecCreate => 'Create Specification';

  @override
  String get createSpecSaveDraft => 'Save as Draft';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsNoProjects => 'No projects yet';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterDelivery => 'Delivery';

  @override
  String get notificationsFilterReward => 'Reward';

  @override
  String get notificationsFilterOrder => 'Order';

  @override
  String get notificationsFilterSystem => 'System';

  @override
  String get notificationsMarkRead => 'Mark as read';

  @override
  String get notificationsMarkUnread => 'Mark as unread';

  @override
  String get notificationsNoNotifications => 'No notifications';

  @override
  String get notificationsFilterByType => 'Filter by type';

  @override
  String notificationsNoFiltered(String type) {
    return 'No $type notifications';
  }

  @override
  String get notificationsAllCaughtUp => 'You\'re all caught up!';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String notificationsSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String notificationsUnreadCount(int count) {
    return '$count unread';
  }

  @override
  String notificationsTotalCount(int count) {
    return '$count total';
  }

  @override
  String get notificationsDeleteTitle => 'Delete Notifications';

  @override
  String notificationsDeleteConfirm(int count) {
    return 'Delete $count selected notifications?';
  }

  @override
  String get notificationsRead => 'Read';

  @override
  String get notificationsJustNow => 'Just now';

  @override
  String get notificationsOpen => 'Open';

  @override
  String get notificationsSettings => 'Notification Settings';

  @override
  String get notificationsTypes => 'Notification Types';

  @override
  String get notificationsDeliveryUpdates => 'Delivery Updates';

  @override
  String get notificationsRewardsPoints => 'Rewards & Points';

  @override
  String get notificationsSystemAlerts => 'System Alerts';

  @override
  String get notificationsSoundVibration => 'Sound & Vibration';

  @override
  String get notificationsSound => 'Sound';

  @override
  String get notificationsVibration => 'Vibration';

  @override
  String get notificationsSettingsSaved => 'Settings saved';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to logout?';

  @override
  String profileVersion(String version) {
    return 'Version $version';
  }

  @override
  String get materialTsl550sd => 'TSL 550 SD';

  @override
  String get materialGirders => 'Girders';

  @override
  String get materialAngles => 'Angles';

  @override
  String get materialChannels => 'Channels';

  @override
  String get materialPipes => 'Pipes';

  @override
  String get materialWires => 'Wires';

  @override
  String get materialColourSheets => 'Colour Sheets';

  @override
  String get unitTons => 'Tons';

  @override
  String get unitKg => 'Kg';

  @override
  String get unitPieces => 'Pieces';

  @override
  String get unitBundles => 'Bundles';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get emptyStateMessage => 'Check back later for updates';

  @override
  String get errorNetworkTitle => 'No Internet Connection';

  @override
  String get errorNetworkMessage =>
      'Please check your internet connection and try again';

  @override
  String get errorServerTitle => 'Server Error';

  @override
  String get errorServerMessage =>
      'Something went wrong on our end. Please try again later.';

  @override
  String get errorUnknownTitle => 'Oops!';

  @override
  String get errorUnknownMessage =>
      'Something unexpected happened. Please try again.';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get callDealer => 'Call Dealer';

  @override
  String callConfirm(String phone) {
    return 'Call $phone?';
  }

  @override
  String get navigateToDealer => 'Navigate to Dealer';

  @override
  String navigateConfirm(String address) {
    return 'Open maps to navigate to:\n$address';
  }

  @override
  String get deliveriesTitle => 'Deliveries';

  @override
  String get searchDeliveries => 'Search deliveries...';

  @override
  String get searchProjects => 'Search projects...';

  @override
  String get searchMistris => 'Search mistris...';

  @override
  String get noDeliveriesFound => 'No Deliveries Found';

  @override
  String get deliveryDetails => 'Delivery Details';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String get deliveryProgress => 'Delivery Progress';

  @override
  String get productDetails => 'Product Details';

  @override
  String get statusAll => 'All';

  @override
  String get statusNew => 'New';

  @override
  String get statusActive => 'Active';

  @override
  String get statusOnHold => 'On Hold';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get tabHistory => 'History';

  @override
  String get noProjectsFound => 'No Projects Found';

  @override
  String get createProject => 'Create Project';

  @override
  String get newProject => 'New Project';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get myProjects => 'My Projects';

  @override
  String get location => 'Location';

  @override
  String get materialSpecifications => 'Material Specifications';

  @override
  String get noSpecificationsYet => 'No specifications yet';

  @override
  String get associatedDealers => 'Associated Dealers';

  @override
  String get noDealersAssociated => 'No dealers associated';

  @override
  String get pointsEarned => 'Points Earned';

  @override
  String get addSpec => 'Add Spec';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get earlier => 'Earlier';

  @override
  String get chatTitle => 'Messages';

  @override
  String get chatSearchConversations => 'Search conversations...';

  @override
  String get chatNoConversations => 'No Conversations';

  @override
  String chatNewCount(int count) {
    return '$count new';
  }

  @override
  String chatConversationCount(int count) {
    return '$count conversations';
  }

  @override
  String get newConversation => 'New Conversation';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get noMessages => 'No Messages Yet';

  @override
  String get startConversation => 'Start a conversation';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileNotSet => 'Not set';

  @override
  String get profileMemberSince => 'Member Since';

  @override
  String get profileUnknown => 'Unknown';

  @override
  String get profileSuccess => 'Success';

  @override
  String get profileVolume => 'Volume';

  @override
  String get profileIdCard => 'ID Card';

  @override
  String get profileViewTslId => 'View your TSL ID';

  @override
  String get profileActivity => 'Activity';

  @override
  String get profileEnabled => 'Enabled';

  @override
  String get profileDisabled => 'Disabled';

  @override
  String get profileOn => 'On';

  @override
  String get profileOff => 'Off';

  @override
  String get profileContactSupport => 'Contact Support';

  @override
  String get profileRateApp => 'Rate the App';

  @override
  String get profileShareApp => 'Share App';

  @override
  String get profileBuildVersion => 'Version 1.0.0 (Build 1)';

  @override
  String get profileCopyright => '© 2024 TSL Steel. All rights reserved.';

  @override
  String get profileYourQrCode => 'Your TSL QR Code';

  @override
  String get profileIdPrefix => 'ID';

  @override
  String get profileShareQrCode => 'Share QR Code';

  @override
  String get profileShareIdCard => 'Share ID Card';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get profileCity => 'City';

  @override
  String get profileFullAddress => 'Full Address';

  @override
  String get profileSaveChanges => 'Save Changes';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutApp => 'About TSL Parivar';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get assignDelivery => 'Assign Delivery';

  @override
  String get addMistri => 'Add Mistri';

  @override
  String get mistriName => 'Mistri Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get specialization => 'Specialization';

  @override
  String get addedSuccessfully => 'Added successfully!';

  @override
  String get reviewPods => 'Review PODs';

  @override
  String get buildingGuide => 'Building Guide';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get notificationsFilterMessage => 'Messages';

  @override
  String get redeemPoints => 'Redeem Points';

  @override
  String get distributePoints => 'Distribute Points';

  @override
  String get dealerRewardsTitle => 'Dealer Rewards';

  @override
  String get architectRewardsTitle => 'Architect Rewards';

  @override
  String get tabDistributed => 'Distributed';

  @override
  String get tabAll => 'All';

  @override
  String get howItWorks => 'How it Works';

  @override
  String get referFriend => 'Refer a Friend';

  @override
  String get orderRequestsDescription =>
      'Select a mistri to assign a new delivery';

  @override
  String get byPhoneAuth => 'By continuing, you agree to our';

  @override
  String get andText => 'and';

  @override
  String otpSentTo(String phone) {
    return 'OTP sent to $phone';
  }

  @override
  String resendOtpIn(int seconds) {
    return 'Resend OTP in ${seconds}s';
  }

  @override
  String get wrongNumber => 'Wrong number?';

  @override
  String get changeNumber => 'Change';

  @override
  String get verifying => 'Verifying...';

  @override
  String get projectNameHint => 'Enter project name';

  @override
  String get selectDealers => 'Select Dealers';

  @override
  String get projectLocationHint => 'Enter project location';

  @override
  String get expectedDelivery => 'Expected Delivery';

  @override
  String get summary => 'Summary';

  @override
  String step(int number) {
    return 'Step $number';
  }

  @override
  String agoMinutes(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String agoHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String agoDays(int days) {
    return '${days}d ago';
  }

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String quantityUnit(String quantity, String unit) {
    return '$quantity $unit';
  }

  @override
  String get noMatchSearch => 'No results match your search';

  @override
  String get startByCreating => 'Start by creating a new project';

  @override
  String get approveOrder => 'Approve';

  @override
  String get rejectOrder => 'Reject';

  @override
  String get moreInfo => 'More Info';

  @override
  String get orderApproved => 'Order approved!';

  @override
  String get orderRejected => 'Order rejected';

  @override
  String get podApproved => 'POD approved and rewards distributed!';

  @override
  String get noOrderRequests => 'No order requests';

  @override
  String get selectRejectReason => 'Select Rejection Reason';

  @override
  String get otpDidntReceive => 'Didn\'t receive the code?';

  @override
  String get otpVerifying => 'Verifying...';

  @override
  String get otpClear => 'Clear';

  @override
  String otpResendCountdown(int seconds) {
    return 'Resend in $seconds s';
  }
}
