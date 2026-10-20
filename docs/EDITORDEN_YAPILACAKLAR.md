# EDİTÖRDEN YAPILACAKLAR

Bu ortamda Godot **editörü çöküyor** (bkz. [BILINEN_SORUNLAR.md](BILINEN_SORUNLAR.md#10-godot-editörü-bu-ortamda-çöküyor)),
o yüzden aşağıdaki işlerin bir kısmı ancak kullanıcının Android Godot editöründe yapılabilir.
Her madde tek başına bağımsız; sırayla yapmak şart değil.

Öncelik sırası: **1 → 2 → 3 → 4 → 5**.

---

## 1) Placeholder kutuları gerçek objelerle değiştir (G28)

Eklenen 30 düğümün hepsi 10 cm'lik `BoxMesh` + **emissive** malzeme.
Eşleştirme tablosu `TAM-PAKET/09_AGENT_TALIMAT_CILA.md`'den:

| Nesne tipi | Kullanılacak varlık / yöntem |
|---|---|
| Günlük sayfaları, mektuplar, tarif | `letter1` düğümünün mesh'i; doku `assets/House/Floor1/storageRoom/birthday_love_letter_*` |
| Kasetler (TAPE-01/02) | Library'deki kaset mesh'inin kopyası; doku `assets/House/Floor2/Library/psx_style_cassette_tape_0.jpg` |
| Şırınga | 2 primitif: gövde `CylinderMesh` (beyaz `StandardMaterial3D`) + iğne ince silindir (metalik). **Açık kutu içinde, ayna yanında** |
| Tahta kuşlar (3 varyant) | Primitif set: gövde (yassı küre) + baş (küre) + gaga (koni) + kanat (ince kutu); malzeme `painted_wooden_door` dokusu kahverengi tint. Varyantlar: **tam** / **tek kanat** (attic) / **kaba-eğri ölçek** (canavar hediyesi) |
| Doz çizelgesi | Duvarda `PlaneMesh` + `old_paper__cardboard_boxes` dokularından biri (Basement klasörü) |
| TEA duvar yazısı | `Label3D`, koyu gri, duvara 2–3 cm mesafe; veya aynı kağıt dokusuyla decal düzlemi |
| **Genel** | Tüm inspect kutularından **`emissive` parlaklığını kaldır**; hover simgesi bulunabilirlik için yeterli |

> `.glb` indirmek **gerekmiyor**. `birthday_love_letter.glb` ve `psx_style_cassette_tape.glb`
> hiçbir sahnede referanslı değil; mesh'leri `letter1`/kaset düğümlerinin içinde
> `ArrayMesh` sub-resource olarak gömülü. **Editörde kopyala-yapıştır gömülü mesh'i taşır.**

### Konumları doğrulanacak düğümler

Koordinatların tamamı oyun oynanmadan yazıldı. Her biri için: kutu görünür mü,
erişilebilir mi, hover simgesi doğru yerde mi, duvarın içinde mi?

**`assets/House/Floor1/storageRoom.tscn`**
| Düğüm | x | y | z | Ne olmalı |
|---|---|---|---|---|
| `woodenBird` | -3.13 | 5.2 | 2.02 | Raf üstünde tahta kuş (tam varyant) |
| `journal01` | -4.28 | 5.2 | 1.97 | Raf üstünde katlı kâğıt |

**`assets/House/Floor1/kitchen.tscn`**
| Düğüm | x | y | z | Ne olmalı |
|---|---|---|---|---|
| `mugs` | -4.41 | 1.68 | 9.13 | Tezgâhta iki kupa |
| `newspaper` | -5.61 | 1.68 | 9.13 | Tezgâhta gazete |
| `recipe` | -5.01 | 1.68 | 9.53 | Tezgâhta tarif kâğıdı (küçültülmüş letter) |
| `journal03` | -4.71 | 1.68 | 8.03 | Çekmece/raf üstünde günlük sayfası |

**`assets/House/Floor1/floor1hallWay.tscn`**
| Düğüm | x | y | z | Ne olmalı |
|---|---|---|---|---|
| `emptyFrame` | 10.91 | 1.9 | -2.2 | Duvarda **boş** fotoğraf çerçevesi |
| `frontDoorExit` | 11.72 | 1.2 | -5.84 | Ön kapı — SON C çıkışı |

**`assets/House/Floor2/Library/Library.tscn`**
| Düğüm | x | y | z | Ne olmalı |
|---|---|---|---|---|
| `medBooks` | 0.28 | 3.53 | 3.33 | Rafta tıp kitapları |
| `journal02` | -0.83 | 4.5 | 1.59 | Raf üstünde günlük sayfası |

**`assets/House/Floor2/Bathroom/bathroom.tscn`**
| Düğüm | x | y | z | Ne olmalı |
|---|---|---|---|---|
| `mirrorLook` | -49.7 | 103.05 | -47.89 | Ayna yüzeyi (iki aşamalı inceleme) |
| `syringeBox` | -50.83 | 103.36 | -48.79 | **Ayna yanında açık kutu, içinde şırınga** — G26 bunu belirginleştirecek |
| `journal04` | -49.63 | 103.36 | -48.79 | Rafta günlük sayfası |

**`assets/House/Floor2/Bedrooms/room2.tscn`**
| Düğüm | x | y | z | Ne olmalı |
|---|---|---|---|---|
| `tape01` | -2.29 | 0.68 | 3.03 | Kaset (Library mesh kopyası) |
| `tape02` | -2.29 | 0.68 | 3.63 | Kaset — yalnızca `tape1_played` sonrası görünür |
| `frontKey` | -1.09 | 0.68 | 3.03 | **Mevcut** düğüm, SON C anahtarı |

**`assets/House/Floor2/Bedrooms/room3.tscn`**
| Düğüm | x | y | z | Ne olmalı |
|---|---|---|---|---|
| `bed3` | 0.9 | 0.5 | -1.6 | Yatak |
| `chains3` | 0.4 | 0.6 | -1.9 | Yatağa cıvatalı zincirler |
| `doseChart` | 1.3 | 1.0 | -1.1 | Duvarda doz çizelgesi (PlaneMesh + old_paper) |
| `doorInside` | -2.3 | 1.4 | -0.9 | Kapının **iç** yüzü — tırmık izleri |
| `letter3` | 1.0 | 0.95 | -1.0 | Gönderilmemiş mektup |
| `journal05` | 0.6 | 0.95 | -1.3 | Yatak yanında günlük sayfası |

**`assets/House/Floor1/Basement.tscn`**
| Düğüm | x | y | z | Ne olmalı |
|---|---|---|---|---|
| `wallWriting` | 4.29 | 1.4 | 4.13 | **TEA** duvar yazısı — Label3D, koyu gri |
| `baseChains` | 1.6 | 0.5 | 1.2 | Zincirler |
| `baseBed` | 0.2 | 0.5 | 2.4 | Yer yatağı |
| `baseBox` | 1.4 | 0.4 | 2.4 | "FOR WHEN YOUR HANDS START SHAKING" kutusu — **açılmaz** |
| `baseApology` | 0.83 | 0.9 | 1.0 | Özür notu |

**`assets/House/Floor2/hallWay/hallWay.tscn`**
| Düğüm | x | y | z | Ne olmalı |
|---|---|---|---|---|
| `giftBird` | -14.9 | 1.0 | 2.53 | Canavarın getirdiği kuş (kaba-eğri varyant) — `tape2_played` sonrası görünür |
| `toRoom3Door` | -4.08 | 1.15 | -3.2 | Room3 kapısı |
| `toAtticDoor` | -21.5 | 1.18 | 3.7 | Çatı katı kapısı |
| `SpawnPoints/from_attic` | -16.26 | 0.17 | 2.0 | Çatıdan dönüş noktası |
| `SpawnPoints/from_room3` | -4.12 | 0.21 | -2.4 | Room3'ten dönüş noktası |

**`assets/House/Floor2/attic.tscn`** (tamamen yeni, primitif geometri)
| Düğüm | Ne olmalı |
|---|---|
| `heightMarks` | Duvarda boy çizgileri — "Mine stop at twelve" |
| `carvingTools` | Oyma aletleri |
| `bird2` | **Yarım kalmış** kuş (tek kanat varyantı) |
| `toHallwayDoor` | Koridora dönüş kapısı |
| `floor`, `ceiling`, `wallN/S/W/E` | Primitif kutular — **ışık sızdırma kontrolü** |

---

## 2) Font fallback ekle (Arapça + Türkçe glifleri)

Proje fontları (**Horror Brush**, **Glacial Indifference**) Arapça glif içermez;
Türkçe için de `ğ ş İ ı ç ö ü` riskli.

1. **Noto Sans** ve **Noto Sans Arabic** `.ttf` dosyalarını projeye ekle
   (örn. `assets/fonts/`).
2. Temada (`assets/main/game_theme.tres`) **fallback font** listesine koy.
   Ana korku fontu kalır, eksik harfler fallback'ten gelir.
3. Godot 4 `TextServer` RTL şekillendirmeyi zaten yapar — sorun yalnızca glif.
4. Test: dil menüsünden Türkçe → `forest_s2` satırındaki **ş / ı / ğ**;
   Arapça → aynı satırın sağdan sola düzgün bağlanması.

---

## 3) Oyun adını değiştir (`17_ISIM_VE_TURKCE.md`)

Yeni ad: **A Beyhan's story** (kullanıcının yazdığı gibi, aynen).

1. `project.godot` → `config/name="Game1"` satırını `config/name="A Beyhan's story"` yap.
2. `assets/main/main_menu.tscn` → iki adet `text = "AFTER THE THRESHOLD"` satırını
   `text = "A Beyhan's story"` yap.
   - Alt başlıklar **aynı kalsın**: `CHAPTER ONE: THE BASEMENT` ve `The Full Entry`.
   - Label kutusu genişliğini kontrol et; yeni isim daha kısa, taşma olmaz ama
     `horizontal_alignment`'ı doğrula.
3. `export_presets.cfg` varsa ürün adı alanını güncelle.
4. Son kontrol: `grep -rn "AFTER THE THRESHOLD\|After the Threshold" --exclude-dir=.godot .`

> **DOKUNMA:** klasör/dosya isimlerini, sahne yollarını, UID'leri **değiştirme**
> (referanslar kırılır). İsim sadece görünen metinlerde değişir.

> **KREDİ KURALI:** Credits içindeki orijinal yapımcı ibaresini **silme**.
> `creditsss` anahtarı üç dilde de "Mono'nun oyunu" diyor. Yayınlanacaksa orijinal oyun
> (*After the Threshold*, **mono19189**) kredisi korunur; bu sürüm genişletilmiş hikâye sürümüdür.

---

## 4) Eksik 9 modeli yerine koy

Öncelik sırasıyla (tam liste: [BILINEN_SORUNLAR.md](BILINEN_SORUNLAR.md#1-model-dosyaları--düzeltme-95-değil-9-eksik)):

1. **`Basement/devils_roulette_-_syringe.glb`** — YÜKSEK. Bodrumdaki şırınga SON B'nin hikâye objesi.
   *Geçici:* G28'in 2 silindir primitifi zaten var.
2. **`Dream/copper_tea_pot.glb`** — ORTA. Çay sahnesinde demlik; çay motifi sahnesi.
3. **`Basement/cassette_player.glb`** — ORTA. Dokuları repoda (`cassette_player_*.jpg/png`).
4. Geri kalan 6 dekor — DÜŞÜK. Primitif ikame yeterli.

Bulma yolları: (a) itch build'indeki `.pck`'den çıkarmak (GDRE Tools PRoot Ubuntu'da çalışır),
(b) Sketchfab'da birebir isimle aramak (dokular repoda, eşleşmeyi onlarla doğrula),
(c) primitif ikame.

---

## 5) Kaset sesleri (G29 sonrası)

Akış *"ses dosyası varsa çal, yoksa statik+altyazı"* şeklinde kurulacak.
İleride ElevenLabs ile üretilirse **yalnızca şu 5 satır** üretilecek ve dosya adları
veri setine işlenecek:

```
tape1_1   tape1_2   tape2_1   tape2_2   tape2_3
```

Bunlar ağabeyin araştırma kasetleri — **diegetik kayıt**, yani sesli olmak zorunda.
Diğer yeni anahtarların hepsi (YOU iç monologları + `phone2_1` + `phone_last`)
**tasarım gereği sessiz**; onlara ses arama.

---

## 6) `.godot` cache'ini düzelt (G21, benim yapacağım)

`.godot/.godot/` iç içe geçmiş. `.godot/.godot/*` bir üst seviyeye taşınacak.

> ⚠️ **`.godot`'u SİLME** — telefonda uzun reimport demek. Yedek almadan silme.

---

## Yapılmayacaklar (net kararlar)

| Konu | Karar |
|---|---|
| **G23 — Objectives UI** | **ATLANIYOR.** Gerçek sistem yok. Sadece G24/G25 monolog ipuçlarıyla ilerlenecek. `obj_*` anahtarları `lang.csv`'de zararsızca duracak, UI'a bağlanmayacak. **Stub silinmeyecek** (autoload kırılır) |
| **91 yetim `.import` dosyası** | Peşine **düşülmeyecek** |
| **YOU monologları için seslendirme** | **Aranmayacak** — tasarım gereği sessiz |
| **Zorunlu yola yeni içerik koymak** | **Yasak.** Hızlı rotanın (test senaryosu A) hâlâ çalışması şart |
| **Mevcut bayrak isimlerini değiştirmek** | **Yasak** — kayıtlı akışlar bağlı |
| **`player.gd`, `sofaScene.gd`, `dream_happy_kitchen.gd` zamanlayıcıları** | **Dokunulmayacak**; sadece başa/sona ekleme |
