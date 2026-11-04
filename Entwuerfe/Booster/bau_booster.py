"""Entwürfe für die Faltbooster: Vorderseite 72 × 104 mm plus je 15 mm Pressnaht oben/unten = 72 × 134 mm.

Gerendert in px bei 300 dpi (850 × 1583 px), damit die Muster-Helfer aus der Rückseite (px) passen.
Aufruf: py bau_booster.py  -> booster_<A|B|C>_v1.html (+ PNG über render.py) und uebersicht_v1.html
"""
import math
import random
import subprocess
import sys
from pathlib import Path

HIER = Path(__file__).resolve().parent
ROOT = HIER.parents[1]
sys.path.insert(0, str(ROOT / "Entwuerfe" / "Rueckseite"))
import bau_rueckseite as br  # noqa: E402

RENDER = Path(r"C:\Users\herma\.claude\skills\grafikdesign\scripts\render.py")
MM = 300 / 25.4
W, H = round(72 * MM), round(134 * MM)          # 850 × 1583
NAHT = round(15 * MM)                            # Pressnaht oben/unten
KY0, KY1 = NAHT, H - NAHT                        # Körper (Vorderseite ohne Nähte)
KH = KY1 - KY0
CX = W / 2
FONTS = br.FONTS
GRUEN, BRAUN = "#1e5a3e", "#8a6526"


def mit_format(w, h, fn, *a, **k):
    """Muster-Helfer der Rückseite auf ein anderes Format umbiegen (sie lesen br.W / br.H)."""
    alt = br.W, br.H
    br.W, br.H = w, h
    try:
        return fn(*a, **k)
    finally:
        br.W, br.H = alt


def pressnaht(y, farbe1, farbe2, linie):
    """Gezackte Pressnaht wie bei echten Boostern: Metallverlauf + feine senkrechte Riffeln + Zackenkante."""
    g = f"naht{int(y)}"
    riffel = "".join(f'<line x1="{x}" y1="{y + 8}" x2="{x}" y2="{y + NAHT - 8}"/>' for x in range(6, W, 12))
    zacken = []
    kante = y + NAHT if y == 0 else y
    for i, x in enumerate(range(0, W + 1, 18)):
        zacken.append((x, kante + (6 if i % 2 else -6)))
    return f"""
<defs><linearGradient id="{g}" x1="0" y1="0" x2="0" y2="1">
  <stop offset="0" stop-color="{farbe2}"/><stop offset=".5" stop-color="{farbe1}"/><stop offset="1" stop-color="{farbe2}"/>
</linearGradient></defs>
<rect x="0" y="{y}" width="{W}" height="{NAHT}" fill="url(#{g})"/>
<g stroke="{linie}" stroke-width="2" opacity=".45">{riffel}</g>
<path d="{br.pfad(zacken)}" fill="none" stroke="{linie}" stroke-width="2.5" opacity=".7"/>"""


def zahl_muenze(cx, cy, r, zahl, gid, oben="TÜR", unten="DEZEMBER"):
    """Münze aus der Rückseite, in der Mitte die Türnummer statt Set-Symbol."""
    m = br.muenze(cx, cy, r, oben, unten, gid, schrift=max(10, r * 0.15))
    ri = r - 24 - 14 - 0.7 * max(10, r * 0.15) - 10
    gross = r * (0.62 if len(str(zahl)) == 1 else 0.52)
    return m + f"""
<circle cx="{cx}" cy="{cy}" r="{ri - 1}" fill="url(#{gid}i)"/>
<text x="{cx + 2}" y="{cy + gross * 0.36 + 2}" text-anchor="middle" font-family="Trajan" font-size="{gross}" fill="#fff1b5">{zahl}</text>
<text x="{cx}" y="{cy + gross * 0.36}" text-anchor="middle" font-family="Trajan" font-size="{gross}" fill="#5e400d">{zahl}</text>"""


def hilfe():
    s = round(3 * MM)
    return f"""<g class="hilfe" fill="none">
  <line x1="0" y1="{KY0}" x2="{W}" y2="{KY0}" stroke="#00a0ff" stroke-width="2" stroke-dasharray="10 6"/>
  <line x1="0" y1="{KY1}" x2="{W}" y2="{KY1}" stroke="#00a0ff" stroke-width="2" stroke-dasharray="10 6"/>
  <rect x="{s}" y="{KY0 + s}" width="{W - 2 * s}" height="{KH - 2 * s}" stroke="#ff2a2a" stroke-width="1.5" stroke-dasharray="8 6"/>
</g>"""


