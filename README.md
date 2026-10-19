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

Yeni bir png/ogg/obj eklerken **import'u beklemeyin** — aşağıdaki üreteci çalıştırın.

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
```
Not: `--script` modunda autoload'lar (GameState/FadeLayer/Wind) mevcut **olmadığından**
her script "Identifier not found: GameState" verir — bu **yanlış pozitiftir**; gerçek
oyunda (yukarıdaki komut) temiz derlenir. Gerçek hata ararken bu satırları yok say.

---

## The Backrooms 1998'den çevrilen varlıklar

`/storage/emulated/0/Ringtones/backrooms_assets` (AssetRipper çıktısı) ve
`backrooms_mod/audio_new`'ten seçilip `.res`'e çevrildi: klasik duvar kâğıdı, nemli halı,
beton/metal dokuları; flüoresan vızıltısı, mutant hırlama/bağırma, uzak HELP, jeneratör,
kahkaha, yüzey ayak sesleri; ve `monster.obj` varlık modeli.
