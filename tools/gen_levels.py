#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Backrooms seviye (.tscn) ureteci.
Grid tabanli: her acilhucre 4m kare; duvarlar boundary kenarlarindan otomatik
uretilir, komsu acik kenarlar birlestirilerek (run) az dugumla cakilir.
Kapi/ogge/isik/spawn/ses hucre koordinatiyla verilir.
"""
import math, os

S = 4.0          # hucre boyutu (m)
H = 2.9          # tavan yuksekligi
T = 0.3          # duvar kalinligi
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "Backrooms")

# --- ortak referanslar ---
PLAYER = "res://assets/player/player.tscn"
PLAYER_UID = "uid://b77cofg7wjxcx"
HOVER = "res://globalTools/Hover.png"
HOVER_UID = "uid://dndvuuny5l3uo"
SCR_DOOR = "res://Scripts/DOORS/generic_door.gd"
SCR_INSPECT = "res://Scripts/inspect_item.gd"
SCR_INTRO = "res://Scripts/scene_intro.gd"
SCR_AMB = "res://Scripts/backrooms_amb.gd"

def cell_world(cx, cz, W, Hh):
    return ((cx - (W - 1) / 2.0) * S, (cz - (Hh - 1) / 2.0) * S)

def is_open(grid, cx, cz):
    if cz < 0 or cz >= len(grid) or cx < 0 or cx >= len(grid[0]):
        return False
    return grid[cz][cx] != '#'


def basis(rx=0.0, ry=0.0):
    """Godot Transform3D basis satirlari (row-major) icin donusum matrisi: R = Ry*Rx."""
    cx, sx = math.cos(rx), math.sin(rx)
    cy, sy = math.cos(ry), math.sin(ry)
    # Rx
    RX = [[1, 0, 0], [0, cx, -sx], [0, sx, cx]]
    # Ry
    RY = [[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]]
    M = [[sum(RY[i][k] * RX[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
    # tscn sirasi: x.x,y.x,z.x, x.y,y.y,z.y, x.z,y.z,z.z  (M satirlari basis vektorleri X,Y,Z)
    return "%g, %g, %g, %g, %g, %g, %g, %g, %g" % (
        M[0][0], M[1][0], M[2][0], M[0][1], M[1][1], M[2][1], M[0][2], M[1][2], M[2][2])


def tr(rx=0.0, ry=0.0, x=0.0, y=0.0, z=0.0):
    return "Transform3D(%s, %g, %g, %g)" % (basis(rx, ry), x, y, z)

class Builder:
    def __init__(self):
        self.ext = {}   # path -> id
        self.ext_order = []
    def x(self, path, rtype, uid=None):
        if path not in self.ext:
            self.ext[path] = ('e%d' % len(self.ext_order), rtype, uid)
            self.ext_order.append(path)
        return self.ext[path][0]

def emit_level(name, spec):
    grid = spec["grid"]
    Hh = len(grid); W = len(grid[0])
    b = Builder()
    subs = []      # (id, text)
    nodes = []     # text blocks
    def sub(rid, text):
        subs.append((rid, text)); return rid

    # palet
    pal = spec["pal"]
    wall_tex = b.x(pal["wall"], "Resource")
    floor_tex = b.x(pal["floor"], "Resource")
    ceil_tex = b.x(pal["ceil"], "Resource")
    panel_tex = b.x("res://assets/backrooms/textures/LightPanel.res", "Resource")

    env_id = sub("Env", "\n".join([
        '[sub_resource type="Environment" id="Env"]',
        "background_mode = 1",
        "background_color = Color(%s)" % pal["bg"],
        "ambient_light_source = 2",
        "ambient_light_color = Color(%s)" % pal["ambc"],
        "ambient_light_energy = %s" % pal["ambe"],
        "tonemap_mode = 2",
        "fog_enabled = true",
        "fog_light_energy = %s" % pal["fog_e"],
        "fog_density = %s" % pal["fog_d"],
        "fog_albedo_color = Color(%s)" % pal["fog_c"],
        "glow_enabled = true",
        "glow_intensity = 0.6",
        "glow_bloom = 0.15",
        "glow_strength = 0.7",
    ]))

    # fiziksel UV: her doku karesi sabit metrekare kaplar (germe/bulaniklik yok)
    TEX_WALL_M = pal.get("tex_wall", 0.55)
    TEX_FLOOR_M = pal.get("tex_floor", 0.7)
    TEX_CEIL_M = pal.get("tex_ceil", 2.4)
    def uvw(meters, tex_m):
        return round(meters / tex_m, 2)

    def mat(mid, tex, scale, col="1, 1, 1, 1", emis=None):
        lines = ['[sub_resource type="StandardMaterial3D" id="%s"]' % mid,
                 'albedo_texture = ExtResource("%s")' % tex,
                 "texture_repeat = 1", "roughness = 0.95",
                 "uv1_scale = Vector3(%s)" % scale]
        if col != "1, 1, 1, 1":
            lines.insert(2, "albedo_color = Color(%s)" % col)
        if emis:
            lines += ["emission_enabled = true",
                      "emission = Color(%s)" % emis[0],
                      "emission_energy_multiplier = %s" % emis[1]]
        return sub(mid, "\n".join(lines))

    mat_wall = mat("Mat_wall", wall_tex, "%g, %g, %g" % (uvw(S, TEX_WALL_M), uvw(H, TEX_WALL_M), uvw(S, TEX_WALL_M)), pal.get("wall_tint", "1, 1, 1, 1"))
    mat_floor = mat("Mat_floor", floor_tex, "%g, 1, %g" % (uvw(W * S, TEX_FLOOR_M), uvw(Hh * S, TEX_FLOOR_M)))
    mat_ceil = mat("Mat_ceil", ceil_tex, "%g, 1, %g" % (uvw(W * S, TEX_CEIL_M), uvw(Hh * S, TEX_CEIL_M)))
    mat_panel = sub("Mat_panel", "\n".join([
        '[sub_resource type="StandardMaterial3D" id="Mat_panel"]',
        'albedo_texture = ExtResource("%s")' % panel_tex,
        "emission_enabled = true",
        "emission = Color(1, 0.985, 0.9, 1)",
        "emission_energy_multiplier = 2.2"]))
    mat_door = sub("Mat_door", "\n".join([
        '[sub_resource type="StandardMaterial3D" id="Mat_door"]',
        "albedo_color = Color(%s)" % pal["door_c"], "roughness = 0.8"]))

    # item malzemeleri (tiklenebilir nesneler icin farkli renkler)
    item_cols = {"key": "0.95, 0.8, 0.15, 1", "fuse": "0.85, 0.2, 0.2, 1",
                 "valve": "0.2, 0.75, 0.8, 1", "box": "0.5, 0.35, 0.2, 1",
                 "note": "0.9, 0.9, 0.85, 1", "water": "0.4, 0.7, 0.95, 1"}
    item_mats = {}
    for k, c in item_cols.items():
        item_mats[k] = sub("Mat_item_%s" % k, "\n".join([
            '[sub_resource type="StandardMaterial3D" id="Mat_item_%s"]' % k,
            "albedo_color = Color(%s)" % c, "roughness = 0.6",
            "metallic = 0.3", "emission_enabled = true",
            "emission = Color(%s)" % c,
            "emission_energy_multiplier = %s" % (1.4 if k == "key" else 0.35)]))

    # paylasim mesh/shape
    def boxmesh(mid, sx, sy, sz):
        return sub(mid, "\n".join(['[sub_resource type="BoxMesh" id="%s"]' % mid,
                                   "size = Vector3(%g, %g, %g)" % (sx, sy, sz)]))
    def boxshape(sid, sx, sy, sz):
        return sub(sid, "\n".join(['[sub_resource type="BoxShape3D" id="%s"]' % sid,
                                   "size = Vector3(%g, %g, %g)" % (sx, sy, sz)]))
    m_panel = boxmesh("Mesh_panel", 1.2, 0.06, 0.6)
    m_item = boxmesh("Mesh_item", 0.4, 0.4, 0.4); s_item = boxshape("Col_item", 0.5, 0.5, 0.5)
    m_door = boxmesh("Mesh_door", 3.8, 2.6, 0.35); s_door = boxshape("Col_door", 3.8, 2.6, 0.35)
    m_slab = boxmesh("Mesh_slab", W * S + T, 0.2, Hh * S + T)
    s_slab = boxshape("Col_slab", W * S + T, 0.2, Hh * S + T)

    # --- duvar runlari ---
    suppress = set()
    for d in spec.get("doors", []):
        suppress.add((d["cx"], d["cz"], d["dir"]))
    wall_runs = []  # (orient, fixed_world, center_world, L)
    for orient in ("N", "S", "E", "W"):
        # her satir/sutun icin acik hucre kenarlarini topla
        runs = {}
        for cz in range(Hh):
            for cx in range(W):
                if not is_open(grid, cx, cz):
                    continue
                nx = cx + {"E": 1, "W": -1}.get(orient, 0)
                nz = cz + {"S": 1, "N": -1}.get(orient, 0)
                blocked = not is_open(grid, nx, nz)
                if not blocked:
                    continue
                if (cx, cz, orient) in suppress:
                    continue
                if orient in ("N", "S"):
                    runs.setdefault(cz, []).append(cx)
                else:
                    runs.setdefault(cx, []).append(cz)
        for fixed, cells in runs.items():
            cells.sort()
            i = 0
            while i < len(cells):
                j = i
                while j + 1 < len(cells) and cells[j + 1] == cells[j] + 1:
                    j += 1
                L = cells[j] - cells[i] + 1
                wall_runs.append((orient, fixed, (cells[i] + cells[j]) / 2.0, L))
                i = j + 1

    wall_mats = {}
    wall_geo = {}
    for (orient, fixed, mid_cell, L) in wall_runs:
        if orient in ("N", "S"):
            key = ("z", L)
        else:
            key = ("x", L)
        if key not in wall_geo:
            length = L * S
            if orient in ("N", "S"):
                wm = boxmesh("Mesh_wz%d" % L, length, H, T); ws = boxshape("Col_wz%d" % L, length, H, T)
            else:
                wm = boxmesh("Mesh_wx%d" % L, T, H, length); ws = boxshape("Col_wx%d" % L, T, H, length)
            wmat = sub("Mat_wall_%s%d" % (key[0], L), "\n".join([
                '[sub_resource type="StandardMaterial3D" id="Mat_wall_%s%d"]' % (key[0], L),
                'albedo_color = Color(%s)' % pal.get("wall_tint", "1, 1, 1, 1"),
                'albedo_texture = ExtResource("%s")' % wall_tex,
                "texture_repeat = 1", "roughness = 0.95",
                "uv1_scale = Vector3(%g, %g, %g)" % (uvw(L * S, TEX_WALL_M), uvw(H, TEX_WALL_M), uvw(L * S, TEX_WALL_M))]))
            wall_geo[key] = (wm, ws, wmat)
    wn = 0
    for (orient, fixed, mid_cell, L) in wall_runs:
        wm, ws, wmat = wall_geo[("z", L) if orient in ("N", "S") else ("x", L)]
        if orient == "N":
            ox, oz = (mid_cell - (W - 1) / 2.0) * S, (fixed - (Hh - 1) / 2.0) * S - S / 2.0
        elif orient == "S":
            ox, oz = (mid_cell - (W - 1) / 2.0) * S, (fixed - (Hh - 1) / 2.0) * S + S / 2.0
        elif orient == "W":
            ox, oz = (fixed - (W - 1) / 2.0) * S - S / 2.0, (mid_cell - (Hh - 1) / 2.0) * S
        else:
            ox, oz = (fixed - (W - 1) / 2.0) * S + S / 2.0, (mid_cell - (Hh - 1) / 2.0) * S
        wn += 1
        nodes.append("\n".join([
            '[node name="wall%d" type="StaticBody3D" parent="."]' % wn,
            "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %g, %g, %g)" % (ox, H / 2.0, oz),
            '[node name="CollisionShape3D" type="CollisionShape3D" parent="wall%d"]' % wn,
            'shape = SubResource("%s")' % ws,
            '[node name="MeshInstance3D" type="MeshInstance3D" parent="wall%d"]' % wn,
            'mesh = SubResource("%s")' % wm,
            'surface_material_override/0 = SubResource("%s")' % wmat]))

    # --- zemin + tavan ---
    nodes.append("\n".join([
        '[node name="floor" type="StaticBody3D" parent="."]',
        "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.1, 0)",
        '[node name="CollisionShape3D" type="CollisionShape3D" parent="floor"]',
        'shape = SubResource("%s")' % s_slab,
        '[node name="MeshInstance3D" type="MeshInstance3D" parent="floor"]',
        'mesh = SubResource("%s")' % m_slab,
        'surface_material_override/0 = SubResource("%s")' % mat_floor]))
    nodes.append("\n".join([
        '[node name="ceiling" type="StaticBody3D" parent="."]',
        "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, %g, 0)" % (H + 0.1),
        '[node name="CollisionShape3D" type="CollisionShape3D" parent="ceiling"]',
        'shape = SubResource("%s")' % s_slab,
        '[node name="MeshInstance3D" type="MeshInstance3D" parent="ceiling"]',
        'mesh = SubResource("%s")' % m_slab,
        'surface_material_override/0 = SubResource("%s")' % mat_ceil]))

    # --- isiklar ---
    flicker_target = None
    for i, lc in enumerate(spec.get("lights", [])):
        x, z = cell_world(lc["cx"], lc["cz"], W, Hh)
        nid = "lamp%d" % i
        if lc.get("flicker"):
            flicker_target = "%s/OmniLight3D" % nid
        nodes.append("\n".join([
            '[node name="%s" type="Node3D" parent="."]' % nid,
            "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %g, %g, %g)" % (x, H - 0.05, z),
            '[node name="MeshInstance3D" type="MeshInstance3D" parent="%s"]' % nid,
            'mesh = SubResource("%s")' % m_panel,
            'surface_material_override/0 = SubResource("%s")' % mat_panel,
            '[node name="OmniLight3D" type="OmniLight3D" parent="%s"]' % nid,
            "light_color = Color(%s)" % pal["light_c"],
            "light_energy = %s" % lc.get("e", pal["light_e"]),
            "omni_range = %s" % lc.get("range", pal["light_range"])]))

    # --- yogun tavan paneli izgarasi (klasik Backrooms esit isik) ---
    # Her acik hucrede (atlamali) emissive panel; isik kaynagi degil, parlak yuzey.
    # OmniLight3D'ler yalnizca spec.lights altinda; gerisi glow + ambient tasiyor.
    for cz in range(Hh):
        for cx in range(W):
            if not is_open(grid, cx, cz):
                continue
            if (cx + cz) % 2 == 1:
                continue
            x, z = cell_world(cx, cz, W, Hh)
            nodes.append("\n".join([
                '[node name="panel_%d_%d" type="MeshInstance3D" parent="."]' % (cx, cz),
                "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %g, %g, %g)" % (x, H - 0.06, z),
                'mesh = SubResource("%s")' % m_panel,
                'surface_material_override/0 = SubResource("%s")' % mat_panel]))

    # --- ses vericileri ---
    for a in spec.get("audio", []):
        sid = b.x(a["stream"], "Resource")
        x, z = cell_world(a["cx"], a["cz"], W, Hh)
        nodes.append("\n".join([
            '[node name="%s" type="AudioStreamPlayer3D" parent="."]' % a["name"],
            "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %g, %g, %g)" % (x, a.get("y", 1.6), z),
            'stream = ExtResource("%s")' % sid,
            "volume_db = %s" % a.get("vol", 0.0),
            "autoplay = %s" % ("true" if a.get("autoplay", True) else "false"),
            "max_distance = %s" % a.get("maxd", 14.0)]))

    # --- prop modeller (obj -> .res mesh) ---
    prop_mat_cache = {}
    def prop_mat(texpath):
        base = texpath.split("/")[-1].split(".")[0]
        mid = "MatP_" + base
        if mid not in prop_mat_cache:
            eid = b.x(texpath, "Resource")
            prop_mat_cache[mid] = sub(mid, "\n".join([
                '[sub_resource type="StandardMaterial3D" id="%s"]' % mid,
                'albedo_texture = ExtResource("%s")' % eid,
                "roughness = 0.85"]))
        return prop_mat_cache[mid]
    plane_id = None
    for i, p in enumerate(spec.get("props", [])):
        mesh_id = b.x(p["mesh"], "Resource")
        pmid = prop_mat(p["tex"])
        x, z = cell_world(p["cx"], p["cz"], W, Hh)
        y = p.get("y", 0.0)
        sc = p.get("scale", 1.0)
        tf = tr(rx=p.get("rx", 0.0), ry=p.get("ry", 0.0), x=x, y=y, z=z)
        if p.get("col"):
            csx, csy, csz = p["col"]
            sid = sub("Col_prop%d" % i, "\n".join([
                '[sub_resource type="BoxShape3D" id="Col_prop%d"]' % i,
                "size = Vector3(%g, %g, %g)" % (csx * sc, csy * sc, csz * sc)]))
            nodes.append("\n".join([
                '[node name="%s" type="StaticBody3D" parent="."]' % p["name"],
                tf,
                '[node name="CollisionShape3D" type="CollisionShape3D" parent="%s"]' % p["name"],
                'shape = SubResource("%s")' % sid,
                '[node name="Mesh" type="MeshInstance3D" parent="%s"]' % p["name"],
                "transform = Transform3D(%g, 0, 0, 0, %g, 0, 0, 0, %g, 0, 0, 0)" % (sc, sc, sc),
                'mesh = ExtResource("%s")' % mesh_id,
                'surface_material_override/0 = SubResource("%s")' % pmid]))
        else:
            nodes.append("\n".join([
                '[node name="%s" type="MeshInstance3D" parent="."]' % p["name"],
                tf,
                "scale = Vector3(%g, %g, %g)" % (sc, sc, sc),
                'mesh = ExtResource("%s")' % mesh_id,
                'surface_material_override/0 = SubResource("%s")' % pmid]))

    # --- decal (kan/kagit) duvar karolar ---
    decal_mat_cache = {}
    def decal_mat(texpath):
        base = texpath.split("/")[-1].split(".")[0]
        mid = "MatD_" + base
        if mid not in decal_mat_cache:
            eid = b.x(texpath, "Resource")
            decal_mat_cache[mid] = sub(mid, "\n".join([
                '[sub_resource type="StandardMaterial3D" id="%s"]' % mid,
                'albedo_texture = ExtResource("%s")' % eid,
                "transparency = 1", "cull_mode = 0",
                "shading_mode = 0", "vertex_color_use_as_albedo = false",
                "polygon_offset_enabled = true"]))
        return decal_mat_cache[mid]
    plane_mesh = sub("Mesh_plane", "\n".join([
        '[sub_resource type="PlaneMesh" id="Mesh_plane"]', "size = Vector2(1, 1)"]))
    for dc in spec.get("decals", []):
        dmid = decal_mat(dc["tex"])
        x, z = cell_world(dc["cx"], dc["cz"], W, Hh)
        w, h = dc.get("w", 1.2), dc.get("h", 1.2)
        y = dc.get("y", 1.4)
        dirv = {"N": (0, -1), "S": (0, 1), "E": (1, 0), "W": (-1, 0)}[dc["dir"]]
        # hucre kenari + iceri 3cm ofset; duvara bakacak sekilde donus
        ox, oz = x + dirv[0] * S / 2.0, z + dirv[1] * S / 2.0
        ox -= dirv[0] * 0.02; oz -= dirv[1] * 0.02
        ry = {"N": 0.0, "S": math.pi, "E": -math.pi / 2.0, "W": math.pi / 2.0}[dc["dir"]]
        nodes.append("\n".join([
            '[node name="%s" type="MeshInstance3D" parent="."]' % dc["name"],
            tr(ry=ry, x=ox, y=y, z=oz),
            "scale = Vector3(%g, %g, 1)" % (w, h),
            'mesh = SubResource("%s")' % plane_mesh,
            'surface_material_override/0 = SubResource("%s")' % dmid]))

    # --- varlik (stalker) instance'lari ---
    for i, en in enumerate(spec.get("entities", [])):
        eid = b.x(ENTITY, "PackedScene")
        x, z = cell_world(en["cx"], en["cz"], W, Hh)
        nodes.append("\n".join([
            '[node name="%s" parent="." instance=ExtResource("%s")]' % (en.get("name", "entity%d" % i), eid),
            "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %g, 0.0, %g)" % (x, z)]))

    # --- tiklenebilir nesneler ---
    for it in spec.get("items", []):
        iid = b.x(SCR_INSPECT, "Script")
        hid = b.x(HOVER, "Texture2D", HOVER_UID)
        x, z = cell_world(it["cx"], it["cz"], W, Hh)
        y = it.get("y", 0.5)
        nodes.append("\n".join([
            '[node name="%s" type="StaticBody3D" parent="."]' % it["name"],
            "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %g, %g, %g)" % (x, y, z),
            'script = ExtResource("%s")' % iid,
            'flag_name = "%s"' % it["flag"],
            'speech_key = "%s"' % it["key"],
            ('destroy_on_pick = true' if it.get("pick") else 'destroy_on_pick = false'),
            ('requires_flag = "%s"' % it["req"]) if it.get("req") else 'requires_flag = ""',
            ('add_sanity = %d' % it["add_sanity"]) if it.get("add_sanity") else 'add_sanity = 0',
            '[node name="CollisionShape3D" type="CollisionShape3D" parent="%s"]' % it["name"],
            'shape = SubResource("%s")' % s_item,
            '[node name="MeshInstance3D" type="MeshInstance3D" parent="%s"]' % it["name"],
            'mesh = SubResource("%s")' % m_item,
            'surface_material_override/0 = SubResource("%s")' % item_mats[it.get("kind", "box")],
            '[node name="play1" type="CanvasLayer" parent="%s"]' % it["name"],
            "layer = 3",
            '[node name="hover" type="Sprite2D" parent="%s/play1"]' % it["name"],
            "visible = false", "position = Vector2(947, 494)",
            "scale = Vector2(0.06, 0.06)", 'texture = ExtResource("%s")' % hid]))

    # --- kapi lar ---
    for d in spec.get("doors", []):
        did = b.x(SCR_DOOR, "Script")
        hid = b.x(HOVER, "Texture2D", HOVER_UID)
        cx, cz = d["cx"], d["cz"]
        dx = {"E": 1, "W": -1}.get(d["dir"], 0); dz = {"S": 1, "N": -1}.get(d["dir"], 0)
        bx, bz = cell_world(cx, cz, W, Hh)
        ox, oz = (bx + dx * S / 2.0), (bz + dz * S / 2.0)
        if d["dir"] in ("E", "W"):
            basis = "0, 0, 1, 0, 1, 0, -1, 0, 0"
        else:
            basis = "1, 0, 0, 0, 1, 0, 0, 0, 1"
        lines = ['[node name="%s" type="StaticBody3D" parent="."]' % d["name"],
                 "transform = Transform3D(%s, %g, %g, %g)" % (basis, ox, 1.3, oz),
                 'script = ExtResource("%s")' % did,
                 'target_scene = "%s"' % d["target"],
                 'spawn_name = "%s"' % d["spawn"]]
        if d.get("flags"):
            lines.append('required_flags = "%s"' % d["flags"])
        if d.get("need_key"):
            lines.append('need_key = "%s"' % d["need_key"])
        lines += [
            '[node name="CollisionShape3D" type="CollisionShape3D" parent="%s"]' % d["name"],
            'shape = SubResource("%s")' % s_door,
            '[node name="MeshInstance3D" type="MeshInstance3D" parent="%s"]' % d["name"],
            'mesh = SubResource("%s")' % m_door,
            'surface_material_override/0 = SubResource("%s")' % mat_door,
            '[node name="play1" type="CanvasLayer" parent="%s"]' % d["name"],
            "layer = 3",
            '[node name="hover" type="Sprite2D" parent="%s/play1"]' % d["name"],
            "visible = false", "position = Vector2(947, 494)",
            "scale = Vector2(0.06, 0.06)", 'texture = ExtResource("%s")' % hid]
        nodes.append("\n".join(lines))

    # --- spawn + player ---
    sp_id = b.x(PLAYER, "PackedScene", PLAYER_UID)
    spawn = spec["spawn"]
    sx, sz = cell_world(spawn["cx"], spawn["cz"], W, Hh)

    def spawn_yaw(cx, cz):
        for d, ry in (("N", 0.0), ("E", math.pi / 2), ("S", math.pi), ("W", -math.pi / 2)):
            nx, nz = {"N": (cx, cz - 1), "E": (cx + 1, cz), "S": (cx, cz + 1), "W": (cx - 1, cz)}[d]
            if is_open(grid, nx, nz):
                return ry
        return 0.0

    nodes.append('[node name="SpawnPoints" type="Node3D" parent="."]')
    for sm in spec.get("spawns", []):
        mx, mz = cell_world(sm["cx"], sm["cz"], W, Hh)
        nodes.append("\n".join([
            '[node name="%s" type="Marker3D" parent="SpawnPoints"]' % sm["name"],
            "transform = " + tr(0, spawn_yaw(sm["cx"], sm["cz"]), mx, 0.3, mz)]))
    nodes.append("\n".join([
        '[node name="Player" parent="." instance=ExtResource("%s")]' % sp_id,
        "transform = " + tr(0, spawn_yaw(spawn["cx"], spawn["cz"]), sx, 0.3, sz)]))

    # --- extraSpeech + intro ---
    nodes.append('\n[node name="extraSpeech" type="CanvasLayer" parent="."]\nlayer = 2')
    nodes.append("\n".join([
        '[node name="line" type="Label" parent="extraSpeech"]',
        "modulate = Color(1, 1, 1, 0)",
        "offset_left = 454.0", "offset_top = 786.0",
        "offset_right = 1454.0", "offset_bottom = 900.0",
        "theme_override_font_sizes/font_size = 20",
        "horizontal_alignment = 1", "vertical_alignment = 1", "autowrap_mode = 3"]))
    if spec.get("intro"):
        iid = b.x(SCR_INTRO, "Script")
        nodes.append("\n".join([
            '[node name="intro" type="Node" parent="."]',
            'script = ExtResource("%s")' % iid,
            'played_flag = "%s"' % spec["intro"]["flag"],
            'speech_key = "%s"' % spec["intro"]["key"]]))

    # --- amb script ---
    if spec.get("amb"):
        aid = b.x(SCR_AMB, "Script")
        cfg = spec["amb"]
        lines = ['[node name="amb" type="Node3D" parent="."]',
                 'script = ExtResource("%s")' % aid]
        if flicker_target:
            lines.append('flicker_light = NodePath("../%s")' % flicker_target)
        if cfg.get("whisper"):
            lines.append('whisper_player = NodePath("../%s")' % cfg["whisper"])
        if cfg.get("growl"):
            lines.append('growl_player = NodePath("../%s")' % cfg["growl"])
        if cfg.get("sfx"):
            lines.append('sfx_player = NodePath("../%s")' % cfg["sfx"])
        if cfg.get("surface"):
            lines.append('surface = "%s"' % cfg["surface"])
        if cfg.get("drain"):
            lines.append('drain_sanity = true')
            lines.append('sanity_rate = %s' % cfg.get("rate", 0.6))
        nodes.append("\n".join(lines))

    # WorldEnvironment node
    nodes.insert(0, "\n".join([
        '[node name="%s" type="Node3D" parent="."]' % name if False else "",
        ]).lstrip("\n"))
    header_root = '[node name="%s" type="Node3D"]' % name
    we = '[node name="WorldEnvironment" type="WorldEnvironment" parent="."]\nenvironment = SubResource("%s")' % env_id
    body = header_root + "\n\n" + we + "\n" + "\n".join("\n" + n for n in nodes)

    # ext_resource satirlari
    extlines = []
    for path in b.ext_order:
        eid, rtype, uid = b.ext[path]
        u = (' uid="%s"' % uid) if uid else ""
        extlines.append('[ext_resource type="%s"%s path="%s" id="%s"]' % (rtype, u, path, eid))

    load_steps = 1 + len(b.ext_order) + len(subs)
    head = "[gd_scene load_steps=%d format=4]\n\n" % load_steps
    out = head + "\n".join(extlines) + "\n\n" + "\n\n".join(t for _, t in subs) + "\n\n" + body + "\n"
    os.makedirs(OUT, exist_ok=True)
    fp = os.path.join(OUT, name + ".tscn")
    with open(fp, "w") as f:
        f.write(out)
    print("WROTE %s  nodes=%d walls=%d steps=%d" % (name, len(nodes), wn, load_steps))


def bfs_ok(spec):
    """spawn'dan her item/door hucreye (kapi acilir sayilir) erisim kontrolu."""
    grid = spec["grid"]; Hh = len(grid); W = len(grid[0])
    start = (spec["spawn"]["cx"], spec["spawn"]["cz"])
    doors = {(d["cx"], d["cz"]) for d in spec.get("doors", [])}
    seen = {start}; q = [start]
    while q:
        cx, cz = q.pop(0)
        for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, nz = cx + dx, cz + dz
            if (nx, nz) in seen:
                continue
            if not is_open(grid, nx, nz) and (nx, nz) not in doors:
                # kapinin diger tarafi: komsu acik hucreden gecis
                pass
            if not is_open(grid, nx, nz):
                continue
            seen.add((nx, nz)); q.append((nx, nz))
    bad = []
    for it in spec.get("items", []):
        if (it["cx"], it["cz"]) not in seen:
            bad.append("item " + it["name"])
    for d in spec.get("doors", []):
        nb = (d["cx"] + {"E": 1, "W": -1}.get(d["dir"], 0),
              d["cz"] + {"S": 1, "N": -1}.get(d["dir"], 0))
        if (d["cx"], d["cz"]) not in seen:
            bad.append("door@ " + d["name"])
        elif is_open(grid, nb[0], nb[1]) and nb not in seen:
            bad.append("door-> " + d["name"])
    return bad


