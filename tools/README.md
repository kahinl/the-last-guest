# tools/ — üretim hattı (pipeline)

Backrooms içeriği üç araçla üretilir. Sıra önemli değil ama **csv/asset değişince
ilgili script, grid değişince üreteç** çalışmalı.

| Araç | Görev | Komut |
|---|---|---|
| `build_assets.gd` | `src/` png/ogg/obj → `.res` (doku/ses/mesh) + prosedürel tavan/panel | `godot --headless --path . --script res://tools/build_assets.gd` |
| `gen_levels.py` | grid → `level0/1/2/hub.tscn` + BFS erişilebilirlik kontrolü | `python3 tools/gen_levels.py` |
| `build_translations.gd` | `lang.csv` → `lang.{en,ar,tr}.translation` | `godot --headless --path . --script res://tools/build_translations.gd` |
| `audit_chain.py` | kapı→hedef→spawn→bayrak→konuşma zinciri + eksik dosya denetimi | `python3 tools/audit_chain.py` |
| `shot.tscn` + `shot.gd` | sanal ekranda (Xvfb) sahne render edip PNG ekran görüntüsü alır | `xvfb-run -a godot --path . --rendering-method gl_compatibility tools/shot.tscn -- "res://SEHNE.tscn" "/tmp/cikti"` |
| `probe.tscn` + `probe.gd` | `SpawnPoints` markerlarını fiziksel olarak denetler (zemin var mı, duruş kapsülü geometri içinde mi, marker gömük mü) | `godot --headless --path . tools/probe.tscn -- spawns res://assets/Backrooms/level0.tscn ...` |
| `dump_tex.gd` | `assets/backrooms/**/*.res` içini PNG olarak döker (doku teşhisi) | `godot --headless --path . --script res://tools/dump_tex.gd` |

---

## 0. Sesleri Vorbis'e çevirme (ffmpeg)

