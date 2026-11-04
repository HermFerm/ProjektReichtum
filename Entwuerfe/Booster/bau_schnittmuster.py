"""Druckfertige Schnittmuster der Faltbooster für alle 24 Türen (2 pro A4-Blatt) + Bastelanleitung als PDF.

Aufbau eines Boosters (Druckseite außen, von links nach rechts):
  [Rücken A 12 mm][Seite D][Vorderseite 72 mm][Seite D][Rücken B 60 mm][Klebelasche 8 mm]
Höhe 134 mm (Körper 104 mm + je 15 mm Pressnaht). Rücken A + B = 72 mm, die Naht liegt 12 mm vom Rand,
damit kein Text über die Naht läuft. D (Seitenbreite = Dicke) richtet sich nach der Kartenzahl.

Aufruf: py bau_schnittmuster.py [Türen ...]   -> Druck/booster/png/*.png und Druck/booster/Booster_Schnittmuster.pdf
"""
import csv
import math
import random
import subprocess
import sys
from pathlib import Path

HIER = Path(__file__).resolve().parent
ROOT = HIER.parents[1]
sys.path.insert(0, str(HIER))
import bau_booster as bb  # noqa: E402

br = bb.br
MM = bb.MM
W, H, NAHT, KY0, KY1 = bb.W, bb.H, bb.NAHT, bb.KY0, bb.KY1
RUECKEN_A = round(12 * MM)
RUECKEN_B = W - RUECKEN_A
LASCHE = round(8 * MM)
BESCHNITT = round(2 * MM)
ZIEL = ROOT / "Druck" / "booster"
PNG = ZIEL / "png"
RENDER = bb.RENDER


def dicke_mm(tuer, karten):
    if tuer == 23:
        return 6
    extra = 1.0 if tuer in (17, 24) else 0.0           # Bau-Sheet
    return max(4, math.ceil(karten * 0.34 + 1.6 + extra))


def strichcode(x, y, w, h, seed):
    rnd = random.Random(seed)
    balken, pos = [], x + 10
    while pos < x + w - 14:
        b = rnd.choice((2, 2, 3, 4, 6))
        if rnd.random() < .6:
            balken.append(f'<rect x="{pos}" y="{y + 8}" width="{b}" height="{h - 34}" fill="#111"/>')
        pos += b + rnd.choice((2, 3, 4))
    return (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="4" fill="#fff"/>' + "".join(balken) +
            f'<text x="{x + w / 2}" y="{y + h - 8}" text-anchor="middle" font-family="Plantin" font-size="19" fill="#111">4 036 2026 1201 {seed:02d}</text>')


def holo_pro_tuer():
    zahl = {}
    with open(ROOT / "Druck" / "Packliste.csv", encoding="utf-8-sig") as f:
        for r in csv.DictReader(f, delimiter=";"):
            if r.get("Druck") == "Holo":
                zahl[int(r["Tür"])] = zahl.get(int(r["Tür"]), 0) + 1
    return zahl


