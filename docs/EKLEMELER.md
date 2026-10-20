# EKLEMELER — Nereye, ne eklendi

Bu belge G00–G20 görevlerinde oyuna eklenen **her düğümü, her bayrağı ve her diyalog
anahtarını** listeler. Kaynak: `git diff` (23 değişen dosya) + 10 yeni dosya.

Konvansiyon:
- **Bayrak** = `Scripts/GameState.gd` içindeki `var` adı.
- **Anahtar** = `lang.csv` içindeki satır anahtarı (çeviri tablosu).
- **Düğüm** = `.tscn` içindeki `[node name="..."]`.
- Koordinatlar `Transform3D(..., x, y, z)` sonundaki üç sayıdır; **hepsi tahmindir**,
  editörde gözle doğrulanmalı (bkz. [EDITORDEN_YAPILACAKLAR.md](EDITORDEN_YAPILACAKLAR.md)).

---

## G00 — Ortak altyapı (yeni dosyalar)

Hiçbir sahneye içerik eklemeden önce, yeni içeriğin **tek desenden** üretilmesi için
beş script ve bir dil tablosu oluşturuldu. Eski kodun adlandırma tutarsızlığı
(`speech/C1/speech1`, `./speech`, `C1/speech1`, `finalTruth/speech1` …) yüzünden her
sahneye ayrı altyazı düğümü yazmak yerine tek bir statik oynatıcı kullanıldı.

### `Scripts/Speech.gd` (yeni, 29 satır)
```
class_name Speech extends RefCounted
static func say(label: Label, key: String) -> void
```
- `const FADE = 0.28`
- Bekleme süresi metin uzunluğundan türetilir: `hold = clampf(len * 0.06, 2.2, 8.0)`
- Tween **Label'a bağlı** (`label.create_tween()`), böylece sahne değişince yarım kalmaz.
- `label.text = key` yazılır; ekranda çevirinin görünmesi Label'ın `auto_translate`
  ayarına bağlıdır. Anahtar bulunamazsa ham anahtar görünür (bu bir hata belirtisidir).

### `Scripts/inspect_item.gd` (yeni, 107 satır) — `extends StaticBody3D`
Yeni içeriğin **tamamı** bunu kullanır. Inspector'dan doldurulan alanlar:

| Alan | Varsayılan | Ne işe yarar |
|---|---|---|
| `flag_name` | `""` | Okundu/alındı bayrağı |
| `speech_key` | `""` | Birinci aşama anahtarı |
| `second_flag` | `""` | İkinci aşama bayrağı (iki turlu inceleme) |
| `second_key` | `""` | İkinci aşama anahtarı |
| `label_path` | `../extraSpeech/line` | Altyazı Label'ı |
| `prompt_path` | `play1/hover` | Etkileşim simgesi |
| `destroy_on_pick` | `false` | Alınınca `queue_free()` |
| `requires_flag` | `""` | Görünürlük koşulu |
| `requires_value` | `true` | Koşulun beklediği değer |
| `counter_name` | `""` | Sayaç bayrağı (kuşlar) |
| `counter_target` | `0` | Ödül eşiği |
| `reward_key` | `""` | Eşik aşılınca oynayan satır |
| `reward_flag` | `""` | Ödülün bir kez oynadığını tutan bayrak |

