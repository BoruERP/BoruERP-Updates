# MiaPaxERP — geliştirme kaydı, 13 Kasım 2026

Bu dal kaynak kodunun geliştirme kopyasıdır. Kuruluma hazır ve bütün ekranları doğrulanmış bir sürüm değildir. Mevcut otomatik güncelleme paketinin yerine geçmez.

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

## Doğrulama ve tamamlanmamış işler

- Yeni kurallar, veri serileştirmesi, işlem kataloğu ve arayüz oluşturma kontrolleri: son kaydedilen koşuda 16 test geçti.
- Çözümün son derlemesi: 0 uyarı, 0 hata. Derlemenin geçmesi gerçek veritabanı akışlarının geçtiği anlamına gelmez.
- Gerçek SQL ve TLS testleri kısıtlı Windows oturumunun Schannel kimlik bilgisi hatası nedeniyle doğrulanamadı. Bunlar başarılı sayılmadı.
- Tam ana pencerenin HTTPS oturumuna geçişi etkinleştirildi. İlk şifre/kurtarma, Excel stok yazma ve yönetici sıfırlama sunucu akışları eklendi; gerçek SQL ortamındaki son doğrulama bekliyor.
- 163 sabit okuma sorgusu ve bütün kayıtlı HTTPS servis yolları için köprü kontrolleri var. Son kaydedilen altyapı koşusunda 730 HTTPS kontrolü geçti; bu sayı TLS atlanan kontrollerini içermez.
- Yeni SQL şeması, gerçek veritabanında işlem/geri alma/eşzamanlılık ve eski verilerle geçiş testinden geçmedi. Canlı veritabanına otomatik uygulanmadı.
- MRP mevcut yüzdeli boru reçetesine dayanır; genel çok seviyeli BOM ve tüm kapasite takvimleri tamamlanmış değildir.
- E-belge sağlayıcısında gerçek hesap, resmî gönderim ve şehir dışı bağlantı testleri yapılmadı. Entegrasyon kodunun bulunması resmî teslimin doğrulandığı anlamına gelmez.
- Bu değişiklikler D: üzerindeki çalışan programa kurulmadı. Yeni kurulum/güncelleme paketi yayımlanmadı.

## Derleme ve test

Windows ve .NET 10 SDK ile `MiapaxERP.slnx` çözümünü açın. Yeni test projesi `MiapaxERP.Tests.HTTPS.Integration` klasöründedir. Gerçek bağlantı testlerini çalıştırmadan önce ortamı hazırlayın; geliştirme kaydını üretim kurulumu olarak kullanmayın.

Sunucu anahtarları, şifreli hesap dosyaları, veritabanı dosyaları ve derleme çıktıları kaynak yayınına dahil edilmez.
Boyutu büyük tanıtım videoları, GeoJSON harita verileri ve places.json veri dosyaları bu hızlı kaynak yayınına eklenmedi; mevcut kurulumdaki bu varlıklar kaynak yayınından bağımsızdır.
