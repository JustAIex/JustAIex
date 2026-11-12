#!/bin/bash
# Erzeugt alle Druckdateien (STL) und Vorschaubilder aus greifer.scad
cd "$(dirname "$0")"
for p in sattel gehaeuse kralle spule anschlag deck koppel taster; do
  openscad -o ../stl/$p.stl --export-format binstl -D "part=\"$p\"" greifer.scad 2>&1 | grep -E "ERROR|WARNING|Simple:" | sed "s/^/[$p] /"
done
R="xvfb-run -a openscad --imgsize=1400,1400 --colorscheme=Tomorrow"
$R -o ../bilder/01_geschlossen.png   --camera=0,0,18,72,0,28,520  -D 'open_deg=0'  greifer.scad 2>/dev/null
$R -o ../bilder/02_offen.png         --camera=0,0,18,72,0,28,520  -D 'open_deg=20' -D 'show_ball=false' greifer.scad 2>/dev/null
$R -o ../bilder/03_schnitt_zu.png    --projection=ortho --camera=0,0,8,90,0,90,430 -D 'section=true' -D 'open_deg=0'  greifer.scad 2>/dev/null
$R -o ../bilder/04_schnitt_offen.png --projection=ortho --camera=0,0,8,90,0,90,430 -D 'section=true' -D 'open_deg=20' greifer.scad 2>/dev/null
$R -o ../bilder/05_von_unten.png     --camera=0,0,-10,128,0,35,420 -D 'open_deg=20' -D 'show_ball=false' greifer.scad 2>/dev/null
ls -la ../stl ../bilder
