#!/usr/bin/env python3
"""Bir .tscn icindeki dugumlerin DUNYA koordinatlarini basar.

Otel sahnelerinde kapı/eset dugumleri ic ice ("floor" gibi) tasıycılarda duruyor;
metinden okunan transform yerel oldugu icin spawn denetimiyle karsilastirilamiyor.
probe "hangi gövde engelliyor" adını verir, bu araç o gövdenin nereye denk geldigini.

  python3 tools/scene_nodes.py <scene.tscn> [ad-regex]
"""
import math
import re
import sys

NUM = r'-?[\d.eE+-]+'


def parse(path):
    ext, sub, nodes = {}, {}, []
    cur_id = None
    cur = None
    for line in open(path, encoding='utf-8', errors='replace'):
        line = line.rstrip('\n')
        m = re.match(r'\[ext_resource type="Script" (?:uid="[^"]*" )?'
                     r'path="res://([^"]+)" id="([^"]+)"\]', line)
        if m:
            ext[m.group(2)] = m.group(1)
            continue
        m = re.match(r'\[sub_resource type="([^"]+)" id="([^"]+)"\]', line)
        if m:
            cur_id = m.group(2)
            sub[cur_id] = {'type': m.group(1), 'size': None}
            continue
        m = re.match(r'\[node name="([^"]+)"(?: type="([^"]+)")?(?: parent="([^"]*)")?'
                     r'(?: instance=ExtResource\("([^"]+)"\))?', line)
        if m:
            cur = {'name': m.group(1), 'type': m.group(2) or 'PackedInstance',
                   'parent': m.group(3), 'inst': m.group(4),
                   'tr': (1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 0.0, 0.0),
                   'script': None, 'shape': None, 'props': {}}
            nodes.append(cur)
            continue
        if line.startswith('['):
            cur_id = None
            continue
        if cur_id and re.match(r'(size|extents) = ', line):
            sub[cur_id]['size'] = line.split('= ')[1]
        if cur is None:
            continue
        if line.startswith('transform = Transform3D('):
            cur['tr'] = tuple(float(v) for v in
                              re.findall(NUM, line[len('transform = Transform3D('):]))
        elif line.startswith('script = ExtResource('):
            sid = re.search(r'"([^"]+)"', line).group(1)
            cur['script'] = ext.get(sid, sid)
        elif line.startswith('shape = SubResource('):
            cur['shape'] = re.search(r'"([^"]+)"', line).group(1)
        elif '= ' in line and not line.startswith('\t'):
            k, v = line.split('= ', 1)
            if k.strip() in ('target_scene', 'spawn_name', 'required_flags', 'need_key',
                             'flag', 'key', 'kind'):
                cur['props'][k.strip()] = v.strip().strip('"')
    return nodes, sub


def world(nodes):
    """Dunya transformu: .tscn'de parent='.' ya da 'A/B' koku-yolu tam yoludur,
    dugum adlari tekil degil (scan modelinde yiginla 'CollisionShape3D' var),
    bu yuzden atalar adla degil tam yolla cozulur."""
    by_path = {}
    for n in nodes:
        full = n['name'] if n['parent'] in (None, '.') else n['parent'] + '/' + n['name']
        n['path'] = full
        by_path[full] = n
    out = {}
    for n in nodes:
        t = n['tr']
        p = n['parent']
        while p and p != '.':
            anc = by_path.get(p)
            if anc is None:
                break
            t = mul(anc['tr'], t)
            pp = anc['parent']
            p = None if pp in (None, '.') else pp
        out[id(n)] = t
    return out


def mul(a, b):
    A = [a[0:3], a[3:6], a[6:9]]
    ao = a[9:12]
    B = [b[0:3], b[3:6], b[6:9]]
    bo = b[9:12]
    R = [[sum(A[i][k] * B[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
    o = [sum(A[i][k] * bo[k] for k in range(3)) + ao[i] for i in range(3)]
    return (R[0][0], R[0][1], R[0][2], R[1][0], R[1][1], R[1][2],
            R[2][0], R[2][1], R[2][2], o[0], o[1], o[2])


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    path = sys.argv[1]
    pat = re.compile(sys.argv[2]) if len(sys.argv) > 2 else re.compile(r'.')
    nodes, sub = parse(path)
    wt = world(nodes)
    hits = {n['path'] for n in nodes
            if pat.search(n['name']) or (n['script'] and pat.search(n['script']))}
    print(f'{"yol":40s} {"tur":14s} {"x":>8s} {"y":>7s} {"z":>8s}  boyut / script')
    for n in nodes:
        # eslesen dugumu cocuklariyla birlikte goster: kapilarin DUGUMU transform
        # tasimiyor, gercek konum CollisionShape3D cocugunda.
        if not any(n['path'] == h or n['path'].startswith(h + '/') for h in hits):
            continue
        t = wt[id(n)]
        sh = sub.get(n['shape']) if n['shape'] else None
        extra = (f"{sh['type']} {sh['size'] or ''}".strip() if sh else '')
        if n['script']:
            extra += '  ' + n['script']
        for k, v in n['props'].items():
            extra += f'  {k}={v}'
        print(f'{n["path"][:40]:40s} {n["type"]:14s} {t[9]:8.2f} {t[10]:7.2f} {t[11]:8.2f}  {extra}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
