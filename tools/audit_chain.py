#!/usr/bin/env python3
"""Zincir denetimi: kapi -> hedef sahne -> spawn -> bayrak -> anahtar -> dil kaydi.
Hatalari listeler; 'ok' satirlari ozettir."""
import csv, os, re, sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
errors, warns = [], []

NODE_RE = re.compile(r'^\[node name="([^"]+)"(?: type="([^"]+)")?(?: parent="([^"]*)")?\]')
EXT_RE = re.compile(r'^\[ext_resource type="([^"]+)".*?path="([^"]+)" id="([^"]+)"')

def parse_tscn(path):
    """Return (nodes, exts). nodes: list of dict(name,type,parent,props)."""
    nodes, exts, cur = [], {}, None
    rel = os.path.relpath(path, ROOT)
    for lineno, line in enumerate(open(path, encoding="utf-8", errors="replace"), 1):
        m = EXT_RE.match(line)
        if m:
            typ, p, _id = m.groups()
            exts[_id] = (typ, p)
            if not os.path.exists(os.path.join(ROOT, p.replace("res://", ""))):
                errors.append("%s:%d MISSING ext_resource %s" % (rel, lineno, p))
            continue
        m = NODE_RE.match(line)
        if m:
            if cur:
                nodes.append(cur)
            cur = dict(name=m.group(1), type=m.group(2) or "instanced",
                       parent=m.group(3) or "", props={}, path=rel, line=lineno)
            continue
        if cur is not None:
            m = re.match(r'^([A-Za-z0-9_/]+) = (.+)$', line)
            if m:
                cur["props"][m.group(1)] = m.group(2).strip()
            elif line.startswith("[") :
                nodes.append(cur); cur = None
    if cur:
        nodes.append(cur)
    return nodes, exts

scenes = {}
for dirpath, dirnames, filenames in os.walk(ROOT):
    dirnames[:] = [d for d in dirnames if d not in (".godot", ".git", "android", "export")]
    for fn in filenames:
        if fn.endswith(".tscn"):
            p = os.path.join(dirpath, fn)
            scenes[os.path.relpath(p, ROOT)] = parse_tscn(p)

# lang anahtarlari
lang_keys = set()
with open(os.path.join(ROOT, "lang.csv"), encoding="utf-8") as f:
    for row in csv.reader(f):
        if row:
            lang_keys.add(row[0])

# bayrak -> veren item'lar
granters = defaultdict(list)
for rel, (nodes, _e) in scenes.items():
    for n in nodes:
        if "flag_name" in n["props"]:
            fl = n["props"]["flag_name"].strip('"')
            if fl:
                granters[fl].append("%s:%d %s" % (rel, n["line"], n["name"]))

doors = []
for rel, (nodes, _e) in scenes.items():
    for n in nodes:
        if "target_scene" in n["props"]:
            doors.append((rel, n))

print("scenes=%d doors=%d flags_granted=%d" % (len(scenes), len(doors), len(granters)))

for rel, n in doors:
    q = lambda k: n["props"].get(k, "").strip('"')
    tgt, spawn = q("target_scene"), q("spawn_name")
    tag = "%s:%d %s" % (rel, n["line"], n["name"])
    trel = tgt.replace("res://", "")
    if not os.path.exists(os.path.join(ROOT, trel)):
        errors.append("%s MISSING target_scene %s" % (tag, tgt)); continue
    if trel not in scenes:
        errors.append("%s target %s not parsed as scene" % (tag, trel)); continue
    tnodes = scenes[trel][0]
    spawn_names = [x["name"] for x in tnodes if x["parent"].endswith("SpawnPoints") or x["parent"] == "SpawnPoints"]
    if spawn and spawn not in spawn_names:
        errors.append("%s target %s has NO spawn '%s' (have: %s)" % (tag, trel, spawn, spawn_names))
    for fl in [f.strip() for f in q("required_flags").split(",") if f.strip()]:
        if fl == "__never__":
            continue
        if fl not in granters:
            errors.append("%s required_flag '%s' granted by NOTHING" % (tag, fl))
        else:
            warns.append("%s needs '%s' <- %s" % (tag, fl, granters[fl]))
    nk = q("need_key")
    if nk and nk not in lang_keys:
        errors.append("%s need_key speech '%s' not in lang.csv" % (tag, nk))

# item: speech_key + requires_flag gecerliligi
for rel, (nodes, _e) in scenes.items():
    for n in nodes:
        sk = n["props"].get("speech_key", "").strip('"')
        rf = n["props"].get("requires_flag", "").strip('"')
        if sk and sk not in lang_keys:
            errors.append("%s:%d %s speech_key '%s' not in lang.csv" % (rel, n["line"], n["name"], sk))

# Bayrak adlarinin GameState'te BILDIRILMIS olmasi sart. Bildirilmemis bir ad
# yuzden set() sessizce basarisiz olur, get() null doner ve bool(null) o
# etkilesimi tamamiyla kirar -- hub_note_2_seen'de gercekten boyle oldu.
with open(os.path.join(ROOT, "Scripts/GameState.gd"), encoding="utf-8", errors="replace") as f:
    declared = set(re.findall(r"^var ([A-Za-z0-9_]+)", f.read(), re.M))
print("gamestate_flags=%d" % len(declared))
FLAG_PROPS = ("flag_name", "requires_flag", "second_flag", "reward_flag", "counter_name")
for rel, (nodes, _e) in scenes.items():
    for n in nodes:
        p = n["props"]
        for prop in FLAG_PROPS:
            v = p.get(prop, "").strip('"')
            if v and v not in declared:
                errors.append("%s:%d %s %s -> GameState'te bildirilmemis bayrak '%s'"
                              % (rel, n["line"], n["name"], prop, v))
        for fl in [x.strip() for x in p.get("required_flags", "").strip('"').split(",") if x.strip()]:
            if fl != "__never__" and fl not in declared:
                errors.append("%s:%d %s required_flags -> bildirilmemis bayrak '%s'"
                              % (rel, n["line"], n["name"], fl))

# entity instancelar ve script referanslari
for rel, (nodes, exts) in scenes.items():
    for n in nodes:
        s = n["props"].get("script", "")
        m = re.match(r'ExtResource\("([^"]+)"\)', s)
        if m and m.group(1) in exts and exts[m.group(1)][0] == "Script":
            p = os.path.join(ROOT, exts[m.group(1)][1].replace("res://", ""))
            if not os.path.isfile(p):
                errors.append("%s missing script %s" % (rel, exts[m.group(1)][1]))

print("\n== ERRORS (%d) ==" % len(errors))
for e in errors: print(" !", e)
print("\n== FLAG DEPENDENCY MAP (%d) ==" % len(warns))
for w in warns: print(" -", w)
