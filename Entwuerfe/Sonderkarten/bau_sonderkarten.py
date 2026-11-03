"""Sonderkarten im Anteilschein-Stil der Rückseite: Titelkarte (Tür 1) und 4 Trennkarten für die Deckvarianten.

Format wie die Druckdaten: 822 × 1122 px (63,5 × 88,9 mm + 3 mm Beschnitt, 300 dpi).
Aufruf:  py bau_sonderkarten.py            -> HTML hier, danach rendern nach Karten/sonder/<Datei>.png
Die PNG-Dateinamen folgen dem Schema der Druckdaten: <Tür>_<Name>_<Exemplar>.png
"""
import subprocess
import sys
from pathlib import Path

HIER = Path(__file__).resolve().parent
ROOT = HIER.parents[1]
sys.path.insert(0, str(ROOT / "Entwuerfe" / "Rueckseite"))
import bau_rueckseite as br  # noqa: E402  (Guilloche, Münze, Seitengerüst)

W, H, CX = br.W, br.H, br.CX
GRUEN, BRAUN = "#1e5a3e", "#8a6526"
RENDER = Path(r"C:\Users\herma\.claude\skills\grafikdesign\scripts\render.py")

KARTEN = [
    dict(datei="01_Titelkarte_1", oben="PROJEKT REICHTUM AG", titel="WILLKOMMEN", unter="bei Projekt Reichtum",
         bild="Bilder/Forest_5.png", fokus="xMidYMid", art="",
         text=["Lieber Robin,", "24 Türchen · 150 Karten · 2 Decks · 4 Varianten.",
               "Betongold gegen Börsenparkett:", "Immobilien gegen Aktien.",
               "Ab Tür 17 tragt ihr das erste Duell aus."],
         spruch="Viel Rendite! – Hermann", farbe=GRUEN),
    dict(datei="17_Trennkarte-Betongold_1", oben="BETONGOLD · VARIANTE STANDARD", titel="BETONGOLD", unter="",
         bild="Bilder/Ba Sing Se_1.png", fokus="xMidYMid", art="MONO-GREEN LANDFALL",
         text=["Hauptdeck: 60 Karten", "Grundstücke kaufen, Zinseszins kassieren.", "Spielt gegen Daytrader oder Luftschlösser."],
         spruch="Steine kann man anfassen. Aktien nicht.", farbe=GRUEN),
    dict(datei="24_Trennkarte-Gutachter_1", oben="BETONGOLD · VARIANTE GEGEN IZZET", titel="BETONGOLD", unter="mit Gutachter",
         bild="Bilder/Demolition Field_1.png", fokus="xMidYMid", art="LANDFALL · ANTI-IZZET",
         text=["Hauptdeck + 12 Karten aus dem Sideboard,", "Umbau laut Bau-Sheet.", "Erst prüfen, dann kaufen."],
         spruch="Erhaltenswert? Mutige Wortwahl.", farbe="#4b5a2a"),
    dict(datei="17_Trennkarte-Daytrader_1", oben="BÖRSENPARKETT · VARIANTE 1", titel="DAYTRADER", unter="",
         bild="Bilder/Wild Ride_1.png", fokus="xMidYMid", art="IZZET PROWESS",
         text=["Kern (42) + Modul Prowess (18) = 60", "Teilt sich den Kern mit Luftschlösser –", "nur eins von beiden gleichzeitig."],
         spruch="Schnell rein, schnell raus.", farbe="#8a2a22"),
    dict(datei="24_Trennkarte-Luftschloesser_1", oben="BÖRSENPARKETT · VARIANTE 2", titel="LUFTSCHLÖSSER", unter="",
         bild="Bilder/Sunderflock_1.png", fokus="xMidYMid", art="IZZET SPELLEMENTALS",
         text=["Kern (42) + Spellementals (18) = 60", "Teilt sich den Kern mit Daytrader –", "nur eins von beiden gleichzeitig."],
         spruch="Groß denken. Bauen später.", farbe="#1f4e86"),
]

FONTS = br.FONTS