# ---------- paletler ----------
P0 = dict(wall="res://assets/backrooms/textures/Wallpaper2.res",
          floor="res://assets/backrooms/textures/Floor_carpet_clean_BaseColor.res",
          ceil="res://assets/backrooms/textures/CeilingTiles.res",
          wall_scale="3,2,3", floor_scale="5,1,5", ceil_scale="6,1,6",
          bg="0.12, 0.11, 0.07, 1", ambc="0.85, 0.72, 0.36, 1", ambe=1.0,
          fog_e=0.4, fog_d=0.006, fog_c="0.85, 0.78, 0.5, 1",
          light_c="1, 0.97, 0.85, 1", light_e=0.45, light_range=13.0,
          wall_tint="1, 0.9, 0.55, 1",
          door_c="0.55, 0.3, 0.16, 1")
P1 = dict(wall="res://assets/backrooms/textures/esp_concrete_black.res",
          floor="res://assets/backrooms/textures/esp_concrete_floor.res",
          ceil="res://assets/backrooms/textures/CeilingTiles.res",
          wall_scale="2,1.5,2", floor_scale="4,1,4", ceil_scale="6,1,6",
          bg="0.03, 0.035, 0.05, 1", ambc="0.5, 0.55, 0.68, 1", ambe=0.6,
          fog_e=0.3, fog_d=0.012, fog_c="0.5, 0.55, 0.6, 1",
          light_c="0.85, 0.88, 1, 1", light_e=0.5, light_range=12.0,
          wall_tint="0.7, 0.75, 0.9, 1",
          door_c="0.3, 0.32, 0.38, 1")
