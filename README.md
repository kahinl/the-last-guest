# The Last Guest — Son Misafir

Godot 4 ile yapılmış, üç dilli (TR / EN / AR) birinci-şahıs atmosfer-korku oyunu.
Bir otelde başlar; **The Backrooms**'a (Level 0 → 1 → 2 → Hub) uzayan opsiyonel bir
hayatta-kalma arc'ı içerir.

> Bu depo **tam kaynak kodudur**: `.glb`/`.obj` modeller, dokular, sesler ve tüm
> scriptler dâhil. `.godot/` önbelleği ve dışa-aktarım çıktıları hariç.

---

## Hızlı başlangıç

1. **Godot 4.7** ile `project.godot` dosyasını aç (Android'deki Godot editörü sorunsuz açar).
2. Ana sahne: `assets/main/main_menu.tscn` (F5 / ▶).
3. Kontroller: `WASD` hareket · `Fare` bakış · `E` etkileşim · `F` el feneri · `Shift` koşu.

Dil: oyun sistem diline göre `lang.{en,ar,tr}.translation` kullanır; `tr` varsayılan
görünür. Tüm replikler `lang.csv`'dedir.

---

## Oyun yapısı

- **Ana akış (otel):** orman → lobi → fener → üst katlar → B1 anahtarı → kaset → TV →
  bodrum kodu `0314` (14 Mart) → servis katı → rüya → final. Üç son: Bırakmak / Tutunmak / Gitmek.
- **Backrooms arc'ı (opsiyonel, ~25-35 dk):** bodrumdaki kilitli kutu (`box_seen`) →
  arkasındaki **no-clip duvarı** → **Level 0** (sarı labirent, pirinç anahtar) →
  **Level 1** (beton otopark, 2 sigorta) → **Level 2** (metal boru, valf + **stalker**) →
  **Hub** (çıkış odası + **stalker**) → otele dönüş.
- **Hayatta kalma:** Backrooms'da akıl (sanity) erir; **badem suyu** ile geri gelir.
  Düşük akıl → vinyet + varlık aktivitesi. Yüzey bazlı ayak sesleri (ahşap/beton/metal/su).

Kod haritası ve hikâye ayrıntısı için: `docs/DOSYA_HARITASI.md`, `docs/HIKAYE.md`.

---

## ⚠️ Kritik çalışma notu: import sistemi kullanılamıyor

Bu projedeki **tüm görsel/işitsel/3B varlıklar Godot'nun normal import pipeline'ı
yerine elle `.res` olarak gömülmüştür.** Sebep: masaüstü Godot (4.5/4.6/4.7) bu
Android/PRoot ortamında `--import` veya editör modunda **`double free` ile çöküyor.**

Sonuç olarak:
- Doku/ses/mesh'ler `assets/backrooms/{textures,audio,meshes}/*.res` altında.
- `.tscn` dosyalar bunları `ext_resource type="Resource"` ile çeker (`Image`→Texture2D,
  `AudioStreamOggVorbis`, `ArrayMesh`).
- Ham girdiler `assets/backrooms/src/` altında durur (png, ogg, obj).

> **Tuzak (2026-10-20'de düzeltildi):** `build_assets.gd` dokuları ham `Image` olarak
> kaydediyordu; `albedo_texture` ise `Texture2D` bekler. Image reddedildiği için tüm
> Backrooms yüzeyleri **dokusuz, düz boyalı** render oluyordu ve hata hiçbir yerde
> görünmüyordu. Artık `.res` içinde `ImageTexture` var (POT ölçeklerde mipmap üretilir)
> ve sahneler `type="Texture2D"` ile çekiyor. Yeni doku eklerken `Image` değil
> **her zaman `_save_tex()`** kullan.

Yeni bir png/ogg/obj eklerken **import'u beklemeyin** — aşağıdaki üreteci çalıştırın.

---

## Nerede çalışılır

| Yer | Ne |
|---|---|
| `/root/TheLastGuest` | **aktif git deposu** + `.godot` önbelleği. Tüm doğrulama burada koşar. |
| `/storage/emulated/0/After-the-threshold` | telefon kopyası, **yalnızca kaynak** (`.git`/`.godot` yok). Android'deki Godot editörü bunu açar. |

Telefon depolaması büyük/küçük harf duyarlı **değil**: repoda `assets/Backrooms/`
(sahneler) ve `assets/backrooms/` (doku/ses/mesh) ayrı klasörlerken telefona geçince
tek klasöre birleşir. Çalışıyor ama yeni dosya eklerken bu ikiliği bil.

---

## Yeniden üretme (regenerate)

### 1. Backrooms asset'leri (png/ogg/obj → .res)
```
godot --headless --path . --script res://tools/build_assets.gd
```
`src/` içindeki tüm png→doku, ogg→ses (LOOP_KEYS döngü olur), obj→`ArrayMesh` çevrilir;
ayrıca tavan karosu + floresan panel prosedürel üretilir.

### 2. Seviye sahneleri (grid → .tscn)
```
python3 tools/gen_levels.py
```
`level0/1/2/hub.tscn` üretilir. **BFS erişilebilirlik doğrulaması** vardır: spawn'dan her
item/kapıya ulaşılamıyorsa üretimi durdurur (çözülmez labirent giremez). Hücre=4 m,
tavan=2.9 m. Oda/koridoru `grid`, içeriği `props/decals/items/doors/entities/lights/audio/amb`
listeleriyle tanımla. Ayrıntı: `tools/README.md`.

### 3. Çeviriler (lang.csv → .translation)
```
godot --headless --path . --script res://tools/build_translations.gd
```
`lang.csv` (sutunlar: `keys,en,ar,tr`) → `lang.{en,ar,tr}.translation`. Virgüllü metinler
**tırnak içinde** olmalı; değilse satır bozuk ayrışır (geçmişte bu bir bug'a yol açtı).

> Sıra: csv/asset değişti → ilgili build script'i çalıştır → `gen_levels.py` (sahne
> içeriyorsa) → headless smoke (aşağıda).

---

## Doğrulama (headless)

```
godot --headless --path . --quit-after 8        # oyun açılıyor mu (script/parse hatası?)
python3 tools/audit_chain.py                    # kapı→hedef→spawn→bayrak zinciri, 0 hata olmalı
godot --headless --path . tools/probe.tscn -- spawns res://assets/Backrooms/level0.tscn
xvfb-run -a godot --path . --rendering-method gl_compatibility tools/shot.tscn -- "res://assets/Backrooms/level0.tscn" "/tmp/level0"
```

Sıra: **smoke → audit_chain → probe → shot**. `audit_chain` kapıların *var olmayan*
spawn adlarını yakalar, `probe` o spawn'ların *fiziksel olarak durulabilir* olduğunu
yakalar, `shot` ise gözle bakılacak kareyi verir (doku/tint/sis ancak böyle doğrulanır).
Not: `--script` modunda autoload'lar (GameState/FadeLayer/Wind) mevcut **olmadığından**
her script "Identifier not found: GameState" verir — bu **yanlış pozitiftir**; gerçek
oyunda (yukarıdaki komut) temiz derlenir. Gerçek hata ararken bu satırları yok say.

---

## The Backrooms 1998'den çevrilen varlıklar

`/storage/emulated/0/Ringtones/backrooms_assets` (AssetRipper çıktısı) ve
`backrooms_mod/audio_new`'ten seçilip `.res`'e çevrildi: klasik duvar kâğıdı, nemli halı,
beton/metal dokuları; flüoresan vızıltısı, mutant hırlama/bağırma, uzak HELP, jeneratör,
kahkaha, yüzey ayak sesleri; ve `monster.obj` varlık modeli.

---

## 2026-10-20 akşamı oturumu (devam)

Aşağıdaki `Kalan işler` listesi bir önceki oturumun **tespit** listesidir; bu bölüm
onların durumunu günceller.

- **KRİTİK, listede yoktu: `player.gd` hiç derlenmiyordu.** `a21e16c` (perf) commit'i
  `_stop_footsteps(fade)` içinde `AudioStreamPlayer.stop(fade)` yazmış; Godot 4'te
  `stop()` argüman kabul etmediği için dosya parse edilemiyor ve **Player script'i
  hiçbir sahnede yüklenmiyordu** (kontrolcü ölü). `eff532b` ile düzeltildi; fade
  geri getirilmedi çünkü çağrıldığı yer hareketin bittiği her fizik karesi.
  **Doğrulama zinciri bunu neden yakalamadı:** `probe`/`shot` çıktısı `grep ^PROBE`
  ile filtrelendiği için `SCRIPT ERROR` satırları logda duruyordu ama hiç görünmüyordu.
  Bundan sonra doğrulamada en az bir kez `grep -E "SCRIPT ERROR|Parse|Failed to load"`
  koşulacak (bu iki araçta artık **sıfır** satır olmalı).
- A1 ve A2'nin hol yarısı kapandı; `hallWay.tscn` probe'ta **7/7 spawn ok**.
- `tools/shot.gd` iki seçenek kazandı: `bright` (ortam ışığını yükseltir; otel
  seviyeleri el feneri olmadan zifiri karanlık render oluyordu) ve
  `cam=x:z[:y[:ry]]` (kamera istenen noktaya konur). Yerleşim teşhisi ikisiz yapılamadı.
- **Bölüm B'nin tamamı kapandı**: B5 ayar oldu, B6-B9 kodlandı, **B10 bilinçli olarak
  değiştirilmedi** (gerekçesi maddede yazılı).
- Karar gerektiren diğer maddeler: **C13** — `/root/After-the-threshold` olduğu gibi
  bırakıldı (tek `.godot` önbelleği orada, yeniden üretmek pahalı). **C14** — Termux
  `~/.bashrc`'deki düz metin Google API anahtarı **doğrulandı**
  (`/data/data/com.termux/files/home/.bashrc`; `/root/.bashrc` değil) ama tercihen
  dokunulmadı. Not: bir kez düz metin görülmüş anahtarın asıl çözümü **dondurup
  yenisini üretmek**, dosyayı düzenlemek değil. **C12** — madde bayat: depoda artık
  `beyhan` remote'u **yok**, tek remote `origin` = `https://github.com/kahinl/the-last-guest.git`
  ve `main` 16 commit önde. Push, hedef netleşince.

### Hol kapılarının gerçek hikâyesi (A1'in kök nedeni tahminden farklıydı)

`hallWay` içindeki `toRoom3Door` (-4.08, 1.15, **-3.2**) ve `toAtticDoor`
(**-21.5**, 1.18, 3.7) G28'de **tahminî koordinatla** konmuştu ve ikisi de holün
zemininin dışında, boşlukta duruyordu: oyuncu onlara **ulaşamıyordu**, yani room3 ve
çatı katı içeriği kilitliydi. Holün yürünebilir bandı `x ∈ [-19, -4] , z ∈ [-0.7, 3.2]`
(+ banyo kolu `x≈-4.2, z→8`); güney duvar yüzü `z≈-1.2`, kuzey duvar yüzü `z≈3.55`.

- `toRoom3Door` → güney duvarda pilaster bölmesine: **(-8.05, 1.02, -1.35)**.
- `toAtticDoor` → kuzey duvardaki **modelde gerçekten var olan ahşap kapıya**:
  **(-18.9, 1.02, 3.5)** (kare ile doğrulandı; kapı yaprağı x≈-19.6..-18.7).
- `Scripts/f_room3.gd` room3'ten çıkışı **room1.tscn**'e gönderiyordu (kopyala-yapıştır
  izi; room1'in `SpawnPoints`'i bile yok, oyuncu `Player` düğümüne düşüyordu). Artık
  `hallWay` → `from_room3` zinciri kurulu ve `from_room3` marker'ı bu yüzden yaşıyor.
- Otel kapı hacimleri **görünmez ama kalın**: `toRoom1/toLibrary/...` kutuları
  1 × 3.43 × 1.77 m. Varış marker'ları bu yüzden duvara ~0.6 m mesafede durmalı;
  eskiden -0.94/-0.98'deydiler ve kutunun içindelerdi (A2'nin "küçük itme"si buydu).
  `from_room1`/`from_library` → z=-0.55, `from_bath` → x=-4.20, `from_room2` → z=2.40,
  `from_attic` → (-18.6, 2.5), `from_room3` → (-8.05, -0.55).

---

## Kalan işler — 2026-10-20 devir notu

Bu oturumda bulunan ama **yapılmayan** her şey. Değer sırasına göre; satır numaraları
o günki hâle göre.

### A. Görsel / oynanış hataları

1. **`hallWay.tscn` → `SpawnPoints/from_room3` altında 2 m içinde zemin YOK**
   (x=-4.12, z=-2.40). Room 3'ten hol'e dönen oyuncu dünyanın dışına düşer.
   Hol çarpışma zemini bu eşikte bitiyor; komşu `from_room1` (z=-0.94) sağlam.
   **KAPANDI** — kök neden tahminden farklıydı, bkz. yukarıdaki "Hol kapılarının
   gerçek hikâyesi". Asıl sorun marker değil, kapının kendisinin boşlukta olmasıydı.
2. **Otel spawn'ları kapı/eset gövdelerinin içinde kalıyor** (probe `<< DURULMAZ`):
   `hallWay`: `from_room2`→`toRoom2`, `from_room1`→`toRoom1`, `from_library`→`toLibrary`,
   `from_bath`→`toBath`, `from_attic`→6×`StaticBody3D`;
   `floor1hallWay`: `default1`→`frontDoorExit`+`handel`, `from_kitchen`→`roomDoor2`,
   `from_floor2`→`f2Door` (marker bulduğu yüzeyin 0.9 m altında).
   **KAPANDI** — hepsi tasindi; iki hol artik 10/10 spawn `blok=hayir`. Ayrinti
   yukaridaki "Hol kapilarinin gercek hikayesi" bolumunde. `from_floor2` ayrica
   merdiven basagindaydi: marker `f2Door` yapriginin ALTINDAYDI (y=4.37), isin
   zemine degil kapiya calisiyordu → `(4.6, 4.65, -1.2)`.
   **Arac notu:** `probe.gd` artik `stairs*` carpismalarini `DURULMAZ` saymiyor
   (`basamak=N` olarak ayri basiyor). Merdivende duran her kapsul bir sonraki
   basamaga degmek zorunda; aksi halde her merdiven spawn'i yanlis pozitif veriyor.
3. **Paletler artık çift tonlama yapıyor.** Doku düzeltmesinden önce tint rengi tek
   başına taşıyordu; şimdi gerçek dokunun üstüne çarpılıyor → `P0` zeytin yeşiline
   kaydı (`wall_tint="1, 0.9, 0.55"` + zaten sarı `Wallpaper2`), `P1` çok karanlık
   (`esp_concrete_black` × mavi-gri tint). `P0/P1/P2/PH` için `shot.tscn` karesine
   bakarak kalibre et. **level2 ve hub kareleri hiç değerlendirilemedi** (seans orada
   kesildi).
   **KAPANDI** — ölçerek: `Wallpaper2` zaten sarı (R178 G177 **B96**), `esp_concrete_black`
   aslında orta gri (R118 G110 B102), `Metal_albedo` neredeyse nötr (R195 G199 B200).
   Tint'ler buna göre: P0 `1,0.98,0.88` · P1 `1.05,1.08,1.15` · P2 `0.95,1,1.02` ·
   PH `1,0.98,0.85`. **level2'nin camgöbeği tint'ten değil `ambc`/`fog_c`'den geliyordu**:
   orası da yeşilimsi + daha karanlık yapıldı (`ambc 0.42,0.55,0.42`, `ambe 0.42`,
   `fog_c 0.3,0.4,0.32`, `light_c 0.75,0.95,0.7`) — palet notunun "en karanlık,
   yeşilimsi" tanımıyla artık uyumlu (parlaklık 72→65, Level 1 67).
4. **`level0.tscn` → `from_level1` spawn'ı `l0key` kaidesinin üstünde**
   (x=24, z=24; zemin y=0.75, marker 1.13 m altında). Snap oyuncuyu 1.43 m'ye, yani
   piramidin üstüne koyuyor. Marker komşu boş hücreye taşınmalı.
   **KAPANDI** — `gen_levels.py` içinde `from_level1` (13,13)→(12,13); yeniden
   üretildi, probe `snap_y=0.68 blok=hayir`. Not: `l0key` `pick:true` oldugu icin
   kadide basilmis bir oyun hata vermezdi (anahtar alinmadan Level 1 acilmiyor);
   yine de kirilganlik kaldirildi.

### B. Performans (bulundu, dokunulmadı)

5. **Tam ekran CRT shader'ı — tek seferde en büyük GPU maliyeti.**
   `assets/player/player.tscn:351` içindeki `CanvasLayer/ColorRect`,
   `assets/player/player.gdshader` `hint_screen_texture` kullanıyor: her karede tam
   framebuffer kopyası + piksel başına 3 ekran örneği (1908×958). Player sahnesi 19
   seviyede instance'lı, `main_menu.tscn:886`'da da aynı overlay var.
   **KAPANDI** — `GameState.crt_enabled` (varsayilan **TRUE**, yani goruntu
   degismedi) + `Scripts/crt_overlay.gd`; ana menude `MENU_CRT` isaretleme kutusu.
   Ayni script `player.tscn` ve `main_menu.tscn`'deki overlay'lere asildi.
   `visible=false` iken Control hic cizilmiyor — ekran dokusu orneklenmedigi icin
   asil maliyet o karede tamamen kalkiyor.
6. **`Scripts/inspect_item.gd:32-37`** — `req` bayrağı için `_process`'te her karede
   `GameState.get(...)` yoklaması. Yalnızca 3 nesne `req` kullanıyor
   (`hallWay.tscn:1291`, `room2.tscn:5721`, `level2.tscn:1359`) ve sonsuza dek yoklar.
   Doğrusu: bayrak setter'ından görünürlüğü itmek. Ayrıca iş yapmayan `_process`
   stub'ları: `kitchen.gd:21`, `dreamfadeout.gd:40`, `main_menu.gd:15`.
   **KAPANDI** — `GameState.flag_set(name,value)` sinyali + `set_flag()` eklendi;
   `inspect_item` artık `_process` **hiç** çalıştırmıyor, kosul yazildigi anda geliyor.
   Bayrak yazan 5 cagri noktasi (`tv.gd`, `scene_intro.gd`, `inspect_item.gd` x3) ve
   `pistolPicking.gd`'deki duz atama `set_flag`'e cevrildi. Uc stub silindi.
   Dogrulama: `tools/test_flagpush.tscn` (3/3).
   > **Tuzak:** test araci `get_tree().root.add_child()`i kendi `_ready`'sinde
   > cagirmamali — "Parent node is busy setting up children" **sessizce** basarisiz
   > oluyor ve ilk sahne hic agaca girmeden "dogru" sonuc veriyordu. Once
   > `await get_tree().process_frame`.
7. **`Scripts/monster.gd:24-26`** — `activated` değilken bile `_physics_process` her
   Basement karesinde koşuyor. `_ready()`'de `set_physics_process(false)` +
   `activate_monster()`'da açmak yeterli.
   **KAPANDI** — sinyal ile aninda, + saniyede 1 yoklayan bir `Timer` guvenlik agi
   (`GameState.pistol_picked = true` diye dogrudan yazan cagri yerleri var; test
   araci gibi). `tools/test_monster.tscn` hâlâ yesil.
8. **`Scripts/flashlight.gd:14-18` ve `cassette.gd:19-22`** — `queue_free()`'den
   **sonra** `await speech.animation_finished` var; nesne serbest kaldığı için
   kuyruğun devamındaki `speech.stop()` hiç çalışmıyor. Bilerek dokunulmadı:
   `queue_free()`'i sona almak, nesnenin ses uzunluğu kadar dünyada görünür kalmasına
   yol açar. Doğru çözüm: `visible=false` + çarpışmayı hemen kapat, free'i sonda yap.
   **KAPANDI** — onerildigi gibi: `visible=false` + `collision_layer=0` + `hide_prompt()`
   hemen, `queue_free()` ses bitince. Carpisma kapandigi icin ikinci bir `interact()`
   isikiniyla zaten ulasilamaz.
9. **`Scripts/backrooms_amb.gd:60-69` ve `level0_amb.gd` `_schedule()`** — her amb
   düğümünde 3 adet `while true: await create_timer(...)`. Sahne kapatıldıktan sonra
   90 sn'ye kadar askıda coroutine/timer tutuyor (`is_inside_tree()` kontrolü var, o
   yüzden çökmüyor). `Timer` düğümüne çevrilmeli.
   **KAPANDI** — `backrooms_amb._schedule()` artik `Timer` dugumu (one_shot, her
   atista yeni rastgele sure). Calisma aninda dogrulandi: level0 `amb`'inde 2 Timer
   (40.9 s / 85.5 s, ikisi de aralikta) kosuyor.
   > **Beklenmedik:** `Scripts/level0_amb.gd` **hicbir sahne tarafindan kullanilmiyor**
   > (level0'un `amb` dugumu `backrooms_amb.gd` tasir). Dosya ya silinmeli ya da
   > nefes-alani tetigi gibi davranislari baska bir yere tasinmali — kendiliginden
   > silinmedi, sahipli bir icerik olabilir.
10. **`project.godot`** — `:37` `window/size/mode=4` (exclusive fullscreen) Android'de
    anlamsız; `:139-140` hem S3TC/BPTC hem ETC2/ASTC içe aktarma açık (ithalat işini
    ikiye katlar; telefonda yalnızca ETC2/ASTC gerekir); `:136` Jolt fiziği sadece
    kapsül-durağın geometri için kullanılıyor (specülatif, ana iş parçacığı maliyeti);
    `:19` boş ses yolu düzeni (her ses Master'da).
    **KARAR: hicbiri degistirilmedi** (2026-10-20 akşamı, gerekçeleriyle):
    · S3TC/BPTC kapatmak ithalat isini yariya indirir AMA (a) Windows/itch export'u
    hâlâ planlanmis bir madde (G32) ve masaustu S3TC ister, (b) bu cihazda editor
    `--import`'ta coktugu icin ithalat zaten kosulamiyor — yani olculebilir kazanc
    yok, geri donuslu zarar riski var. · Jolt'tan geri almak carpisma davranisini
    degistirir (otel taranmis geometri + kapisma spawn'lari yeni dogruladi),
    speculatif bir kazanic icin risk alinmadi. · `mode=4` Android'de yok sayiliyor,
    masaustunde ise gercek bir davranis degisikligi; tek basina dokunulmadi.
    · `default_bus_layout=""` bir kusur degil: Godot'nun yerlesik tek Master yolu
    demek. Gercekten cok yollu duzen istenirse ekilecek bir dosya, silinecek bir
    satir degil.

### C. İş/araç tarafında kalanlar

11. **`docs/` .gitignore'da** — `BILINEN_SORUNLAR.md`, `DOSYA_HARITASI.md`, `EKLEMELER.md`,
    `EDITORDEN_YAPILACAKLAR.md`, `HIKAYE.md` **hiçbir zaman commit'lenmemiş**; sadece bu
    cihazda duruyorlar. Cihaz değişirse gider. Bu yüzden bu bölüm `README.md`'ye yazıldı.
    **KAPANDI** — `.gitignore`'dan cikarildi, 5 dosya commit'lendi (1266 satir, 88 KB;
    hassas icerik taramasi temiz). Artik `docs/` ile README ayni seyleri tekrarlamasın:
    kalici/teknik bilgi docs/'a, oturum devir notu README'ye.
12. **Hiçbir şey GitHub'a gönderilmedi.** 4 commit yerelde: `bb9b8f6` spawn sistemi,
    `a21e16c` perf, `43e323a` dokular, `ba1befb` doküman. İki remote var:
    `origin` (moon18-eng/After-the-threshold) ve `beyhan` (kahinl/a-beyhans-story).
13. **`/root/After-the-threshold` artık gereksiz** — içindeki commit'lenmemiş iş
    `TheLastGuest`'e taşındı; diğer tek `.godot` önbelleği de orada. Silmek güvenli ama
    `.godot`'u yeniden üretmek bu cihazda uzun sürer.
14. **Termux'un düşmesi yarı çözüldü** — uyku kilidi artık otomatik alınıyor
    (Termux `~/.bashrc`), `tmux 3.6` kurulu ve `/root/bin/agent` son seansı tmux
    içinde devam ettiriyor. **Android taraf hâlâ elle:** Ayarlar → Uygulamalar →
    Termux → Pil → Sınırsız (WIKO T60 / Android 13). Ayrıca Termux `~/.bashrc:5`'te
    düz metin bir Google API anahtarı duruyor.
15. **Uzun iş her zaman `nohup … > log` ile koşulmalı.** Bash aracının kendi
    background görevleri CLI süreciyle birlikte ölüyor (bu sekansta level1 sonrası
    o yüzden yarım kaldı); `nohup` ile başlatılan render ise CLI düştükten sonra
    bitmişti.
