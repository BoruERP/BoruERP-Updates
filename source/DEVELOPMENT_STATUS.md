# MiaPaxERP — geliştirme kaydı, 13 Kasım 2026

2.8.3 kaynak ve Windows x64 paket yayını. Ana dal yayını aynı SQL/TLS doğrulamasını tekrar çalıştırır ve başarılı olursa GitHub Releases paketini oluşturur. Otomatik güncelleme için masaüstü dosyaları ZIP kökünde paketlenir. Ana/Yan bildirimleri paket yüklemesinden sonra mevcut yayıncı anahtarıyla imzalanır. Uzak masaüstü kullanılmaz.

## Bu kopyadaki değişiklikler

- HTTPS oturumu, sunucuda kimlik/yetki denetimi ve imzaları açıkça tanımlanmış işlem kataloğu. Uzak masaüstü kullanılmaz.
- Eski stok, üretim, cari, finans, laboratuvar ve yardımcı ekran işlemlerinin sunucu servislerine taşınması; sabit sorgu kimlikleriyle salt okuma köprüsü.
- Satışın stok, cari, muhasebe ve girilmiş tahsilatla aynı işlemde kaydedilmesi; dövizli satış/tahsilat kur farkı.
- Sipariş–mal kabul–alış faturası miktar, fiyat ve KDV eşleştirme işlemleri.
- Depo/raf, parti, rezervasyon, transfer, sayım, üretimde hammadde–mamul parti bağlantıları.
- Dengeli muhasebe fişi, yevmiye, mizan ve aylık dönem kilidi. Kesin fiş değiştirilmez; ters fiş kullanılır. Resmî e-defter onayı iddiası yoktur.
- Sevkiyat/kantar ve boru basınç testi ekranları; fotoğraf/video arşivi, ayrı teknik inceleme, PDF raporu.
- Menü arama ve konum işareti; laboratuvar/kalibrasyon PDF arşivi.
- Makine kapasitesi, reçete/hedef KG üzerinden malzeme ihtiyaç hesabı ve fiilî maliyet kayıtları.
- Hızlı Bilişim, web sitesi, mağaza ve mobil hesap yönetimi için HTTPS sunucu adaptörleri. Sağlayıcı sonuçlarını istemcinin yazabildiği uçlar yayımlanmaz.

## Doğrulama ve kurulum sınırları

- GitHub Windows koşusu 43377312600: 20/20 test geçti, atlanan test yok; tam çözüm 0 uyarı / 0 hata.
- Gerçek TLS oturumu, güvenilmeyen sertifikanın ve yanlış alan adının reddi doğrulandı. Gerçek şifreli SQL bağlantısı geçti.
- İzole veritabanında satış/stok/cari/tahsilat, kısmi döviz ödeme yuvarlaması, geri alma, depo/rezervasyon/sayım değerlemesi, sipariş–kabul–fatura, parti izi, kapasite, fiilî maliyet, dönem kilidi ve bağımsız basınç onayı doğrulandı.
- 163 sabit okuma sorgusu ve kayıtlı HTTPS servis yolları denetlenir. Bu, bütün ekranların müşterinin verisiyle elle denenmiş olduğu iddiası değildir.
- Son mobil yan cihaz koruması, basınç tekrar kaydı ve paketleme de yayın öncesi aynı CI'da tekrar doğrulanır.
- İlk şifre/kurtarma, Excel ve yönetici sıfırlama sunucu akışları kodda mevcuttur; müşterinin gerçek hesap/verileriyle kabul denemesi gerekir.
- MRP boru üretiminin yüzdeli reçete/hedef KG yapısına dayanır; genel çok seviyeli BOM planlayıcısı değildir.
- Hızlı Bilişim hesabı/GİB gerçek gönderimi, mağaza sağlayıcıları ve müşterinin alan adı/modem bağlantısı bu testlerde kullanılmadı. Gerçek anahtarlar müşteri ana sunucusunda girilmelidir.
- Yeni Android APK imzalanmadı. Mevcut imzalı APK HTTPS adresi ve kişisel eşleme koduyla kullanılır; yeni bağlantı kodu desteği kaynakta bulunur.
- Canlı D: kurulumu ve müşteri veritabanı bu kaynak yayını tarafından değiştirilmedi.
- Basınç testi reddedilen parti güvenlik gereği serbest bırakılamaz. Yeniden işleme/teknik uygunsuzluk süreci işletilmeden geçmiş ret yok sayılmaz.

## Elle kurulum

Önce SQL veritabanını ve mevcut kurulum klasörünü yedekleyin. Windows x64 paketini ayrı klasöre açın. Ana bilgisayarda Kolay-Kurulum.cmd ile HTTPS sunucusunu yapılandırın; alan adı ve modem 443 yönlendirmesi ana sunucuya ait olmalıdır. Yan bilgisayarda Masaustu/MiapaxERP.Desktop.exe içindeki bağlantı ekranında HTTPS ana sunucu adresini seçin. SQL portunu internete açmayın. Mevcut lisans ve kullanıcı yetkileri geçerlidir. Yeni modüllerin kurulum işlemi MODULES.INSTALL yetkisi ister. Ana sunucu ve yan cihazların sürümü aynı olmalıdır.

## Derleme ve test

Windows ve .NET 10 SDK ile `MiapaxERP.slnx` çözümünü açın. Yeni test projesi `MiapaxERP.Tests.HTTPS.Integration` klasöründedir. Gerçek bağlantı testlerini çalıştırmadan önce ortamı hazırlayın; geliştirme kaydını üretim kurulumu olarak kullanmayın.

Sunucu anahtarları, şifreli hesap dosyaları, veritabanı dosyaları ve derleme çıktıları kaynak yayınına dahil edilmez.
Boyutu büyük tanıtım videoları, GeoJSON harita verileri ve places.json veri dosyaları bu hızlı kaynak yayınına eklenmedi; mevcut kurulumdaki bu varlıklar kaynak yayınından bağımsızdır.

## 2.8.3 arayüz ve güncelleme düzeltmeleri

Yeni sekiz modül ana ekran içinde açılır; mevcut menü stilini ve seçili temayı kullanır. Depo raf ağacı, muhasebe dönem/mizanı, satın alma satır eşleştirmesi, basınç ölçümleri, sevkiyat rotası, dövizli tahsilat özeti, makine planları ve MRP/maliyet ayrı çalışma alanlarıdır.
Girişteki MiaPaxERP logosu korunur. Stok–üretim–sevkiyat–finans akışını gösteren sessiz çizim animasyonu eklenir; pencere gizlendiğinde durur ve Windows hareket azaltma ayarına uyar.
Bilinen eski BoruERP güncelleme adresi mevcut MiaPaxERP kanalına taşınır; özel sunucu adresleri korunur. Yeni sürüm dosya sürümü 2.8.3.0'dır. Güncelleme paketi mevcut RSA-PSS anahtarıyla doğrulanır; anahtar değiştirilmez.