def karte(k):
    bx, by, bw, bh = 150, 300, W - 300, 350
    bild = (ROOT / k["bild"]).as_uri()
    titel_y = 250 if not k["unter"] else 236
    unter = (f'<text x="{CX}" y="282" text-anchor="middle" font-family="PlantinIt" font-size="30" fill="{BRAUN}">{k["unter"]}</text>'
             if k["unter"] else "")
    gross = 50 if len(k["titel"]) <= 11 else 44
    zeilen = "".join(
        f'<text x="{CX}" y="{748 + i * 34}" text-anchor="middle" font-family="Plantin" font-size="24" fill="#2a2216">{z}</text>'
        for i, z in enumerate(k["text"]))
    art = (f'<text x="{CX}" y="696" text-anchor="middle" font-family="Trajan" font-size="21" letter-spacing="4" fill="{BRAUN}">{k["art"]}</text>'
           if k["art"] else "")
    y_spruch = 748 + len(k["text"]) * 34 + 14
    return f"""
<defs>
  <radialGradient id="bbg" cx="50%" cy="48%" r="70%">
    <stop offset="0" stop-color="#f8f0da"/><stop offset=".75" stop-color="#eee0b9"/><stop offset="1" stop-color="#d9c48f"/>
  </radialGradient>
  <clipPath id="fenster"><rect x="{bx}" y="{by}" width="{bw}" height="{bh}" rx="6"/></clipPath>
</defs>
<rect width="{W}" height="{H}" fill="url(#bbg)"/>
{br.wellenfeld('#3d7a5a', .10, abstand=8, amp=3, wl=55)}
{br.guilloche_rahmen(98, 18, 14, 34, 8, GRUEN, 0.9, .85)}
{br.guilloche_rahmen(98, 18, 8, 17, 2, BRAUN, 0.8, .6, mod=0)}
<rect x="122" y="122" width="{W - 244}" height="{H - 244}" rx="6" fill="none" stroke="{GRUEN}" stroke-width="2"/>
<rect x="128" y="128" width="{W - 256}" height="{H - 256}" rx="4" fill="none" stroke="{BRAUN}" stroke-width=".8"/>
<text x="{CX}" y="176" text-anchor="middle" font-family="Trajan" font-size="17" letter-spacing="4" fill="{BRAUN}">{k["oben"]}</text>
<text x="{CX}" y="{titel_y}" text-anchor="middle" font-family="Trajan" font-size="{gross}" letter-spacing="3" fill="{k["farbe"]}">{k["titel"]}</text>
{unter}
<image href="{bild}" x="{bx}" y="{by}" width="{bw}" height="{bh}" preserveAspectRatio="{k["fokus"]} slice" clip-path="url(#fenster)"/>
<rect x="{bx}" y="{by}" width="{bw}" height="{bh}" rx="6" fill="none" stroke="{k["farbe"]}" stroke-width="5"/>
<rect x="{bx - 7}" y="{by - 7}" width="{bw + 14}" height="{bh + 14}" rx="9" fill="none" stroke="#c9a24a" stroke-width="1.5"/>
{art}
<line x1="230" y1="714" x2="{W - 230}" y2="714" stroke="{BRAUN}" stroke-width="1"/>
{zeilen}
<text x="{CX}" y="{y_spruch}" text-anchor="middle" font-family="PlantinIt" font-size="25" fill="{k["farbe"]}">{k["spruch"]}</text>
<text x="{CX}" y="{H - 150}" text-anchor="middle" font-family="Trajan" font-size="13" letter-spacing="2" fill="{BRAUN}">SERIE MMXXVI · PRIVAT, NICHT ZUM VERKAUF</text>
"""


def seite(titel, inhalt):
    html = br.seite(titel, inhalt)
    extra = (f'  @font-face {{ font-family: Plantin; src: url("{FONTS}mplantin.ttf"); }}\n'
             f'  @font-face {{ font-family: PlantinIt; src: url("{FONTS}mplantinit.ttf"); }}\n')
    return html.replace("  html, body", extra + "  html, body", 1)


def main():
    ziel = ROOT / "Karten" / "sonder"
    ziel.mkdir(parents=True, exist_ok=True)
    for k in KARTEN:
        h = HIER / f'{k["datei"]}.html'
        h.write_text(seite(k["datei"], karte(k)), encoding="utf-8")
        subprocess.run([sys.executable, str(RENDER), str(h), "--ohne-hilfe", "--aus", str(ziel / f'{k["datei"]}.png')], check=True)


if __name__ == "__main__":
    main()
