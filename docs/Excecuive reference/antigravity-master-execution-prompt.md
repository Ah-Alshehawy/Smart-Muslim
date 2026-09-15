# Master Prompt — Antigravity / Claude
## Smart Muslim Comprehensive Hardening, Completion & Release Execution

أنت المنفذ الرئيسي لمشروع **Smart Muslim | المسلم الذكي** الموجود في:

`D:\Projects\Smart-Muslim`

تعامل مع هذا الطلب باعتباره **مهمة تنفيذ شاملة End-to-End**، وليس قائمة اقتراحات أو مراجعة نظرية.

لديك وثيقة مرجعية:
`docs/master-improvement-spec.md`

اقرأها أولًا، ثم افحص المشروع الحالي بالكامل قبل تعديل أي شيء.

---

# 0. القاعدة الأساسية

المطلوب هو الوصول إلى **Android Alpha متقدمة قابلة للاستخدام الحقيقي**، مع بنية صحيحة لـiOS مستقبلًا.

لا تكتفِ بإظهار الواجهات.

أي ميزة لا تعمل فعليًا تعتبر:
- Missing
- Broken
- Partial
أو Blocked

ويجب تسجيل حالتها بوضوح.

**ممنوع الادعاء بأن ميزة تعمل لمجرد نجاح build أو unit test.**

---

# 1. ابدأ بالـAudit وليس بالتعديل

افحص أولًا:

- المشروع كاملًا.
- architecture.
- dependencies.
- Android configuration.
- iOS configuration.
- assets.
- database.
- localization.
- navigation.
- BLoCs.
- repositories.
- services.
- notifications.
- audio.
- location.
- sensors.
- Quran data.
- Hadith data.
- Athkar data.
- prayer calculation.
- settings persistence.
- release configuration.
- existing docs.

ثم أنشئ أو حدّث:

`docs/current-state-audit.md`

يحتوي:
- ما يعمل.
- ما لا يعمل.
- ما هو ناقص.
- ما هو placeholder.
- ما هو غير مختبر.
- blockers.
- خطة التنفيذ.

لا تبدأ بحذف أو إعادة كتابة أجزاء تعمل إلا بعد فهمها.

---

# 2. طبّق الوثيقة كاملة

نفّذ كل المتطلبات الموجودة في:

`docs/master-improvement-spec.md`

ولا تتجاهل البنود المتعلقة بالبيانات أو الاختبارات أو الإصدارات.

---

# 3. الصلاة والمواقيت — P0

راجع المنظومة بالكامل.

تحقق من:
- الموقع.
- timezone.
- date.
- calculation method.
- madhab.
- Asr method.
- high latitude handling إن لزم.
- adjustments.
- daylight saving/timezone changes.
- next prayer.
- countdown.

يجب أن تكون إعدادات المستخدم حقيقية ومتصلة بالـdomain/repository/database.

لا تترك إعدادات شكلية لا تؤثر في الحساب.

أنشئ اختبارات مرجعية لمواقع معروفة، مع توثيق طريقة الحساب.

---

# 4. الموقع والمدن — P0

نفّذ:
- automatic location.
- last-known-position fallback.
- timeout مناسب.
- manual selection.
- country/region/city.
- city search.
- coordinates.
- timezone.
- Arabic/English labels.

وفّر Dataset منظمًا وقابلًا للتوسع.

بالنسبة لمصر، يجب ألا تكون البيانات محصورة في القاهرة والإسكندرية؛ غطِّ المحافظات والمدن المطلوبة وفق مصدر جغرافي مناسب.

لا تضع آلاف السجلات داخل UI code.

---

# 5. القبلة — P0

أعد بناء Qibla Compass end-to-end.

لا تستخدم قيمة bearing ثابتة كحل.