P2 = dict(wall="res://assets/backrooms/textures/Metal_albedo.res",
          floor="res://assets/backrooms/textures/Metal_albedo.res",
          ceil="res://assets/backrooms/textures/Vents.res",
          wall_scale="2,2,2", floor_scale="3,1,3", ceil_scale="4,1,4",
          bg="0.02, 0.04, 0.05, 1", ambc="0.35, 0.6, 0.68, 1", ambe=0.55,
          fog_e=0.25, fog_d=0.014, fog_c="0.4, 0.6, 0.65, 1",
          light_c="0.6, 0.92, 1, 1", light_e=0.5, light_range=12.0,
          wall_tint="0.6, 0.85, 0.95, 1",
          door_c="0.45, 0.25, 0.12, 1")
PH = dict(P0); PH["ambc"] = "0.82, 0.7, 0.4, 1"; PH["ambe"] = 1.05
PH["fog_d"] = 0.006; PH["door_c"] = "0.2, 0.6, 0.3, 1"; PH["wall_tint"] = "1, 0.92, 0.6, 1"

A = "res://assets/backrooms/audio/"
MP = "res://assets/backrooms/meshes/"
TP = "res://assets/backrooms/textures/"
BARREL = dict(mesh=MP + "Barrel_LOD0.mesh.res", tex=TP + "Barrel_White_Albedo.res", col=[0.6, 0.86, 0.6], y=0.0)
CRATE = dict(mesh=MP + "BreakableCrate.mesh.res", tex=TP + "Crate_Breakable_Diffuse.res", col=[0.62, 0.4, 0.84], y=0.19)
CHAIR = dict(mesh=MP + "Chair_01_LOD0.mesh.res", tex=TP + "Chair_A.res", col=[0.57, 0.98, 0.55], y=0.0)
BLOOD = TP + "Blood_Decals_A.res"
PAPERS = TP + "Decals_papers_BaseColor.res"