def rueckseite(tuer, karten):
    """Rückseite 72 × 134 mm (px). Inhalt nur im Bereich der ersten 58 mm (Rücken B), rechts davon die Naht."""
    held = bb.held_fuer(tuer)
    dunkel, mittel, hell = bb.HELDEN[held]
    breit = RUECKEN_B - round(4 * MM)                      # nutzbare Breite links der Naht
    cx = breit / 2 + 20
    feld = bb.mit_format(W, H, br.wellenfeld, hell, .07, abstand=10, amp=4, wl=70)
    holo = holo_pro_tuer().get(tuer, 0)
    holo_txt = "1 Holo-Karte" if holo == 1 else f"{holo} Holo-Karten"
    inhalt = "Überraschung" if tuer == 23 else f"{karten} Karten, davon {holo_txt}"
    zeilen = [
        ("Beleren", 34, "#fff", f"TÜR {tuer} · {inhalt.upper()}"),
        (None, 18, None, None),
        ("Plantin", 26, "#f2ead6", "Sammle alle 150 Karten und baue"),
        ("Plantin", 26, "#f2ead6", "zwei Decks: Betongold gegen"),
        ("Plantin", 26, "#f2ead6", "Börsenparkett. Ab Tür 17 wird"),
        ("Plantin", 26, "#f2ead6", "gespielt."),
        (None, 18, None, None),
        ("PlantinIt", 24, hell, "Kann Spuren von Insidern enthalten."),
        ("PlantinIt", 24, hell, "Nicht geeignet für Personen unter 36."),
    ]
    y, txt = KY0 + 330, []
    for font, groesse, farbe, t in zeilen:
        if font:
            txt.append(f'<text x="{cx}" y="{y}" text-anchor="middle" font-family="{font}" font-size="{groesse}" fill="{farbe}">{t}</text>')
        y += groesse + 14
    return f"""
<defs><linearGradient id="rbg" x1="0" y1="0" x2="0" y2="1">
  <stop offset="0" stop-color="{dunkel}"/><stop offset=".5" stop-color="{mittel}"/><stop offset="1" stop-color="{dunkel}"/>
</linearGradient>
<linearGradient id="gold2" x1="0" y1="0" x2="0" y2="1">
  <stop offset="0" stop-color="#fff6c8"/><stop offset=".45" stop-color="#f0c75a"/><stop offset=".55" stop-color="#c9952e"/><stop offset="1" stop-color="#8a5f16"/>
</linearGradient></defs>
<rect width="{W}" height="{H}" fill="url(#rbg)"/>
<rect width="{W}" height="{H}" fill="#000" opacity=".25"/>
{feld}
{br.muenze(cx, KY0 + 110, 46, '', '', 'rm', schrift=9)}
<text x="{cx}" y="{KY0 + 196}" text-anchor="middle" font-family="Trajan" font-size="24" letter-spacing="8" fill="url(#gold2)">PROJEKT</text>
<text x="{cx}" y="{KY0 + 262}" text-anchor="middle" font-family="Beleren" font-size="70" fill="url(#gold2)" stroke="#1a1004" stroke-width="3" paint-order="stroke">REICHTUM</text>
{''.join(txt)}
{strichcode(cx - 150, KY1 - 250, 300, 120, tuer)}
<text x="{cx}" y="{KY1 - 96}" text-anchor="middle" font-family="Plantin" font-size="19" fill="{hell}">Hergestellt in Aachen, Leipzig, München und Jena.</text>
<text x="{cx}" y="{KY1 - 66}" text-anchor="middle" font-family="Trajan" font-size="15" letter-spacing="2" fill="{hell}" opacity=".8">SERIE MMXXVI · PRIVAT, NICHT ZUM VERKAUF</text>
{bb.pressnaht(0, mittel, dunkel, hell)}
{bb.pressnaht(KY1, mittel, dunkel, hell)}
"""


def seite_px(titel, w, h, inhalt):
    html = bb.seite(titel, inhalt)
    return (html.replace(f'width: {W}px; height: {H}px;', f'width: {w}px; height: {h}px;')
                .replace(f'data-format="{W}x{H}px"', f'data-format="{w}x{h}px"')
                .replace(f'<svg width="{W}" height="{H}" viewBox="0 0 {W} {H}"', f'<svg width="{w}" height="{h}" viewBox="0 0 {w} {h}"'))


def render(html_text, name):
    h = PNG / f"{name}.html"
    h.write_text(html_text, encoding="utf-8")
    subprocess.run([sys.executable, str(RENDER), str(h), "--ohne-hilfe", "--aus", str(PNG / f"{name}.png")], check=True, capture_output=True)
    h.unlink()
    return PNG / f"{name}.png"


