"""Entwürfe für die Kartenrückseite von Projekt Reichtum.

Format: 822 × 1122 px = 63,5 × 88,9 mm plus 3 mm Beschnitt bei 300 dpi (wie Druck/vorderseiten/).
Endformat (Schnitt) liegt 36 px innen, Sicherheitsabstand weitere 36 px (3 mm) innen.

Aufruf:  py bau_rueckseite.py [--v 1]
Erzeugt rueckseite_<A|B|C>_v<n>.html; rendern mit dem Skill grafikdesign (scripts/render.py).
"""
import argparse
import math
import random
from pathlib import Path

W, H = 822, 1122
T = 36          # Beschnitt -> Endformat
S = 72          # Sicherheitsabstand (3 mm innerhalb des Endformats)
RADIUS = 38     # Eckenrundung der Karte (ca. 3 mm)
CX, CY = W / 2, H / 2

FONTS = "file:///C:/Users/herma/AppData/Local/Microsoft/Windows/Fonts/"


def f(v):
    return f"{v:.1f}"


def pfad(pts, zu=False):
    s = "M" + " L".join(f"{f(x)},{f(y)}" for x, y in pts)
    return s + (" Z" if zu else "")


# ---------- Geometrie ----------

def rundrechteck(inset, r):
    """Segmente eines abgerundeten Rechtecks (im Uhrzeigersinn) mit Gesamtlänge."""
    x0, y0, x1, y1 = inset, inset, W - inset, H - inset
    segs = [
        ("L", (x0 + r, y0), (x1 - r, y0), (0, -1)),
        ("A", (x1 - r, y0 + r), r, -math.pi / 2, 0),
        ("L", (x1, y0 + r), (x1, y1 - r), (1, 0)),
        ("A", (x1 - r, y1 - r), r, 0, math.pi / 2),
        ("L", (x1 - r, y1), (x0 + r, y1), (0, 1)),
        ("A", (x0 + r, y1 - r), r, math.pi / 2, math.pi),
        ("L", (x0, y1 - r), (x0, y0 + r), (-1, 0)),
        ("A", (x0 + r, y0 + r), r, math.pi, 1.5 * math.pi),
    ]
    laengen = []
    for s in segs:
        if s[0] == "L":
            laengen.append(math.dist(s[1], s[2]))
        else:
            laengen.append(s[2] * (s[4] - s[3]))
    return segs, laengen


def punkt_auf(segs, laengen, s):
    for seg, l in zip(segs, laengen):
        if s <= l or seg is segs[-1]:
            t = min(s / l, 1) if l else 0
            if seg[0] == "L":
                (ax, ay), (bx, by), n = seg[1], seg[2], seg[3]
                return ax + (bx - ax) * t, ay + (by - ay) * t, n[0], n[1]
            (cx, cy), r, a0, a1 = seg[1], seg[2], seg[3], seg[4]
            a = a0 + (a1 - a0) * t
            return cx + r * math.cos(a), cy + r * math.sin(a), math.cos(a), math.sin(a)
        s -= l


def guilloche_rahmen(inset, r, amp, wellenlaenge, linien, farbe, breite, deckkraft, mod=0.35):
    """Verwobene Wellenlinien entlang eines abgerundeten Rechtecks (Banknoten-Rahmen)."""
    segs, laengen = rundrechteck(inset, r)
    L = sum(laengen)
    m = max(1, round(L / wellenlaenge))
    n = 2400
    teile = []
    for k in range(linien):
        ph = 2 * math.pi * k / linien
        pts = []
        for i in range(n + 1):
            s = L * i / n
            x, y, nx, ny = punkt_auf(segs, laengen, s)
            u = 2 * math.pi * m * s / L
            o = amp * math.sin(u + ph) * (1 - mod + mod * math.sin(u / 4 + ph))
            pts.append((x + nx * o, y + ny * o))
        teile.append(f'<path d="{pfad(pts, True)}"/>')
    return (f'<g fill="none" stroke="{farbe}" stroke-width="{breite}" opacity="{deckkraft}">'
            + "".join(teile) + "</g>")


