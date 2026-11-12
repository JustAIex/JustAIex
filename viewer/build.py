#!/usr/bin/env python3
"""Baut die interaktive 3D-Ansicht: exportiert die Teile in Einbaulage aus
cad/greifer.scad und bettet sie in viewer/template.html ein.
Aufruf: python3 viewer/build.py [Ausgabedatei]"""
import base64, os, struct, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

here = os.path.dirname(os.path.abspath(__file__))
scad = os.path.join(here, "..", "cad", "greifer.scad")
names = ["sattel", "gehaeuse", "kralle", "spule", "koppel", "anschlag", "deck", "taster", "servo", "horn"]
tmp = tempfile.mkdtemp()

def export(n):
    out = os.path.join(tmp, n + ".stl")
    subprocess.run(["openscad", "-o", out, "--export-format", "binstl", "-D", 'part="v_%s"' % n, scad],
                   check=True, capture_output=True)
    d = open(out, "rb").read()
    cnt = struct.unpack("<I", d[80:84])[0]
    buf = bytearray()
    for i in range(cnt):
        f = struct.unpack("<9f", d[84 + i * 50 + 12: 84 + i * 50 + 48])
        buf += struct.pack("<9h", *[max(-32767, min(32767, round(v * 100))) for v in f])
    return n, cnt, base64.b64encode(bytes(buf)).decode()

with ThreadPoolExecutor(4) as ex:
    res = list(ex.map(export, names))
data = "{" + ",".join('%s:"%s"' % (n, b) for n, _, b in res) + "}"
html = open(os.path.join(here, "template.html"), encoding="utf-8").read().replace("/*MESHDATA*/{}", data)
out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, "ballgreifer_3d.html")
open(out, "w", encoding="utf-8").write(html)
print("Dreiecke:", {n: c for n, c, _ in res}, "->", out, len(html) // 1024, "KB")