يجب:
- قراءة sensors.
- تحديث heading حيًا.
- حساب Qibla bearing من موقع المستخدم.
- عرض heading الحالي.
- عرض Qibla bearing.
- تدوير المؤشر.
- معايرة/تعليمات.
- معالجة sensor unavailable.
- التعامل مع true/magnetic north بما يتوافق مع المكتبة والمنصة.

أضف tests للحساب الرياضي.

ثم قم بتمييز:
`Automated Verified`
عن
`Physical Device Verified`.

إذا لم يتوفر جهاز حقيقي أثناء التنفيذ، لا تضع Physical PASS.

---

# 6. الآذان والصوت — P0

هذه من أهم المهام.

الصوت الحالي لا يعمل.

افحص:
- pubspec assets.
- Android resources.
- notification channels.
- audio player.
- audio focus.
- permissions.
- scheduling.
- alarm/notification payload.
- background playback.
- locked screen.
- terminated app.
- reboot.
- timezone/date changes.

أضف:
**Test Audio** لكل صوت.

وفّر تخصيصًا لكل صلاة:

الفجر / الظهر / العصر / المغرب / العشاء

ولكل صلاة:
- notification ON/OFF.
- pre-prayer ON/OFF.
- pre-prayer duration.
- adhan ON/OFF.
- audio selection.
- full adhan / takbeer-only where supported.
- iqama ON/OFF.
- iqama delay.
- app-level silence duration:
  OFF → 5 → 10 → 15 → 30 → OFF.

اجعل الإعدادات persistent.

**لا تدّعِ التحكم الكامل في system volume أو DND إذا كانت المنصة لا تسمح به دون صلاحيات.**

تحقق من ملفات الصوت وحقوق استخدامها.

إذا كانت التسجيلات الحالية غير قابلة لإعادة التوزيع قانونيًا، لا تعتمد عليها لمجرد أنها تعمل؛ سجّل blocker واستبدلها بمصدر مرخص.

---

# 7. الصفحة الرئيسية — P0/P1

أعد ترتيب Dashboard بحيث تظهر الصلوات الخمس في الشاشة الحالية دون scroll في أحجام الهواتف المستهدفة قدر الإمكان.

لا تصغر الخط بشكل يضر usability.

بطاقة الصلاة القادمة تعرض:
- next prayer.
- countdown.
- city.
- automatic/manual location.
- notification status.

بجوار كل صلاة:
- وقت.
- notification state.
- settings button.

---

# 8. القرآن — P0/P1

أكمل Dataset القرآن.

يجب أن يكون:
- كاملًا.
- موثق المصدر.
- مرخصًا لإعادة التوزيع.
- integrity-validated.

**ممنوع استخدام AI لتوليد أو استكمال النص القرآني.**

أضف:

### Mode A
Text Reading.

### Mode B
Mushaf/Page View
يحاكي المصحف، مع نسخة بيانات/صور/خط موثقة قانونيًا.

### Mode C
Compact View.

صمّم domain بحيث يمكن لاحقًا إضافة:
- translations.
- reciters/audio.

لا تضف الصوت الآن.

أضف:
- search.
- last read.
- bookmarks.
- surah information.
- page navigation حيث يدعمها الإصدار.

لا تفترض أن كل editions تستخدم نفس ayah numbering.

---

# 9. الأذكار — P1

وسّع قاعدة الأذكار الثابتة الموثقة.

لكل ذكر:
- النص.
- category.
- count.
- source.
- book.
- hadith number if applicable.
- grading.
- grading source.
- verification status.

أضف:
- search.
- favorites.
- counter.
- progress persistence.
- daily wird.

لا تخلط الضعيف بالصحيح/الثابت.

---

# 10. الحديث — P1

حوّل القسم إلى مكتبة حديثية حقيقية.

أضف مجموعات الكتب ومصادر السنة.

يجب أن تفصل بين:
**Book Source**
و
**Hadith Grading**

لكل حديث:
- full text.
- narrator.
- source.
- book.
- chapter.
- source number.
- grading.
- grading source.
- takhrij.
- topics.
- variants where appropriate.
- verification state.
- license/source metadata.

