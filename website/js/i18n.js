/**
 * SMART MUSLIM — INTERNATIONALIZATION & BILINGUAL ENGINE
 * Languages: Arabic (العربية - Default / RTL), English (English / LTR)
 * Zero external libraries • Direct reactive DOM binding
 */

const I18N_DATA = {
  ar: {
    // Navigation
    nav_brand_title: "المسلم الذكي",
    nav_brand_subtitle: "Smart Muslim • صدقة جارية",
    nav_home: "الرئيسية",
    nav_features: "المزايا",
    nav_quran: "القرآن الكريم",
    nav_privacy: "الخصوصية",
    nav_sources: "المصادر",
    nav_roadmap: "خارطة الطريق",
    nav_faq: "الأسئلة الشائعة",
    nav_download: "تحميل التطبيق",
    nav_about: "عن المطور (SBS)",
    nav_other_apps: "برامج أخرى مجانية",
    nav_menu: "القائمة",

    // Hero Section
    hero_badge: "✨ صدقة جارية • بدون إعلانات • بدون تتبع • مجاني 100%",
    hero_title: "المسلم الذكي",
    hero_subtitle: "رفيقك للعبادة والطاعة",
    hero_desc: "تطبيق إسلامي حديث، مبني على الأصالة والصدق واحترام الخصوصية. يجمع المصحف الشريف، مواقيت الصلاة الدقيقة، اتجاه القبلة، وحصن المسلم في تجربة هادئة وسريعة.",
    hero_cta_download: "تحميل التطبيق",
    hero_cta_features: "استكشف المزايا",
    hero_cta_other_apps: "برامج أخرى مجانية ✨",
    hero_availability: "متاح لنظام أندرويد • نسخة الويب الفورية • دعم متصفح أبل",

    // Quran Ayah Motto
    ayah_text: "« قُلْ هَٰذِهِ سَبِيلِي أَدْعُو إِلَى اللَّهِ عَلَىٰ بَصِيرَةٍ أَنَا وَمَنِ اتَّبَعَنِي وَسُبْحَانَ اللَّهِ وَمَا أَنَا مِنَ الْمُشْرِكِينَ »",
    ayah_cite: "— سورة يوسف: آية ١٠٨ —",

    // Trust Pillars (Why Smart Muslim)
    trust_title: "لماذا المسلم الذكي؟",
    trust_subtitle: "أربعة مبادئ راسخة تم بناء التطبيق عليها ليكون رفيقك الإيماني الموثوق",
    trust_1_title: "أصيل وموثق (Authentic)",
    trust_1_desc: "نصوص قرآنية بالرسم العثماني المعتمد من مجمع الملك فهد، وأحاديث نبوية صحيحة بأحكام المحدثين المعتمدة دون أي اجتهادات عشوائية.",
    trust_2_title: "خصوصيتك ليست منتجاً (Private)",
    trust_2_desc: "صفر تتبع تحليلي (Zero Analytics). حساب المواقيت والقبلة يتم محلياً على جهازك دون إرسال إحداثياتك لأي خادم إطلاقاً.",
    trust_3_title: "خالٍ من الإعلانات تماماً (Ad-Free)",
    trust_3_desc: "مشروع خيري غير ربحي وصدقة جارية. لا يحتوي على أي لافتات إعلانية أو اشتراكات تجارية تشتت خشوعك وتركيزك في العبادة.",
    trust_4_title: "يعمل دون إنترنت (Offline-First)",
    trust_4_desc: "المصحف الشريف كاملاً، قاعدة بيانات الأذكار، وحسابات المواقيت الفلكية مدمجة بالكامل لتعمل معك في أي مكان دون الحاجة للاتصال.",

    // Features Section
    features_title: "كل ما تحتاجه في تجربة إسلامية واحدة",
    features_subtitle: "خدمات رقمية مبنية وفق أعلى معايير البرمجة الحديثة والتصميم الهادئ",
    feat_available: "متاح حالياً",
    feat_coming_soon: "قريباً",
    
    feat_1_title: "مواقيت الصلاة الدقيقة",
    feat_1_desc: "حساب فلكي دقيق ومحلي حسب موقعك، مع دعم كافة الطرق المعتمدة (مصر، أم القرى، رابطة العالم الإسلامي، كراتشي وغيرها).",
    feat_2_title: "الأذان والتنبيهات المجدولة",
    feat_2_desc: "تنبيهات للأذان بصوت 14 مؤذناً وقارئاً من الحرمين الشريفين والمسجد الأقصى وكبار المشايخ مع خيارات التكبير فقط.",
    feat_3_title: "اتجاه القبلة الدقيق",
    feat_3_desc: "بوصلة تفاعلية دقيقة توجهك مباشرة نحو الكعبة المشرفة باستخدام مستشعرات البوصلة المدمجة وحسابات الدائرة العظمى.",
    feat_4_title: "المصحف الشريف كاملاً",
    feat_4_desc: "114 سورة و 6,236 آية و 604 صفحات مطابقة لمصحف المدينة النبوية، مع حفظ الفواصل وعلامات القراءة والبحث السريع.",
    feat_5_title: "التسبيح الإلكتروني الذكي",
    feat_5_desc: "مسبحة رقمية مع تفاعل لمسي (اهتزاز)، دورات مسبقة للأذكار (33، 100)، وعداد إحصائي بسيط ومريح للعين.",
    feat_6_title: "الأحاديث النبوية الشريفة",
    feat_6_desc: "باقة الأربعين النووية مخرجة بالسند والمتن مع أحكام الصحة وتخريج الأئمة (البخاري ومسلم) والشرح الفقهي الميسر.",
    feat_7_title: "حصن المسلم والأذكار",
    feat_7_desc: "أذكار الصباح والمساء، أذكار الصلاة والنوم، مدعمة بالأدلة النبوية الصحيحة ودون أي أحاديث ضعيفة.",
    feat_8_title: "المكتبة الإسلامية والكتب العلمية",
    feat_8_desc: "مكتبة متكاملة للكتب الشرعية في العقيدة والفقه والسيرة النبوية بصيغة قابلة للقراءة دون اتصال (قيد التطوير للمرحلة 5).",

    // Quran Section
    quran_section_badge: "المصحف الشريف",
    quran_section_title: "القرآن الكريم — تجربة قراءة هادئة",
    quran_section_desc: "تم تصميم قارئ القرآن الكريم ليوفر بيئة مريحة خالية من أي مشتتات، مع وضوح فائق للخط العثماني وسهولة التنقل بين الأجزاء والسور.",
    quran_stat_1_val: "١١٤",
    quran_stat_1_lbl: "سورة كاملة",
    quran_stat_2_val: "٦,٢٣٦",
    quran_stat_2_lbl: "آية كريمة",
    quran_stat_3_val: "٦٠٤",
    quran_stat_3_lbl: "صفحة مطابقة للمصحف",
    quran_stat_4_val: "١٠٠٪",
    quran_stat_4_lbl: "أوفلاين ومجاني",

    // Privacy Section
    privacy_title: "خصوصيتك ليست ميزة إضافية",
    privacy_subtitle: "صُمم المسلم الذكي ليكون آمناً بالكامل؛ لا نجمع بياناتك ولا نطلب أذونات غير ضرورية",
    privacy_perm_loc_title: "الموقع الجغرافي (GPS):",
    privacy_perm_loc_desc: "يُستخدم حصرياً داخل جهازك لحساب مواقيت الصلاة واتجاه الكعبة، ولا يتم رفعه أو تسجيله في أي خادم خارجي.",
    privacy_perm_notif_title: "الإشعارات الصوتية:",
    privacy_perm_notif_desc: "تُستخدم لجدولة تنبيهات الأذان محلياً عبر نظام الهاتف لتذكيرك بوقت الصلاة في الموعد المحدد.",
    privacy_no_tracking: "خالٍ من حزم التتبع (No Google Analytics / No Firebase Analytics / No Telemetry).",

    // Sources Section
    sources_title: "من أين يأتي المحتوى؟",
    sources_subtitle: "الشفافية الكاملة في مصادر النصوص الدينية والحسابات الفلكية",
    sources_th_domain: "المجال",
    sources_th_source: "المصدر المعتمد",
    sources_th_license: "النسخة والترخيص",
    sources_th_verify: "التحقق والتوثيق",

    // Roadmap Section
    roadmap_title: "خارطة الطريق",
    roadmap_subtitle: "تطور مستمر وواضح لخدمة المستخدمين والمجتمع الإسلامي",
    roadmap_phase_1: "المرحلة الأولى [مكتملة ومحققة]: نواة التطبيق، محرك المواقيت الفلكي، القبلة، وجدولة الأذان.",
    roadmap_phase_2: "المرحلة الثانية [مدمجة حالياً]: المصحف الشريف برسم عثماني موثق، وفواصل القراءة والتفسير الميسر.",
    roadmap_phase_3: "المرحلة الثالثة والرابعة [مدمجة]: الأربعون النووية، أذكار حصن المسلم، والمسبحة الإلكترونية الذكية.",
    roadmap_phase_5: "المرحلة الخامسة [قيد التطوير]: المكتبة الإسلامية والكتب الشرعية وميزات الويدجت لشاشة القفل.",

    // FAQ Section
    faq_title: "الأسئلة الشائعة",
    faq_subtitle: "إجابات واضحة وصادقة حول تطبيق المسلم الذكي ومبادئه",

    // Download Center
    download_title: "تحميل التطبيق",
    download_subtitle: "اختر النسخة المناسبة لنظام تشغيلك واستمتع بتجربة إيمانية متكاملة",
    dl_android_badge: "النسخة الكاملة (موصى بها)",
    dl_android_title: "أندرويد (ملف APK مباشر)",
    dl_android_desc: "التطبيق الكامل بحجم 122 ميجابايت متضمناً كافة أصوات الأذان والإشعارات الخلفية أوفلاين.",
    dl_android_btn: "تحميل للأندرويد (APK مباشر)",
    
    dl_web_badge: "نسخة خفيفة فورية",
    dl_web_title: "تطبيق الويب (PWA)",
    dl_web_desc: "يعمل مباشرة من المتصفح دون استهلاك مساحة الذاكرة، ويدعم كافة الأجهزة.",
    dl_web_btn: "فتح وتشغيل نسخة الويب",
    
    dl_ios_badge: "أجهزة أبل (iOS)",
    dl_ios_title: "أيفون وأيباد",
    dl_ios_desc: "يمكن تشغيل وتثبيت التطبيق كأيقونة مستقلة عبر متصفح Safari بخطوات بسيطة.",
    dl_ios_btn: "طريقة التثبيت على الأيفون 📱",

    // About & SBS Section
    about_title: "عن المطور وشركة SBS",
    about_subtitle: "فريق تطوير تقني متخصص يسخر خبراته لخدمة المجتمع والمشاريع الهادفة",
    about_company_name: "SBS للحلول البرمجية",
    about_company_desc: "شركة برمجية رائدة متخصصة في تطوير الأنظمة الرقمية الحديثة، المواقع الإلكترونية، وتطبيقات الهواتف الذكية بأعلى معايير الجودة والاستقرار.",
    about_visit_btn: "زيارة موقع SBS الرسمي ↗",
    about_portfolio_title: "مجالات العمل والمبادرات المجتمعية:",
    about_item_1: "تطبيق المسلم الذكي (صدقة جارية ومجاني 100%).",
    about_item_2: "Smart CV Builder (أداة احترافية مجانية لإنشاء السير الذاتية).",
    about_item_3: "تطوير الأنظمة السحابية المخصصة وإدارة المؤسسات.",
    about_item_4: "تطبيقات الهواتف الذكية عالية الأداء والخصوصية.",

    // Other Apps Section
    other_apps_title: "برامج وتطبيقات أخرى مجانية",
    other_apps_subtitle: "مبادرات رقمية مجانية ومفتوحة لخدمة الجميع وتسهيل أعمالهم",
    cv_builder_badge: "أداة مهنية مجانية",
    cv_builder_title: "Smart CV Builder (صانع السيرة الذاتية الذكي)",
    cv_builder_desc: "منصة متكاملة وسريعة تتيح لك بناء وتنسيق سيرتك الذاتية بسهولة تامة، مع قوالب عصرية متوافقة مع أنظمة الفرز الآلي (ATS) وقابلة للتنزيل والطباعة المباشرة.",
    cv_builder_btn: "فتح Smart CV Builder ↗",
    more_apps_note: "سيتم إضافة المزيد من التطبيقات والأدوات المجانية الأخرى هنا تباعاً بإذن الله...",

    // iOS Modal
    ios_modal_title: "تثبيت التطبيق على الأيفون",
    ios_modal_desc: "خطوات بسيطة لإضافة التطبيق كأيقونة عادية على شاشتك الرئيسية:",
    ios_step_1: "افتح الموقع في متصفح Safari، ثم اضغط زر المشاركة (Share ⎋) أسفل الشاشة.",
    ios_step_2: "مرر للأسفل في القائمة واختر «إضافة إلى الصفحة الرئيسية» (Add to Home Screen ⊞).",
    ios_step_3: "اضغط على «إضافة» (Add) في الزاوية العلوية، وسيظهر التطبيق كأيقونة مستقلة فوراً.",
    ios_modal_close: "تم، شكراً لك",

    // Footer
    footer_dedication: "هذا التطبيق صدقة جارية عن أبي وأمي وأختي وعني وعن أهل بيتي. نسألكم الدعاء.",
    footer_copyright: "تطوير وإنتاج شركة SBS للحلول البرمجية © 2026. جميع الحقوق محفوظة كوقف خيري.",
  },

  en: {
    // Navigation
    nav_brand_title: "Smart Muslim",
    nav_brand_subtitle: "المسلم الذكي • Sadaqah Jariyah",
    nav_home: "Home",
    nav_features: "Features",
    nav_quran: "Holy Quran",
    nav_privacy: "Privacy",
    nav_sources: "Sources",
    nav_roadmap: "Roadmap",
    nav_faq: "FAQ",
    nav_download: "Download",
    nav_about: "Developer (SBS)",
    nav_other_apps: "Other Free Apps",
    nav_menu: "Menu",

    // Hero Section
    hero_badge: "✨ Perpetual Charity • Ad-Free • Zero Tracking • 100% Free",
    hero_title: "Smart Muslim",
    hero_subtitle: "Your Modern Daily Islamic Companion",
    hero_desc: "A contemporary Islamic application built on authenticity, trust, and privacy. Bringing together the Holy Quran, accurate prayer times, Qibla direction, and prophetic adhkar in a serene, distraction-free interface.",
    hero_cta_download: "Download App",
    hero_cta_features: "Explore Features",
    hero_cta_other_apps: "Other Free Apps ✨",
    hero_availability: "Available for Android • Instant Web PWA • Apple Safari Support",

    // Quran Ayah Motto
    ayah_text: "“Say, 'This is my way; I invite to Allah with insight, I and those who follow me. And exalted is Allah; and I am not of those who associate others with Him.' ”",
    ayah_cite: "— Surah Yusuf: Verse 108 —",

    // Trust Pillars (Why Smart Muslim)
    trust_title: "Why Smart Muslim?",
    trust_subtitle: "Four unshakeable pillars engineered into the core product to safeguard your worship",
    trust_1_title: "Authentic & Verified",
    trust_1_desc: "Canonical Quranic scripture adhering to King Fahd Complex standards, with graded prophetic hadiths sourced strictly from verified heritage scholars.",
    trust_2_title: "Privacy is Not a Product",
    trust_2_desc: "Zero tracking, zero analytics telemetry. Prayer calculations and Qibla azimuth are processed purely on-device without transmitting coordinates.",
    trust_3_title: "Completely Ad-Free",
    trust_3_desc: "An enduring charitable initiative (Sadaqah Jariyah). Completely devoid of commercial banners, popups, or paid subscriptions.",
    trust_4_title: "Offline-First Reliability",
    trust_4_desc: "The complete Quran text, adhkar collections, and astronomical prayer engines reside directly on your phone, working anywhere without internet.",

    // Features Section
    features_title: "Everything You Need in One Serene Experience",
    features_subtitle: "Digital Islamic utilities built with production-grade technology and minimalist clarity",
    feat_available: "Available Now",
    feat_coming_soon: "Coming Soon",
    
    feat_1_title: "Precise Prayer Times",
    feat_1_desc: "Offline astronomical calculation supporting major global conventions (Egypt, Umm al-Qura, MWL, ISNA, Karachi, and Hanafi Asr).",
    feat_2_title: "Adhan & Scheduled Alerts",
    feat_2_desc: "Notifications featuring 14 authentic reciters from Makkah, Madinah, Al-Aqsa, and renowned scholars, with Takbeer-only options.",
    feat_3_title: "Qibla Direction",
    feat_3_desc: "Real-time compass orientation pointing straight to the Holy Kaaba using live magnetometer sensor streams and Great Circle mathematics.",
    feat_4_title: "The Holy Quran",
    feat_4_desc: "All 114 Surahs, 6,236 Ayahs, and 604 pages matching the Madinah Mushaf, with ayah bookmarks, tafsir notes, and instant text search.",
    feat_5_title: "Smart Electronic Tasbeeh",
    feat_5_desc: "Tactile digital counter with haptic feedback, preset dhikr cycles (33, 100), and distraction-free lifetime counting statistics.",
    feat_6_title: "Prophetic Hadiths",
    feat_6_desc: "Al-Arba'in an-Nawawiyyah with complete isnad, authenticity grading (Sahih al-Bukhari & Muslim), and concise juristic commentary.",
    feat_7_title: "Hisn al-Muslim Adhkar",
    feat_7_desc: "Morning, evening, post-prayer, and daily supplications sourced from verified Sunnah, strictly excluding unauthenticated narrations.",
    feat_8_title: "Authenticated Islamic Library",
    feat_8_desc: "Comprehensive e-reader for classic Islamic books across Aqeedah, Fiqh, and Seerah with offline access (In Development for Phase 5).",

    // Quran Section
    quran_section_badge: "The Holy Quran",
    quran_section_title: "The Holy Quran — A Serene Reading Experience",
    quran_section_desc: "Crafted to provide a tranquil atmosphere free from digital noise, with immaculate Uthmani typography and effortless navigation.",
    quran_stat_1_val: "114",
    quran_stat_1_lbl: "Complete Surahs",
    quran_stat_2_val: "6,236",
    quran_stat_2_lbl: "Sacred Ayahs",
    quran_stat_3_val: "604",
    quran_stat_3_lbl: "Canonical Pages",
    quran_stat_4_val: "100%",
    quran_stat_4_lbl: "Offline & Free",

    // Privacy Section
    privacy_title: "Privacy is Not an Add-On",
    privacy_subtitle: "Smart Muslim is engineered to be fully private; we never collect your data or demand unnecessary permissions",
    privacy_perm_loc_title: "Geographic Location (GPS):",
    privacy_perm_loc_desc: "Processed strictly on-device for astronomical prayer times and Qibla azimuth calculation; never logged or sent to servers.",
    privacy_perm_notif_title: "Audio Notifications:",
    privacy_perm_notif_desc: "Used strictly for local prayer alarms and Adhan notifications scheduled by your phone's operating system.",
    privacy_no_tracking: "Free of telemetry SDKs (No Google Analytics / No Firebase Analytics / No Tracking Beacons).",

    // Sources Section
    sources_title: "Where Does the Content Come From?",
    sources_subtitle: "Total transparency regarding religious textual provenance and astronomical calculation algorithms",
    sources_th_domain: "Domain",
    sources_th_source: "Verified Source",
    sources_th_license: "Version & License",
    sources_th_verify: "Verification Standard",

    // Roadmap Section
    roadmap_title: "Product Roadmap",
    roadmap_subtitle: "A transparent and steady commitment to developing high-utility Islamic technology",
    roadmap_phase_1: "Phase 1 [Completed]: Core platform, astronomical calculation engine, Qibla compass, Adhan scheduling.",
    roadmap_phase_2: "Phase 2 [Integrated]: Complete Tanzil Uthmani Quran, bookmarks, reading markers, and concise Tafsir.",
    roadmap_phase_3: "Phase 3 & 4 [Integrated]: An-Nawawi Forty Hadiths, Hisn al-Muslim Adhkar, and Smart Electronic Tasbeeh.",
    roadmap_phase_5: "Phase 5 [In Development]: Scientific Islamic book reader, standalone lock-screen widgets.",

    // FAQ Section
    faq_title: "Frequently Asked Questions",
    faq_subtitle: "Straightforward and honest answers regarding Smart Muslim and its guiding principles",

    // Download Center
    download_title: "Download Smart Muslim",
    download_subtitle: "Select the preferred edition for your device and enjoy a dignified Islamic companion",
    dl_android_badge: "Full Edition (Recommended)",
    dl_android_title: "Android (Direct APK Package)",
    dl_android_desc: "Complete 122MB package containing all 14 Adhan recordings and scheduled offline notification engines.",
    dl_android_btn: "Download for Android (Direct APK)",
    
    dl_web_badge: "Instant Web Edition",
    dl_web_title: "Web Client (PWA)",
    dl_web_desc: "Runs instantly in any modern browser without taking storage space, supporting desktop and mobile.",
    dl_web_btn: "Launch Web Client",
    
    dl_ios_badge: "Apple Devices (iOS)",
    dl_ios_title: "iPhone & iPad",
    dl_ios_desc: "Can be installed and run as a standalone home-screen app via Apple Safari with simple steps.",
    dl_ios_btn: "iOS Installation Guide 📱",

    // About & SBS Section
    about_title: "About the Developer & SBS",
    about_subtitle: "A dedicated software engineering team building meaningful digital solutions for society",
    about_company_name: "SBS Software Solutions",
    about_company_desc: "A leading technology company specializing in modern digital platforms, cloud architectures, and privacy-first mobile applications.",
    about_visit_btn: "Visit Official SBS Website ↗",
    about_portfolio_title: "Active Initiatives & Works:",
    about_item_1: "Smart Muslim Application (Continuous non-profit charity).",
    about_item_2: "Smart CV Builder (Free professional resume builder).",
    about_item_3: "Custom Enterprise Cloud Software & Management Systems.",
    about_item_4: "High-Performance Mobile and Web Applications.",

    // Other Apps Section
    other_apps_title: "Other Free Community Tools",
    other_apps_subtitle: "Free, open tools built to assist everyday users in productivity and career development",
    cv_builder_badge: "Free Professional Tool",
    cv_builder_title: "Smart CV Builder",
    cv_builder_desc: "A fast, privacy-respecting platform to design and generate ATS-compliant professional resumes with modern templates, downloadable instantly.",
    cv_builder_btn: "Open Smart CV Builder ↗",
    more_apps_note: "More free community applications and utilities will be added here progressively, God willing...",

    // iOS Modal
    ios_modal_title: "Installing on iPhone & iPad",
    ios_modal_desc: "Three simple steps to add Smart Muslim to your iOS home screen:",
    ios_step_1: "Open the website in Apple Safari, then tap the Share icon (Share ⎋) at the bottom.",
    ios_step_2: "Scroll down the share sheet and select «Add to Home Screen» (Add to Home Screen ⊞).",
    ios_step_3: "Tap «Add» in the top-right corner; Smart Muslim will appear as a standalone app on your device.",
    ios_modal_close: "Got it, Thank you",

    // Footer
    footer_dedication: "This application is a continuous charity (Sadaqah Jariyah) for my parents, my sister, myself, and my household. We humbly request your prayers.",
    footer_copyright: "Developed & Produced by SBS Software Solutions © 2026. All rights dedicated as a charitable trust.",
  }
};