Godot'nun `AudioStreamOggVorbis.load_from_buffer`'ı **Vorbis** ister; **Opus desteklemez**
(libopus ile üretilen .ogg'lar `DECODEFAIL` verir). Ham wav'ları şu şekilde çevir:
```
ffmpeg -i KAYNAK.wav -c:a libvorbis -q:a 4 assets/backrooms/src/AD.ogg
```
Sonra `build_assets.gd` çalıştır (ogg'ları `.res` yapar; `LOOP_KEYS` listesindekiler döngü olur).

## 1. OBJ → mesh

`assets/backrooms/src/obj/*.obj` koy; `build_assets.gd` v/vn/vt üçlülerini köşe köşe
çözüp dörtgenleri fan'layarak `ArrayMesh` üretir → `assets/backrooms/meshes/<ad>.mesh.res`.
**Yön:** Unity dışa aktarımında bazı modeller Z-up gelir (örn `monster.obj`); sahneye
koyarken `rotX(-90)` gerekir (`gen_levels.py` bunu prop `rx` alanıyla yapar).

---

## 2. gen_levels.py — seviye tanımı

Her seviye bir `dict`. `grid` satırları: `#`=dolu, `.`=boş. Hücre merkezi
`(cx - (W-1)/2)*4` , `(cz - (H-1)/2)*4`. Dış duvarlar otomatik; kapalı komşu kenarlar
birleştirilerek (run) az düğümle üretilir.

Alanlar:
- `pal` — palet (wall/floor/ceil doku `.res`, uv ölçekleri, sis/ambient/ışık renkleri).
- `spawn` / `spawns[]` — `{name,cx,cz}` (fade ile gelinen Marker3D adları).
- `lights[]` — `{cx,cz,e?,range?,flicker?}`; `flicker:true` olan `amb`'e titreme hedefi olur.
- `items[]` — `inspect_item.gd`: `{name,cx,cz,flag,key,kind,pick?,req?,add_sanity?}`.
  `kind`: key/fuse/valve/box/note/water (renk). `pick:true` → alınca yok olur.
  `req` → başka bir bayrak sağlanmadan görünmez. `add_sanity` → alınca akıl.
- `doors[]` — `generic_door.gd`: `{name,cx,cz,dir,target,spawn,flags?,need_key?}`.
  `dir`=N/S/E/W (kapı o kenardaki duvar boşluğuna oturur). `flags` virgülle çoklu
  (`"a,b"` ikisi de gerekir). `need_key` → kilitliyken gösterilen replik anahtarı.
- `props[]` — `{name,mesh,tex,cx,cz,ry?,rx?,scale?,col?}`; `col=[x,y,z]` verilirse
  StaticBody+çarpışma, yoksa sadece görsel. `prop()` yardımcısını kullan.
- `decals[]` — `{name,tex,cx,cz,dir,y,w,h}`; duvara bakan şeffaf PlaneMesh (kan/kâğıt).
- `entities[]` — `{name,cx,cz}`; `entity.tscn` (stalker) instance'ı.
- `audio[]` — `{name,cx,cz,stream,vol?,maxd?,autoplay?,y?}`; AudioStreamPlayer3D.
- `amb` — `backrooms_amb.gd`: `{whisper?,growl?,sfx?,surface?,drain?,rate?}`.
  `surface` → `GameState.step_surface` (ayak sesi); `drain:true` → akıl erimesi.
- `intro` — `scene_intro.gd`: `{flag,key}` (sahneye ilk girişte bir kez).

### Erişilebilirlik (BFS)
`main()`, üretmeden önce her seviyede spawn'dan tüm item/kapı hücrelerine
(kapı-açılır sayılır) erişim kontrolü yapar; erişilemeyen varsa **üretime durdurur**.
Yeni grid çizerken bu seni korur.

### Üreteci çalıştırma
```
python3 tools/gen_levels.py
```
Çıktı: `assets/Backrooms/{level0,level1,level2,hub}.tscn`. Sonra headless smoke +
`--script` ile sahne instantiate testi yap.

---

## 3. Renk/palet ipuçları
- Level 0: `P0` sarı kâğıt + halı, sıcak ışık, yoğun sarı sis.
- Level 1: `P1` siyah beton, soğuk düşük ışık, mavi-gri sis.
- Level 2: `P2` metal + vent tavanı, en karanlık, yeşilimsi ışık.
- Hub: `PH` Level-0 paletinin açık/umutlu hâli (yeşil çıkış kapısı).

⚠️ `wall_tint` artık **gerçek dokunun üstüne çarpılıyor**. Bir ara `.res` dosyaları ham
`Image` olarak kaydedildiği için `albedo_texture` onları reddediyor ve yüzey düz boya
gibi render oluyordu; o dönemde tint'ler rengi tek başına taşıyordu. Doku düzeltmesinden
sonra aynı tint çift tonlama yapıyor — palet değişirken mutlaka `shot.tscn` karesine bak.

---

## 4. Spawn noktaları ve zemin oturtma

Bir sahneye fade ile girilirken `player.gd` şu sırayı izler:
`FadeLayer.next_spawn_name` → `SpawnPoints/<ad>` Marker3D → `global_transform` kopyalanır
→ `_snap_to_floor()`.

- **Adlandırma:** `default` (sahneye ilk giriş) ve `from_<geldigin_yer>` (örn.
  `from_level0`, `from_backrooms`). `generic_door.gd`'nin `spawn_name` alanı bunu karşılar;
  karşılığı yoksa sessiz kalmaz, `push_warning` basar ve sahnedeki `Player` konumuna düşer.
- **Zemin oturtma:** markerlar tarihsel olarak zeminin ~0.3 m üstünde duruyor ama gövde
  merkezi zemin + `SPAWN_FOOT_Y` (0.68 m; `CollisionShape3D` ofseti 0.297 − kapsül yarım
  başı 0.977) olmalı. Snap olmasa oyuncu her geçişte zemine gömülüp fizik tarafından
  dışarı fırlatılıyor. **Marker yüksekliğini düzeltmekle uğraşma, snap halleder.**
- **Denetim:**
  ```
  godot --headless --path . tools/probe.tscn -- spawns res://...tscn res://...tscn
  godot --headless --path . tools/probe.tscn -- res://SEHNE.tscn "x:z" "x:z:yref"
  ```
  `<< DURULMAZ` satırları: zemin yok, duruş kapsülü geometri içinde, ya da marker
  zeminin altında. Yeni kapı/spawn ekledikten sonra bu araçtan temiz geçmeli.
- `audit_chain.py` ayrıca **kapı→hedef→spawn adının var olup olmadığını** denetler;
  `probe` ise o noktanın **fiziksel olarak durulabilir** olduğunu doğrular. İkisi farklı
  şeyleri bulur, ikisini de çalıştır.