def prop(nm, base, cx, cz, ry=0.0, scale=1.0):
    d = dict(base); d.update(name=nm, cx=cx, cz=cz, ry=ry, scale=scale); return d

BUZZ = A + "537769__janbezouska__factory-fluorescent-light-buzz.ogg.res"
LIGHTS = A + "547799__joelspace__florescent-lights-of-the-backrooms-1.ogg.res"
DANGER = A + "Ambient_Danger.ogg.res"
UNDER = A + "amb_underground_room.ogg.res"
SMILER = A + "smiler_idle_drone.ogg.res"
WHISPER = A + "watcher_static_stare.ogg.res"
BREATH = A + "BreathScared.ogg.res"
GROWL = A + "Mutant_Growl_01.ogg.res"
GROWL2 = A + "Mutant_Growl_02.ogg.res"
SCREAM = A + "Mutant_Scream.ogg.res"
HELP = A + "HELP.ogg.res"
METAL = A + "Metal_Impact.ogg.res"
LAUGH = A + "187736__jasonthedemon__crazy-laugh-echo.ogg.res"
GEN = A + "generator-off.ogg.res"
ENTBUZZ = A + "175210__minigunfiend__creatures-loud-buzz.ogg.res"

L0 = "res://assets/Backrooms/level0.tscn"
L1 = "res://assets/Backrooms/level1.tscn"
L2 = "res://assets/Backrooms/level2.tscn"
LH = "res://assets/Backrooms/hub.tscn"
ATTIC = "res://assets/House/Floor2/attic.tscn"
BASE = "res://assets/House/Floor1/Basement.tscn"
ENTITY = "res://assets/Backrooms/entity.tscn"