أضف:
- global search.
- source filters.
- grading filters.
- topics.
- favorites.
- last read.
- copy/share with source.
- multi-source view.
- mutafaq alayhi indicator where justified.

لا تدخل كتبًا منسوبة إلى مؤلفين دون التحقق من صحة النسبة والنسخة والترخيص.

---

# 11. Splash وAbout/Contact

استبدل نص Splash بالنص المطلوب:

**صَدَقَةٌ جَارِيَةٌ ... نَسْأَلُكُمُ الدُّعَاءَ**

استخدم التشكيل.

أضف بيانات المطور في موضع مناسب:

**Developed by:**  
**Eng. Ahmed Alshehawy**  
+201006765695  
ah.alshehawy@gmail.com

وفي «اتصل بنا»:

**Smart Business Solutions (SBS)**  
+201553853030  
info@sbs.net

لا تجعل Splash مزدحمة.

---

# 12. UI/UX

راجع جميع الشاشات بعد تنفيذ الوظائف.

يجب:
- الحفاظ على الهوية الحالية حيث هي جيدة.
- إزالة الازدحام.
- تحسين hierarchy.
- تحسين switches/icons.
- دعم RTL/LTR.
- Light/Dark.
- loading/error/empty/success.
- responsive layouts.
- accessibility.
- عدم الاعتماد على اللون وحده.
- localization لكل النصوص.

لا تستخدم strings ثابتة داخل widgets إذا كان يجب ترجمتها.

---

# 13. Content Governance

حدّث:

- `docs/data-sources.md`
- `docs/content-governance.md`
- `docs/quran-data-validation.md`
- أي docs ذات صلة.

لكل dataset ديني:
Source → License → Integrity → Review → Metadata → Import → Validation → Release.

لا تجعل AI مصدرًا للمحتوى الديني.

---

# 14. نظام الإصدار — يجب تنفيذه الآن

من هذه النقطة لا يوجد build مجهول.

كل build يجب أن يحمل:
- semantic version.
- unique increasing build number.
- channel.
- timestamp.
- commit hash إذا توفر.
- test status.

ابدأ من النسخة المناسبة للحالة الحالية، مثل:

`0.2.0-dev.1`

ثم:
`0.2.0-dev.2`
...

عند جاهزية Alpha:
`0.2.0-alpha.1`

لا تقفز مباشرة إلى Production.

---

# 15. Release Pipeline محلي

أنشئ سكربت/أداة مناسبة للمشروع لتنفيذ:

1. clean.
2. pub get.
3. analyze.
4. test.
5. build release.
6. collect artifact.
7. calculate SHA-256.
8. collect file size.
9. collect version/build metadata.
10. generate release manifest.
11. append project history.
12. copy artifact إلى مجلد الإصدار دون حذف النسخ القديمة.

إذا أمكن، أنشئ:
`tool/release.dart`
أو حلًا مناسبًا للبيئة الحالية.

---

# 16. Releases

أنشئ:

```text
releases/
  dev/
  alpha/
  beta/
  rc/
  stable/
```

كل إصدار يجب أن يحتفظ بنسخته.

مثال:

```text
releases/dev/
  smart-muslim-0.2.0-dev.1-arm64-v8a.apk
  smart-muslim-0.2.0-dev.1-manifest.json
  smart-muslim-0.2.0-dev.1-sha256.txt
```

إذا تم بناء universal APK بدل split-per-ABI، وثّق ذلك ولا تخفيه.

---

# 17. التاريخ والـChangelog

أنشئ وحدث دائمًا:

`docs/project-history.md`

و:

`CHANGELOG.md`

كل release أو إصلاح مهم يجب أن يسجل.

مثال:

```markdown
## 2026-09-02 — 0.2.0-dev.1

### Type
Release

### Added
- ...

### Fixed
- ...

### Changed
- ...

### Tests
- flutter analyze: PASS
- flutter test: PASS
- Physical device: NOT VERIFIED

### Artifact
- ...

### SHA-256
- ...
```