def seite(titel, inhalt):
    return f"""<!doctype html><html><head><meta charset="utf-8"><title>{titel}</title>
<style>
  @font-face {{ font-family: Trajan; src: url("{FONTS}TrajanPro-Regular.ttf"); }}
  @font-face {{ font-family: Beleren; src: url("{FONTS}beleren-bold_P1.01.ttf"); }}
  @font-face {{ font-family: Plantin; src: url("{FONTS}mplantin.ttf"); }}
  @font-face {{ font-family: PlantinIt; src: url("{FONTS}mplantinit.ttf"); }}
  html, body {{ margin: 0; width: {W}px; height: {H}px; overflow: hidden; background: #fff; }}
  svg {{ display: block; }}
  text {{ font-variant-ligatures: none; font-feature-settings: "liga" 0, "dlig" 0, "calt" 0, "clig" 0; }}
  body.ohne-hilfe .hilfe {{ display: none; }}
</style></head>
<body data-format="{W}x{H}px">
<svg width="{W}" height="{H}" viewBox="0 0 {W} {H}" xmlns="http://www.w3.org/2000/svg">
{inhalt}
{hilfe()}
</svg>
<script>if (location.search.indexOf("ohne-hilfe") >= 0) document.body.classList.add("ohne-hilfe");</script>
</body></html>"""


# ---------- Varianten (Beispiel: Tür 5, 7 Karten) ----------
TUER, KARTEN = 5, 7


def variante_a():
    """Anteilschein: wie die Kartenrückseite, Türnummer in der Münze."""
    rahmen = mit_format(W, KH, br.guilloche_rahmen, 46, 14, 11, 28, 7, GRUEN, 1.0, .85)
    rahmen2 = mit_format(W, KH, br.guilloche_rahmen, 46, 14, 6, 14, 2, BRAUN, 0.9, .6, mod=0)
    feld = mit_format(W, H, br.wellenfeld, '#3d7a5a', .10, abstand=8, amp=3, wl=55)
    cy = KY0 + KH * 0.52
    return f"""
<defs><radialGradient id="abg" cx="50%" cy="48%" r="70%">
  <stop offset="0" stop-color="#f8f0da"/><stop offset=".75" stop-color="#eee0b9"/><stop offset="1" stop-color="#d9c48f"/>
</radialGradient></defs>
<rect width="{W}" height="{H}" fill="url(#abg)"/>
{feld}
<g transform="translate(0,{KY0})">{rahmen}{rahmen2}
  <rect x="70" y="70" width="{W - 140}" height="{KH - 140}" rx="6" fill="none" stroke="{GRUEN}" stroke-width="2.5"/>
  <rect x="77" y="77" width="{W - 154}" height="{KH - 154}" rx="4" fill="none" stroke="{BRAUN}" stroke-width="1"/>
</g>
<text x="{CX}" y="{KY0 + 165}" text-anchor="middle" font-family="Trajan" font-size="22" letter-spacing="5" fill="{BRAUN}">PROJEKT REICHTUM AG</text>
<text x="{CX}" y="{KY0 + 250}" text-anchor="middle" font-family="Trajan" font-size="74" letter-spacing="6" fill="{GRUEN}">BOOSTER</text>
<line x1="200" y1="{KY0 + 285}" x2="{W - 200}" y2="{KY0 + 285}" stroke="{BRAUN}" stroke-width="1.5"/>
{br.rosette(CX, cy, 300, 66, 120, 1, GRUEN, .8, .55)}
{br.ringwelle(CX, cy, 300, 9, 40, 4, GRUEN, .9, .7)}
{zahl_muenze(CX, cy, 205, TUER, 'a')}
<text x="{CX}" y="{KY1 - 205}" text-anchor="middle" font-family="Trajan" font-size="34" letter-spacing="4" fill="{GRUEN}">{KARTEN} KARTEN · 1 HOLO</text>
<line x1="200" y1="{KY1 - 182}" x2="{W - 200}" y2="{KY1 - 182}" stroke="{BRAUN}" stroke-width="1.5"/>
<text x="{CX}" y="{KY1 - 140}" text-anchor="middle" font-family="Trajan" font-size="20" letter-spacing="4" fill="{BRAUN}">SERIE MMXXVI · NENNWERT: UNBEZAHLBAR</text>
{pressnaht(0, '#e9d9a8', '#b99a52', '#6b5320')}
{pressnaht(KY1, '#e9d9a8', '#b99a52', '#6b5320')}
"""


