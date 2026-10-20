# BİLİNEN SORUNLAR

Durum: **TAM-PAKET** (`/storage/emulated/0/Ringtones/TAM-PAKET/`) alındıktan sonra güncellendi.
Paketteki `11_AGENT_CEVAPLAR_A-E.md` birkaç eski varsayımı **çürüttü**; aşağıda doğrusu yazılı.

---

## 1. Model dosyaları — DÜZELTME: 95 değil, **9** eksik

`.gitignore` içinde `*.glb` var, bu yüzden GitHub deposu **hiç** `.glb` içermiyor
(100 adet `.glb.import` yan dosyası var ama kaynak yok). Kullanıcının elinde orijinal
arşiv de **yok** — aramak/istemek gereksiz.

**Ama bu bir sorun değil.** Sahneler tek tek taranmış:
- 13 ana sahnenin **10'unda `.glb` referansı SIFIR**. Modeller sahne dosyalarına
  `ArrayMesh` **sub-resource olarak gömülü** (`floor1hallWay`: 63 gömülü mesh, `.glb`
  geçişi 0; `kitchen` ve `room3` de aynı). Sahne dosyalarının 20–80 MB olmasının sebebi bu.
- Yani oyun "çoğu sahnede modelsiz" **açılmıyor**. Ev, mutfak, canavar — hepsi sahnenin içinde.
- Gerçekten eksik olan **9 model** var (`ext_resource` olarak referanslı ama dosyası yok):

| Model | Sahne | Öncelik | Sonuç | Çözüm |
|---|---|---|---|---|
| `Basement/devils_roulette_-_syringe.glb` | `Basement.tscn` | **YÜKSEK** | Bodrumdaki şırınga görünmez — SON B hikâye objesi | Sketchfab / itch PCK; geçici 2 silindir primitif zaten G28'de var |
| `Dream/copper_tea_pot.glb` | `dream_HappyKitchen.tscn` | ORTA | Çay sahnesinde demlik görünmez — çay motifi | Sketchfab "copper tea pot" veya primitif gövde+ağız |
| `Basement/cassette_player.glb` | `Basement.tscn` | ORTA | Kaset çalar prop görünmez | Sketchfab; dokuları repoda var (`cassette_player_*.jpg/png`) |
| `Basement/vhs_tape.glb` | `Basement.tscn` | DÜŞÜK | VHS kaset prop görünmez | İnce kutu primitif + mevcut doku |
| `Basement/vhs_tape_rip.glb` | `Basement.tscn` | DÜŞÜK | Yırtık VHS prop görünmez | Primitif yeterli |
| `Basement/old_paper__cardboard_boxes.glb` | `Basement.tscn` | DÜŞÜK | Karton kutular görünmez | Kutu primitif + `old_paper` dokuları repoda |
| `Basement/carpet (5).glb` | `Basement.tscn` | DÜŞÜK | Halı görünmez | Düzlem + halı dokusu |
| `Basement/rewinders_3dst19.glb` | `Basement.tscn` | DÜŞÜK | Dekor cihaz görünmez | Primitif veya atla |
| `room2/old_glass_ceilling_lamp.glb` | `room2.tscn` | DÜŞÜK | Tavan lambası görünmez (ışık düğümü ayrıysa oyun etkilenmez) | Küre + silindir primitif |