لا تعدّل الماضي بطريقة تمحو الأحداث؛ أضف إدخالات جديدة.

---

# 18. الاختبارات

نفّذ على الأقل:

### Unit
- prayer calculations.
- Qibla bearing.
- settings state.
- data validation.

### Integration
- location → prayer.
- location → qibla.
- settings → scheduler.
- Quran database.
- Hadith database.
- Athkar database.

### UI
- navigation.
- RTL.
- LTR.
- dark/light.
- loading/error states.

### Android physical
إذا كان الجهاز متاحًا:
- location.
- qibla rotation.
- audio.
- notifications.
- locked screen.
- terminated app.
- reboot.
- persistence.

أي اختبار لم يتم فعليًا يجب أن يسجل:
`NOT VERIFIED`.

---

# 19. لا تتوقف عند أول نجاح

بعد كل مجموعة تغييرات:

`flutter analyze`
ثم
`flutter test`
ثم build.

إذا فشل شيء:
- أصلحه.
- أعد الاختبار.
- سجّل السبب إذا كان مهمًا.

لا تترك المشروع في حالة build غير مستقرة.

---

# 20. قاعدة عدم الكذب في التقارير

في التقرير النهائي استخدم هذه الحالات فقط:

- IMPLEMENTED
- AUTOMATED VERIFIED
- PHYSICALLY VERIFIED
- PARTIAL
- BLOCKED
- NOT TESTED

ممنوع كتابة PASS لميزة لم تُختبر فعليًا عندما يتطلب اختبارها جهازًا حقيقيًا.

---

# 21. لا تنتظر أسئلة مني أثناء التنفيذ

لديك تفويض لاتخاذ القرارات التقنية المعقولة.

إذا وجدت خيارين:
اختر الأنسب للإنتاج، ووثّق القرار في:
`docs/decisions.md`

إذا كان هناك blocker خارجي مثل:
- license.
- unavailable iOS hardware.
- missing legally redistributable audio.

لا تخترع حلًا.

سجّل:
- المشكلة.
- أثرها.
- البدائل.
- الحل المؤقت إن وجد.
- ما يلزم لإغلاقها.

ثم واصل بقية العمل.

---

# 22. بعد التنفيذ

أنشئ تقريرًا نهائيًا:

`docs/comprehensive-hardening-report.md`

يحتوي على:

1. Executive Summary.
2. What was implemented.
3. What was fixed.
4. Content completeness.
5. Audio status.
6. Qibla status.
7. Prayer calculation status.
8. Location status.
9. Quran status.
10. Hadith status.
11. Athkar status.
12. Tests.
13. Physical tests.
14. Release artifacts.
15. Version/build.
16. SHA-256.
17. Known limitations.
18. Remaining blockers.
19. Next recommended milestone.

وفي نهاية التقرير:
**لا تكتب Production Ready إلا إذا كانت الشروط فعلًا مستوفاة.**

---

# 23. أهم شرط

في نهاية هذا العمل يجب أن أحصل على:

- مشروع منظم.
- وظائف حقيقية.
- بيانات دينية موثقة.
- إعدادات محفوظة.
- آذان يعمل فعليًا حيث تسمح المنصة.
- قبلة تعمل فعليًا على الجهاز عند اختبارها.
- قرآن أساسي مكتمل.
- مكتبة حديث قابلة للتوسع.
- أذكار موسعة وموثقة.
- مدن ومواقع منظمة.
- APK قابلة للتثبيت.
- سلسلة إصدارات.
- سجل تاريخي دائم.
- changelog.
- release manifest.
- checksum.
- تقرير صادق عن الحالة.

**ابدأ الآن بالفحص الشامل، ثم التنفيذ، ثم الاختبارات، ثم الإصدار. لا تكتفِ بخطة أو تقرير نظري.**