def variante_b():
    """Booster klassisch: dunkel, großes Kunstwerk der Gang, Logo in Gold, Türnummer als Münz-Plakette."""
    bild = (ROOT / "Bilder" / "Forest_5.png").as_uri()
    by0, by1 = KY0 + 300, KY1 - 290
    return f"""
<defs>
  <linearGradient id="bbg" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#0d2a1c"/><stop offset=".5" stop-color="#123b28"/><stop offset="1" stop-color="#06140d"/>
  </linearGradient>
  <linearGradient id="bgold" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#fff2b8"/><stop offset=".5" stop-color="#e2b84f"/><stop offset="1" stop-color="#9b6f1e"/>
  </linearGradient>
  <linearGradient id="bfade" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#fff" stop-opacity="0"/><stop offset=".12" stop-color="#fff" stop-opacity="1"/>
    <stop offset=".82" stop-color="#fff" stop-opacity="1"/><stop offset="1" stop-color="#fff" stop-opacity="0"/>
  </linearGradient>
  <mask id="bmask"><rect x="0" y="{by0}" width="{W}" height="{by1 - by0}" fill="url(#bfade)"/></mask>
</defs>
<rect width="{W}" height="{H}" fill="url(#bbg)"/>
<image href="{bild}" x="-40" y="{by0}" width="{W + 80}" height="{by1 - by0}" preserveAspectRatio="xMidYMid slice" mask="url(#bmask)"/>
<text x="{CX}" y="{KY0 + 120}" text-anchor="middle" font-family="Trajan" font-size="34" letter-spacing="10" fill="url(#bgold)">PROJEKT</text>
<text x="{CX}" y="{KY0 + 232}" text-anchor="middle" font-family="Beleren" font-size="118" fill="url(#bgold)" stroke="#2a1a05" stroke-width="3" paint-order="stroke">Reichtum</text>
{br.symbol(CX, KY0 + 276, 60, '#e2b84f')}
<rect x="60" y="{KY1 - 250}" width="{W - 120}" height="60" rx="30" fill="#000" opacity=".55"/>
<text x="{CX}" y="{KY1 - 208}" text-anchor="middle" font-family="Beleren" font-size="36" fill="#f3e3b0">{KARTEN} Karten · 1 Holo-Karte</text>
<text x="{CX}" y="{KY1 - 120}" text-anchor="middle" font-family="Trajan" font-size="40" letter-spacing="8" fill="url(#bgold)">BOOSTER</text>
{zahl_muenze(W - 170, KY0 + KH * 0.64, 128, TUER, 'b')}
{pressnaht(0, '#f4f4f4', '#9a9a9a', '#555')}
{pressnaht(KY1, '#f4f4f4', '#9a9a9a', '#555')}
"""