Davranışlar:
- `_ready()`: `destroy_on_pick` ve bayrak zaten yanıksa düğüm hiç doğmaz → **sayfa tekrar doğmaz**.
- `_process()`: `requires_flag` sahne içinde sonradan sağlanabilir (tape1 oynatılınca
  tape02'nin görünmesi gibi), koşul sağlanana kadar her kare kontrol edilir, sonra
  `set_process(false)`.
- `_apply_visibility()`: koşul sağlanmazsa `visible = false` **ve** `collision_layer = 0`.
- `interact()`: `_used` kilidi çift oynatmayı engeller; iki aşamalı incelemede ikinci
  tur için kilit tekrar açılır; konuşma boyunca `GameState.interaction_locked` kullanılmaz
  (kendi yerel kilidi yeter), ödül bloğu 0.9 sn bekleyip `reward_key`'i oynatır.

### `Scripts/scene_intro.gd` (yeni, 25 satır) — `extends Node`
Sahne köküne `intro` adında çocuk Node olarak eklenir.
`@export played_flag, speech_key, label_path = "../extraSpeech/line", delay = 1.6`
- Gecikme sırasında oyuncu sahneden çıktıysa **bayrak yakılmaz** (`is_inside_tree()` kontrolü),
  tekrar girince oynar.

### `Scripts/DOORS/generic_door.gd` (yeni, 43 satır) — `extends StaticBody3D`
`kapi_sablonu.gd.txt` deseninin Speech'li hali.
`@export_file("*.tscn") target_scene`, `spawn_name = "default"`, `required_flags` (virgülle),
`need_key = "hallWay_need1"`.
- `Input.is_action_just_pressed("ui_accept")` guard'ı içerir.
- Koşul sağlanmazsa `need_key` satırını oynatır.

### `Scripts/DOORS/frontDoor.gd` (yeni, 31 satır) — SON C
Aşağıda G16'da anlatılıyor.

### `lang.csv` (yeni, 98 satır)
`keys,en,ar` başlığı + **97 anahtar**. `ar` sütunu şimdilik `en`'in birebir kopyasıdır
(bkz. G30 kararı). Ayrıntı: [RAPOR_G22_TUTARLILIK.md](RAPOR_G22_TUTARLILIK.md).

### `assets/main/game_theme.tres` (yeni)
`project.godot → gui/theme/custom`'a bağlandı.

### `globalTools/` (yeni klasör)
`Objectives.tscn`, `Steps.tscn`, `FadeLayer.tscn`, `Wind.tscn`, `Comfy.tscn`,
`KeyPad.tscn`, `keypad.gd`, `Hover.png`, `BHover.png`, `flashlight/`.
> `Objectives.tscn` **84 baytlık boş bir stub**'dır; API'si yoktur (G23'ü bloklar).

### `Sounds/` (yeni klasör, 8 mp3)
Orijinal depoda bulunamayan ortam sesleri için **geçici ikame kopyalar**:
`dragon-studio-dry-thunder-364468.mp3`, `freesound_community-ambience-night-field-cricket-01-7015.mp3`,
`freesound_community-heavy_breathing-34377.mp3`, `freesounds-4u-door-handle-1-401153.mp3`,
`fronbondi_skegs-field-brisk-walking-on-dry-grass-late-night-ambience-recording-7948.mp3`,
`soundreality-wind-blowing-457954.mp3`, `spinopel-creaky-floorboards-281297.mp3`,
`u_5hx6qi66bg-strange-whispers-415245.mp3`.

### Her sahneye eklenen ortak iki düğüm
Altyazı için, dokunulan **her** sahneye aynı ikili eklendi:
```
[node name="extraSpeech" type="CanvasLayer" parent="."]   layer = 2
[node name="line"      type="Label"     parent="extraSpeech"]
    modulate = Color(1,1,1,0)      # başta görünmez
    offset_left = 454  offset_top = 786
    offset_right = 1454 offset_bottom = 900
    font_size = 20, horizontal/vertical_alignment = 1, autowrap_mode = 3
```
Eklendiği sahneler: `main.tscn`, `storageRoom.tscn`, `kitchen.tscn`, `bathroom.tscn`,
`Library.tscn`, `floor1hallWay.tscn`, `hallWay.tscn`, `room1.tscn`, `room2.tscn`,
`room3.tscn`, `Basement.tscn`, `attic.tscn`.

Her inceleme düğümünün kendi iç yapısı da aynıdır:
```
X (StaticBody3D)  script = inspect_item.gd, transform, collision_layer
├── CollisionShape3D   shape = BoxShape3D (sub_resource)
├── MeshInstance3D     mesh = BoxMesh + emissive StandardMaterial3D (placeholder)
└── play1 (CanvasLayer)
    └── hover (Sprite2D)  texture = Hover.png / BHover.png, visible = false
```

---

## G01 — Tahta kuş (depo)  ·  KUS_SISTEMI
**`assets/House/Floor1/storageRoom.tscn`**

| Düğüm | Koordinat | Bayrak | Anahtar |
|---|---|---|---|
| `woodenBird` | `-3.13, 5.2, 2.02` | `bird_found` | `storage_bird` |

- `destroy_on_pick = true`
- `counter_name = "birds_found"`, `counter_target = 3`, `reward_key = "bird_all"`,
  `reward_flag = "bird_all_seen"` → **üçüncü kuşta G18 ödülü**.
- Kuş sayacı üç ayrı sahnede paylaşılır; sayaç `GameState`'de olduğu için sahne geçişinde sıfırlanmaz.

## G02 — Mutfak detayları  ·  AILE
**`assets/House/Floor1/kitchen.tscn`**

| Düğüm | Koordinat | Bayrak | Anahtar |
|---|---|---|---|
| `mugs` | `-4.41, 1.68, 9.13` | `kitchen_mugs_seen` | `kitchen_2` |
| `newspaper` | `-5.61, 1.68, 9.13` | `newspaper_seen` | `newspaper_1` |
| `recipe` | `-5.01, 1.68, 9.53` | `recipe_read` | `mom_recipe` (destroy) |
| `journal03` | `-4.71, 1.68, 8.03` | `journal_03_read` | `journal_03` (destroy) |

**`assets/House/Floor1/kitchen.gd`** — `_ready()` yeniden yazıldı:
- Eski hali `if GameState.kitchen_entered == 0: kitchen_entered += 1` idi; yani sayaç
  yalnızca ilk girişte artıyordu. Artık **her girişte artar** (`kitchen_entered += 1`).
- 1. giriş: eski davranış korunur (3 sn sonra `somthing.play()`).
- 2. girişten itibaren: 3 sn sonra bir kez `symptom_1` (`symptom1_done`).
> Bu değişiklik G12'nin çalışması için gerekliydi ama **orijinal mutfağın giriş
> sayacını da değiştirir**; sayaç başka yerde okunuyorsa etkilenebilir.

## G03 — Banyo ayna + şırınga  ·  BELIRTI
**`assets/House/Floor2/Bathroom/bathroom.tscn`**

| Düğüm | Koordinat | Bayrak | Anahtar |
|---|---|---|---|
| `mirrorLook` | `-49.7, 103.05, -47.89` | `bath_mirror_seen` → sonra `symptom2_done` | `bath_2` → `symptom_2` |
| `syringeBox` | `-50.83, 103.36, -48.79` | `syringe_found` | `bath_syringe` (destroy) |
| `journal04` | `-49.63, 103.36, -48.79` | `journal_04_read` | `journal_04` (destroy) |

- `mirrorLook` **iki aşamalı incelemenin** tek örneğidir: `second_flag` + `second_key`.
  İlk bakış `bath_2`, ikinci bakış `symptom_2`. `inspect_item.gd`'deki ikinci tur için
  `_used` kilidinin yeniden açılması tam olarak bu düğüm için yazıldı.
- `syringe_found` **SON B'nin tek anahtarıdır**: `monster.gd` ateş etmek yerine bu
  bayrağa bakar. Kutu şu an 10 cm'lik emissive bir placeholder ve aynanın hemen yanında
  değil — G26 bunu belirginleştirecek.

## G04 — Kütüphane tıp kitapları  ·  GECMIS
**`assets/House/Floor2/Library/Library.tscn`**

| Düğüm | Koordinat | Bayrak | Anahtar |
|---|---|---|---|
| `medBooks` | `0.28, 3.53, 3.33` | `lib_books_seen` | `Lib_3` |
| `journal02` | `-0.83, 4.5, 1.59` | `journal_02_read` | `journal_02` (destroy) |

## G05 — Koridor boş fotoğraf çerçevesi  ·  AILE
**`assets/House/Floor1/floor1hallWay.tscn`**

| Düğüm | Koordinat | Bayrak | Anahtar |
|---|---|---|---|
| `emptyFrame` | `10.91, 1.9, -2.2` | `hallway_frame_seen` | `hallway_frame` |
| `frontDoorExit` | `11.72, 1.2, -5.84` | — | `hallWay_need1` / `door_leave_1` |

- `frontDoorExit` `Scripts/DOORS/frontDoor.gd`'yi taşır (G16).

## G06 — Anne mektubu fotoğrafın arkasında  ·  AILE
**`Scripts/familyPicture.gd`** — mevcut script genişletildi, düğüm eklenmedi.
- Eski davranış korunur ama **bir kez** oynaması `room1_picture_seen` ile sağlanır.
- 1. bakış: orijinal `speech.play("s1")` + `whisper`, ardından varsa `s2` animasyonu.
- 2. bakış (`room1_picture_seen == true`): `mom_letter_read` yakılır, sırayla
  `mom_letter1` → `mom_letter2`.
- `mom_letter_read` zaten yanıksa sessizce döner (spam koruması).
- `@onready var line = $"../extraSpeech/line"` eklendi; `room1.tscn`'e yalnızca
  `extraSpeech/line` ikilisi bu yüzden eklendi (14 satır).

## G07 — Günlük sayfaları (5 adet)  ·  GECMIS
Beş sayfaya dağıtıldı, hepsi `destroy_on_pick = true` → **sayfa tekrar doğmaz**.

| # | Sahne | Düğüm | Koordinat | Bayrak | Anahtar |
|---|---|---|---|---|---|
| 01 | `storageRoom.tscn` | `journal01` | `-4.28, 5.2, 1.97` | `journal_01_read` | `journal_01` |
| 02 | `Library.tscn` | `journal02` | `-0.83, 4.5, 1.59` | `journal_02_read` | `journal_02` |
| 03 | `kitchen.tscn` | `journal03` | `-4.71, 1.68, 8.03` | `journal_03_read` | `journal_03` |
| 04 | `bathroom.tscn` | `journal04` | `-49.63, 103.36, -48.79` | `journal_04_read` | `journal_04` |
| 05 | `room3.tscn` | `journal05` | `0.6, 0.95, -1.3` | `journal_05_read` | `journal_05` |

> Zincir **sıraya zorlanmaz**; oyuncu sayfaları istediği sırayla bulabilir.
> G24 (sıradaki sayfanın ipucu) bu yüzden henüz bağlı değil.

## G08 — Room3 tedavi odası dönüşümü  ·  GECMIS
**`assets/House/Floor2/Bedrooms/room3.tscn`** (+175 satır)

| Düğüm | Koordinat | Bayrak | Anahtar |
|---|---|---|---|
| `intro` (Node, `scene_intro.gd`) | — | `room3_speech_played` | `room3_1` |
| `bed3` | `0.9, 0.5, -1.6` | — | `room3_2` *(bayrak `room3_2_seen`)* |
| `chains3` | `0.4, 0.6, -1.9` | `room3_4_seen` | `room3_4` |
| `doseChart` | `1.3, 1.0, -1.1` | `room3_5_seen` | `room3_5` |
| `doorInside` | `-2.3, 1.4, -0.9` | `room3_3_seen` | `room3_3` |
| `letter3` | `1.0, 0.95, -1.0` | `letter3_picked` | `letter3_1` (destroy) |
| `journal05` | `0.6, 0.95, -1.3` | `journal_05_read` | `journal_05` (destroy) |

- Room3 artık **boş bir yatak odası değil**: yatağa cıvatalanmış zincirler, kapının
  **iç** tarafındaki tırmık izleri, kenarına doz sayıları yazılmış çizelge, gönderilmemiş mektup.
- `room3_5` = "…The ticks stop on March 14th." → G19'un tarih ipucu.

## G09 — TAPE-01 ve TAPE-02  ·  GECMIS
**`assets/House/Floor2/Bedrooms/room2.tscn`**

| Düğüm | Koordinat | Bayrak | Not |
|---|---|---|---|
| `tape01` | `-2.29, 0.68, 3.03` | `tape1_picked` | destroy |
| `tape02` | `-2.29, 0.68, 3.63` | `tape2_picked` | destroy, `requires_flag = "tape1_played"` |
| `frontKey` | `-1.09, 0.68, 3.03` | `frontKey_picked` | **mevcut** düğüm, G16 için taşındı |

> Kasetlerin kendisinde `speech_key` yok; satırlar TV'de oynar.

**`Scripts/tv.gd`** — mevcut TV akışı genişletildi:
```gdscript
const TAPE_LINES := {
    "tape1": ["tape1_1", "tape1_2"],
    "tape2": ["tape2_1", "tape2_2", "tape2_3"],
}
```
- `interact()` başında: `GameState.casset_putted` ise `_play_tape()` çağrılır ve döner.
  Yani **orijinal kaset akışı bozulmaz**, kaset takıldıktan sonra aynı TV araştırma
  kasetleri için kullanılmaya devam eder.
- `_play_tape()`: `tape1_picked and not tape1_played` → `tape1`; değilse aynı mantıkla
  `tape2`. Sıra zorunlu değil ama `tape02`'nin sahnede görünmesi `tape1_played`'e bağlı.
- Oynatım: `Visualnoise.visible = true`, `whiteNoise.play()`, `cassetPlayer.play()`,
  sonra `for key in TAPE_LINES[tape]: await Speech.say(line, key)`.
- Bitişte gürültü kapatılır, `interaction_locked = false`, **her iki kaset de oynadıysa**
  `$CollisionShape3D.disabled = true`.
- `_ready()`'deki kilit koşulu `casset_putted` → `casset_putted and tape1_played and tape2_played`
  olarak sıkılaştırıldı.
- **TV odası çıkış kilidi düzeltmesi:** orijinal akışın sonunda `interaction_locked`
  takılı kalıyordu; artık `GameState.interaction_locked = false` ve
  `$CollisionShape3D.disabled = false` akışın sonunda açıkça geri alınır.
- `@onready var line = $"../extraSpeech/line"` eklendi.

**`Scripts/frontKey.gd`** — `queue_free()` konuşma animasyonundan **sonraya** alındı:
`visible = false; collision_layer = 0; speech.play("s2"); await …; queue_free()`.
Eski hali anahtarı animasyon bitmeden yok ediyordu.

## G10 — Telefon 2. ve 3. olay  ·  SIMDI
**`Scripts/Phone.gd`** — düğüm eklenmedi, script genişletildi.
- `$CollisionShape3D.queue_free()` → `$CollisionShape3D.disabled = true`.
  Telefon **tekrar çalabilsin** diye yok edilmiyor, sadece devre dışı bırakılıyor.
- `_late_call_pending()`:
  - `phone_scene_visits >= 5 and not phone2_done` → 2. olay
  - `final_truth_interacted and not phone_last_done` → 3. olay
- `_late_call()`: 1 sn bekleme → `phone2_done` ise `cry1` + `phone2_1`;
  değilse `phone_last_done = true` + `phone_last`. Sonra `pos.play("RESET")` + `hung.play()`.
- Ziyaret sayacı `_ready()`'de **her sahne girişinde** artar (`phone_scene_visits += 1`).
> **Dikkat:** test senaryosunda not düşüldüğü gibi sayaç sahne geçişlerinde şişebilir;
> eşiğin (3 / 5) gerçekten doğru ziyaretlerde tetiklenip tetiklenmediği oynanarak doğrulanmadı.

## G11 — Canavarın insanlığı (3 an)  ·  SIMDI
| An | Dosya | Bayrak | Anahtar |
|---|---|---|---|
| 1 | `assets/House/Floor1/Basement/basement.gd` (`_ready`, `lucid1_done`) | `lucid1_done` | `lucid_1` |
| 2 | `Scripts/mainJS.gd` (`monster_encounters == 2`) | — | `monster_watch` |
| 3 | `hallWay.tscn → giftBird` (`requires_flag = "tape2_played"`) | `gift_bird_found` | `monster_gift` |

- `mainJS.gd`'de mevcut `monster_encounters == 3 → trigger_scare` bloğunun **önüne**
  `== 2` bloğu eklendi; scare akışına dokunulmadı.
- `basement.gd`'de `lucid_1` mevcut `player.unfreeze()` + fare yakalama bloğunun
  **sonuna** eklendi (kırılgan zamanlayıcılara dokunmamak için).
- Bodrumdaki duvar yazısı (`wallWriting`, `monster_word`) bu üçlemenin dördüncü, opsiyonel yankısı.

## G12 — Belirti anı 1 ve 3  ·  BELIRTI
| # | Tetikleyici | Dosya | Bayrak | Anahtar |
|---|---|---|---|---|
| 1 | Mutfağa 2. giriş | `kitchen.gd` | `symptom1_done` | `symptom_1` |
| 2 | Aynaya 2. bakış | `bathroom.tscn → mirrorLook` | `symptom2_done` | `symptom_2` |
| 3 | Tabanca alınışı | `Scripts/pistolPicking.gd` | `symptom3_done` | `symptom_3` |

**`Scripts/pistolPicking.gd`**: `pistolPick.pause()` ile `queue_free()` arasındaki boşluğa
```gdscript
if not GameState.symptom3_done:
    GameState.symptom3_done = true
    Speech.say(get_node_or_null("../extraSpeech/line") as Label, "symptom_3")
```
> `await` edilmiyor — tabanca yok olurken satır ekranda kalsın diye bilinçli.
> G26 bu satırı `syringe_found == false` iken `hint_syringe_missing` ile değiştirecek.

## G13 — Bodrum detayları  ·  SIMDI
**`assets/House/Floor1/Basement.tscn`** (+144 satır)

| Düğüm | Koordinat | Bayrak | Anahtar |
|---|---|---|---|
| `wallWriting` | `4.29, 1.4, 4.13` | `monster_word_seen` | `monster_word` |
| `baseChains` | `1.6, 0.5, 1.2` | `base_chains_seen` | `base_6` |
| `baseBed` | `0.2, 0.5, 2.4` | `base_bed_seen` | `base_7` |
| `baseBox` | `1.4, 0.4, 2.4` | `box_seen` | `base_box` |
| `baseApology` | `0.83, 0.9, 1.0` | `basement_props_seen` | `base_5` |

- `baseBox` **açılmaz**; sadece monolog verir ("FOR WHEN YOUR HANDS START SHAKING").
- `base_1..base_4` mevcut içerikti, değiştirilmedi.

## G14 — SON A yazıları  ·  SONLAR
**`Scripts/monster.gd → die()`**
- Orijinal sıra: `black.play("fade_in")` → sesleri durdur → `await` → menü.
- Yeni sıra: sesleri durdur → **`ending_letgo_1`, `ending_letgo_2`** → `black.play("fade_in")` → menü.
- `ending_letgo_done` bayrağı **ölümden yeniden yüklemede satırların tekrar oynamaması** için.
- `_line()` yardımcısı: `get_node_or_null("../../../extraSpeech/line")`.
  Bu yol, `monster` düğümünün sahnedeki derinliğine bağlıdır — sahne ağacı değişirse kırılır.
- Karartmadan **önce** 2.0 sn beklenir, böylece canavarın düşüş animasyonu satırların üstüne binmez.

## G15 — SON B (şırınga sonu)  ·  SONLAR
**`Scripts/monster.gd`**
```gdscript
func interact():
    if is_processing_shot or not activated: return
    if GameState.syringe_found and not GameState.ending_holdon_done:
        await _ending_holdon()
        return
    ...
```
- `_ending_holdon()`: `is_processing_shot = true`, `can_move = false`, `hide_prompt()`,
  `ending_holdon_done = true`, `player.freeze()` (metod varsa), `steps.stop()`,
  her iki CollisionShape `set_deferred("disabled", true)`, `MosterShows` / `MosterShows2` /
  `BackgroundSound` durdurulur, `Wind.stop()`, `Comfy.stop()`,
  sonra `ending_holdon_1 → ending_holdon_2 → ending_holdon_3`, `black.play("fade_in")`, menü.
- **Ateş edilmez.** Şırınga cebindeyse `interact()` ateş yoluna hiç girmez.
> Risk: şırınga zorunlu akışta değil, tek bir placeholder kutuya bağlı. Oyuncu banyoya
> hiç uğramazsa SON B'yi göremez ve **nedenini de öğrenemez** (G26 + G23 bunu çözer).

## G16 — SON C (kaçış sonu)  ·  SONLAR
**Yeni dosya `Scripts/DOORS/frontDoor.gd`** + `floor1hallWay.tscn → frontDoorExit`.
```
frontKey_picked == false → "hallWay_need1"
frontKey_picked == true  → "door_leave_1" → ending_leave_done = true
                         → FadeLayer.fade_and_change_scene("res://assets/main/main.tscn", "default")
```
**`assets/main/main.gd`** — orman sahnesi:
- `$breathing.stop()` **sonrasına** `if GameState.ending_leave_done: await _ending_leave(); return`
  eklendi; orijinal 15 sn'lik `instractions` zamanlayıcısına dokunulmadı (return ile atlanır).
- `_ending_leave()`: 4 sn → `ending_leave_1` → `ending_leave_2` →
  `FadeLayer.fade_and_change_scene("res://assets/main/main_menu.tscn", "default")`.

**`Scripts/frontkeyPlacing.gd`** — düzeltildi:
- `handelPlacing.gd`'nin kopyasıydı ve **yanlış bayrakları** okuyup yazıyordu
  (`doorHandel_picked` / `is_handel_installed`). `frontKey_picked` / `is_frontkey_installed`
  olarak değiştirildi.
- `_ready()` eklendi: anahtar zaten takıldıysa `key.visible = true` + CollisionShape kaldırılır.
> `frontkeyPlacing.gd` ve `doorHandel.gd` **hâlâ hiçbir sahneye bağlı değil** (yetim script).
> SON C doğrudan `frontDoor.gd` üzerinden çalışır, anahtar takma adımına ihtiyacı yok.

## G17 — Çatı katı (yeni sahne)  ·  KUS_SISTEMI
**Yeni dosya `assets/House/Floor2/attic.tscn`** — tamamen primitif geometriden kurulu
(zemin, tavan, 4 duvar, hepsi `StaticBody3D` + `BoxMesh`).

| Düğüm | Bayrak | Anahtar |
|---|---|---|
| `intro` (Node, `scene_intro.gd`) | `attic_speech_played` | `attic_1` |
| `heightMarks` | `attic_2_seen` | `attic_2` |
| `carvingTools` | `attic_3_seen` | `attic_3` |
| `bird2` | `bird2_found` | `bird_2` + kuş sayacı (G18) |
| `toHallwayDoor` (`generic_door.gd`) | — | `hallWay_need1` |
| `SpawnPoints/from_hallway` (Marker3D) | — | — |

Ayrıca `hallWay.tscn`'e:

| Düğüm | Koordinat | Bayrak | Anahtar |
|---|---|---|---|
| `toAtticDoor` | `-21.5, 1.18, 3.7` | — | `hallWay_need1` |
| `toRoom3Door` | `-4.08, 1.15, -3.2` | — | `hallWay_need1` |
| `SpawnPoints/from_attic` | `-16.26, 0.17, 2.0` | — | — |
| `SpawnPoints/from_room3` | `-4.12, 0.21, -2.4` | — | — |

> Çatı katı **ışıksız bir kutu** değil: `WorldEnvironment` + `OmniLight3D` içeriyor.
> Ama duvar kalınlıkları primitif olduğu için ışık sızdırma riski var (test listesi D).

## G18 — Üç kuş tamamlama ödülü  ·  KUS_SISTEMI
Üç kuş üç ayrı sahnede, ortak sayaç `birds_found`:

| # | Sahne | Düğüm | Bayrak | Anahtar |
|---|---|---|---|---|
| 1 | `storageRoom.tscn` | `woodenBird` | `bird_found` | `storage_bird` |
| 2 | `attic.tscn` | `bird2` | `bird2_found` | `bird_2` |
| 3 | `hallWay.tscn` | `giftBird` | `gift_bird_found` | `monster_gift` |

Üçüncüsünde `counter_target = 3` aşılınca `reward_flag = "bird_all_seen"` yakılır,
0.9 sn beklenir ve `bird_all` oynar. Ödül **bir kez**; `bird_all_seen` yanıksa tekrar oynamaz.

`giftBird` özel: `requires_flag = "tape2_played"` → **TAPE-02 izlenmeden görünmez**.
Bu, canavarın "hediye" anının araştırma kasetlerinden sonra gelmesini garanti eder.

> `bird_all` hikâyenin tez cümlesidir: *"Three birds. One he made for a child, one he
> never finished, one he carved as a monster. Same hands. Always the same hands."*

## G19 — Kod bulmacası ipucu bağlantısı  ·  SIMDI
Yeni düğüm **eklenmedi**; mevcut keypad kodu `"0314"` ile yeni içerik metin üzerinden bağlandı:
- `kitchen.tscn → newspaper` → `newspaper_1`: *"…the date is circled in red. March 14th."*
- `room3.tscn → doseChart` → `room3_5`: *"…The ticks stop on March 14th."*

İki bağımsız ipucu aynı tarihe çıkar; oyuncu kodu bulamasa bile hikâye tutarlı kalır.

## G20 — CH2 tohumu kontrolü  ·  CH2
- `base_box` ("FOR WHEN YOUR HANDS START SHAKING") açılmaz, sadece monolog verir →
  devam oyununa bırakılmış bir kutu.
- `epi_*` ve `garden_1/2` anahtarları `lang.csv`'ye yazıldı ama **hiçbir yere bağlı değil**
  (G27 bunu bağlayacak).
- `Objectives` autoload'u hiçbir yeni içeriğe işaret etmiyor.

---

## Değişen dosyaların özeti

```
Scripts/GameState.gd                       |  57 +   (30 → 87 bayrak/sayaç)
Scripts/Phone.gd                           |  49 +-  G10
Scripts/familyPicture.gd                   |  31 +-  G06
Scripts/frontKey.gd                        |   4 +-  G09
Scripts/frontkeyPlacing.gd                 |  11 +-  G16
Scripts/mainJS.gd                          |   2 +   G11
Scripts/monster.gd                         |  51 +-  G14 + G15
Scripts/pistolPicking.gd                   |  11 +-  G12
Scripts/tv.gd                              |  45 +-  G09
assets/House/Floor1/Basement.tscn          | 144 +   G13 (5 düğüm)
assets/House/Floor1/Basement/basement.gd   |   5 +   G11
assets/House/Floor1/floor1hallWay.tscn     |  66 +   G05 + G16 (2 düğüm)
assets/House/Floor1/kitchen.gd             |  12 +-  G02 + G12
assets/House/Floor1/kitchen.tscn           | 125 +   G02 + G07 (4 düğüm)
assets/House/Floor1/storageRoom.tscn       |  76 +   G01 + G07 (2 düğüm)
assets/House/Floor2/Bathroom/bathroom.tscn | 104 +   G03 + G07 (3 düğüm)
assets/House/Floor2/Bedrooms/room1.tscn    |  14 +   G06 (sadece extraSpeech)
assets/House/Floor2/Bedrooms/room2.tscn    | 101 +   G09 (3 düğüm)
assets/House/Floor2/Bedrooms/room3.tscn    | 175 +   G08 + G07 (7 düğüm)
assets/House/Floor2/Library/Library.tscn   |  80 +   G04 + G07 (2 düğüm)
assets/House/Floor2/hallWay/hallWay.tscn   | 114 +   G17 + G18 (3 düğüm + 2 marker)
assets/main/main.gd                        |  15 +-  G16
assets/main/main.tscn                      |  15 +   G16 (sadece extraSpeech)
23 files changed, 1278 insertions(+), 29 deletions(-)
```

**Toplam eklenen etkileşimli düğüm: 30** (26 `inspect_item` + 2 `generic_door`/`frontDoor`
+ 2 `scene_intro`). Yeni sahne: 1 (`attic.tscn`).