class I18nManager {
  constructor() {
    this.currentLang = localStorage.getItem('smart_muslim_lang') || 'ar';
  }

  init() {
    this.applyLanguage(this.currentLang);
  }

  setLanguage(lang) {
    if (lang !== 'ar' && lang !== 'en') return;
    this.currentLang = lang;
    localStorage.setItem('smart_muslim_lang', lang);
    this.applyLanguage(lang);
  }

  toggleLanguage() {
    const nextLang = this.currentLang === 'ar' ? 'en' : 'ar';
    this.setLanguage(nextLang);
  }

  applyLanguage(lang) {
    const isRtl = lang === 'ar';
    document.documentElement.lang = lang;
    document.documentElement.dir = isRtl ? 'rtl' : 'ltr';

    // Translate all elements with data-i18n
    const elements = document.querySelectorAll('[data-i18n]');
    elements.forEach(el => {
      const key = el.getAttribute('data-i18n');
      if (I18N_DATA[lang] && I18N_DATA[lang][key]) {
        el.textContent = I18N_DATA[lang][key];
      }
    });

    // Translate all elements with data-i18n-html
    const htmlElements = document.querySelectorAll('[data-i18n-html]');
    htmlElements.forEach(el => {
      const key = el.getAttribute('data-i18n-html');
      if (I18N_DATA[lang] && I18N_DATA[lang][key]) {
        el.innerHTML = I18N_DATA[lang][key];
      }
    });

    // Update language toggle button text
    const langBtn = document.getElementById('lang-toggle-btn');
    if (langBtn) {
      langBtn.textContent = isRtl ? 'English' : 'العربية';
      langBtn.setAttribute('aria-label', isRtl ? 'Switch to English' : 'التحويل إلى اللغة العربية');
    }

    // Dispatch event for UI modules
    window.dispatchEvent(new CustomEvent('languageChanged', { detail: { lang, isRtl } }));
  }

  t(key) {
    return (I18N_DATA[this.currentLang] && I18N_DATA[this.currentLang][key]) || key;
  }
}

window.i18n = new I18nManager();