def variante_c():
    """Duell: Betongold (Mauerwerk) oben links gegen Börsenparkett (Kurschart) unten rechts, Münze mit Türnummer."""
    rnd = random.Random(5)
    ya, yb = KY0 + KH * 0.36, KY0 + KH * 0.64
    oben = f"0,0 {W},0 {W},{ya:.0f} 0,{yb:.0f}"
    unten = f"0,{yb:.0f} {W},{ya:.0f} {W},{H} 0,{H}"
    ziegel = []
    for row, y in enumerate(range(0, int(yb) + 40, 40)):
        ziegel.append(f'<line x1="0" y1="{y}" x2="{W}" y2="{y}"/>')
        x = -(row % 2) * 46
        while x < W:
            ziegel.append(f'<line x1="{x}" y1="{y}" x2="{x}" y2="{y + 40}"/>')
            x += 92
    kerzen, preis = [], KY1 - 120
    for x in range(30, W, 34):
        auf = rnd.random() < .65
        d = rnd.uniform(12, 40)
        o, c = preis, (preis - d if auf else preis + d * .7)
        f = "#5fd0ff" if auf else "#ff5a4a"
        kerzen.append(f'<line x1="{x}" y1="{min(o, c) - 14:.0f}" x2="{x}" y2="{max(o, c) + 14:.0f}" stroke="{f}" stroke-width="2"/>'
                      f'<rect x="{x - 9}" y="{min(o, c):.0f}" width="18" height="{abs(o - c) + 1:.0f}" fill="{f}"/>')
        preis = c
    gold = "#e2bd62"
    return f"""
<defs>
  <clipPath id="co"><polygon points="{oben}"/></clipPath><clipPath id="cu"><polygon points="{unten}"/></clipPath>
  <linearGradient id="cg1" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#2f7a3a"/><stop offset="1" stop-color="#123d1c"/></linearGradient>
  <linearGradient id="cg2" x1="1" y1="1" x2="0" y2="0"><stop offset="0" stop-color="#0b1f45"/><stop offset=".6" stop-color="#173a78"/><stop offset="1" stop-color="#3a1640"/></linearGradient>
  <linearGradient id="cgt" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fbe6a2"/><stop offset=".55" stop-color="#d9b04f"/><stop offset="1" stop-color="#9c7425"/></linearGradient>
</defs>
<polygon points="{oben}" fill="url(#cg1)"/>
<g clip-path="url(#co)" stroke="#0d2a12" stroke-width="2.5" opacity=".55">{''.join(ziegel)}</g>
<polygon points="{unten}" fill="url(#cg2)"/>
<g clip-path="url(#cu)">{''.join(kerzen)}</g>
<line x1="0" y1="{yb:.0f}" x2="{W}" y2="{ya:.0f}" stroke="{gold}" stroke-width="7"/>
<text x="60" y="{KY0 + 150}" font-family="Trajan" font-size="62" letter-spacing="3" fill="url(#cgt)" stroke="#2a1a05" stroke-width="1.5" paint-order="stroke">BETONGOLD</text>
<text x="{W - 60}" y="{KY1 - 110}" text-anchor="end" font-family="Trajan" font-size="54" letter-spacing="2" fill="url(#cgt)" stroke="#2a1a05" stroke-width="1.5" paint-order="stroke">BÖRSENPARKETT</text>
<text x="{W - 60}" y="{KY1 - 60}" text-anchor="end" font-family="Plantin" font-size="30" fill="#f3e3b0">{KARTEN} Karten · 1 Holo</text>
{zahl_muenze(CX, KY0 + KH * 0.5, 190, TUER, 'c', oben='PROJEKT', unten='REICHTUM')}
{pressnaht(0, '#f1dc9a', '#a8822e', '#5a4210')}
{pressnaht(KY1, '#f1dc9a', '#a8822e', '#5a4210')}
"""


# ---------- v2: Play-Booster nach dem Vorbild echter Booster ----------
# Farbe je Held: (dunkel, mittel, hell)
HELDEN = {
    "Robin": ("#0d3a1f", "#1f7a3e", "#9af0a8"),
    "Hermann": ("#0c2550", "#1f5aa8", "#9fd8ff"),
    "Paul": ("#3d0c0a", "#a8261c", "#ffb08a"),
    "Johann": ("#3a220c", "#8a5a24", "#ffd08a"),
    "Max": ("#26113f", "#5e34a0", "#d8b4ff"),
    "Gruppe": ("#3a2a06", "#a8801c", "#ffe7a0"),
}
SONDER_BAND = {1: "LÄNDER-BOOSTER", 6: "NIKOLAUS-BOOSTER", 17: "SPIELWOCHENENDE", 20: "SPIELMARKEN",
               23: "ÜBERRASCHUNG", 24: "HEILIGABEND"}


def held_fuer(tuer):
    if tuer in (1, 24):
        return "Gruppe"
    if tuer == 6:
        return "Robin"
    reihe = ["Hermann", "Paul", "Johann", "Max", "Robin"]
    andere = [t for t in range(2, 24) if t != 6]
    return reihe[andere.index(tuer) % 5]


def schnoerkel(x, y, s, spiegel=False, farbe="url(#gold2)"):
    """Goldener Zierschnörkel (Ranke mit eingerollten Enden), gespiegelt für die rechte Seite."""
    d = ("M0,0 C18,-22 52,-24 70,-8 C84,4 78,26 60,26 C46,26 44,10 56,8 "
         "M0,0 C-14,14 -40,18 -56,8 C-68,0 -62,-16 -50,-16 C-40,-16 -40,-6 -46,-4 "
         "M22,-14 C26,-30 44,-36 54,-30 M30,6 C40,20 30,34 18,32")
    t = f"translate({x},{y}) scale({-s if spiegel else s},{s})"
    return (f'<g transform="{t}" fill="none" stroke-linecap="round">'
            f'<path d="{d}" stroke="#1a1004" stroke-width="{7 / s:.1f}" opacity=".7"/>'
            f'<path d="{d}" stroke="{farbe}" stroke-width="{3.6 / s:.1f}"/></g>')


