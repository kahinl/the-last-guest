# HIKAYE — "The Last Guest" (Son Misafir) teması

## Kısa cevap

Oyun, **isimsiz bir canavarlı ev hikâyesinden terk edilmiş bir otel hikâyesine** çevrildi.
Yapısal olarak hiçbir şey değişmedi: aynı sahneler, aynı modeller, aynı bulmaca zinciri,
aynı üç son. Değişen tek şey **anlatı katmanı**: mekân artık bir aile evi değil, ağabeyin
"seyahatte" diye kaydını yapıp kendini kilitlediği bir **otel**. Oyuncu, fırtınada kapısı
kilitlenen son misafir.

Bu dönüşüm 2026-10-19'da `lang.csv` yeniden yazılarak + menü başlıkları ve birkaç script
yolu düzeltmesiyle yapıldı. Eski sürüm yedeği: `lang.csv.bak`.

---

## Zorunlu akış hiç değişmedi

```
orman → otele giriş (lobi) → fener (resepsiyon arkası)
  → floor2Key → üst katlar → B1 anahtarı (room2_4) → kaset
  → TV flashback → bodrum kodu (0314 = 14 Mart) → servis katı/bodrum açılır
  → koltuk → T1-T4 → rüya → Happy Kitchen → bodrum final modu
  → tabanca → canavar kalkar → 2 vuruş → karartma → menü
```

Hiçbir bayrak adı, sahne dosyası, node yolu veya mekanik değiştirilmedi. Yalnızca
metinler ve başlık güncellendi.

## Sahne eşlemesi (ev → otel)

| Sahne (dosya adı değişmedi) | Ev temalı eski anlam | Otel temalı yeni anlam |
|---|---|---|
| `main.tscn` dış dünya | ormandaki ev | fırtınada ışıkları yanan terk edilmiş otel |
| `floor1hallWay` | giriş holü | **lobi / resepsiyon**; fener resepsiyonun arkasında |
| `kitchen` | mutfak | **personel mutfağı** |
| `storageRoom` | depo | **eşya odası** (hiç geri alınmamış bavullar) |
| `Library` | kütüphane | **okuma salonu** |
| `Bathroom` | banyo | **misafirhane banyosu** |
| `room1/room2/room3` | yatak odaları | **1/2/3 numaralı odalar** |
| `attic` | çatı katı | çatı katı (aynı — personel katı üzeri) |
| `Basement` | bodrum | **servis katı**; `accessCard` artık üzerinde "B1" yazan bodrum anahtarı |
| `hospitalKey_picked` bayrağı | hastane anahtarı | iç adlandırma korundu; metinlerde artık "hastane" yok |

## Anlatı çekirdeği (korunan trajedi)

Ağabey, kalıtsal titreme hastalığını araştıran akademisyen. Üniversiteye de kardeşine de
"seyahatteyim" dedi ve çocukluklarının geçtiği bu **otelin** en alt servisine kendi
kendini kilitledi (`journal_04`, `tape2_2`). Küçük kardeş — oyuncu — fırtınada otele
sığınır; kapı kendi kendine kilitlenir. Kasetler, günlükler, doz çizelgesi, zincirler,
tahta kuşlar, 14 Mart (kod: 0314), çay ritüeli: hepsi aynı, yalnızca mekân dili otel.

Ölçüt cümlesi değişmedi: *"Same hands. Always the same hands."* (`bird_all`)

## Bu turda değişen/düzeltilen teknik noktalar

- `project.godot` → `config/name="The Last Guest"`; menüde üç etiket → "The Last Guest".
- `lang.csv`: 113 anahtar birebir korundu (diff ile doğrulandı); yalnızca metinler otel
  diline çevrildi. `ar` sütunu da yeniden çevrildi.
- `lang.*.translation` dosyaları artık **bu depoda üretiliyor**: headless Godot ile
  geçici bir GDScript kullanılıp `Translation.add_message` üzerinden yazıldı (editör
  import'u bu ortamda her sürümde `double free` ile çöküyor). CSV değiştiğinde aynı
  yöntem tekrar edilmeli.
- `Scripts/mainJS.gd`: `monster_watch` etiket yolu düzeltildi (`../../` → `../../../`;
  script `monster/Area3D` altında, `extraSpeech` sahne kökünde). Bu, mevcut oyunda
  **hiç oynamayan** bir repliğin sessiz hatasıydı.
- `Scripts/scene_intro.gd`: null-label koruması + teleport sonrası bir kare bekleme.
- `Scripts/inspect_item.gd`, `assets/main/main.gd`: null-label korumaları (davranış aynı).

## Bilinen kozmetik kusurlar (bilinçli bırakıldı)

- Odalarda hâlâ **"Two brothers"** ifadesi geçiyor (`room1_2`, `mom_letter1/2`); otelde
  "iki erkek kardeş misafir" okuması yapılabilir ama istenirse "two guests"a çevrilebilir.
- `Happy_1`'de lobide görülen tahta kuş, `storage_bird`'dan önce oynayan rüyada
  anlatılıyor; sıra uyumu orijinalde de yoktu.
- `epi_*` / `garden_*` anahtarları yazılı ama hiçbir yere bağlı değil (G27 bekliyor).

## Genişleme: Backrooms arc'ı (süre ~1 saat+)

Trajedi aynı kalır ama mekân **çok katmanlı bir labirente** açılır. Ağabeyin "seyahatteyim"
yalanının ardındaki gerçek: hastalık değil, **no-clip** — kendini odaların arkasına attı.
Bodrumdaki kilitli kutu ("FOR WHEN YOUR HANDS START SHAKING") aslında bir badem suyu
kutusu ve arkasındaki duvar nefes alıyor. Kutuyu açınca duvar geçit veriyor.

Seviyeler bir geri sayımdır: sarı (Level 0) → beton (Level 1) → metal/boru (Level 2) →
yuvarlak çıkış (Hub). Her katmanda uğultu bir oktav düşer, ışık azalır, varlık yaklaşırlaşır.
Hub'daki misafir defterinin her sayfasında **senin adın** yazılı ve son kayıt yarına —
döngü mekânsallaşır. Çıkışa döndüğünde `backrooms_survived` yanar; ya otelden çıkıp döngüye
(SON C) ya da "daha derin" kapısına (asla açılmaz) bakarsın.

Opsiyonel ama uzun: tüm arc'ı geçmek ~25-35 dk ekler; anahtar/sigorta/valf avı +
varlık sesleri + notlar. Ana bulmaca zincirine dokunmaz — arc tamamen üstüne biner.