def netz(tuer, karten):
    """Ganzes Schnittmuster einer Tür als PNG (mit 2 mm Beschnitt). Gibt Pfad und Maße in mm zurück."""
    D = round(dicke_mm(tuer, karten) * MM)
    vorne = render(bb.seite("v", bb.variante_b2(tuer, karten, holo=karten > 0)), f"t{tuer:02d}_vorne")
    hinten = render(bb.seite("h", rueckseite(tuer, karten)), f"t{tuer:02d}_hinten")
    dunkel, mittel, hell = bb.HELDEN[bb.held_fuer(tuer)]
    b = BESCHNITT
    x_ra, x_s1 = b, b + RUECKEN_A
    x_vo = x_s1 + D
    x_s2 = x_vo + W
    x_rb = x_s2 + D
    x_la = x_rb + RUECKEN_B
    nw = x_la + LASCHE + b
    nh = H + 2 * b
    hu, vu = hinten.as_uri(), vorne.as_uri()
    inhalt = f"""
<defs>
  <clipPath id="ra"><rect x="{x_ra - b}" y="0" width="{RUECKEN_A + b}" height="{nh}"/></clipPath>
  <clipPath id="rb"><rect x="{x_rb}" y="0" width="{RUECKEN_B}" height="{nh}"/></clipPath>
  <linearGradient id="seite" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="{dunkel}"/><stop offset=".5" stop-color="{mittel}"/><stop offset="1" stop-color="{dunkel}"/></linearGradient>
</defs>
<rect width="{nw}" height="{nh}" fill="{dunkel}"/>
<!-- Seiten: Farbe + Pressnaht -->
<g transform="translate({x_s1},{b})"><rect width="{D}" height="{H}" fill="url(#seite)"/></g>
<g transform="translate({x_s2},{b})"><rect width="{D}" height="{H}" fill="url(#seite)"/></g>
<!-- Rücken A zeigt die rechten 12 mm der Rückseite, Rücken B die linken 60 mm -->
<image href="{hu}" x="{x_s1 - W}" y="{b}" width="{W}" height="{H}" clip-path="url(#ra)"/>
<image href="{hu}" x="{x_rb}" y="{b}" width="{W}" height="{H}" clip-path="url(#rb)"/>
<image href="{vu}" x="{x_vo}" y="{b}" width="{W}" height="{H}"/>
<!-- Klebelasche mit abgeschrägten Ecken -->
<path d="M{x_la},{b} L{x_la + LASCHE},{b + round(4 * MM)} L{x_la + LASCHE},{b + H - round(4 * MM)} L{x_la},{b + H} Z" fill="{mittel}" opacity=".6"/>
<text x="{x_la + LASCHE / 2}" y="{b + H / 2}" text-anchor="middle" font-family="Plantin" font-size="26" fill="#fff" opacity=".8" transform="rotate(-90 {x_la + LASCHE / 2} {b + H / 2})">KLEBEN</text>
<!-- Beschnitt oben/unten/rechts füllen -->
<rect x="0" y="0" width="{nw}" height="{b}" fill="{dunkel}"/><rect x="0" y="{nh - b}" width="{nw}" height="{b}" fill="{dunkel}"/>
<rect x="{x_la + LASCHE}" y="0" width="{b}" height="{nh}" fill="#fff"/>
"""
    pfad = render(seite_px(f"Netz {tuer}", nw, nh, inhalt), f"t{tuer:02d}_netz")
    falz = [x_s1, x_vo, x_s2, x_rb, x_la]
    return dict(png=pfad, w=nw / MM, h=nh / MM, b=b / MM, falz=[(x - 0) / MM for x in falz], lasche_x=(x_la + LASCHE) / MM, d=D / MM)


def marken(x0, y0, n, label):
    """Schnitt- und Falzmarken (mm) für ein Netz, das bei (x0, y0) liegt (inkl. Beschnitt)."""
    b = n["b"]
    l, t = x0 + b, y0 + b                         # Endformat links/oben
    r = x0 + n["lasche_x"]
    u = y0 + n["h"] - b
    s = []
    for x in (l, r):
        s += [f'<line x1="{x}" y1="{t - b - 1}" x2="{x}" y2="{t - b - 5}"/>', f'<line x1="{x}" y1="{u + b + 1}" x2="{x}" y2="{u + b + 5}"/>']
    for y in (t, u):
        s += [f'<line x1="{l - b - 1}" y1="{y}" x2="{l - b - 5}" y2="{y}"/>', f'<line x1="{r + b + 1}" y1="{y}" x2="{r + b + 5}" y2="{y}"/>']
    for fx in n["falz"]:
        x = x0 + fx
        s += [f'<line x1="{x}" y1="{t - b - 1}" x2="{x}" y2="{t - b - 5}" stroke-dasharray="1 0.8"/>',
              f'<line x1="{x}" y1="{u + b + 1}" x2="{x}" y2="{u + b + 5}" stroke-dasharray="1 0.8"/>']
    txt = f'<text x="{r + b + 2}" y="{t + 2}" font-family="Arial" font-size="2.6" fill="#666" transform="rotate(90 {r + b + 2} {t + 2})">{label}</text>'
    return '<g stroke="#000" stroke-width="0.2">' + "".join(s) + "</g>" + txt


