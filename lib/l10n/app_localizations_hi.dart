// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'TSL परिवार';

  @override
  String get appTagline => 'निर्माण का दिल';

  @override
  String get heroBannerTitle => 'साहसी बनाएं। बेहतर बनाएं। TSL के साथ बनाएं।';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get commonLoading => 'लोड हो रहा है...';

  @override
  String get commonError => 'कुछ गलत हो गया';

  @override
  String get commonRetry => 'पुनः प्रयास करें';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get commonSubmit => 'जमा करें';

  @override
  String get commonConfirm => 'पुष्टि करें';

  @override
  String get commonDelete => 'हटाएं';

  @override
  String get commonEdit => 'संपादित करें';

  @override
  String get commonViewAll => 'सभी देखें';

  @override
  String get commonView => 'देखें';

  @override
  String get commonSearch => 'खोजें';

  @override
  String get commonNoResults => 'कोई परिणाम नहीं मिला';

  @override
  String get commonYes => 'हाँ';

  @override
  String get commonNo => 'नहीं';

  @override
  String get commonOk => 'ठीक है';

  @override
  String get commonDone => 'हो गया';

  @override
  String get commonNext => 'अगला';

  @override
  String get commonBack => 'वापस';

  @override
  String get commonSkip => 'छोड़ें';

  @override
  String get commonContinue => 'जारी रखें';

  @override
  String get commonGetStarted => 'शुरू करें';

  @override
  String get commonCall => 'कॉल करें';

  @override
  String get commonMessage => 'संदेश';

  @override
  String get commonNavigate => 'नेविगेट करें';

  @override
  String get statusAssigned => 'सौंपा गया';

  @override
  String get statusInProgress => 'प्रगति में';

  @override
  String get statusPending => 'लंबित';

  @override
  String get statusPendingApproval => 'अनुमोदन लंबित';

  @override
  String get statusCompleted => 'पूर्ण';

  @override
  String get statusDelivered => 'वितरित';

  @override
  String get statusRejected => 'अस्वीकृत';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get onboardingTitle1 => 'TSL परिवार में आपका स्वागत है';

  @override
  String get onboardingDesc1 =>
      'TSL परिवार से जुड़ें और भारत के विश्वसनीय निर्माण सामग्री नेटवर्क का हिस्सा बनें।';

  @override
  String get onboardingTitle2 => 'ट्रैक करें और डिलीवर करें';

  @override
  String get onboardingDesc2 =>
      'डिलीवरी प्रबंधित करें, ऑर्डर ट्रैक करें, और हर सफल डिलीवरी पर पुरस्कार अर्जित करें।';

  @override
  String get onboardingTitle3 => 'साथ मिलकर बढ़ें';

  @override
  String get onboardingDesc3 =>
      'TSL के साथ अपना करियर बनाएं। अधिक डिलीवरी, अधिक पुरस्कार, बेहतर भविष्य।';

  @override
  String get roleSelectionTitle => 'अपनी भूमिका चुनें';

  @override
  String get roleSelectionSubtitle =>
      'चुनें कि आप TSL परिवार का उपयोग कैसे करना चाहते हैं';

  @override
  String get roleMistri => 'मिस्त्री';

  @override
  String get roleMistriDesc => 'सामग्री वितरित करने वाले फील्ड वर्कर';

  @override
  String get roleDealer => 'डीलर';

  @override
  String get roleDealerDesc =>
      'ऑर्डर और मिस्त्रियों का प्रबंधन करने वाले वितरक';

  @override
  String get roleArchitect => 'आर्किटेक्ट';

  @override
  String get roleArchitectDesc =>
      'प्रोजेक्ट्स के लिए सामग्री निर्दिष्ट करने वाले इंजीनियर';

  @override
  String get roleSelectionFooter => 'जारी रखने के लिए अपनी भूमिका चुनें';

  @override
  String get loginTitle => 'लॉगिन';

  @override
  String get loginSubtitle => 'जारी रखने के लिए अपना फ़ोन नंबर दर्ज करें';

  @override
  String get loginPhoneLabel => 'फ़ोन नंबर';

  @override
  String get loginPhoneHint => '10 अंकों का मोबाइल नंबर दर्ज करें';

  @override
  String get loginSendOtp => 'OTP भेजें';

  @override
  String get loginPhoneError =>
      'कृपया एक मान्य 10 अंकों का फ़ोन नंबर दर्ज करें';

  @override
  String get loginPhoneRequired => 'कृपया अपना फ़ोन नंबर दर्ज करें';

  @override
  String get loginSendOtpFailed =>
      'OTP भेजने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get loginIndiaOnly => 'फिलहाल केवल भारत में उपलब्ध';

  @override
  String get otpTitle => 'OTP सत्यापित करें';

  @override
  String otpSubtitle(String phoneNumber) {
    return '$phoneNumber पर भेजा गया 6 अंकों का कोड दर्ज करें';
  }

  @override
  String get otpVerify => 'सत्यापित करें';

  @override
  String get otpResend => 'OTP पुनः भेजें';

  @override
  String otpResendIn(int seconds) {
    return '$seconds सेकंड में OTP पुनः भेजें';
  }

  @override
  String get otpError => 'अमान्य OTP। कृपया पुनः प्रयास करें।';

  @override
  String get navHome => 'होम';

  @override
  String get navDeliveries => 'डिलीवरी';

  @override
  String get navRewards => 'पुरस्कार';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get navOrders => 'ऑर्डर';

  @override
  String get navMistris => 'मिस्त्री';

  @override
  String get navProjects => 'प्रोजेक्ट्स';

  @override
  String get greetingMorning => 'सुप्रभात';

  @override
  String get greetingAfternoon => 'नमस्कार';

  @override
  String get greetingEvening => 'शुभ संध्या';

  @override
  String mistriHomeGreeting(String name) {
    return 'नमस्ते, $name!';
  }

  @override
  String mistriHomeRewardPoints(int points) {
    return '$points पॉइंट्स';
  }

  @override
  String get mistriHomeApprovedPoints => 'स्वीकृत';

  @override
  String get mistriHomePendingPoints => 'लंबित';

  @override
  String get mistriHomeAssignedDealer => 'आपके असाइन किए गए डीलर';

  @override
  String get mistriHomeActiveDeliveries => 'सक्रिय डिलीवरी';

  @override
  String get mistriHomeNoDeliveries => 'कोई सक्रिय डिलीवरी नहीं';

  @override
  String get mistriHomeRequestOrder => 'नया ऑर्डर अनुरोध करें';

  @override
  String get mistriHomeHelp => 'सहायता / बिल्डिंग गाइड';

  @override
  String deliveryExpectedDate(String date) {
    return 'अपेक्षित: $date';
  }

  @override
  String deliveryDistance(String distance) {
    return '$distance किमी दूर';
  }

  @override
  String get deliveryViewDetails => 'विवरण देखें';

  @override
  String get deliveryMarkReached => 'पहुंचे चिह्नित करें';

  @override
  String get deliverySubmitProof => 'प्रमाण जमा करें';

  @override
  String get deliveryMessageDealer => 'डीलर को संदेश भेजें';

  @override
  String get podTitle => 'डिलीवरी का प्रमाण';

  @override
  String get podDeliverySummary => 'डिलीवरी सारांश';

  @override
  String get podLocationVerification => 'स्थान सत्यापन';

  @override
  String get podLocationVerified => 'स्थान सत्यापित';

  @override
  String podLocationWarning(int distance) {
    return 'आप डिलीवरी स्थान से $distance मीटर दूर हैं';
  }

  @override
  String get podPhotos => 'फ़ोटो (न्यूनतम 2 आवश्यक)';

  @override
  String get podAddPhoto => 'फ़ोटो जोड़ें';

  @override
  String get podQuantityAssigned => 'सौंपी गई मात्रा';

  @override
  String get podQuantityDelivered => 'वितरित मात्रा';

  @override
  String get podIssues => 'समस्याएं रिपोर्ट करें (यदि कोई हो)';

  @override
  String get podNotes => 'अतिरिक्त नोट्स';

  @override
  String get podSubmitDelivery => 'डिलीवरी प्रमाण जमा करें';

  @override
  String get rewardsTitle => 'पुरस्कार';

  @override
  String get rewardsBalance => 'पुरस्कार शेष';

  @override
  String get rewardsRank => 'आपकी रैंक';

  @override
  String get rewardsTrustedMistri => 'TSL विश्वसनीय मिस्त्री';

  @override
  String get rewardsTabEarned => 'अर्जित';

  @override
  String get rewardsTabRedeemed => 'भुनाया';

  @override
  String get rewardsTabPending => 'लंबित';

  @override
  String get rewardsRedeem => 'पॉइंट्स भुनाएं';

  @override
  String get rewardsNoTransactions => 'अभी तक कोई पुरस्कार लेनदेन नहीं';

  @override
  String get requestOrderTitle => 'नया ऑर्डर अनुरोध करें';

  @override
  String get requestOrderMaterial => 'सामग्री का प्रकार';

  @override
  String get requestOrderQuantity => 'मात्रा';

  @override
  String get requestOrderUnit => 'इकाई';

  @override
  String get requestOrderLocation => 'डिलीवरी स्थान';

  @override
  String get requestOrderDate => 'अपेक्षित डिलीवरी तिथि';

  @override
  String get requestOrderUrgency => 'तात्कालिकता';

  @override
  String get requestOrderUrgencyNormal => 'सामान्य';

  @override
  String get requestOrderUrgencyUrgent => 'तत्काल';

  @override
  String get requestOrderUrgencyAsap => 'जल्द से जल्द';

  @override
  String get requestOrderCustomerName => 'ग्राहक का नाम';

  @override
  String get requestOrderCustomerPhone => 'ग्राहक का फ़ोन';

  @override
  String get requestOrderNotes => 'अतिरिक्त नोट्स';

  @override
  String get requestOrderSubmit => 'अनुरोध जमा करें';

  @override
  String get dealerHomeKpiMistris => 'कुल मिस्त्री';

  @override
  String get dealerHomeKpiDeliveries => 'सक्रिय डिलीवरी';

  @override
  String get dealerHomeKpiPending => 'लंबित अनुमोदन';

  @override
  String get dealerHomeKpiVolume => 'साप्ताहिक मात्रा';

  @override
  String get dealerHomeLoyaltyPoints => 'लॉयल्टी पॉइंट्स';

  @override
  String get dealerHomeMistriPool => 'मिस्त्री पूल';

  @override
  String get dealerHomeTopMistri => 'शीर्ष प्रदर्शन करने वाले मिस्त्री';

  @override
  String get dealerHomeAddMistri => 'मिस्त्री जोड़ें';

  @override
  String get dealerHomeAssignDelivery => 'डिलीवरी असाइन करें';

  @override
  String get mistriMgmtTitle => 'मिस्त्री प्रबंधन';

  @override
  String get mistriMgmtAddNew => 'नया मिस्त्री जोड़ें';

  @override
  String get mistriMgmtFilterActive => 'सक्रिय';

  @override
  String get mistriMgmtFilterInactive => 'निष्क्रिय';

  @override
  String mistriMgmtDeliveries(int count) {
    return '$count डिलीवरी';
  }

  @override
  String mistriMgmtSuccessRate(int rate) {
    return '$rate% सफलता';
  }

  @override
  String get mistriMgmtAssign => 'असाइन करें';

  @override
  String get orderRequestsTitle => 'ऑर्डर अनुरोध';

  @override
  String get orderRequestsTabNew => 'नए';

  @override
  String get orderRequestsTabAll => 'सभी';

  @override
  String get orderRequestsTabHistory => 'इतिहास';

  @override
  String get orderRequestsApprove => 'स्वीकृत करें';

  @override
  String get orderRequestsReject => 'अस्वीकार करें';

  @override
  String get orderRequestsRequestInfo => 'जानकारी मांगें';

  @override
  String get orderRequestsRejectReason => 'अस्वीकृति का कारण';

  @override
  String get orderRequestsNoRequests => 'कोई ऑर्डर अनुरोध नहीं';

  @override
  String get pendingApprovalsTitle => 'लंबित अनुमोदन';

  @override
  String get pendingApprovalsPhotoGallery => 'फ़ोटो गैलरी';

  @override
  String get pendingApprovalsMapView => 'मैप व्यू';

  @override
  String get pendingApprovalsAssignedLocation => 'असाइन किया गया स्थान';

  @override
  String get pendingApprovalsSubmittedLocation => 'जमा किया गया स्थान';

  @override
  String pendingApprovalsDistance(int distance) {
    return 'दूरी: $distance मीटर';
  }

  @override
  String get pendingApprovalsMistriNotes => 'मिस्त्री के नोट्स';

  @override
  String get pendingApprovalsIssuesReported => 'रिपोर्ट की गई समस्याएं';

  @override
  String get pendingApprovalsRewardCalc => 'पुरस्कार गणना';

  @override
  String get pendingApprovalsBasePoints => 'बेस पॉइंट्स';

  @override
  String get pendingApprovalsBonusPoints => 'बोनस पॉइंट्स';

  @override
  String get pendingApprovalsTotalPoints => 'कुल पॉइंट्स';

  @override
  String get pendingApprovalsApprove => 'स्वीकृत करें';

  @override
  String get pendingApprovalsNoApprovals => 'कोई लंबित अनुमोदन नहीं';

  @override
  String get architectHomeProjects => 'सक्रिय प्रोजेक्ट्स';

  @override
  String get architectHomeSpecs => 'विनिर्देश';

  @override
  String get architectHomeConnectedDealers => 'जुड़े हुए डीलर';

  @override
  String get architectHomeRecentSpecs => 'हालिया विनिर्देश';

  @override
  String get architectHomeCreateSpec => 'विनिर्देश बनाएं';

  @override
  String get architectHomeNewProject => 'नया प्रोजेक्ट';

  @override
  String get createSpecTitle => 'विनिर्देश बनाएं';

  @override
  String get createSpecProjectName => 'प्रोजेक्ट का नाम';

  @override
  String get createSpecProjectType => 'प्रोजेक्ट का प्रकार';

  @override
  String get createSpecTypeHousing => 'आवास';

  @override
  String get createSpecTypeCommercial => 'व्यावसायिक';

  @override
  String get createSpecTypeIndustrial => 'औद्योगिक';

  @override
  String get createSpecTypeRailways => 'रेलवे';

  @override
  String get createSpecMaterial => 'सामग्री';

  @override
  String get createSpecGrade => 'ग्रेड';

  @override
  String get createSpecDealers => 'संबद्ध डीलर';

  @override
  String get createSpecLocation => 'प्रोजेक्ट स्थान';

  @override
  String get createSpecTimeline => 'अपेक्षित समयसीमा';

  @override
  String get createSpecCreate => 'विनिर्देश बनाएं';

  @override
  String get createSpecSaveDraft => 'ड्राफ्ट के रूप में सहेजें';

  @override
  String get projectsTitle => 'प्रोजेक्ट्स';

  @override
  String get projectsNoProjects => 'अभी तक कोई प्रोजेक्ट नहीं';

  @override
  String get notificationsTitle => 'सूचनाएं';

  @override
  String get notificationsFilterAll => 'सभी';

  @override
  String get notificationsFilterDelivery => 'डिलीवरी';

  @override
  String get notificationsFilterReward => 'पुरस्कार';

  @override
  String get notificationsFilterOrder => 'ऑर्डर';

  @override
  String get notificationsFilterSystem => 'सिस्टम';

  @override
  String get notificationsMarkRead => 'पढ़ा हुआ चिह्नित करें';

  @override
  String get notificationsMarkUnread => 'अपठित चिह्नित करें';

  @override
  String get notificationsNoNotifications => 'कोई सूचना नहीं';

  @override
  String get notificationsFilterByType => 'प्रकार के अनुसार फ़िल्टर करें';

  @override
  String notificationsNoFiltered(String type) {
    return 'कोई $type सूचना नहीं';
  }

  @override
  String get notificationsAllCaughtUp => 'आप पूरी तरह अपडेट हैं!';

  @override
  String get notificationsMarkAllRead => 'सभी को पढ़ा हुआ चिह्नित करें';

  @override
  String notificationsSelectedCount(int count) {
    return '$count चयनित';
  }

  @override
  String notificationsUnreadCount(int count) {
    return '$count अपठित';
  }

  @override
  String notificationsTotalCount(int count) {
    return 'कुल $count';
  }

  @override
  String get notificationsDeleteTitle => 'सूचनाएं हटाएं';

  @override
  String notificationsDeleteConfirm(int count) {
    return 'क्या $count चयनित सूचनाएं हटानी हैं?';
  }

  @override
  String get notificationsRead => 'पढ़ा हुआ';

  @override
  String get notificationsJustNow => 'अभी';

  @override
  String get notificationsOpen => 'खोलें';

  @override
  String get notificationsSettings => 'सूचना सेटिंग्स';

  @override
  String get notificationsTypes => 'सूचना प्रकार';

  @override
  String get notificationsDeliveryUpdates => 'डिलीवरी अपडेट';

  @override
  String get notificationsRewardsPoints => 'पुरस्कार और अंक';

  @override
  String get notificationsSystemAlerts => 'सिस्टम अलर्ट';

  @override
  String get notificationsSoundVibration => 'ध्वनि और वाइब्रेशन';

  @override
  String get notificationsSound => 'ध्वनि';

  @override
  String get notificationsVibration => 'वाइब्रेशन';

  @override
  String get notificationsSettingsSaved => 'सेटिंग्स सहेज ली गईं';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get profileEditProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get profileSettings => 'सेटिंग्स';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileNotifications => 'सूचनाएं';

  @override
  String get profilePrivacy => 'गोपनीयता';

  @override
  String get profileLogout => 'लॉगआउट';

  @override
  String get profileLogoutConfirm => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

  @override
  String profileVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get materialTsl550sd => 'TSL 550 SD';

  @override
  String get materialGirders => 'गर्डर';

  @override
  String get materialAngles => 'एंगल';

  @override
  String get materialChannels => 'चैनल';

  @override
  String get materialPipes => 'पाइप';

  @override
  String get materialWires => 'तार';

  @override
  String get materialColourSheets => 'रंगीन शीट';

  @override
  String get unitTons => 'टन';

  @override
  String get unitKg => 'किलो';

  @override
  String get unitPieces => 'टुकड़े';

  @override
  String get unitBundles => 'बंडल';

  @override
  String get emptyStateTitle => 'यहाँ अभी कुछ नहीं है';

  @override
  String get emptyStateMessage => 'अपडेट के लिए बाद में जांचें';

  @override
  String get errorNetworkTitle => 'इंटरनेट कनेक्शन नहीं';

  @override
  String get errorNetworkMessage =>
      'कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें';

  @override
  String get errorServerTitle => 'सर्वर त्रुटि';

  @override
  String get errorServerMessage =>
      'हमारी तरफ से कुछ गलत हुआ। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get errorUnknownTitle => 'उफ़!';

  @override
  String get errorUnknownMessage =>
      'कुछ अप्रत्याशित हुआ। कृपया पुनः प्रयास करें।';

  @override
  String appVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get callDealer => 'डीलर को कॉल करें';

  @override
  String callConfirm(String phone) {
    return '$phone को कॉल करें?';
  }

  @override
  String get navigateToDealer => 'डीलर तक नेविगेट करें';

  @override
  String navigateConfirm(String address) {
    return 'मानचित्र पर नेविगेट करें:\n$address';
  }

  @override
  String get deliveriesTitle => 'डिलीवरी';

  @override
  String get searchDeliveries => 'डिलीवरी खोजें...';

  @override
  String get searchProjects => 'प्रोजेक्ट खोजें...';

  @override
  String get searchMistris => 'मिस्त्री खोजें...';

  @override
  String get noDeliveriesFound => 'कोई डिलीवरी नहीं मिली';

  @override
  String get deliveryDetails => 'डिलीवरी विवरण';

  @override
  String get customerDetails => 'ग्राहक विवरण';

  @override
  String get deliveryProgress => 'डिलीवरी प्रगति';

  @override
  String get productDetails => 'उत्पाद विवरण';

  @override
  String get statusAll => 'सभी';

  @override
  String get statusNew => 'नया';

  @override
  String get statusActive => 'सक्रिय';

  @override
  String get statusOnHold => 'रुका हुआ';

  @override
  String get statusDraft => 'ड्राफ्ट';

  @override
  String get statusInactive => 'निष्क्रिय';

  @override
  String get tabHistory => 'इतिहास';

  @override
  String get noProjectsFound => 'कोई प्रोजेक्ट नहीं मिला';

  @override
  String get createProject => 'प्रोजेक्ट बनाएं';

  @override
  String get newProject => 'नया प्रोजेक्ट';

  @override
  String get clearSearch => 'खोज साफ़ करें';

  @override
  String get myProjects => 'मेरे प्रोजेक्ट';

  @override
  String get location => 'स्थान';

  @override
  String get materialSpecifications => 'सामग्री विनिर्देश';

  @override
  String get noSpecificationsYet => 'अभी कोई विनिर्देश नहीं';

  @override
  String get associatedDealers => 'जुड़े डीलर';

  @override
  String get noDealersAssociated => 'कोई डीलर जुड़ा नहीं';

  @override
  String get pointsEarned => 'अर्जित अंक';

  @override
  String get addSpec => 'विनिर्देश जोड़ें';

  @override
  String get notificationsEmpty => 'अभी कोई सूचना नहीं';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get earlier => 'पहले';

  @override
  String get chatTitle => 'संदेश';

  @override
  String get chatSearchConversations => 'बातचीत खोजें...';

  @override
  String get chatNoConversations => 'कोई बातचीत नहीं';

  @override
  String chatNewCount(int count) {
    return '$count नए';
  }

  @override
  String chatConversationCount(int count) {
    return '$count बातचीत';
  }

  @override
  String get newConversation => 'नई बातचीत';

  @override
  String get typeMessage => 'संदेश टाइप करें...';

  @override
  String get online => 'ऑनलाइन';

  @override
  String get offline => 'ऑफलाइन';

  @override
  String get noMessages => 'अभी कोई संदेश नहीं';

  @override
  String get startConversation => 'बातचीत शुरू करें';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get profileNotSet => 'सेट नहीं';

  @override
  String get profileMemberSince => 'सदस्यता तिथि';

  @override
  String get profileUnknown => 'अज्ञात';

  @override
  String get profileSuccess => 'सफलता';

  @override
  String get profileVolume => 'वॉल्यूम';

  @override
  String get profileIdCard => 'आईडी कार्ड';

  @override
  String get profileViewTslId => 'अपना TSL आईडी देखें';

  @override
  String get profileActivity => 'गतिविधि';

  @override
  String get profileEnabled => 'सक्षम';

  @override
  String get profileDisabled => 'अक्षम';

  @override
  String get profileOn => 'चालू';

  @override
  String get profileOff => 'बंद';

  @override
  String get profileContactSupport => 'सहायता से संपर्क करें';

  @override
  String get profileRateApp => 'ऐप रेट करें';

  @override
  String get profileShareApp => 'ऐप साझा करें';

  @override
  String get profileBuildVersion => 'संस्करण 1.0.0 (बिल्ड 1)';

  @override
  String get profileCopyright => '© 2024 TSL Steel. सर्वाधिकार सुरक्षित।';

  @override
  String get profileYourQrCode => 'आपका TSL QR कोड';

  @override
  String get profileIdPrefix => 'आईडी';

  @override
  String get profileShareQrCode => 'QR कोड साझा करें';

  @override
  String get profileShareIdCard => 'आईडी कार्ड साझा करें';

  @override
  String get profileFullName => 'पूरा नाम';

  @override
  String get profileCity => 'शहर';

  @override
  String get profileFullAddress => 'पूरा पता';

  @override
  String get profileSaveChanges => 'परिवर्तन सहेजें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get biometricAuth => 'बायोमेट्रिक प्रमाणीकरण';

  @override
  String get termsOfService => 'सेवा की शर्तें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get aboutApp => 'TSL परिवार के बारे में';

  @override
  String get logoutConfirmTitle => 'लॉगआउट';

  @override
  String get logoutConfirmMessage => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

  @override
  String get assignDelivery => 'डिलीवरी सौंपें';

  @override
  String get addMistri => 'मिस्त्री जोड़ें';

  @override
  String get mistriName => 'मिस्त्री का नाम';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get specialization => 'विशेषज्ञता';

  @override
  String get addedSuccessfully => 'सफलतापूर्वक जोड़ा गया!';

  @override
  String get reviewPods => 'POD की समीक्षा करें';

  @override
  String get buildingGuide => 'भवन निर्माण गाइड';

  @override
  String get helpSupport => 'सहायता और समर्थन';

  @override
  String get notificationsFilterMessage => 'संदेश';

  @override
  String get redeemPoints => 'अंक भुनाएं';

  @override
  String get distributePoints => 'अंक वितरित करें';

  @override
  String get dealerRewardsTitle => 'डीलर पुरस्कार';

  @override
  String get architectRewardsTitle => 'आर्किटेक्ट पुरस्कार';

  @override
  String get tabDistributed => 'वितरित';

  @override
  String get tabAll => 'सभी';

  @override
  String get howItWorks => 'यह कैसे काम करता है';

  @override
  String get referFriend => 'दोस्त को रेफर करें';

  @override
  String get orderRequestsDescription =>
      'नई डिलीवरी सौंपने के लिए मिस्त्री चुनें';

  @override
  String get byPhoneAuth => 'जारी रखकर, आप हमारी सहमत हैं';

  @override
  String get andText => 'और';

  @override
  String otpSentTo(String phone) {
    return '$phone पर OTP भेजा गया';
  }

  @override
  String resendOtpIn(int seconds) {
    return '${seconds}s में OTP पुनः भेजें';
  }

  @override
  String get wrongNumber => 'गलत नंबर?';

  @override
  String get changeNumber => 'बदलें';

  @override
  String get verifying => 'सत्यापित हो रहा है...';

  @override
  String get projectNameHint => 'प्रोजेक्ट का नाम दर्ज करें';

  @override
  String get selectDealers => 'डीलर चुनें';

  @override
  String get projectLocationHint => 'प्रोजेक्ट स्थान दर्ज करें';

  @override
  String get expectedDelivery => 'अपेक्षित डिलीवरी';

  @override
  String get summary => 'सारांश';

  @override
  String step(int number) {
    return 'चरण $number';
  }

  @override
  String agoMinutes(int minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String agoHours(int hours) {
    return '$hours घंटे पहले';
  }

  @override
  String agoDays(int days) {
    return '$days दिन पहले';
  }

  @override
  String get tomorrow => 'कल';

  @override
  String quantityUnit(String quantity, String unit) {
    return '$quantity $unit';
  }

  @override
  String get noMatchSearch => 'आपकी खोज से कोई परिणाम नहीं मिला';

  @override
  String get startByCreating => 'नया प्रोजेक्ट बनाकर शुरू करें';

  @override
  String get approveOrder => 'स्वीकृत';

  @override
  String get rejectOrder => 'अस्वीकृत';

  @override
  String get moreInfo => 'अधिक जानकारी';

  @override
  String get orderApproved => 'ऑर्डर स्वीकृत!';

  @override
  String get orderRejected => 'ऑर्डर अस्वीकृत';

  @override
  String get podApproved => 'POD स्वीकृत और पुरस्कार वितरित!';

  @override
  String get noOrderRequests => 'कोई ऑर्डर अनुरोध नहीं';

  @override
  String get selectRejectReason => 'अस्वीकृति का कारण चुनें';

  @override
  String get otpDidntReceive => 'कोड प्राप्त नहीं हुआ?';

  @override
  String get otpVerifying => 'सत्यापित हो रहा है...';

  @override
  String get otpClear => 'साफ़ करें';

  @override
  String otpResendCountdown(int seconds) {
    return '$seconds सेकंड में पुनः भेजें';
  }
}
