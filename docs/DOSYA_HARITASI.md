# DOSYA HARİTASI — Hangi dosya neden değişti

## 1. Yeni dosyalar (10)

| Dosya | Satır | Görev | Amaç |
|---|---|---|---|
| `Scripts/Speech.gd` | 29 | G00 | Ortak altyazı oynatıcı (`class_name Speech`, statik `say`) |
| `Scripts/inspect_item.gd` | 107 | G00 | Genel inceleme/toplama nesnesi — yeni içeriğin tamamı bunu kullanır |
| `Scripts/scene_intro.gd` | 25 | G00 | Sahneye ilk girişte bir kez oynayan monolog |
| `Scripts/DOORS/generic_door.gd` | 43 | G00 | Koşullu genel kapı (çatı katı gidiş-dönüş) |
| `Scripts/DOORS/frontDoor.gd` | 31 | G16 | SON C ön kapısı |
| `assets/House/Floor2/attic.tscn` | ~260 | G17 | Çatı katı — tamamen yeni sahne, primitif geometri |
| `assets/main/game_theme.tres` | — | G00 | `gui/theme/custom` |
| `lang.csv` | 98 | G00 | Çeviri tablosu (`keys,en,ar`, 97 anahtar) |
| `lang.csv.import` + `lang.en.translation` + `lang.ar.translation` | — | G00 | Android editörün `lang.csv`'den ürettiği yan dosyalar |
| `Sounds/` (8 mp3 + 8 .import) | — | G00 | Bulunamayan ortam sesleri için **geçici ikame kopyalar** |
| `globalTools/` | — | G00 | Autoload sahneleri (`Steps`, `FadeLayer`, `Wind`, `Objectives`, `Comfy`, `KeyPad`, `flashlight/`, hover png'leri) |

## 2. Değişen dosyalar (23)

### Script'ler (11)

| Dosya | +/- | Görev | Ne değişti |
|---|---|---|---|
| `Scripts/GameState.gd` | +57 | hepsi | Bayrak sayısı **30 → 87**. Dört blok hâlinde: kuş sistemi, toplanabilirler/belgeler, tek seferlik incelemeler, semptomlar+telefon, sonlar |
| `Scripts/monster.gd` | +51 | G14, G15 | `die()` içine SON A satırları; yeni `_ending_holdon()` + `interact()` başına şırınga kontrolü; `_line()` yardımcısı |
| `Scripts/Phone.gd` | +49 | G10 | `CollisionShape3D` artık `queue_free` yerine `disabled`; `_late_call_pending()` + `_late_call()`; `_ready()` dal yapısı yeniden |
| `Scripts/tv.gd` | +45 | G09 | `TAPE_LINES` sabiti; `interact()` başına `casset_putted` dalı; yeni `_play_tape()`; `interaction_locked`/`CollisionShape3D` geri alımı |
| `Scripts/familyPicture.gd` | +31/-14 | G06 | `room1_picture_seen` guard; ikinci bakışta `mom_letter1`+`mom_letter2`; varsa `s2` animasyonu |
| `assets/main/main.gd` | +15 | G16 | `$breathing.stop()` sonrasına `ending_leave_done` dalı; yeni `_ending_leave()` |
| `assets/House/Floor1/kitchen.gd` | +12 | G02, G12 | `kitchen_entered` artık **her girişte** artıyor; 2. girişten itibaren `symptom_1` |
| `Scripts/frontkeyPlacing.gd` | +11 | G16 | Yanlış bayraklar düzeltildi (`doorHandel_picked`→`frontKey_picked`, `is_handel_installed`→`is_frontkey_installed`); `_ready()` eklendi |
| `Scripts/pistolPicking.gd` | +11 | G12 | `pause()` ile `queue_free()` arasına `symptom_3` |
| `assets/House/Floor1/Basement/basement.gd` | +5 | G11 | `unfreeze()`+fare yakalama bloğunun sonuna `lucid_1` |
| `Scripts/frontKey.gd` | +4/-2 | G09 | `queue_free()` konuşma animasyonundan sonraya alındı |
| `Scripts/mainJS.gd` | +2 | G11 | `monster_encounters == 2 → monster_watch` (mevcut `== 3` scare bloğunun önüne) |

### Sahneler (12)

| Sahne | + | Görev | Eklenen düğümler |
|---|---|---|---|
| `assets/House/Floor2/Bedrooms/room3.tscn` | 175 | G08, G07 | `extraSpeech`, `intro`, `bed3`, `chains3`, `doseChart`, `doorInside`, `letter3`, `journal05` |
| `assets/House/Floor1/Basement.tscn` | 144 | G13 | `extraSpeech`, `wallWriting`, `baseChains`, `baseBed`, `baseBox`, `baseApology` |
| `assets/House/Floor1/kitchen.tscn` | 125 | G02, G07 | `extraSpeech`, `mugs`, `newspaper`, `recipe`, `journal03` |
| `assets/House/Floor2/hallWay/hallWay.tscn` | 114 | G17, G18 | `extraSpeech`, `giftBird`, `toRoom3Door`, `toAtticDoor`, `SpawnPoints/from_attic`, `SpawnPoints/from_room3` |
| `assets/House/Floor2/Bathroom/bathroom.tscn` | 104 | G03, G07 | `extraSpeech`, `mirrorLook`, `syringeBox`, `journal04` |
| `assets/House/Floor2/Bedrooms/room2.tscn` | 101 | G09 | `extraSpeech`, `tape01`, `tape02`, `frontKey` (mevcut düğüm taşındı) |
| `assets/House/Floor2/Library/Library.tscn` | 80 | G04, G07 | `extraSpeech`, `medBooks`, `journal02` |
| `assets/House/Floor1/storageRoom.tscn` | 76 | G01, G07 | `extraSpeech`, `woodenBird`, `journal01` |
| `assets/House/Floor1/floor1hallWay.tscn` | 66 | G05, G16 | `extraSpeech`, `emptyFrame`, `frontDoorExit` |
| `assets/main/main.tscn` | 15 | G16 | yalnızca `extraSpeech` + `line` |
| `assets/House/Floor2/Bedrooms/room1.tscn` | 14 | G06 | yalnızca `extraSpeech` + `line` |

## 3. Dokunulmayan dosyalar

Bilinçli olarak **hiç değiştirilmedi**:

- `Scripts/player.gd` — planlama dosyasında "DOKUNMA" işaretli
- `Scripts/FadeLayer.gd` — aynı
- `sofaScene.gd`, `dream_happy_kitchen.gd` — kırılgan zamanlayıcılar; sadece
  başa/sona ekleme yapıldı (bu ikisine aslında hiç dokunulmadı, zincir korundu)
- `globalTools/keypad.gd` — `"0314"` kodu orijinal, değiştirilmedi; yalnızca metin
  tarafında anlamlandırıldı (G19)
- `Scripts/doorHandel.gd`, `Scripts/handelPlacing.gd` — orijinal, olduğu gibi
- Mevcut tutarsız adlar bilerek korundu: `MosterShows`, `MosterShows2`, `handel`,
  `casset_putted`, `somthing`, `instractions`

## 4. Yetim dosyalar (yazıldı ama hiçbir sahneye bağlı değil)

| Dosya | Durum |
|---|---|
| `Scripts/frontkeyPlacing.gd` | G16'da düzeltildi ama hiçbir `.tscn` bunu bir düğüme atamıyor. SON C doğrudan `frontDoor.gd` üzerinden çalışır |
| `Scripts/doorHandel.gd` | Orijinal depo içeriği; zaten bağlı değildi |
| `globalTools/Objectives.tscn` | **84 baytlık boş stub** — `[node name="Objectives" type="Node"]` dışında bir şey yok, API yok. `project.godot`'da autoload olarak kayıtlı |
| `lang.csv` içindeki `epi_1, epi_a, epi_b, epi_3, garden_1, garden_2, obj_*` | Anahtarlar yazılı, hiçbir script okumuyor (G23, G27 bağlayacak) |

## 5. Autoload'lar (doğrulandı)

| Ad | UID | Yol |
|---|---|---|
| `Steps` | `uid://b475i8i3iuv7d` | `globalTools/Steps.tscn` |
| `FadeLayer` | `uid://dw6t6p2upwq61` | `globalTools/FadeLayer.tscn` |
| `Wind` | `uid://b442dgt2kw0yl` | `globalTools/Wind.tscn` |
| `GameState` | `uid://byhhr1rxopags` | `Scripts/GameState.gd` |
| `Objectives` | `uid://blncchl6c3ldv` | `globalTools/Objectives.tscn` |
| `Comfy` | `uid://mbg3r0sohhhw` | `globalTools/Comfy.tscn` |
| `PauseMenu` | `uid://dsqwr27xktti` | `assets/main/pause_menu.tscn` |

`run/main_scene = "uid://owaruqfsyvm1"` → `assets/main/main_menu.tscn`
`gui/theme/custom = "uid://b531pkflj2f7d"` → `assets/main/game_theme.tres`

## 6. İki kopya sorunu

Proje iki yerde duruyor:

| Yol | Durum |
|---|---|
| `/root/After-the-threshold` | **Esas çalışma kopyası.** Git takipli, hızlı dosya sistemi. Tüm düzenlemeler burada |
| `/storage/emulated/0/After-the-threshold` | Paylaşılan depolama kopyası. `.git` yok (depodaki 3 pack symlink'i kırıktı). Android Godot editörü bu kopyada açıldı ve `.godot/` + `lang.*.translation` dosyalarını **burada** üretti |

`/storage` → `/root` yönünde yalnızca `.godot/`, `lang.csv.import`, `lang.en.translation`,
`lang.ar.translation` kopyalandı. Ters yönde ise yalnızca değişen kaynak dosyalar
senkronlanacak; `/storage`'daki `.godot/` **bir daha üzerine yazılmayacak**.

> G21 bu iki kopyayı tek kaynağa indirmeyi hedefliyor; henüz tamamlanmadı.

## 7. Otel teması dönüşümü (2026-10-19)

Yapı sabit, anlatı değişti: ev → terk edilmiş otel ("The Last Guest"). Ayrıntı `HIKAYE.md`'de.

| Dosya | Ne değişti |
|---|---|
| `lang.csv` | 113 anahtar korundu, tüm en/ar/tr metinleri otel diline çevrildi. Eski hâli: `lang.csv.bak` |
| `lang.en/ar/tr.translation` | Editör import'u bu ortamda çöktüğü için headless GDScript ile (`Translation.add_message`) yeniden üretildi |
| `project.godot` | `config/name="The Last Guest"` |
| `assets/main/main_menu.tscn` | Başlık + alt başlık etiketleri "The Last Guest" |
| `Scripts/mainJS.gd` | `monster_watch` etiket yolu düzeltmesi (`../../` → `../../../`) — replik artık gerçekten oynuyor |
| `Scripts/scene_intro.gd` | null-label koruması + teleport sonrası `process_frame` bekleme |
| `Scripts/inspect_item.gd`, `assets/main/main.gd` | null-label korumaları (davranış aynı) |
| `Scripts/GameState.gd` | Yalnızca yorum: `accessCard_picked` = B1 bodrum anahtarı |

**Senkronizasyon uyarısı:** `/storage/emulated/0/After-the-threshold` kopyası **eski ev
temalı** dilde kaldı. Android'de test etmek isteyen önce şu dosyaları kopyalamalı:
`lang.csv`, `lang.*.translation`, `project.godot`, `assets/main/main_menu.tscn`,
`Scripts/mainJS.gd`, `Scripts/scene_intro.gd`, `Scripts/inspect_item.gd`,
`assets/main/main.gd`.

## 8. Backrooms Level 0 eklemesi (2026-10-19, ikinci tur)

The Backrooms 1998'den çıkarılan assetlerle **opsiyonel gizli alan**:

| Dosya | Görev |
|---|---|
| `assets/Backrooms/level0.tscn` | Klasik Level 0: sarı duvar kâğıdı, nemli halı, flüoresan tavan, sis, 4 oda + koridor, titreyen ışık, fısıltı zamanlayıcı, nefes tuzak alanı, fotoğraf easter egg'i |
| `Scripts/level0_amb.gd` | Işık titremesi + 28-60sn'lik rastgele fısıltı + odaya girince nefes |
| `assets/backrooms/src/` | Ham kaynaklar (png/ogg) — .res üretiminin girdisi |
| `assets/backrooms/textures/*.res` | Wallpaper2, halı (temiz/eskimiş), üretilen tavan + ışık paneli dokuları, creepy fotoğraf |
| `assets/backrooms/audio/*.res` | 12 ses: flüoresan vızıltısı, Backrooms ortam, tehlike, smiler drone, watcher fısıltıları, nefes, çığlık (Vorbis/ogg — Opus DEĞİL, Godot desteklemez) |
| `assets/House/Floor2/attic.tscn` | + `toLevel0Door` (çatı katı kuzey duvarı; `attic_3_seen` şartı) + `from_level0` spawn |
| `GameState.gd` | + `level0_photo_seen`, `level0_speech_played`, `level0_entered` |
| `lang.csv` | + `level0_1`, `level0_photo`, `level0_locked` (116 anahtar) |

**Kritik ortam notu:** Masaüstü Godot (4.5.2/4.6.3/4.7.2) bu PRoot'ta `--import`/editör modunda **her zaman** `double free` ile çöküyor. Yeni görsel/işitsel varlıklar bu yüzden import sistemini baypas ederek ham `Image`/`AudioStreamOggVorbis` nesneleri olarak `.res` içine gömüldü (`Scripts/_resbuild_tmp.gi` deseni; script silindi, çıktı depoda). Android editörü tscn'leri normal açar; .res'ler import gerektirmez.

## 9. Backrooms çok seviyeli arc (2026-10-19, üçüncü tur)

Oyun tek gizli odadan **4 seviyeli bir geri sayım arc'ına** çıktı. Amaç: toplam süreyi
~1 saatin üzerine taşımak.

**Akış:** bodrumdaki kilitli kutu (`box_seen`) → arkasındaki **no-clip duvarı** →
`level0` (sarı labirent, **pirinç anahtar** ara) → `level1` (beton otopark, **2 sigorta**)
→ `level2` (metal boru kâbusu, **valf**) → `hub` (yuvarlak çıkış odası) → otelden çıkış.

| Dosya | Görev |
|---|---|
| `tools/gen_levels.py` | Grid'den .tscn üreteci. Oda/koridor + kapı boşlukları + ışık/item/spawn/ses/amb. BFS erişilebilirlik doğrulaması var (çözülmez grid üretimi engeller). Hücre=4m, tavan=2.9m. Yeniden üret: `python3 tools/gen_levels.py` |
| `assets/Backrooms/level0.tscn` | Üreteçle yeniden yazıldı (elle yazılmış ilk sürümün yerine geçti). 15x15 labirent, 11 ışık, anahtar+foto+badem suyu+yumurta, 3 kapı |
| `assets/Backrooms/level1.tscn` | 15x15 beton otopark, loş, 2 sigorta + sigorta paneli, jeneratör/tehlike/HELP sesleri |
| `assets/Backrooms/level2.tscn` | 15x15 metal boru katmanı, en karanlık, valf + zincir notu, varlık hırlama/bağırma/metal vuruş zamanlayıcı |
| `assets/Backrooms/hub.tscn` | 11x11 çıkış odası; EXIT (otele dönüş), Level 2'ye dönüş, ve "daha derin" kapısı (asla açılmaz, `__never__` bayrağı) |
| `Scripts/backrooms_amb.gd` | Genelleştirilmiş atmosfer: titrek ışık + whisper/growl/sfx rastgele zamanlayıcıları (bos NodePath'lar atlanır) |
| `assets/House/Floor1/Basement.tscn` | + `noClipDoor` (baseBox arkası, `box_seen` şartlı, level0'a açılır) |
| `assets/House/Floor2/attic.tscn` | `toLevel0Door` ikinci giriş olarak duruyor |
| `GameState.gd` | +16 bayrak (level0_key, level1_fuse1/2, level2_valve, hub_note_seen, backrooms_survived, ...) |
| `lang.csv` | 116 → **132** anahtar. 16 yeni Backrooms repliği (en/ar/tr) |
| `assets/backrooms/{textures,audio}/*.res` | +5 doku (beton/metal/vent), +14 ses (mutant, help, metal, generator, laugh) — toplam 37 .res |

**Bug düzeltmesi:** `level0_locked` ve `level0_photo` satırlarında virgüllü alanlar
tırnaksız yazılmış; CSV 5/8 sütuna ayrışıp bozuk çeviri üretiyordu. Tırnakla sarıldı,
çeviriler 132 anahtar için yeniden üretildi.

**Not:** Masaüstü Godot hâlâ `--import`'ta çöktüğü için tüm yeni varlıklar `.res`
(import baypas). `.tscn`'ler `ext_resource type="Resource"` ile .res çekiyor; Image→
Texture2D, AudioStreamOggVorbis sorunsuz yükleniyor (5 sahne instantiate edildi).

## 10. Diğer oyundan (Backrooms 1998) model/ses/HUD taşınması (dördüncü tur)

Kullanıcı seçimi: prop+decal, görünür varlık+kovalayıcı, survival HUD+ayak sesleri.

**OBJ → .res (import baypas):** masaüstü Godot `--import` çöktüğü için `.obj`'ler
GDScript'te elle parse edilip `SurfaceTool` ile `ArrayMesh` olarak `.res` gömüldü
(`assets/backrooms/meshes/*.mesh.res`). v/vn/vt üçlüleri köşe köşe çözüldü, dörtgenler
fan'lendi. Monster Z-up → yerleştirirken rotX(-90).

| Dosya | Görev |
|---|---|
| `assets/backrooms/meshes/{monster,Barrel_LOD0,Chair_01_LOD0,BreakableCrate}.mesh.res` | Prop + varlık mesh'leri |
| `assets/backrooms/textures/{Zombie_Body_Diffuse,Barrel_White_Albedo,Chair_A,Crate_Breakable_Diffuse,Blood_Decals_A,Decals_papers_BaseColor,VHS_Monster}.res` | Prop dokuları + jumpscare yüzü |
| `assets/backrooms/audio/Footstep_{Concrete,Metal,WaterOverKnee}_01.ogg.res` | Yüzey ayak sesleri |
| `tools/gen_levels.py` | +prop/decal/entity üretimi + `basis()` rotasyon yardımcısı + `add_sanity` |
| `Scripts/backrooms_entity.gd` | Tetik alanına girince beliren, kovalayan, yakalayınca jumpscare + `reload_current_scene` ile spawn'a dönüş + sanity cezası |
| `assets/Backrooms/entity.tscn` | Reusable varlık sahnesi (monster Body + Area trigger + growl + scream + CanvasLayer jumpscare) |
| `Scripts/backrooms_amb.gd` | +`surface` (yüzeyi GameState'e yazar) +`drain_sanity`/`sanity_rate` (akıl erimesi) |
| `Scripts/inspect_item.gd` | +`add_sanity` (badem suyu = +40 akıl) |
| `globalTools/Hud.{gd,tscn}` | Yeni autoload: sadece Backrooms sahnelerinde görünür akıl çubuğu + vinyet |
| `globalTools/Steps.tscn` | +concrete/metal/water ayak sesi player'ları |
| `Scripts/player.gd` | Ayak sesi `GameState.step_surface`'e göre seçilir; DOKUNMA yasağına istisna (yalnız adım bloğu, yüzey-agnostik kalır) |
| `project.godot` | +Hud autoload |
| `GameState.gd` | +`sanity`, `deaths`, `step_surface` |

**Level 2 ve Hub'da stalker** var (valf/çıkış başında). Level 0/1'de yok (öğrenme eğişi).
**Not:** `--script` modunda tüm script'ler "Identifier not found: GameState" verir — bu
yalnızca autoload'ların o modda olmaması; oyun içinde sorunsuz derlenir (boot smoke temiz).