def funkeln(n, y0, y1, seed, farbe="#fff4c8"):
    rnd = random.Random(seed)
    sterne = []
    for _ in range(n):
        x, y, r = rnd.uniform(30, W - 30), rnd.uniform(y0, y1), rnd.uniform(5, 14)
        sterne.append(f'<path d="M{x:.0f},{y - r:.0f} Q{x:.0f},{y:.0f} {x + r:.0f},{y:.0f} Q{x:.0f},{y:.0f} {x:.0f},{y + r:.0f} '
                      f'Q{x:.0f},{y:.0f} {x - r:.0f},{y:.0f} Q{x:.0f},{y:.0f} {x:.0f},{y - r:.0f} Z" fill="{farbe}" opacity="{rnd.uniform(.5, .95):.2f}"/>')
    return "".join(sterne)


def variante_b2(tuer, karten, holo=True):
    held = held_fuer(tuer)
    dunkel, mittel, hell = HELDEN[held]
    bild = (ROOT / "Bilder" / f"Booster_{held}.png").as_uri()
    band = SONDER_BAND.get(tuer, "PLAY-BOOSTER")
    by = KY1 - 168                                   # Band oben
    karten_txt = f"{karten} KARTEN" if karten else "ÜBERRASCHUNG"
    tag = (f'<g transform="translate({W - 175},{KY0 + KH * 0.705}) rotate(-8)">'
           f'<rect x="-120" y="-38" width="240" height="76" rx="16" fill="#0b0b0b" opacity=".78" stroke="url(#gold2)" stroke-width="3"/>'
           f'<text x="0" y="-6" text-anchor="middle" font-family="Beleren" font-size="25" fill="#fff">1 HOLO-KARTE</text>'
           f'<text x="0" y="24" text-anchor="middle" font-family="Beleren" font-size="21" fill="{hell}">in jedem Booster!</text></g>') if holo else ""
    return f"""
<defs>
  <linearGradient id="gold2" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#fff6c8"/><stop offset=".45" stop-color="#f0c75a"/><stop offset=".55" stop-color="#c9952e"/><stop offset="1" stop-color="#8a5f16"/>
  </linearGradient>
  <linearGradient id="titel" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#ffffff"/><stop offset=".5" stop-color="{hell}"/><stop offset="1" stop-color="{mittel}"/>
  </linearGradient>
  <linearGradient id="oben" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="{dunkel}" stop-opacity=".95"/><stop offset=".22" stop-color="{dunkel}" stop-opacity=".55"/><stop offset=".34" stop-color="{dunkel}" stop-opacity="0"/>
    <stop offset=".62" stop-color="{dunkel}" stop-opacity="0"/><stop offset=".82" stop-color="{dunkel}" stop-opacity=".75"/><stop offset="1" stop-color="{dunkel}" stop-opacity=".98"/>
  </linearGradient>
  <radialGradient id="vign" cx="50%" cy="45%" r="75%">
    <stop offset=".6" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".55"/>
  </radialGradient>
  <linearGradient id="band" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="{hell}"/><stop offset=".18" stop-color="{mittel}"/><stop offset="1" stop-color="{dunkel}"/>
  </linearGradient>
  <filter id="schatten" x="-10%" y="-20%" width="120%" height="140%"><feDropShadow dx="0" dy="5" stdDeviation="5" flood-color="#000" flood-opacity=".75"/></filter>
  <filter id="glow" x="-20%" y="-40%" width="140%" height="180%"><feGaussianBlur stdDeviation="9" result="b"/><feFlood flood-color="{hell}" flood-opacity=".55"/><feComposite in2="b" operator="in"/><feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter>
</defs>
<rect width="{W}" height="{H}" fill="{dunkel}"/>
<image href="{bild}" x="0" y="{KY0 + 90}" width="{W}" height="{KH}" preserveAspectRatio="xMidYMin slice"/>
<rect x="0" y="{KY0}" width="{W}" height="{KH}" fill="url(#oben)"/>
<rect x="0" y="{KY0}" width="{W}" height="{KH}" fill="url(#vign)"/>
{funkeln(26, KY0 + 20, KY0 + 330, tuer)}
<text x="44" y="{KY0 + 58}" font-family="Beleren" font-size="28" fill="#fff" filter="url(#schatten)">{karten_txt}</text>
<g transform="translate({W - 44},{KY0 + 58})" filter="url(#schatten)">
  <text x="-62" y="0" text-anchor="end" font-family="Beleren" font-size="24" fill="#fff">DEUTSCH</text>
  <rect x="-56" y="-26" width="56" height="34" rx="6" fill="#fff"/>
  <text x="-28" y="1" text-anchor="middle" font-family="Beleren" font-size="24" fill="#111">36+</text>
</g>
<g filter="url(#schatten)">
  {br.muenze(CX, KY0 + 118, 40, '', '', 'lg', schrift=8)}
  <text x="{CX}" y="{KY0 + 192}" text-anchor="middle" font-family="Trajan" font-size="30" letter-spacing="12" fill="url(#gold2)">PROJEKT</text>
  <text x="{CX}" y="{KY0 + 286}" text-anchor="middle" font-family="Beleren" font-size="112" fill="url(#gold2)" stroke="#1a1004" stroke-width="4" paint-order="stroke">REICHTUM</text>
</g>
{schnoerkel(120, KY0 + 248, 1.1)}{schnoerkel(W - 120, KY0 + 248, 1.1, spiegel=True)}
{zahl_muenze(W - 118, KY0 + 420, 86, tuer, 'tb')}
{tag}
<g filter="url(#glow)">
  <text x="{CX}" y="{by - 92}" text-anchor="middle" font-family="Beleren" font-size="86" fill="url(#titel)" stroke="#120a02" stroke-width="5" paint-order="stroke">BETONGOLD</text>
  <text x="{CX}" y="{by - 26}" text-anchor="middle" font-family="Beleren" font-size="50" letter-spacing="4" fill="url(#titel)" stroke="#120a02" stroke-width="4" paint-order="stroke">vs. BÖRSENPARKETT</text>
</g>
<rect x="0" y="{by}" width="{W}" height="86" fill="url(#band)"/>
<line x1="0" y1="{by + 2}" x2="{W}" y2="{by + 2}" stroke="url(#gold2)" stroke-width="5"/>
<line x1="0" y1="{by + 84}" x2="{W}" y2="{by + 84}" stroke="url(#gold2)" stroke-width="5"/>
<text x="{CX}" y="{by + 59}" text-anchor="middle" font-family="Beleren" font-size="50" letter-spacing="2" fill="#fff" filter="url(#schatten)">{band}</text>
{schnoerkel(60, by + 43, .55)}{schnoerkel(W - 60, by + 43, .55, spiegel=True)}
<text x="{CX}" y="{KY1 - 32}" text-anchor="middle" font-family="Trajan" font-size="17" letter-spacing="3" fill="{hell}" opacity=".85">SERIE MMXXVI · PRIVAT, NICHT ZUM VERKAUF</text>
{pressnaht(0, mittel, dunkel, hell)}
{pressnaht(KY1, mittel, dunkel, hell)}
"""