def G(rows):
    return [list(r) for r in rows]


LEVEL0 = dict(
    grid=G([
        "###############",
        "#.....#.....#.#",
        "#.###.#.###.#.#",
        "#.#.......#...#",
        "#.#.#####.###.#",
        "#...#...#.....#",
        "###.#.#.#.###.#",
        "#...#.#...#.#.#",
        "#.###.#####.#.#",
        "#.#.......#...#",
        "#.#.#####.#.###",
        "#.#.#...#.#...#",
        "#...#.###.###.#",
        "#.....#.......#",
        "###############"]),
    pal=P0, spawn=dict(cx=1, cz=1),
    spawns=[dict(name="default", cx=1, cz=1), dict(name="from_attic", cx=1, cz=1),
            dict(name="from_level1", cx=13, cz=13)],
    lights=[dict(cx=1, cz=1), dict(cx=7, cz=1), dict(cx=13, cz=1),
            dict(cx=3, cz=5, flicker=True), dict(cx=9, cz=5), dict(cx=13, cz=5),
            dict(cx=1, cz=9), dict(cx=7, cz=9), dict(cx=13, cz=9),
            dict(cx=5, cz=13), dict(cx=11, cz=13, flicker=True)],
    items=[
        dict(name="l0key", cx=13, cz=13, kind="key", flag="level0_key",
             key="level0_key_line", pick=True),
        dict(name="photo", cx=7, cz=13, kind="note", flag="level0_photo_seen",
             key="level0_photo"),
        dict(name="almond", cx=1, cz=13, kind="water", flag="level0_water",
             key="level0_water", pick=True, add_sanity=40),
        dict(name="nest", cx=9, cz=3, kind="box", flag="level0_nest_seen",
             key="level0_nest")],
    doors=[
        dict(name="toHotel", cx=1, cz=1, dir="W", target=BASE, spawn="default",
             need_key=""),
        dict(name="toAttic", cx=1, cz=1, dir="N", target=ATTIC, spawn="from_level0",
             need_key=""),
        dict(name="toL1", cx=13, cz=1, dir="E", target=L1, spawn="from_level0",
             flags="level0_key", need_key="level0_locked")],
    audio=[
        dict(name="buzz", cx=1, cz=1, stream=BUZZ, vol=-6, maxd=12),
        dict(name="ambLights", cx=7, cz=7, stream=LIGHTS, vol=-5, maxd=30),
        dict(name="smiler", cx=9, cz=3, stream=SMILER, vol=-9, maxd=10),
        dict(name="whisper", cx=7, cz=11, stream=WHISPER, vol=-3, maxd=26, autoplay=False),
        dict(name="laugh", cx=13, cz=13, stream=LAUGH, vol=-4, maxd=16, autoplay=False)],
    amb=dict(whisper="whisper", growl="laugh", surface="wood", drain=True, rate=0.35),
    props=[
        prop("bar1", BARREL, 5, 1, ry=0.4),
        prop("crate1", CRATE, 1, 5, ry=0.9),
        prop("chair1", CHAIR, 11, 1, ry=2.0),
        prop("bar2", BARREL, 13, 9, ry=1.1),
        prop("crate2", CRATE, 3, 13, ry=0.2, scale=1.3),
        prop("chair2", CHAIR, 9, 7, ry=3.1),
    ],
    decals=[
        dict(name="blood1", tex=BLOOD, cx=9, cz=3, dir="E", y=1.3, w=1.3, h=1.3),
        dict(name="papers1", tex=PAPERS, cx=1, cz=9, dir="W", y=1.5, w=1.4, h=1.0),
        dict(name="papers2", tex=PAPERS, cx=13, cz=5, dir="E", y=1.4, w=1.2, h=0.9),
    ],
    intro=dict(flag="level0_speech_played", key="level0_1"))

