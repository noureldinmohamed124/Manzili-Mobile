import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'منزلي'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'حاول تاني'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'أكد'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'احفظ'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @loginSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمام، دخلت 👌'**
  String get loginSuccess;

  /// No description provided for @fillEmailPassword.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الإيميل والباسورد الأول'**
  String get fillEmailPassword;

  /// No description provided for @signInCta.
  ///
  /// In ar, this message translates to:
  /// **'ادخل'**
  String get signInCta;

  /// No description provided for @signInLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري الدخول…'**
  String get signInLoading;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت الباسورد؟'**
  String get forgotPassword;

  /// No description provided for @rememberMe.
  ///
  /// In ar, this message translates to:
  /// **'خليك فاكرني'**
  String get rememberMe;

  /// No description provided for @noAccountSignUp.
  ///
  /// In ar, this message translates to:
  /// **'معندكش حساب؟ اعمل حساب'**
  String get noAccountSignUp;

  /// No description provided for @signUpCta.
  ///
  /// In ar, this message translates to:
  /// **'اعمل حساب'**
  String get signUpCta;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In ar, this message translates to:
  /// **'عندك حساب؟ سجل دخول'**
  String get haveAccountSignIn;

  /// No description provided for @signupHasAccountPrefix.
  ///
  /// In ar, this message translates to:
  /// **'عندك حساب؟ '**
  String get signupHasAccountPrefix;

  /// No description provided for @signupSignInLink.
  ///
  /// In ar, this message translates to:
  /// **'سجل دخول'**
  String get signupSignInLink;

  /// No description provided for @signupScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'اعمل حساب جديد'**
  String get signupScreenTitle;

  /// No description provided for @signupSocialDivider.
  ///
  /// In ar, this message translates to:
  /// **'أو كمل بجوجل / فيسبوك'**
  String get signupSocialDivider;

  /// No description provided for @createServiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'اعمل خدمة جديدة'**
  String get createServiceTitle;

  /// No description provided for @fieldServiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'اسم الخدمة'**
  String get fieldServiceTitle;

  /// No description provided for @fieldCategory.
  ///
  /// In ar, this message translates to:
  /// **'نوع الخدمة'**
  String get fieldCategory;

  /// No description provided for @fieldDescription.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get fieldDescription;

  /// No description provided for @fieldBasePrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الأساسي'**
  String get fieldBasePrice;

  /// No description provided for @fieldImages.
  ///
  /// In ar, this message translates to:
  /// **'صور الخدمة'**
  String get fieldImages;

  /// No description provided for @fieldVariants.
  ///
  /// In ar, this message translates to:
  /// **'خيارات / مقاسات'**
  String get fieldVariants;

  /// No description provided for @fieldExtras.
  ///
  /// In ar, this message translates to:
  /// **'مميزات إضافية'**
  String get fieldExtras;

  /// No description provided for @draftToggle.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كمسودة'**
  String get draftToggle;

  /// No description provided for @ctaPublishService.
  ///
  /// In ar, this message translates to:
  /// **'اعمل الخدمة'**
  String get ctaPublishService;

  /// No description provided for @ctaLeaveWithoutSave.
  ///
  /// In ar, this message translates to:
  /// **'ارجع من غير حفظ'**
  String get ctaLeaveWithoutSave;

  /// No description provided for @errTitleLength.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم خدمة صح'**
  String get errTitleLength;

  /// No description provided for @errCategory.
  ///
  /// In ar, this message translates to:
  /// **'اختار نوع الخدمة'**
  String get errCategory;

  /// No description provided for @errDescription.
  ///
  /// In ar, this message translates to:
  /// **'اكتب وصف أوضح شوية'**
  String get errDescription;

  /// No description provided for @errPrice.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سعر صحيح'**
  String get errPrice;

  /// No description provided for @errImages.
  ///
  /// In ar, this message translates to:
  /// **'لازم تضيف صورة واحدة على الأقل'**
  String get errImages;

  /// No description provided for @editServiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'عدّل الخدمة'**
  String get editServiceTitle;

  /// No description provided for @ctaSaveEdits.
  ///
  /// In ar, this message translates to:
  /// **'احفظ التعديلات'**
  String get ctaSaveEdits;

  /// No description provided for @errKeepOneImage.
  ///
  /// In ar, this message translates to:
  /// **'لازم تسيب صورة واحدة على الأقل'**
  String get errKeepOneImage;

  /// No description provided for @statusSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالة الخدمة'**
  String get statusSheetTitle;

  /// No description provided for @statusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get statusActive;

  /// No description provided for @statusPaused.
  ///
  /// In ar, this message translates to:
  /// **'موقوفة'**
  String get statusPaused;

  /// No description provided for @statusDraft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get statusDraft;

  /// No description provided for @errStatusChange.
  ///
  /// In ar, this message translates to:
  /// **'ماقدرناش نغير الحالة، جرّب تاني'**
  String get errStatusChange;

  /// No description provided for @autoAcceptTitle.
  ///
  /// In ar, this message translates to:
  /// **'القبول التلقائي'**
  String get autoAcceptTitle;

  /// No description provided for @autoAcceptSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فعّل القبول التلقائي'**
  String get autoAcceptSubtitle;

  /// No description provided for @autoAcceptHint.
  ///
  /// In ar, this message translates to:
  /// **'بيتفعّل بس لما الخدمة تكون شغّالة ومش موقوفة.'**
  String get autoAcceptHint;

  /// No description provided for @errAutoAcceptSave.
  ///
  /// In ar, this message translates to:
  /// **'ماقدرناش نحفظ الإعداد ده، جرّب تاني'**
  String get errAutoAcceptSave;

  /// No description provided for @earningsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرباحك وتحليلاتك'**
  String get earningsTitle;

  /// No description provided for @filterToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get filterToday;

  /// No description provided for @filterWeek.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع'**
  String get filterWeek;

  /// No description provided for @filterMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر'**
  String get filterMonth;

  /// No description provided for @cardGross.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح الإجمالية'**
  String get cardGross;

  /// No description provided for @cardPending.
  ///
  /// In ar, this message translates to:
  /// **'أرباح معلقة'**
  String get cardPending;

  /// No description provided for @cardOrdersCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الطلبات'**
  String get cardOrdersCount;

  /// No description provided for @cardAvgOrder.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الطلب'**
  String get cardAvgOrder;

  /// No description provided for @topServices.
  ///
  /// In ar, this message translates to:
  /// **'أقوى الخدمات'**
  String get topServices;

  /// No description provided for @recentEarnings.
  ///
  /// In ar, this message translates to:
  /// **'آخر الأرباح'**
  String get recentEarnings;

  /// No description provided for @errAnalyticsLoad.
  ///
  /// In ar, this message translates to:
  /// **'في مشكلة في تحميل التحليلات'**
  String get errAnalyticsLoad;

  /// No description provided for @errAnalyticsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لسه مفيش بيانات كفاية نعرضها'**
  String get errAnalyticsEmpty;

  /// No description provided for @vipTitle.
  ///
  /// In ar, this message translates to:
  /// **'أدوات VIP'**
  String get vipTitle;

  /// No description provided for @vipCtaMore.
  ///
  /// In ar, this message translates to:
  /// **'اعرف أكتر'**
  String get vipCtaMore;

  /// No description provided for @vipCtaSubscribe.
  ///
  /// In ar, this message translates to:
  /// **'اشترك في VIP'**
  String get vipCtaSubscribe;

  /// No description provided for @vipActive.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك شغّال'**
  String get vipActive;

  /// No description provided for @vipExpired.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك خلص'**
  String get vipExpired;

  /// No description provided for @vipNone.
  ///
  /// In ar, this message translates to:
  /// **'مش مشترك'**
  String get vipNone;

  /// No description provided for @vipLocked.
  ///
  /// In ar, this message translates to:
  /// **'مقفول'**
  String get vipLocked;

  /// No description provided for @vipUnlocked.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get vipUnlocked;

  /// No description provided for @offersTitle.
  ///
  /// In ar, this message translates to:
  /// **'العروض'**
  String get offersTitle;

  /// No description provided for @offerEditorTitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض جديد'**
  String get offerEditorTitle;

  /// No description provided for @offerEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العرض'**
  String get offerEditTitle;

  /// No description provided for @fieldOfferTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان العرض'**
  String get fieldOfferTitle;

  /// No description provided for @fieldLinkedService.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة'**
  String get fieldLinkedService;

  /// No description provided for @fieldDiscount.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الخصم'**
  String get fieldDiscount;

  /// No description provided for @fieldDates.
  ///
  /// In ar, this message translates to:
  /// **'من / لحد'**
  String get fieldDates;

  /// No description provided for @fieldNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get fieldNotes;

  /// No description provided for @composePostTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتب بوست'**
  String get composePostTitle;

  /// No description provided for @fieldPostTitle.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get fieldPostTitle;

  /// No description provided for @fieldPostBody.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى'**
  String get fieldPostBody;

  /// No description provided for @fieldMedia.
  ///
  /// In ar, this message translates to:
  /// **'صورة أو فيديو'**
  String get fieldMedia;

  /// No description provided for @fieldTags.
  ///
  /// In ar, this message translates to:
  /// **'هاشتاجات'**
  String get fieldTags;

  /// No description provided for @fieldVisibility.
  ///
  /// In ar, this message translates to:
  /// **'مين يشوفه؟'**
  String get fieldVisibility;

  /// No description provided for @fieldSchedule.
  ///
  /// In ar, this message translates to:
  /// **'جدولة النشر'**
  String get fieldSchedule;

  /// No description provided for @ctaPublish.
  ///
  /// In ar, this message translates to:
  /// **'انشر'**
  String get ctaPublish;

  /// No description provided for @ctaSaveDraft.
  ///
  /// In ar, this message translates to:
  /// **'احفظ كمسودة'**
  String get ctaSaveDraft;

  /// No description provided for @scheduledPostsTitle.
  ///
  /// In ar, this message translates to:
  /// **'البوستات المجدولة'**
  String get scheduledPostsTitle;

  /// No description provided for @templatesTitle.
  ///
  /// In ar, this message translates to:
  /// **'قوالب جاهزة'**
  String get templatesTitle;

  /// No description provided for @templatesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استخدمها وتعدّل عليها بسرعة'**
  String get templatesSubtitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @notifFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get notifFilterAll;

  /// No description provided for @notifFilterOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get notifFilterOrders;

  /// No description provided for @notifFilterMessages.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل'**
  String get notifFilterMessages;

  /// No description provided for @notifFilterSystem.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get notifFilterSystem;

  /// No description provided for @supportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معانا'**
  String get supportTitle;

  /// No description provided for @fieldSupportName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get fieldSupportName;

  /// No description provided for @fieldSupportEmail.
  ///
  /// In ar, this message translates to:
  /// **'الإيميل'**
  String get fieldSupportEmail;

  /// No description provided for @fieldIssueType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المشكلة'**
  String get fieldIssueType;

  /// No description provided for @fieldSupportDesc.
  ///
  /// In ar, this message translates to:
  /// **'اشرح المشكلة'**
  String get fieldSupportDesc;

  /// No description provided for @fieldAttachment.
  ///
  /// In ar, this message translates to:
  /// **'ملف (اختياري)'**
  String get fieldAttachment;

  /// No description provided for @supportSubmit.
  ///
  /// In ar, this message translates to:
  /// **'ابعت الطلب'**
  String get supportSubmit;

  /// No description provided for @supportSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تمام، وصلنا طلبك'**
  String get supportSuccessTitle;

  /// No description provided for @supportTicketLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم التذكرة'**
  String get supportTicketLabel;

  /// No description provided for @supportNextSteps.
  ///
  /// In ar, this message translates to:
  /// **'هنرجعلك بالتحديث على الإيميل أو من الإشعارات.'**
  String get supportNextSteps;

  /// No description provided for @adminHub.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get adminHub;

  /// No description provided for @adminUsers.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمين'**
  String get adminUsers;

  /// No description provided for @adminServices.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get adminServices;

  /// No description provided for @adminOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get adminOrders;

  /// No description provided for @adminFinance.
  ///
  /// In ar, this message translates to:
  /// **'المالية'**
  String get adminFinance;

  /// No description provided for @adminAnnouncements.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات'**
  String get adminAnnouncements;

  /// No description provided for @adminReports.
  ///
  /// In ar, this message translates to:
  /// **'تقارير'**
  String get adminReports;

  /// No description provided for @sellerTools.
  ///
  /// In ar, this message translates to:
  /// **'أدوات البائع'**
  String get sellerTools;

  /// No description provided for @buyerSection.
  ///
  /// In ar, this message translates to:
  /// **'تسوق'**
  String get buyerSection;

  /// No description provided for @exploreSellers.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف البائعين'**
  String get exploreSellers;

  /// No description provided for @cart.
  ///
  /// In ar, this message translates to:
  /// **'سلة الخدمات'**
  String get cart;

  /// No description provided for @trackOrders.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الطلب'**
  String get trackOrders;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profileTitle;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navServices.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get navServices;

  /// No description provided for @navRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get navRequests;

  /// No description provided for @navOrdersPaid.
  ///
  /// In ar, this message translates to:
  /// **'أوردراتي'**
  String get navOrdersPaid;

  /// No description provided for @navWallet.
  ///
  /// In ar, this message translates to:
  /// **'فلوسي'**
  String get navWallet;

  /// No description provided for @requestTabPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get requestTabPending;

  /// No description provided for @requestTabApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم الموافقة'**
  String get requestTabApproved;

  /// No description provided for @requestTabRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get requestTabRejected;

  /// No description provided for @requestsEmptyPending.
  ///
  /// In ar, this message translates to:
  /// **'مافيش طلبات قيد المراجعة. ابعت طلب من السلة والبياع هيرد 👀'**
  String get requestsEmptyPending;

  /// No description provided for @requestsEmptyApproved.
  ///
  /// In ar, this message translates to:
  /// **'لسه مفيش طلبات متأكدة هنا.'**
  String get requestsEmptyApproved;

  /// No description provided for @requestsEmptyRejected.
  ///
  /// In ar, this message translates to:
  /// **'مافيش طلبات مرفوضة.'**
  String get requestsEmptyRejected;

  /// No description provided for @browseServicesCta.
  ///
  /// In ar, this message translates to:
  /// **'تصفح الخدمات'**
  String get browseServicesCta;

  /// No description provided for @walletLedgerHint.
  ///
  /// In ar, this message translates to:
  /// **'هنا سجل التحويلات والمدفوعات. التحويل بإثبات بيتحقق من الإدارة الأول.'**
  String get walletLedgerHint;

  /// No description provided for @walletTotalSent.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المدفوع'**
  String get walletTotalSent;

  /// No description provided for @walletTotalReceived.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستلم'**
  String get walletTotalReceived;

  /// No description provided for @walletTransactionHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمليات'**
  String get walletTransactionHistory;

  /// No description provided for @walletHistorySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شوف كل التحويلات والحالات'**
  String get walletHistorySubtitle;

  /// No description provided for @walletEmptyState.
  ///
  /// In ar, this message translates to:
  /// **'لسه مفيش عمليات. هتظهر هنا أول ما تتحرك فلوسك.'**
  String get walletEmptyState;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get backToHome;

  /// No description provided for @cartInfoBanner.
  ///
  /// In ar, this message translates to:
  /// **'هتبعت طلبك للبائع الأول، والدفع بيكون بعد ما يوافق 👌'**
  String get cartInfoBanner;

  /// No description provided for @cartSubmitRequest.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get cartSubmitRequest;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'السلة فاضية 😅'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyCta.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ شوف خدمات'**
  String get cartEmptyCta;

  /// No description provided for @homeSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بتدور على إيه؟'**
  String get homeSearchHint;

  /// No description provided for @servicesSearchDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'دور على خدمة'**
  String get servicesSearchDialogTitle;

  /// No description provided for @servicesSearchFieldHint.
  ///
  /// In ar, this message translates to:
  /// **'دور على خدمة…'**
  String get servicesSearchFieldHint;

  /// No description provided for @servicesSearchAction.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get servicesSearchAction;

  /// No description provided for @servicesFilterLabel.
  ///
  /// In ar, this message translates to:
  /// **'فلترة'**
  String get servicesFilterLabel;

  /// No description provided for @badgeDiscount.
  ///
  /// In ar, this message translates to:
  /// **'خصم'**
  String get badgeDiscount;

  /// No description provided for @badgeVip.
  ///
  /// In ar, this message translates to:
  /// **'مرشحه'**
  String get badgeVip;

  /// No description provided for @badgeTopSold.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر طلبًا'**
  String get badgeTopSold;

  /// No description provided for @serviceRequestHelper.
  ///
  /// In ar, this message translates to:
  /// **'هتطلب الخدمة الأول وبعدين تتأكد من السعر قبل الدفع'**
  String get serviceRequestHelper;

  /// No description provided for @orderNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تفاصيل الطلب…'**
  String get orderNotesHint;

  /// No description provided for @favouritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favouritesTitle;

  /// No description provided for @navFavourites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get navFavourites;

  /// No description provided for @orderTabActive.
  ///
  /// In ar, this message translates to:
  /// **'جارية'**
  String get orderTabActive;

  /// No description provided for @orderTabDone.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get orderTabDone;

  /// No description provided for @orderTabCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغية'**
  String get orderTabCancelled;

  /// No description provided for @orderStatusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد التنفيذ'**
  String get orderStatusInProgress;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get orderStatusDelivered;

  /// No description provided for @orderCardCta.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get orderCardCta;

  /// No description provided for @ordersEmptyDone.
  ///
  /// In ar, this message translates to:
  /// **'لسه مفيش أوردرات مكتملة هنا.'**
  String get ordersEmptyDone;

  /// No description provided for @ordersEmptyCancelled.
  ///
  /// In ar, this message translates to:
  /// **'مافيش أوردرات ملغية.'**
  String get ordersEmptyCancelled;

  /// No description provided for @homeHeaderSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شغل يدوي وأكل بيتي على أصوله 👋'**
  String get homeHeaderSubtitle;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