def karten_pro_tuer():
    import csv
    zahl = {}
    with open(ROOT / "Druck" / "Packliste.csv", encoding="utf-8-sig") as f:
        for r in csv.DictReader(f, delimiter=";"):
            zahl[int(r["Tür"])] = zahl.get(int(r["Tür"]), 0) + 1
    return zahl


def main_v2(tueren):
    zahl = karten_pro_tuer()
    for t in tueren:
        h = HIER / f"booster_v2_tuer{t:02d}.html"
        h.write_text(seite(f"Booster Tür {t}", variante_b2(t, zahl.get(t, 0), holo=zahl.get(t, 0) > 0)), encoding="utf-8")
        subprocess.run([sys.executable, str(RENDER), str(h), "--ohne-hilfe", "--aus", str(HIER / f"booster_v2_tuer{t:02d}.png")], check=True, capture_output=True)
    print("ok")


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--v2":
        main_v2([int(t) for t in sys.argv[2:]] or [1, 2, 3, 4, 5, 6])
        return
    pngs = []
    for name, fn in (("A", variante_a), ("B", variante_b), ("C", variante_c)):
        h = HIER / f"booster_{name}_v1.html"
        h.write_text(seite(f"Booster {name}", fn()), encoding="utf-8")
        for zusatz in ([], ["--ohne-hilfe", "--aus", str(HIER / f"booster_{name}_v1_ohne.png")]):
            subprocess.run([sys.executable, str(RENDER), str(h)] + zusatz, check=True, capture_output=True)
        pngs.append(f"booster_{name}_v1_ohne.png")
    print("ok")


if __name__ == "__main__":
    main()