Çözüm sırası: (1) itch build'indeki `.pck`'den çıkarmak (GDRE Tools PRoot Ubuntu'da çalışır),
(2) Sketchfab'da birebir isimle aramak (dokular repoda, eşleşmeyi onlarla doğrula),
(3) primitif ikame (şırınga/demlik hariç hepsinde yeterli).

> **91 yetim `.import` dosyasının peşine DÜŞME.** `birthday_love_letter.glb`,
> `psx_style_cassette_tape.glb`, `pistol.glb`, `abandoned_kitchen.glb` vb. hiçbir sahnede
> referanslı değil. G28 için gerekmezler — o mesh'ler `letter1`/kaset düğümlerinin içinde
> gömülü, editörde düğümü kopyalamak mesh'i de taşır.

---

## 2. Objectives sistemi **yok** — G23 atlanıyor

Doğrulandı: orijinal repoda da `Objectives`'in kaynak dosyası yok; autoload UID'si
boşluğa işaret ediyordu. `globalTools/Objectives.tscn` benim yarattığım **84 baytlık stub**:
```
[gd_scene format=3 uid="uid://blncchl6c3ldv"]
[node name="Objectives" type="Node"]
```
Kullanıcıda da gerçek bir hedef HUD tasarımı yok.

**Karar (paket madde E):** G23'teki fallback geçerli — **sadece monolog ipuçlarıyla
(G24/G25) ilerle.** `obj_journal`, `obj_birds`, `obj_tapes`, `obj_room3` anahtarları
`lang.csv`'de zararsızca dursun, **UI'a bağlama**.

> **Stub'ı SİLME** — autoload kırılır. Olduğu gibi bırak.

Sonuç: oyuncuya "3 kuş var, 5 günlük var, 2 kaset var" diyen hiçbir arayüz olmayacak.
Keşif tamamen monolog ipuçlarına kalıyor. Bu bilinçli bir tercih.

---

## 3. Font — Arapça ve Türkçe glif riski

Proje fontları (**Horror Brush**, **Glacial Indifference**) Arapça glif **içermez**.
Arapça seçildiğinde kutular (□) görülebilir.

- Godot 4 `TextServer` RTL şekillendirmeyi **yapar**; sorun yalnızca glif eksikliğidir.
- Çözüm tek hamlede: **Noto Sans** (Türkçe dâhil Latin) + **Noto Sans Arabic** `.ttf`
  dosyalarını projeye ekleyip temada **fallback font** olarak tanımla. Ana korku fontu
  kalır, eksik harfler fallback'ten gelir.
- Test: dil menüsünden Türkçe → `forest_s2` satırındaki **ş / ı / ğ** harfleri;
  Arapça → aynı satırın sağdan sola düzgün bağlanması.

Bu fontlar şu an projede **yok**. Eklenmeleri gerekiyor.

---

## 4. Çeviri tablosu durumu

| Kaynak | Satır | İçerik |
|---|---|---|
| `04_lang.csv` | 93 | 92 temel anahtar, sadece `en` |
| `13_lang_TAM_en_ar.csv` | 109 | 108 anahtar, `keys,en,ar` — **gerçek Arapça** |
| `12_arapca_ceviri.csv` | 109 | 108 anahtar, `anahtar;ar` |
| `15_turkce_ceviri.csv` | 109 | 108 anahtar, `anahtar;tr` — **gerçek Türkçe** |
| `10_lang_EK.csv` | 17 | 16 cila anahtarı, sadece `en` |
| **projedeki `lang.csv`** | 98 | 97 anahtar, `keys,en,ar` — `ar` sütunu `en`'in kopyası |

**Eksik dosya:** `17_ISIM_VE_TURKCE.md` "proje köküne `16_lang_TAM_en_ar_tr.csv` koy"
diyor ama **zip'te `16_*` yok**. `13` + `15`'ten birleştirilerek üretilmesi gerekiyor.

**Hedef tablo:** `keys,en,ar,tr` — **113 anahtar** (108 paket + 5 bende olan).

### Pakette olmayan 5 anahtar (çevirisi istenecek)
```
LOADING   → "LOADING"
P_1       → "PAUSED"
P_2       → "CONTINUE"
P_3       → "MAIN MENU"
P_4       → "QUIT"
```
> Bu beşi ayrıca **kodda hiçbir yerde kullanılmıyor** (grep doğrulandı). Pause menüsü
> ve yükleme ekranı için spekülatif eklenmişlerdi. Zararsızlar; talimat gereği
> `ar`/`tr` sütunlarına şimdilik `en` metni kopyalanacak, **boş bırakılmayacak**.

### Bende olmayan 16 anahtar (paketten eklenecek)
`hint_room3`, `journal_hint_2..5`, `journal_hint_tapes`, `bath_syringe_hint`,
`hint_syringe_missing`, `obj_journal`, `obj_birds`, `obj_tapes`, `obj_room3`,
`epi_1`, `epi_a`, `epi_b`, `epi_3`

### Çeviride bilinçli uyarlama
`monster_word`: duvara kazınmış üç harf İngilizce **T. E. A.**, Arapça **ش. ا. ي.**
(şay = çay), Türkçe **Ç. A. Y.** Üç dilde de çay motifine bağlanıyor — çeviri hatası değil.

Ayrıca `YOU` hitabı Türkçe'de **SEN** olarak uyarlanmış (`SEN: Zihnim bomboş...`).

---

## 5. Seslendirme — tasarım gereği sessiz

**Karar (paket madde D):**
- Yeni 16 anahtarın hepsi + `phone2_1` + `phone_last` **tasarım gereği sessiz**.
  Oyunda YOU iç monologları zaten hiç seslendirilmedi, sadece altyazı. Bunlara ses **arama**.
- Ses olmayınca gerçekten eksik kalan tek grup: **`tape1_1, tape1_2, tape2_1, tape2_2, tape2_3`**
  (ağabeyin araştırma kasetleri — diegetik kayıt).
- Plan: kaset çalar sesi + düşük statik + altyazı (satır başına 4–5 sn).
- ElevenLabs yolu kullanıcıda var ama **bu turda kullanılmayacak**. Akış
  *"ses dosyası varsa çal, yoksa statik+altyazı"* şeklinde kurulacak ki sonra dosya
  bırakmak yeterli olsun.

Onaylanan mevcut dosyalar:
```
assets/House/Floor2/Bedrooms/room2/freesound_community-tape-player-sounds-90780.mp3   kaset çalar
assets/House/Floor2/Bedrooms/room2/fe_da_silva-white-noise-179828.mp3                  white noise
assets/House/Floor2/hallWay/a55b9e2e-...(mp3cut.net).wav                               cry → pitch_scale 0.85
assets/Dream/freesound_community-garden-sunny-day-54490.mp3                            epilog ✅
```

`Sounds/` altındaki 8 mp3 **ikame kopya** — repoda bulunamayan ortam sesleri için
geçici olarak konuldu. Orijinalleri bulunursa değiştirilecek.

---

## 6. G28 — 30 placeholder kutu

Eklenen **30 etkileşimli düğümün hepsi** şu an 10 cm'lik `BoxMesh` + **emissive**
`StandardMaterial3D`. Oyuncu "tahta kuş" değil, parlayan bir küp görüyor.

G28'in eşleştirme tablosu (`09_AGENT_TALIMAT_CILA.md`) repodaki **hazır varlıkları**
kullanmayı söylüyor — `.glb` indirmek gerekmiyor:

| Nesne | Kaynak |
|---|---|
| Günlük sayfaları, mektuplar, tarif | `letter1` düğümünün mesh'i (sahnede gömülü); doku `assets/House/Floor1/storageRoom/birthday_love_letter_*` |
| Kasetler (TAPE-01/02) | Library'deki kaset mesh'inin kopyası; doku `assets/House/Floor2/Library/psx_style_cassette_tape_0.jpg` |
| Şırınga | 2 primitif: gövde `CylinderMesh` (beyaz) + iğne ince silindir (metalik). Açık kutuda, ayna yanında |
| Tahta kuşlar (3 varyant) | Primitif set: gövde (yassı küre) + baş (küre) + gaga (koni) + kanat (ince kutu); `painted_wooden_door` dokusu kahverengi tint. Varyantlar: tam / tek kanat (attic) / kaba-eğri ölçek (canavar hediyesi) |
| Doz çizelgesi | Duvarda `PlaneMesh` + `old_paper__cardboard_boxes` dokularından biri |
| TEA duvar yazısı | `Label3D`, koyu gri, duvara 2–3 cm mesafe; veya aynı kağıt dokusuyla decal düzlemi |
| **Genel** | Tüm inspect kutularından `emissive` kaldır; hover simgesi bulunabilirlik için yeterli |

---

## 7. Koordinatlar tahmin

30 düğümün `transform` değerleri **oyun oynanmadan** yazıldı (bkz. [EKLEMELER.md](EKLEMELER.md)).
Bir kısmı duvarın içinde, zeminin altında ya da erişilemeyen yükseklikte olabilir.
Özellikle şüpheli olanlar:
- `storageRoom → woodenBird` / `journal01` → `y = 5.2` (depo tavanına yakın olabilir)
- `Library → journal02` → `y = 4.5`
- `bathroom` düğümleri → `-49.7, 103.05, -47.89` (banyo sahnesinin ölçeği farklı, `-49/103` gerçekçi görünüyor ama doğrulanmadı)
- `attic.tscn` tamamen primitif → duvar kalınlığı yüzünden **ışık sızdırma** riski

---

## 8. Altyazı Label yolu doğrulanmadı

`Speech.say(label, key)` Label'ın `text`'ine **anahtarı** yazar; çevirinin görünmesi
Label'ın `auto_translate` ayarına bağlı. Anahtar bulunamazsa **ham anahtar ekranda görünür**
— bu bir hata belirtisidir ve test A'daki ilk madde tam olarak bunu kontrol eder
("forest_s1..s4 cümle olarak görünüyor, anahtar değil").

İki göreli yol oynanarak test edilmedi:
- `Scripts/Phone.gd` → `$"../extraSpeech/line"`
- `Scripts/monster.gd → _line()` → `$"../../../extraSpeech/line"`

**Mantık doğrulaması (paket madde 1):** `cry` kökte (`parent="."`) ve script `$"../cry"`
diyorsa, Phone düğümünün kendisi de kökün **direk çocuğu** olmak zorunda (`../` = kök).
`extraSpeech` köke eklendiği için `$"../extraSpeech/line"` **doğru**.
`monster.gd`'de orijinal kod `$"../../../Player"` kullanıyor ve `Player` kökte — üç `../`
köke çıkıyor demek; `extraSpeech` kökteyse o da doğru.
> Yine de iki sahnede de `grep 'name="extraSpeech"'` ile `parent="."` olduğu doğrulanacak
> ve gerçek oyunda bir kez (telefon 2. olay + `lucid_1`) görünürlük test edilecek.

---

## 9. `.godot/` cache iç içe geçmiş

`cp -r` hedefteki stub klasörün **içine** kopyaladı:
```
.godot/.gdignore          ← benim başarısız import denemelerimden
.godot/editor/            ← stub
.godot/imported/          ← stub, 0 dosya
.godot/.godot/imported/   ← GERÇEK cache, 1.4G, 24 glb-kaynaklı dosya
.godot/.godot/uid_cache.bin  ← 68552 bayt
```
Sonuç: `Main scene's path could not be resolved from UID`, `Error loading custom project
theme 'uid://b531pkflj2f7d'`, `local_path.is_empty()`.

**Çözüm:** `.godot/.godot/*` içeriğini bir üst seviyeye taşı, boş iç klasörü sil.

> ⚠️ **`.godot`'u SİLME** — telefonda uzun reimport demek. Yedek almadan silme.

---

## 10. Godot editörü bu ortamda çöküyor

Godot **4.7.2-stable linux.arm64** indirildi ve çalışıyor, ama **editör / `--import` yolu
çöküyor**: `double free or corruption (out)`, exit 134. **Boş bir projede de** üremiyor,
yani proje hatası değil. `LD_PRELOAD=libjemalloc` ile gerçek hata ortaya çıktı:
`FATAL: Index p_index = 1 is out of bounds (size() = 0)` @ `core/templates/cowdata.h:197`,
"Regenerating editor help cache" sırasında.

Denenen ve **işe yaramayan** yollar: `--headless`, Xvfb + gerçek display + `--editor`,
`--rendering-driver dummy`, `taskset -c 0`, `ulimit -s unlimited`, `MALLOC_CHECK_=0`.

**Çalışan yol:** runtime. Xvfb `:99` + llvmpipe (OpenGL 4.5 Compatibility, Mesa 26.0.8)
projenin `gl_compatibility` renderer'ı için yeterli. Yani oyun **oynanabilir/kaydedilebilir**,
sadece editör açılamıyor.

---

## 11. İki proje kopyası ayrışmış

| Yol | Durum |
|---|---|
| `/root/After-the-threshold` | Git takipli, tüm düzenlemeler burada. `.godot` iç içe (madde 9) |
| `/storage/emulated/0/After-the-threshold` | Android Godot editörünün açtığı kopya; `.godot` + `lang.*.translation` **burada üretildi**. `.git` yok (depodaki 3 pack symlink'i kırıktı) |

`project.godot`'daki `locale/translations` satırı **her iki kopyada da aktif**
(`git diff --stat -- project.godot` boş). `09_AGENT_TALIMAT_CILA.md`'deki "satır yorumda"
tespiti **artık geçerli değil** — doğrulandı.

G21 yine de bitirilmeli: esas kopya ilan edilecek, diğeri `arsiv_YYYY-AA-GG` diye
yeniden adlandırılacak, tarihli zip yedeği alınacak.

---

## 12. Henüz yapılmamış işler

| Konu | Durum |
|---|---|
| `garden_1`, `garden_2`, `epi_1`, `epi_a`, `epi_b`, `epi_3` | `lang.csv`'de yazılı, **hiçbir yere bağlı değil** → G27 |
| `obj_journal`, `obj_birds`, `obj_tapes`, `obj_room3` | Yazılı, **bağlanmayacak** (madde 2 kararı) |
| Günlük zinciri ipuçları (`journal_hint_2..5`, `journal_hint_tapes`) | Anahtarlar hazır, tetikleyici yok → G24 |
| `hint_room3` (Kat2 koridor yönlendirmesi) | Anahtar hazır, tetikleyici yok → G25 |
| `bath_syringe_hint`, `hint_syringe_missing` (SON B bulunabilirliği) | Anahtarlar hazır, tetikleyici yok → G26 |
| Oyun adı `A Beyhan's story` | **Değiştirilmedi** → `17_ISIM_VE_TURKCE.md` |
| Türkçe 3. dil | **Eklenmedi** → `17_ISIM_VE_TURKCE.md` |
| `16_lang_TAM_en_ar_tr.csv` | Zip'te yok, `13`+`15`'ten üretilecek |
| Windows export / itch build | Export template yok, bu ortamda üretilemez → G32 |

---

## 13. Bilinçli yetim dosyalar

| Dosya | Neden |
|---|---|
| `Scripts/frontkeyPlacing.gd` | G16'da yanlış bayraklar düzeltildi ama hiçbir `.tscn` bunu bir düğüme atamıyor. SON C doğrudan `frontDoor.gd` üzerinden çalışır, anahtar takma adımına ihtiyacı yok |
| `Scripts/doorHandel.gd` | Orijinal depo içeriği; zaten bağlı değildi |
| `globalTools/Objectives.tscn` | Boş stub, **silinmeyecek** (madde 2) |

---

## 14. Sayı tutarsızlığı — ÇÖZÜLDÜ

G00 sırasında "97 anahtar", doğrulamada "98 satır" denmişti. Doğrusu:
**98 satır = 1 başlık + 97 anahtar** (50 orijinal + 47 yeni). Kaynak veri seti 92 anahtardı.
`GameState.gd` = **74 var** (27 orijinal + 47 yeni); docs/README.md'deki "87" yanlış sayıydı, **74 olarak düzeltildi**.

---

## 15. 2026-10-20 seansında bulunan, DÜZELTİLMEYEN kusurlar

Tam liste (performans maddeleri dahil) **`README.md` → "Kalan işler — 2026-10-20 devir
notu"** bölümünde; çünkü bu `docs/` klasörü `.gitignore`'da, yani burada yazanlar
commit'lenmez ve cihaz değişirse kaybolur. Oyunu ilgilendiren kritik dördü burada da duruyor:

1. **`hallWay` → `from_room3` spawn'ının altında 2 m içinde zemin yok** (x=-4.12, z=-2.40).
   Room 3'ten hol'e dönen oyuncu dünyanın dışına düşer. Hol'ün çarpışma zemini o eşikte
   bitiyor; yanındaki `from_room1` (z=-0.94) sağlam. **Bilinen en ciddi açık.**
2. **Paletler çift tonlama yapıyor.** `.res` dosyaları ham `Image` olduğu için
   `albedo_texture` onları reddediyordu ve yüzeyler düz boya gibi render oluyordu;
   tint rengi tek başına taşıyordu. Doku düzeltmesinden (`43e323a`) sonra tint gerçek
   dokunun üstüne çarpılıyor: `P0` zeytin yeşiline kaydı, `P1` çok karanlık.
   `level2` ve `hub` kareleri bu değişimden sonra **hiç değerlendirilemedi**.
3. **Otel spawn'ları kapı gövdelerinin içinde**: `hallWay` `from_room2/from_room1/
   from_library/from_bath/from_attic`, `floor1hallWay` `default1/from_kitchen/from_floor2`.
   Varışta küçük itme üretiyor; her biri için ayrı karar gerekiyor.
4. **`level0` → `from_level1` (x=24, z=24) `l0key` kaidesinin üstünde**; zemin y=0.75,
   marker 1.13 m altında, snap oyuncuyu piramidin üstüne koyuyor.

Yeniden üretmek için:
```
godot --headless --path . tools/probe.tscn -- spawns \
  res://assets/House/Floor2/hallWay/hallWay.tscn res://assets/House/Floor1/floor1hallWay.tscn
```
`<< DURULMAZ` satırları = durulamayan spawn. Bu araç `audit_chain.py`'nin göremediği
**fiziksel** sorunları yakalar; ikisi farklı şeyleri bulur.