LEVEL1 = dict(
    grid=G([
        "###############",
        "#...#.....#...#",
        "#.#.#.###.#.#.#",
        "#.#...#.#...#.#",
        "#.###.#.#.###.#",
        "#...#.#.#.#...#",
        "###.#.#.#.#.###",
        "#.....#...#...#",
        "#.###.#####.###",
        "#.#.#.......#.#",
        "#.#.#.#####.#.#",
        "#...#.#...#...#",
        "###.#.#.#.###.#",
        "#.....#.....#.#",
        "###############"]),
    pal=P1, spawn=dict(cx=1, cz=1),
    spawns=[dict(name="default", cx=1, cz=1), dict(name="from_level0", cx=1, cz=1),
            dict(name="from_level2", cx=13, cz=13)],
    lights=[dict(cx=1, cz=1), dict(cx=7, cz=3, flicker=True), dict(cx=13, cz=7),
            dict(cx=3, cz=9), dict(cx=9, cz=11, flicker=True), dict(cx=13, cz=13)],
    items=[
        dict(name="fuse1", cx=1, cz=13, kind="fuse", flag="level1_fuse1",
             key="level1_fuse1_line", pick=True),
        dict(name="fuse2", cx=13, cz=1, kind="fuse", flag="level1_fuse2",
             key="level1_fuse2_line", pick=True),
        dict(name="breaker", cx=7, cz=7, kind="note", flag="level1_breaker_seen",
             key="level1_breaker")],
    doors=[
        dict(name="toL0", cx=1, cz=1, dir="W", target=L0, spawn="from_level1",
             need_key=""),
        dict(name="toL2", cx=13, cz=13, dir="E", target=L2, spawn="from_level1",
             flags="level1_fuse1,level1_fuse2", need_key="level1_locked")],
    audio=[
        dict(name="gen", cx=7, cz=7, stream=GEN, vol=-8, maxd=26),
        dict(name="under", cx=1, cz=7, stream=UNDER, vol=-6, maxd=20),
        dict(name="help", cx=13, cz=1, stream=HELP, vol=-2, maxd=22, autoplay=False),
        dict(name="metal", cx=9, cz=9, stream=METAL, vol=-4, maxd=18, autoplay=False),
        dict(name="danger", cx=13, cz=13, stream=DANGER, vol=-10, maxd=14)],
    amb=dict(whisper="help", growl="metal", surface="concrete", drain=True, rate=0.6),
    props=[
        prop("bar1", BARREL, 5, 1, ry=0.3),
        prop("crate1", CRATE, 13, 5, ry=1.2),
        prop("bar2", BARREL, 1, 9, ry=2.2),
        prop("chair1", CHAIR, 9, 13, ry=0.7),
        prop("crate2", CRATE, 5, 13, ry=0.1, scale=1.4),
    ],
    decals=[
        dict(name="blood1", tex=BLOOD, cx=13, cz=13, dir="S", y=1.2, w=1.4, h=1.4),
        dict(name="blood2", tex=BLOOD, cx=1, cz=7, dir="W", y=1.3, w=1.2, h=1.2),
        dict(name="papers1", tex=PAPERS, cx=7, cz=7, dir="N", y=1.5, w=1.3, h=1.0),
    ],
    intro=dict(flag="level1_speech_played", key="level1_1"))

