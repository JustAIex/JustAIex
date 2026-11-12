# Ballgreifer für die Tennisschläger-Spitze

Kunstprojekt: ein 4‑Finger‑Greifer, der an der Schlägerspitze mit eingespannt wird und per Tastendruck einen Tennisball greift.

- **[BAUPLAN.md](BAUPLAN.md)** – Funktionsprinzip, Druckteile, Einkaufsliste, Verdrahtung, Zusammenbau
- `cad/greifer.scad` – parametrisches 3D‑Modell (OpenSCAD)
- `stl/` – Druckdateien
- `firmware/main.py` – Steuerprogramm für den Raspberry Pi Pico (MicroPython)
- `bilder/` – Vorschaubilder
- `viewer/` – interaktive 3D-Ansicht mit nummerierten Teilen und Zusammenbau-Schritten (`build.py` erzeugt `ballgreifer_3d.html` aus dem Modell)
