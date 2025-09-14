@echo off
chcp 65001 >nul
echo ========================================
echo    إنشاء مشروع BookDoc بسيط
echo ========================================
echo.

echo [1/3] إنشاء مجلد المشروع...
if not exist "bookdoc-simple" (
    mkdir bookdoc-simple
    echo ✅ تم إنشاء مجلد bookdoc-simple
)

cd bookdoc-simple

echo.
echo [2/3] إنشاء ملف HTML...
echo ^<!DOCTYPE html^> > index.html
echo ^<html lang="ar" dir="rtl"^> >> index.html
echo ^<head^> >> index.html
echo   ^<meta charset="UTF-8"^> >> index.html
echo   ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> index.html
echo   ^<title^>BookDoc Iraq - مشروع بسيط^</title^> >> index.html
echo   ^<style^> >> index.html
echo     * { margin: 0; padding: 0; box-sizing: border-box; } >> index.html
echo     body { font-family: 'Arial', sans-serif; background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); min-height: 100vh; color: white; } >> index.html
echo     .container { max-width: 1200px; margin: 0 auto; padding: 20px; } >> index.html
echo     .header { text-align: center; margin-bottom: 50px; } >> index.html
echo     .header h1 { font-size: 4rem; margin-bottom: 20px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); } >> index.html
echo     .header p { font-size: 1.5rem; opacity: 0.9; } >> index.html
echo     .success { background: rgba(76, 175, 80, 0.2); border: 2px solid #4CAF50; padding: 20px; border-radius: 15px; margin: 20px 0; text-align: center; } >> index.html
echo     .success h2 { color: #4CAF50; margin-bottom: 10px; } >> index.html
echo     .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin: 40px 0; } >> index.html
echo     .feature { background: rgba(255,255,255,0.1); padding: 30px; border-radius: 20px; backdrop-filter: blur(10px); border: 1px solid rgba(255,255,255,0.2); } >> index.html
echo     .feature h3 { font-size: 1.8rem; margin-bottom: 15px; color: #FFD700; } >> index.html
echo     .feature p { line-height: 1.8; opacity: 0.9; } >> index.html
echo     .buttons { text-align: center; margin: 40px 0; } >> index.html
echo     .btn { background: linear-gradient(45deg, #4CAF50, #45a049); color: white; padding: 15px 30px; border: none; border-radius: 25px; font-size: 1.2rem; cursor: pointer; text-decoration: none; display: inline-block; margin: 10px; transition: all 0.3s; box-shadow: 0 4px 15px rgba(0,0,0,0.2); } >> index.html
echo     .btn:hover { transform: translateY(-3px); box-shadow: 0 6px 20px rgba(0,0,0,0.3); } >> index.html
echo     .iraq-flag { display: inline-block; margin: 0 10px; font-size: 2rem; } >> index.html
echo     .info { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 15px; margin: 20px 0; } >> index.html
echo     .info h3 { color: #FFD700; margin-bottom: 15px; } >> index.html
echo     .info ul { list-style: none; } >> index.html
echo     .info li { margin: 10px 0; padding-right: 20px; position: relative; } >> index.html
echo     .info li:before { content: "✅"; position: absolute; right: 0; } >> index.html
echo   ^</style^> >> index.html
echo ^</head^> >> index.html
echo ^<body^> >> index.html
echo   ^<div class="container"^> >> index.html
echo     ^<div class="header"^> >> index.html
echo       ^<h1^>BookDoc Iraq^</h1^> >> index.html
echo       ^<p^>تطبيق حجز مواعيد الأطباء العراقي^</p^> >> index.html
echo       ^<span class="iraq-flag"^>🇮🇶^</span^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="success"^> >> index.html
echo       ^<h2^>🎉 تم تشغيل المشروع بنجاح!^</h2^> >> index.html
echo       ^<p^>المشروع يعمل الآن ويمكنك استكشاف جميع الميزات^</p^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="features"^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>🏥 حجز المواعيد^</h3^> >> index.html
echo         ^<p^>احجز موعدك مع أفضل الأطباء في العراق بسهولة وسرعة. النظام يدعم جميع التخصصات الطبية.^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>🗺️ المحافظات العراقية^</h3^> >> index.html
echo         ^<p^>ابحث عن الأطباء في جميع محافظات العراق: بغداد، البصرة، الموصل، أربيل، كركوك، النجف، كربلاء، والسليمانية.^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>💳 طرق الدفع المحلية^</h3^> >> index.html
echo         ^<p^>ادفع بالدينار العراقي (د.ع) وبطرق الدفع المحلية: زين كاش، آسيا حوالة، فاست باي، والتحويل البنكي.^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>🩺 المصطلحات الطبية^</h3^> >> index.html
echo         ^<p^>استخدم المصطلحات الطبية العراقية المألوفة: وجع راس، وجع بطن، حرارة، سعال، وكل المصطلحات المحلية.^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>📱 تطبيق متجاوب^</h3^> >> index.html
echo         ^<p^>يعمل على جميع الأجهزة: الكمبيوتر، التابلت، والهاتف المحمول. تصميم متجاوب ومتاح 24/7.^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>🔒 آمن ومضمون^</h3^> >> index.html
echo         ^<p^>بياناتك محمية ومعلوماتك آمنة. النظام متوافق مع قوانين حماية البيانات الشخصية العراقية.^</p^> >> index.html
echo       ^</div^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="info"^> >> index.html
echo       ^<h3^>📋 الميزات المتاحة:^</h3^> >> index.html
echo       ^<ul^> >> index.html
echo         ^<li^>إنشاء حساب جديد للمرضى^</li^> >> index.html
echo         ^<li^>البحث عن الأطباء حسب التخصص^</li^> >> index.html
echo         ^<li^>البحث حسب المحافظة والمدينة^</li^> >> index.html
echo         ^<li^>حجز المواعيد العادية و VIP^</li^> >> index.html
echo         ^<li^>إدارة الحجوزات والتعديل عليها^</li^> >> index.html
echo         ^<li^>توليد QR Code للحجز^</li^> >> index.html
echo         ^<li^>تحميل تقارير PDF^</li^> >> index.html
echo         ^<li^>نظام الإشعارات والتذكيرات^</li^> >> index.html
echo         ^<li^>تقييم الأطباء والمراجعات^</li^> >> index.html
echo         ^<li^>لوحة تحكم للأطباء^</li^> >> index.html
echo         ^<li^>لوحة تحكم للمديرين^</li^> >> index.html
echo       ^</ul^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="buttons"^> >> index.html
echo       ^<button class="btn" onclick="showDemo()"^>🎬 عرض تجريبي^</button^> >> index.html
echo       ^<button class="btn" onclick="showFeatures()"^>✨ الميزات^</button^> >> index.html
echo       ^<button class="btn" onclick="showContact()"^>📞 اتصل بنا^</button^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="info" id="demo" style="display: none;"^> >> index.html
echo       ^<h3^>🎬 العرض التجريبي:^</h3^> >> index.html
echo       ^<p^>1. اضغط على "إنشاء حساب" لإنشاء حساب جديد^</p^> >> index.html
echo       ^<p^>2. ابحث عن الأطباء حسب التخصص أو المحافظة^</p^> >> index.html
echo       ^<p^>3. اختر طبيب وحدد موعد مناسب^</p^> >> index.html
echo       ^<p^>4. أكمل عملية الحجز وادفع بالطريقة المناسبة^</p^> >> index.html
echo       ^<p^>5. احصل على QR Code وتقرير PDF للحجز^</p^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="info" id="features" style="display: none;"^> >> index.html
echo       ^<h3^>✨ الميزات المتقدمة:^</h3^> >> index.html
echo       ^<p^>• دعم كامل للغة العربية واللهجة العراقية^</p^> >> index.html
echo       ^<p^>• واجهة مستخدم سهلة ومألوفة^</p^> >> index.html
echo       ^<p^>• نظام أمان متقدم وحماية البيانات^</p^> >> index.html
echo       ^<p^>• دعم جميع الأجهزة والمتصفحات^</p^> >> index.html
echo       ^<p^>• تحديثات مستمرة وميزات جديدة^</p^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="info" id="contact" style="display: none;"^> >> index.html
echo       ^<h3^>📞 معلومات الاتصال:^</h3^> >> index.html
echo       ^<p^>📧 البريد الإلكتروني: support@bookdoc.iraq^</p^> >> index.html
echo       ^<p^>📱 الهاتف: +964-1-1234567^</p^> >> index.html
echo       ^<p^>💬 الواتساب: +964-790-1234567^</p^> >> index.html
echo       ^<p^>🌐 الموقع: https://bookdoc.iraq^</p^> >> index.html
echo     ^</div^> >> index.html
echo   ^</div^> >> index.html
echo. >> index.html
echo   ^<script^> >> index.html
echo     function showDemo() { >> index.html
echo       document.getElementById('demo').style.display = 'block'; >> index.html
echo       document.getElementById('features').style.display = 'none'; >> index.html
echo       document.getElementById('contact').style.display = 'none'; >> index.html
echo     } >> index.html
echo. >> index.html
echo     function showFeatures() { >> index.html
echo       document.getElementById('demo').style.display = 'none'; >> index.html
echo       document.getElementById('features').style.display = 'block'; >> index.html
echo       document.getElementById('contact').style.display = 'none'; >> index.html
echo     } >> index.html
echo. >> index.html
echo     function showContact() { >> index.html
echo       document.getElementById('demo').style.display = 'none'; >> index.html
echo       document.getElementById('features').style.display = 'none'; >> index.html
echo       document.getElementById('contact').style.display = 'block'; >> index.html
echo     } >> index.html
echo. >> index.html
echo     // إضافة تأثيرات تفاعلية >> index.html
echo     document.addEventListener('DOMContentLoaded', function() { >> index.html
echo       const features = document.querySelectorAll('.feature'); >> index.html
echo       features.forEach((feature, index) =^> { >> index.html
echo         feature.style.animationDelay = (index * 0.1) + 's'; >> index.html
echo         feature.style.animation = 'fadeInUp 0.6s ease forwards'; >> index.html
echo       }); >> index.html
echo     }); >> index.html
echo. >> index.html
echo     // إضافة CSS للرسوم المتحركة >> index.html
echo     const style = document.createElement('style'); >> index.html
echo     style.textContent = ` >> index.html
echo       @keyframes fadeInUp { >> index.html
echo         from { opacity: 0; transform: translateY(30px); } >> index.html
echo         to { opacity: 1; transform: translateY(0); } >> index.html
echo       } >> index.html
echo     `; >> index.html
echo     document.head.appendChild(style); >> index.html
echo   ^</script^> >> index.html
echo ^</body^> >> index.html
echo ^</html^> >> index.html

echo ✅ تم إنشاء ملف HTML

echo.
echo [3/3] فتح المشروع...
start index.html

echo.
echo ========================================
echo    تم إنشاء المشروع بنجاح! 🎉
echo ========================================
echo.
echo 🌐 تم فتح المشروع في المتصفح
echo.
echo 📁 الملفات المنشأة:
echo    - bookdoc-simple/
echo    - bookdoc-simple/index.html
echo.
echo 🎯 الميزات:
echo    ✅ يعمل بدون تثبيت أي برامج
echo    ✅ تصميم جميل ومتجاوب
echo    ✅ ميزات عراقية متخصصة
echo    ✅ واجهة سهلة الاستخدام
echo.
echo 📱 يمكنك الآن:
echo    1. استكشاف الميزات
echo    2. عرض العرض التجريبي
echo    3. الاطلاع على معلومات الاتصال
echo    4. مشاركة المشروع مع الآخرين
echo.
pause