LEVEL2 = dict(
    grid=G([
        "###############",
        "#.#.........#.#",
        "#.#.#######.#.#",
        "#...#.....#...#",
        "###.#.###.#.###",
        "#...#.#.#.#...#",
        "#.###.#.#.###.#",
        "#.#...#.#...#.#",
        "#.#.###.###.#.#",
        "#.#.......#...#",
        "#.#######.###.#",
        "#.......#.....#",
        "#####.#.#####.#",
        "#...#.#.......#",
        "###############"]),
    pal=P2, spawn=dict(cx=1, cz=1),
    spawns=[dict(name="default", cx=1, cz=1), dict(name="from_level1", cx=1, cz=1),
            dict(name="from_hub", cx=13, cz=13)],
    lights=[dict(cx=1, cz=1, e=0.35), dict(cx=7, cz=5, flicker=True, e=0.3),
            dict(cx=13, cz=7, e=0.3), dict(cx=5, cz=11, flicker=True, e=0.3),
            dict(cx=13, cz=13, e=0.4)],
    items=[
        dict(name="valve", cx=13, cz=13, kind="valve", flag="level2_valve",
             key="level2_valve_line", pick=True, req="level2_saw_help"),
        dict(name="cage", cx=7, cz=1, kind="note", flag="level2_saw_help",
             key="level2_help")],
    doors=[
        dict(name="toL1", cx=1, cz=1, dir="W", target=L1, spawn="from_level2",
             need_key=""),
        dict(name="toHub", cx=13, cz=13, dir="E", target=LH, spawn="from_level2",
             flags="level2_valve", need_key="level2_locked")],
    audio=[
        dict(name="ent", cx=7, cz=7, stream=ENTBUZZ, vol=-7, maxd=20),
        dict(name="danger", cx=13, cz=13, stream=DANGER, vol=-8, maxd=16),
        dict(name="growl", cx=7, cz=1, stream=GROWL, vol=-2, maxd=24, autoplay=False),
        dict(name="growl2", cx=11, cz=9, stream=GROWL2, vol=-2, maxd=24, autoplay=False),
        dict(name="scream", cx=13, cz=13, stream=SCREAM, vol=-3, maxd=20, autoplay=False),
        dict(name="metal", cx=3, cz=9, stream=METAL, vol=-5, maxd=16, autoplay=False)],
    amb=dict(whisper="growl", growl="scream", sfx="metal", surface="metal", drain=True, rate=0.95),
    entities=[dict(name="stalker", cx=11, cz=13)],
    props=[
        prop("bar1", BARREL, 13, 1, ry=0.5),
        prop("crate1", CRATE, 1, 13, ry=1.4),
        prop("bar2", BARREL, 11, 5, ry=2.6),
        prop("bar3", BARREL, 3, 9, ry=0.2),
        prop("chair1", CHAIR, 13, 11, ry=1.9),
    ],
    decals=[
        dict(name="blood1", tex=BLOOD, cx=7, cz=1, dir="N", y=1.3, w=1.5, h=1.5),
        dict(name="blood2", tex=BLOOD, cx=13, cz=13, dir="S", y=1.2, w=1.4, h=1.4),
        dict(name="papers1", tex=PAPERS, cx=1, cz=7, dir="W", y=1.4, w=1.2, h=0.9),
    ],
    intro=dict(flag="level2_speech_played", key="level2_1"))