def rosette(cx, cy, R, r, d, kopien, farbe, breite, deckkraft, punkte=1800):
    """Spirograph-Rosette (Hypotrochoide), mehrfach gedreht übereinandergelegt."""
    g = math.gcd(int(R), int(r))
    umlauf = int(r) // g
    teile = []
    for k in range(kopien):
        dreh =math.pi * k / kopien / max(1, (R - r) // g)
        pts = []
        n = punkte * umlauf
        for i in range(n + 1):
            t = 2 * math.pi * umlauf * i / n
            x = (R - r) * math.cos(t) + d * math.cos((R - r) / r * t)
            y = (R - r) * math.sin(t) - d * math.sin((R - r) / r * t)
            xr = x * math.cos(dreh) - y * math.sin(dreh)
            yr = x * math.sin(dreh) + y * math.cos(dreh)
            pts.append((cx + xr, cy + yr))
        teile.append(f'<path d="{pfad(pts, True)}"/>')
    return (f'<g fill="none" stroke="{farbe}" stroke-width="{breite}" opacity="{deckkraft}">'
            + "".join(teile) + "</g>")


def ringwelle(cx, cy, R, amp, n, linien, farbe, breite, deckkraft, amp2=0, n2=0):
    """Kreisring aus verwobenen Wellenlinien."""
    teile = []
    for k in range(linien):
        ph = 2 * math.pi * k / linien
        pts = []
        for i in range(1441):
            a = 2 * math.pi * i / 1440
            rr = R + amp * math.sin(n * a + ph) + amp2 * math.sin(n2 * a - ph)
            pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
        teile.append(f'<path d="{pfad(pts, True)}"/>')
    return (f'<g fill="none" stroke="{farbe}" stroke-width="{breite}" opacity="{deckkraft}">'
            + "".join(teile) + "</g>")


def wellenfeld(farbe, deckkraft, abstand=9, amp=4, wl=70):
    """Feines Untergrundmuster aus Sinuslinien über die ganze Fläche inkl. Beschnitt."""
    teile = []
    y = -10
    k = 0
    while y < H + 10:
        pts = [(x, y + amp * math.sin(2 * math.pi * x / wl + k * 0.55)) for x in range(-10, W + 11, 6)]
        teile.append(f'<path d="{pfad(pts)}"/>')
        y += abstand
        k += 1
    return f'<g fill="none" stroke="{farbe}" stroke-width="0.7" opacity="{deckkraft}">' + "".join(teile) + "</g>"


def symbol(cx, cy, groesse, farbe, licht=None):
    """Set-Symbol (steigende Kurve mit Pfeilspitze) aus Werkzeuge/Set-Symbol-erzeugen.ps1."""
    linie = [(0.24, 0.68), (0.40, 0.52), (0.51, 0.60), (0.66, 0.42)]
    spitze = [(0.60, 0.33), (0.78, 0.28), (0.72, 0.47)]

    def p(u, v, dx=0, dy=0):
        return cx + (u - 0.51) * groesse + dx, cy + (v - 0.48) * groesse + dy

    def form(c, dx=0, dy=0):
        return (f'<path d="{pfad([p(u, v, dx, dy) for u, v in linie])}" fill="none" stroke="{c}" '
                f'stroke-width="{f(0.09 * groesse)}" stroke-linejoin="miter" stroke-miterlimit="8"/>'
                f'<path d="{pfad([p(u, v, dx, dy) for u, v in spitze], True)}" fill="{c}"/>')
    s = ""
    if licht:
        s += form(licht, 1.6, 1.8)   # Lichtkante unten rechts -> wirkt eingeprägt
    return s + form(farbe)


def muenze(cx, cy, R, oben, unten, gid, schrift=34):
    """Goldmünze mit Riffelrand, Schriftring und Set-Symbol."""
    riffel = []
    for i in range(240):
        a = 2 * math.pi * i / 240
        riffel.append(f'<line x1="{f(cx + (R - 11) * math.cos(a))}" y1="{f(cy + (R - 11) * math.sin(a))}" '
                      f'x2="{f(cx + (R - 1) * math.cos(a))}" y2="{f(cy + (R - 1) * math.sin(a))}"/>')
    ri = R - 24                    # Innenfläche
    cap = schrift * 0.70
    r_oben = ri - 14 - cap         # Grundlinie oben: Buchstaben wachsen nach außen
    r_unten = ri - 14              # Grundlinie unten: Buchstaben wachsen nach innen
    ring_innen = r_oben - 10
    sep = (r_oben + r_unten) / 2
    def raute(a):
        x, y = cx + sep * math.cos(a), cy + sep * math.sin(a)
        e = 7
        return f'<path d="M{f(x)},{f(y - e)} L{f(x + e)},{f(y)} L{f(x)},{f(y + e)} L{f(x - e)},{f(y)} Z" fill="#6b4a12"/>'
    return f"""
  <defs>
    <radialGradient id="{gid}g" cx="40%" cy="35%" r="75%">
      <stop offset="0" stop-color="#fff4c2"/><stop offset=".35" stop-color="#ecc75e"/>
      <stop offset=".75" stop-color="#b98a2e"/><stop offset="1" stop-color="#7c5717"/>
    </radialGradient>
    <radialGradient id="{gid}i" cx="42%" cy="38%" r="70%">
      <stop offset="0" stop-color="#f9e39a"/><stop offset=".6" stop-color="#d9ac45"/>
      <stop offset="1" stop-color="#a87a25"/>
    </radialGradient>
    <path id="{gid}po" d="M{f(cx - r_oben)},{f(cy)} A{f(r_oben)},{f(r_oben)} 0 0 1 {f(cx + r_oben)},{f(cy)}"/>
    <path id="{gid}pu" d="M{f(cx - r_unten)},{f(cy)} A{f(r_unten)},{f(r_unten)} 0 0 0 {f(cx + r_unten)},{f(cy)}"/>
    <filter id="{gid}s" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="6" stdDeviation="9" flood-color="#000" flood-opacity=".55"/>
    </filter>
  </defs>
  <circle cx="{f(cx)}" cy="{f(cy)}" r="{R}" fill="url(#{gid}g)" filter="url(#{gid}s)"/>
  <g stroke="#7a5414" stroke-width="1.6" opacity=".55">{''.join(riffel)}</g>
  <circle cx="{f(cx)}" cy="{f(cy)}" r="{R - 13}" fill="none" stroke="#fff2b8" stroke-width="1.2" opacity=".7"/>
  <circle cx="{f(cx)}" cy="{f(cy)}" r="{ri}" fill="url(#{gid}i)" stroke="#8a611a" stroke-width="2.5"/>
  {ringwelle(cx, cy, ring_innen - 30, 6, 24, 5, '#9a6e1e', 0.8, .45)}
  <circle cx="{f(cx)}" cy="{f(cy)}" r="{f(ring_innen)}" fill="none" stroke="#8a611a" stroke-width="1.8"/>
  <text font-family="Trajan" font-size="{schrift}" fill="#5e400d" letter-spacing="3">
    <textPath href="#{gid}po" startOffset="50%" text-anchor="middle">{oben}</textPath></text>
  <text font-family="Trajan" font-size="{schrift}" fill="#5e400d" letter-spacing="3">
    <textPath href="#{gid}pu" startOffset="50%" text-anchor="middle">{unten}</textPath></text>
  {raute(math.pi)}{raute(0)}
  {symbol(cx, cy + 4, ring_innen * 1.55, '#5e400d', '#fff1b5')}
"""


def hilfslinien():
    return f"""
<g class="hilfe" fill="none">
  <rect x="{T}" y="{T}" width="{W - 2 * T}" height="{H - 2 * T}" rx="{RADIUS}" stroke="#00a0ff" stroke-width="1.5"/>
  <rect x="{S}" y="{S}" width="{W - 2 * S}" height="{H - 2 * S}" stroke="#ff2a2a" stroke-width="1.2" stroke-dasharray="8 6"/>
</g>"""


def seite(titel, inhalt):
    return f"""<!doctype html><html><head><meta charset="utf-8"><title>{titel}</title>
<style>
  @font-face {{ font-family: Trajan; src: url("{FONTS}TrajanPro-Regular.ttf"); }}
  @font-face {{ font-family: MatrixSC; src: url("{FONTS}matrixbsc.ttf"); }}
  html, body {{ margin: 0; width: {W}px; height: {H}px; overflow: hidden; background: #000; }}
  svg {{ display: block; }}
  body.ohne-hilfe .hilfe {{ display: none; }}
</style></head>
<body data-format="{W}x{H}px">
<svg width="{W}" height="{H}" viewBox="0 0 {W} {H}" xmlns="http://www.w3.org/2000/svg">
{inhalt}
{hilfslinien()}
</svg>
<script>if (location.search.indexOf("ohne-hilfe") >= 0) document.body.classList.add("ohne-hilfe");</script>
</body></html>"""


# ---------- Varianten ----------

def variante_a():
    """Banknote: dunkelgrün mit Guilloche-Rahmen, große Goldmünze, Titel oben und kopfstehend unten."""
    gold = "#d8b25a"
    titel = (f'<text x="{CX}" y="292" text-anchor="middle" font-family="Trajan" font-size="44" '
             f'letter-spacing="6" fill="url(#ag)">PROJEKT REICHTUM</text>')
    return f"""
<defs>
  <radialGradient id="abg" cx="50%" cy="50%" r="65%">
    <stop offset="0" stop-color="#1f5039"/><stop offset=".7" stop-color="#11301f"/><stop offset="1" stop-color="#081a10"/>
  </radialGradient>
  <linearGradient id="ag" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#fbe6a2"/><stop offset=".55" stop-color="#d9b04f"/><stop offset="1" stop-color="#9c7425"/>
  </linearGradient>
</defs>
<rect width="{W}" height="{H}" fill="url(#abg)"/>
{wellenfeld('#7fc2a0', .10)}
{guilloche_rahmen(86, 26, 11, 30, 6, gold, 0.9, .75)}
{guilloche_rahmen(86, 26, 6, 52, 3, '#7fc2a0', 0.7, .45, mod=0)}
<rect x="104" y="104" width="{W - 208}" height="{H - 208}" rx="14" fill="none" stroke="{gold}" stroke-width="1.6" opacity=".8"/>
<rect x="110" y="110" width="{W - 220}" height="{H - 220}" rx="10" fill="none" stroke="{gold}" stroke-width=".8" opacity=".6"/>
{rosette(170, 170, 60, 22, 30, 1, gold, .7, .8)}
{rosette(W - 170, 170, 60, 22, 30, 1, gold, .7, .8)}
{rosette(170, H - 170, 60, 22, 30, 1, gold, .7, .8)}
{rosette(W - 170, H - 170, 60, 22, 30, 1, gold, .7, .8)}
{ringwelle(CX, CY, 262, 14, 36, 6, gold, .8, .55, 5, 9)}
{titel}
<g transform="rotate(180 {CX} {CY})">{titel}</g>
{muenze(CX, CY, 222, 'BETONGOLD', 'BÖRSENPARKETT', 'a')}
"""


def variante_b():
    """Anteilschein: helles Wertpapier mit grünem Guilloche-Rahmen, Siegel-Münze, Nennwert-Witz."""
    gruen = "#1e5a3e"
    braun = "#8a6526"
    return f"""
<defs>
  <radialGradient id="bbg" cx="50%" cy="48%" r="70%">
    <stop offset="0" stop-color="#f8f0da"/><stop offset=".75" stop-color="#eee0b9"/><stop offset="1" stop-color="#d9c48f"/>
  </radialGradient>
</defs>
<rect width="{W}" height="{H}" fill="url(#bbg)"/>
{wellenfeld('#3d7a5a', .10, abstand=8, amp=3, wl=55)}
{guilloche_rahmen(98, 18, 14, 34, 8, gruen, 0.9, .85)}
{guilloche_rahmen(98, 18, 8, 17, 2, braun, 0.8, .6, mod=0)}
<rect x="122" y="122" width="{W - 244}" height="{H - 244}" rx="6" fill="none" stroke="{gruen}" stroke-width="2"/>
<rect x="128" y="128" width="{W - 256}" height="{H - 256}" rx="4" fill="none" stroke="{braun}" stroke-width=".8"/>
<text x="{CX}" y="214" text-anchor="middle" font-family="Trajan" font-size="40" letter-spacing="4" fill="{gruen}">PROJEKT REICHTUM</text>
<line x1="230" y1="236" x2="{W - 230}" y2="236" stroke="{braun}" stroke-width="1"/>
<text x="{CX}" y="270" text-anchor="middle" font-family="Trajan" font-size="22" letter-spacing="10" fill="{braun}">ANTEILSCHEIN</text>
{rosette(CX, CY + 20, 210, 46, 92, 1, gruen, .7, .7)}
{rosette(CX, CY + 20, 180, 30, 60, 1, braun, .6, .55)}
{ringwelle(CX, CY + 20, 218, 8, 40, 4, gruen, .8, .7)}
{muenze(CX, CY + 20, 128, 'BETONGOLD', 'BÖRSENPARKETT', 'b', schrift=21)}
<text x="{CX}" y="{H - 250}" text-anchor="middle" font-family="Trajan" font-size="20" letter-spacing="3" fill="{gruen}">NENNWERT: UNBEZAHLBAR</text>
<line x1="230" y1="{H - 232}" x2="{W - 230}" y2="{H - 232}" stroke="{braun}" stroke-width="1"/>
<text x="{CX}" y="{H - 202}" text-anchor="middle" font-family="Trajan" font-size="13" letter-spacing="1.5" fill="{braun}">SERIE MMXXVI · AACHEN · LEIPZIG · MÜNCHEN · JENA</text>
"""


def variante_c():
    """Duell: Betongold (grün, Mauerwerk) gegen Börsenparkett (blau, Kurschart), Münze auf der Diagonale."""
    rnd = random.Random(7)
    # Trennlinie durch die Mitte, von rechts oben nach links unten
    ya, yb = 0.33 * H, 0.67 * H            # bei x = W bzw. x = 0
    oben = f"0,0 {W},0 {W},{f(ya)} 0,{f(yb)}"
    unten = f"0,{f(yb)} {W},{f(ya)} {W},{H} 0,{H}"
    # Mauerwerk
    ziegel = []
    zh, zb = 34, 78
    for row, y in enumerate(range(-10, int(yb) + 40, zh)):
        off = (row % 2) * zb / 2
        ziegel.append(f'<line x1="-10" y1="{y}" x2="{W + 10}" y2="{y}"/>')
        x = -off
        while x < W + 10:
            ziegel.append(f'<line x1="{f(x)}" y1="{y}" x2="{f(x)}" y2="{y + zh}"/>')
            x += zb
    # Kurschart: Kerzen mit Aufwärtstrend
    kerzen = []
    preis = 0.80 * H
    for i, x in enumerate(range(24, W, 30)):
        auf = rnd.random() < 0.62
        delta = rnd.uniform(10, 34)
        o = preis
        c = preis - delta if auf else preis + delta * 0.7
        hi, lo = min(o, c) - rnd.uniform(4, 16), max(o, c) + rnd.uniform(4, 16)
        farbe = "#5fd0ff" if auf else "#ff5a4a"
        kerzen.append(f'<line x1="{x}" y1="{f(hi)}" x2="{x}" y2="{f(lo)}" stroke="{farbe}" stroke-width="1.6"/>'
                      f'<rect x="{x - 8}" y="{f(min(o, c))}" width="16" height="{f(abs(o - c) + 1)}" fill="{farbe}" opacity=".85"/>')
        preis = c
        if preis < 0.55 * H:
            preis += 60
    gitter = "".join(f'<line x1="0" y1="{y}" x2="{W}" y2="{y}"/>' for y in range(300, H + 1, 48)) + \
             "".join(f'<line x1="{x}" y1="0" x2="{x}" y2="{H}"/>' for x in range(15, W + 1, 60))
    gold = "#e2bd62"
    # goldenes Band entlang der Diagonale
    dx, dy = W, ya - yb
    l = math.hypot(dx, dy)
    nx, ny = -dy / l, dx / l
    def lin(o):
        return f'<line x1="{f(0 + nx * o)}" y1="{f(yb + ny * o)}" x2="{f(W + nx * o)}" y2="{f(ya + ny * o)}"/>'
    band = f'<g stroke="{gold}" fill="none">' + \
        f'<g stroke-width="3">{lin(-12)}{lin(12)}</g><g stroke-width="1" opacity=".7">{lin(-18)}{lin(18)}</g></g>'
    return f"""
<defs>
  <clipPath id="co"><polygon points="{oben}"/></clipPath>
  <clipPath id="cu"><polygon points="{unten}"/></clipPath>
  <linearGradient id="cg1" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#2f7a3a"/><stop offset="1" stop-color="#123d1c"/>
  </linearGradient>
  <linearGradient id="cg2" x1="1" y1="1" x2="0" y2="0">
    <stop offset="0" stop-color="#0b1f45"/><stop offset=".6" stop-color="#173a78"/><stop offset="1" stop-color="#3a1640"/>
  </linearGradient>
  <linearGradient id="cgt" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#fbe6a2"/><stop offset=".55" stop-color="#d9b04f"/><stop offset="1" stop-color="#9c7425"/>
  </linearGradient>
</defs>
<polygon points="{oben}" fill="url(#cg1)"/>
<g clip-path="url(#co)" stroke="#0d2a12" stroke-width="2.2" opacity=".55">{''.join(ziegel)}</g>
<polygon points="{unten}" fill="url(#cg2)"/>
<g clip-path="url(#cu)"><g stroke="#8fb4ff" stroke-width=".7" opacity=".18">{gitter}</g>{''.join(kerzen)}</g>
{band}
<rect x="{S}" y="{S}" width="{W - 2 * S}" height="{H - 2 * S}" rx="14" fill="none" stroke="{gold}" stroke-width="3"/>
<rect x="{S + 8}" y="{S + 8}" width="{W - 2 * S - 16}" height="{H - 2 * S - 16}" rx="10" fill="none" stroke="{gold}" stroke-width="1" opacity=".7"/>
<text x="{S + 46}" y="{S + 96}" font-family="Trajan" font-size="50" letter-spacing="3" fill="url(#cgt)" stroke="#2a1a05" stroke-width="1" paint-order="stroke">BETONGOLD</text>
<text x="{W - S - 46}" y="{H - S - 60}" text-anchor="end" font-family="Trajan" font-size="44" letter-spacing="2" fill="url(#cgt)" stroke="#2a1a05" stroke-width="1" paint-order="stroke">BÖRSENPARKETT</text>
{muenze(CX, CY, 190, 'PROJEKT', 'REICHTUM', 'c', schrift=34)}
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--v", type=int, default=1)
    a = ap.parse_args()
    hier = Path(__file__).parent
    for name, fn in (("A", variante_a), ("B", variante_b), ("C", variante_c)):
        ziel = hier / f"rueckseite_{name}_v{a.v}.html"
        ziel.write_text(seite(f"Rückseite {name}", fn()), encoding="utf-8")
        print(ziel.name)


if __name__ == "__main__":
    main()