def anleitung():
    schritte = [
        "Drucken: A4, 250–300 g/m², matt oder seidenmatt, beidseitig nicht nötig. Maßstab 100 % (nicht „an Seite anpassen“).",
        "Schneiden: entlang der Schnittmarken an den Ecken (durchgezogene Striche) mit Lineal und Cutter. Der farbige Rand dahinter ist Beschnitt.",
        "Rillen: an den gestrichelten Falzmarken oben und unten ein Lineal anlegen und mit einem stumpfen Messerrücken oder Falzbein nachziehen.",
        "Falten: alle vier Falze nach hinten knicken, so dass die Vorderseite mittig liegt.",
        "Kleben: Klebelasche mit doppelseitigem Klebeband oder Klebestift bestreichen, Rücken A darüberlegen und andrücken. Es entsteht ein Schlauch.",
        "Unten verschließen: die Pressnaht unten flachdrücken (die Seiten knicken dabei nach innen), innen mit Klebeband verschließen.",
        "Füllen: Karten laut Packliste einlegen, die Holo-Karte zuletzt. Dann die obere Pressnaht genauso verschließen.",
        "Tipp: Zuerst einen Probe-Booster aus einem Fehldruck bauen. Für Tür 1 und 17 sind die Seiten breiter, weil mehr Karten hineinkommen.",
    ]
    li = "".join(f'<li>{s}</li>' for s in schritte)
    return f"""<section class="blatt anleitung">
<h1>Projekt Reichtum – Faltbooster</h1>
<p>24 Booster, 2 pro Blatt. Zuordnung der Karten: <b>Druck/Packliste.csv</b> (Spalte „Tür“).</p>
<ol>{li}</ol>
<p class="klein">Schnittmarke: durchgezogener Strich außerhalb des Boosters. Falzmarke: gestrichelter Strich. Rücken A (12 mm) kommt beim Kleben über die Lasche.</p>
</section>"""


def main():
    PNG.mkdir(parents=True, exist_ok=True)
    zahl = bb.karten_pro_tuer()
    tueren = [int(t) for t in sys.argv[1:]] or list(range(1, 25))
    netze = []
    for t in tueren:
        n = netz(t, zahl.get(t, 0))
        netze.append((t, n))
        print(f"Tür {t:2d}: {zahl.get(t, 0):2d} Karten, Seite {n['d']:.0f} mm, Netz {n['w']:.1f} × {n['h']:.1f} mm")
    blaetter = []
    for i in range(0, len(netze), 2):
        teil = netze[i:i + 2]
        inhalt, svg = [], []
        for j, (t, n) in enumerate(teil):
            x0 = (210 - n["w"]) / 2 - 3
            y0 = 10 + j * 142
            inhalt.append(f'<img src="{n["png"].as_uri()}" style="position:absolute; left:{x0}mm; top:{y0}mm; width:{n["w"]}mm; height:{n["h"]}mm">')
            svg.append(marken(x0, y0, n, f"Tür {t} · Seite {n['d']:.0f} mm"))
        blaetter.append(f'<section class="blatt">{"".join(inhalt)}<svg class="marken" viewBox="0 0 210 297">{"".join(svg)}</svg></section>')
    html = f"""<!doctype html><html><head><meta charset="utf-8"><title>Booster-Schnittmuster</title>
<style>
  @page {{ size: 210mm 297mm; margin: 0 }}
  html, body {{ margin: 0; }}
  .blatt {{ position: relative; width: 210mm; height: 297mm; page-break-after: always; overflow: hidden; }}
  .marken {{ position: absolute; left: 0; top: 0; width: 210mm; height: 297mm; }}
  .anleitung {{ font-family: Georgia, serif; padding: 18mm; box-sizing: border-box; font-size: 11.5pt; line-height: 1.45; }}
  .anleitung h1 {{ font-size: 20pt; margin: 0 0 6mm; }}
  .anleitung li {{ margin-bottom: 3mm; }}
  .klein {{ font-size: 9.5pt; color: #444; }}
</style></head><body data-format="210x297mm">
{anleitung()}
{''.join(blaetter)}
</body></html>"""
    ziel = ZIEL / "Booster_Schnittmuster.html"
    ziel.write_text(html, encoding="utf-8")
    subprocess.run([sys.executable, str(RENDER), str(ziel), "--pdf", "--aus", str(ZIEL / "Booster_Schnittmuster.png")], check=True)
    print("PDF:", ZIEL / "Booster_Schnittmuster.pdf")


if __name__ == "__main__":
    main()