HUB = dict(
    grid=G([
        "###########",
        "#.........#",
        "#.##...##.#",
        "#.#.....#.#",
        "#...###...#",
        "#.#.....#.#",
        "#.##...##.#",
        "#.........#",
        "#.#######.#",
        "#.........#",
        "###########"]),
    pal=PH, spawn=dict(cx=5, cz=5),
    spawns=[dict(name="default", cx=5, cz=5), dict(name="from_level2", cx=5, cz=5)],
    lights=[dict(cx=5, cz=1, e=1.1), dict(cx=1, cz=5), dict(cx=9, cz=5),
            dict(cx=5, cz=5, e=1.3), dict(cx=5, cz=9)],
    items=[dict(name="hubnote", cx=5, cz=3, kind="note", flag="hub_note_seen",
                key="hub_note")],
    doors=[
        dict(name="toHotel", cx=5, cz=1, dir="N", target=BASE, spawn="default",
             need_key=""),
        dict(name="toL2", cx=1, cz=5, dir="W", target=L2, spawn="from_hub",
             need_key=""),
        dict(name="deeper", cx=9, cz=5, dir="E", target=LH, spawn="default",
             flags="__never__", need_key="hub_deeper")],
    audio=[
        dict(name="ambLights", cx=5, cz=5, stream=LIGHTS, vol=-7, maxd=24),
        dict(name="whisper", cx=1, cz=5, stream=WHISPER, vol=-4, maxd=18, autoplay=False)],
    amb=dict(whisper="whisper", surface="wood"),
    entities=[dict(name="hubstalker", cx=5, cz=9)],
    props=[
        prop("chair1", CHAIR, 5, 7, ry=3.14),
        prop("bar1", BARREL, 3, 1, ry=0.6),
    ],
    decals=[
        dict(name="papers1", tex=PAPERS, cx=5, cz=1, dir="N", y=1.5, w=1.4, h=1.0),
    ],
    intro=dict(flag="hub_speech_played", key="hub_1"))


def main():
    specs = [("level0", LEVEL0), ("level1", LEVEL1), ("level2", LEVEL2), ("hub", HUB)]
    fail = False
    for nm, sp in specs:
        bad = bfs_ok(sp)
        if bad:
            print("BFS FAIL %s: %s" % (nm, bad)); fail = True
    if fail:
        print("ERISILEMEZ hucreler var, grid duzelt!")
        return
    for nm, sp in specs:
        emit_level(nm, sp)


if __name__ == "__main__":
    main()
