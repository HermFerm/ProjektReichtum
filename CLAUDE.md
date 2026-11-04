# Projekt Reichtum – Übergabe für Claude

Diese Datei liest Claude Code automatisch, wenn es in diesem Ordner gestartet wird. Sie fasst zusammen, was in den bisherigen Sitzungen (30.10.–03.11.2026) erarbeitet wurde. **Lies zu Beginn jeder Sitzung zusätzlich `Projektstand.md`.** Dort steht der verbindliche, datierte Verlauf. Nach getaner Arbeit kommt dort ein Update mit Datum dazu.

## Worum es geht

Hermann Ziege (der Nutzer, „der Schenker“) baut für seinen Freund **Robin Reich** einen **Magic-the-Gathering-Adventskalender** mit 24 Türchen für Dezember 2026. **Tür 1 ist am 01.12.2026.** Die Karten müssen also vorher gedruckt und gepackt sein.

- Inhalt sind personalisierte Proxy-Karten aus **zwei aktuellen Standard-Decks**.
- Die Decks sind mit Insidern einer Freundesgruppe aus fünf Männern gestaltet: Robin, Hermann, Paul Seidler, Johann Kittel und Max Tschirpke.
- Die WhatsApp-Gruppe heißt „Projekt Reichtum“. Ihr Dauerthema ist finanzielle Freiheit.
- Robin ist ein **erfahrener** Spieler (Magic Arena). Er bekommt beide Decks und spielt sie mit Freunden, die ihn besuchen.
- Hintergrund zu den Personen: `Vorlagen/Beschreibung der Gang.docx`.

## Kernkonzept

- **„Betongold“ (Mono-Green Landfall)** gegen **„Börsenparkett“ (Izzet)**: Immobilien gegen Aktien, das Dauerthema der Gruppe als Duell.
- **Pool aus 150 Karten → 4 Varianten, aber nur 2 Decks gleichzeitig baubar:**
  - Izzet Prowess
  - Izzet Spellementals (teilt sich einen Kern von 42 Karten mit Prowess)
  - Landfall Standard
  - Landfall Anti-Izzet (mit Sideboard)
- **Matchup-Daten** (decklistdata.com, 29.04.–26.10.2026): Prowess gegen Landfall 49 : 51, Elementals gegen Landfall 53 : 47. Am 02.11. mit aktuellen MTGO-Listen abgeglichen (`Deckabgleich.md`).
- **Flavor-Name-Prinzip** (wie bei den Godzilla- bzw. Universes-Within-Karten):
  - Eigener Name, eigenes Bild und eigener Flavortext.
  - Der Oracle-Name steht klein darunter.
  - **Regeltext und Schlüsselwörter bleiben exakt wie bei Scryfall, auf Englisch.** Der Flavortext ist deutsch.
- **Türchenplan:**
  - Tür 1: Länderpaket (19 Standardländer, randlos)
  - Tür 2–16: 15 Booster mit 6–7 Karten, Tür 6 ist „Robins Stiefel“ (nur Robin-Karten)
  - Tür 17: Bau-Sheet für Duell 1
  - Tür 18, 19, 21, 22: Module (Spellementals und Landfall-Sideboard)
  - Tür 20: Spielmarken
  - Tür 23: Kleinigkeit 2 (offen)
  - Tür 24: letzter Booster „alle zusammen“ (mit Bugatti) und Bau-Sheet für alle 4 Varianten

## Ablauf der Erzeugung (Pipeline)

Quellen ändern, dann die Skripte der Reihe nach neu starten. **Erzeugte Dateien nie von Hand ändern.**

1. `Kartenpool.csv`, `Flavortexte.md`, `Bildauftraege.md` → `Werkzeuge/Planungstabelle.ps1` → `Planungstabelle.csv`, `Tuerchenplan.md`
2. `Bildprompts.md` + Planungstabelle → `Werkzeuge/Bildauftraege-erzeugen.ps1` → `Werkzeuge/Bildauftraege/<Chat>.json` → `Werkzeuge/Bildgenerator.ps1` → `Bilder/` (nur bei neuen Bildern nötig)
3. Planungstabelle + `Spielmarken.csv` + `Bilder/` + Scryfall → `Werkzeuge/MSE-Set-erzeugen.ps1` → `Karten/Projekt-Reichtum.mse-set`, `Karten/png/` (dauert etwa 5 Minuten)
4. `Karten/png/` → `Werkzeuge/Druckdaten-erzeugen.ps1` → `Druck/vorderseiten/`, `Druck/Packliste.csv`

## Dateien

| Datei | Inhalt |
|---|---|
| `Projektstand.md` | **Hauptdokument:** Ziel, Entscheidungen, Deckliste, Türchenplan, Verlauf mit Datum, nächste Schritte |
| `Kartenpool.csv` | alle 150 Karten mit Person, Flavorname und Begründung, warum die Mechanik passt (Trennzeichen `;`) |
| `Deckabgleich.md` | Abgleich aller Varianten mit MTGO-Listen (27.10.–02.11.), Option B umgesetzt |
| `Bildprompts.md` | Stilblock und Prompt pro Karte (V1–V4 bei 4er-Karten) |
| `Bildauftraege.md` | welches Foto zu welcher Karte/Variante gehört, für alle 150 Bilder |
| `Flavortexte.md` | Flavortext pro Exemplar (Nummer = Bildvariante V1–V4), mit Zeichenbudget nach der Länge des Oracle-Texts |
| `Planungstabelle.csv`, `Tuerchenplan.md` | **erzeugt** von `Werkzeuge/Planungstabelle.ps1`: alle 150 Karten mit Tür, Person, Insider, Flavortext und Bilddatei. Besondere Tage stehen in der Liste `$fixes` im Skript. |
| `Werkzeuge/Bildgenerator.ps1` | Bilder über die OpenAI-API (`gpt-image-2.5-sunburst`, `/v1/images/edits`). Überschreibt nie (neuer Versuch = `_versuchN`), Protokoll mit Kosten in `Bilder/_Protokoll.csv`. Aufruf: `-Auftraege <json> [-Nur "Name1,Name2"]` |
| `Werkzeuge/Bildauftraege-erzeugen.ps1` | erzeugt `Werkzeuge/Bildauftraege/<Chat>.json` aus `Bildprompts.md`, `Planungstabelle.csv` und der Foto-Zuordnung im Skript |
| `Werkzeuge/MSE-Set-erzeugen.ps1` | Kartensatz im Magic Set Editor (`../MagicSetEditor/mse.com`, außerhalb des Repos): Set + PNG-Export nach `Karten/png/`. `-Nur "Opt,Forest"` für Tests, `-Aktualisieren` lädt Scryfall neu (Cache `Daten/scryfall.json`) |
| `Spielmarken.csv` | **Quelle** für Token und Spielhilfen (Baumwesen, Erdbändigen-Marker, Stallion-Kopie): Tür, Texte, Farbe, Bild. `MSE-Set-erzeugen.ps1` setzt sie mit der Vorlage M15 Token, Dateiname `<Tür>_Token-<Marke>_<Exemplar>`. Mit `-Nur "Spielmarken"` testen. |
| `Werkzeuge/Pruefung.ps1` | **Prüfung vor dem Druck:** Deckgrößen und 4er-Regel, Scryfall frisch (Oracle-Änderungen, Standard-Legalität), Kartensatz Feld für Feld gegen Oracle, Druckbilder (Anzahl, 822 × 1122, 300 dpi, Rückseite). Nach jeder Änderung am Kartensatz laufen lassen. |
| `Werkzeuge/Bild-erweitern.ps1` | erweitert ein Bild nach oben/zu den Seiten (Outpainting), damit das Motiv tiefer sitzt. Originalpixel werden wieder darübergelegt, Gesichter bleiben exakt. Ergebnis `_versuchN`, Aufruf `-Bilder "Forest_8" [-Skala 0.9]` |
| `Werkzeuge/Set-Symbol-erzeugen.ps1` | Set-Symbol `Karten/Set-Symbol.mse-symbol`: Münze mit steigender Kurve, Farbe nach Seltenheit |
| `Werkzeuge/Druckdaten-erzeugen.ps1` | Druckbilder mit 3 mm Beschnitt (822 × 1122 px, 300 dpi) nach `Druck/vorderseiten/` + `Druck/Packliste.csv` (Karte → Türchen) |
| `Bilder/` | 150 fertige Kartenbilder `<Karte>_<Exemplar>.png`, Charakterblätter `_Charakterblatt_<Name>.png`, verworfene Versionen in `_verworfen/` |
| `Karten/` | MSE-Set, Set-Symbol, `png/` (153 Karten = 150 + 3 Saga-Beilegkarten von Esper Origins) |
| `Druck/` | Druckdaten für **zwei MPC-Decks**: `vorderseiten/` (144, normal) und `holo/` (36, „Holographic foil (front)“: eine Karte pro Booster, Spielmarken, Titelkarte; Liste `$holo` in `Druckdaten-erzeugen.ps1`), dazu `rueckseite.png` für beide, `Packliste.csv` (Karte → Tür, Spalte „Druck“ normal/Holo), `Bestellanleitung.md` (MPC) |
| `Entwuerfe/Sonderkarten/bau_sonderkarten.py` | Titelkarte und 4 Trennkarten im Anteilschein-Stil → `Karten/sonder/` (schon im Druckformat). `Druckdaten-erzeugen.ps1` übernimmt sie und erzeugt dazu die gekennzeichneten Ersatzkarten (Liste `$ersatz`). |
| `Entwuerfe/Booster/bau_booster.py`, `bau_schnittmuster.py` | Faltbooster (Play-Booster-Stil, „DEUTSCH 36+“): Vorderseite je Tür (`--v2 <Türen>`), Rückseite und Schnittmuster → `Druck/booster/Booster_Schnittmuster.pdf` (13 Seiten A4, 2 Booster pro Blatt). Motive `Bilder/Booster_<Held>.png`, Zuordnung in `held_fuer()`, Sonderbänder in `SONDER_BAND`. |
| `Entwuerfe/Rueckseite/bau_rueckseite.py` | Rückseite (Variante B Anteilschein, ENTSCHIEDEN 03.11.) → `Druck/rueckseite.png` |
| `Entwuerfe/` | Gestaltungsentwürfe (Rahmenvergleich, Rückseite …) |
| `Foto-Wunschliste.md` | Wunschliste und Abgleich: Fotobasis ist vollständig, offen ist nur das echte Seifenblasen-Foto (optional) |
| `Fotos/` | sortierte Fotos (siehe unten). Sie liegen im privaten Repo `HermFerm/ProjektReichtum`, **außer** `_Videos/`, `_Nicht-verwenden/` und `Sonstiges/`, die nur auf Hermanns erstem Rechner liegen (siehe `.gitignore`). |
| `Fotos/_Sortierprotokoll.csv`, `_Umbenennungsprotokoll.csv` | jede Verschiebung bzw. Umbenennung, damit sie sich rückgängig machen lässt |
| `Fotos/_Zuordnung/Wer-ist-drauf.csv` | Kandidatenfotos K-1 bis K-38 mit den Personen, die Hermann eingetragen hat |
| `.claude/commands/vertiefen.md` | Slash-Befehl `/vertiefen` (Prompt-Vertiefung nach Expertenperspektive) |

### Aufbau des Ordners `Fotos/`

| Ordner | Inhalt |
|---|---|
| `Robin/`, `Hermann/`, `Paul/`, `Johann/`, `Max/` | `<Name>_ref_01` (Referenz) und `<Name>_portrait_NN` |
| `Gruppe/` | Garten-Jena, Mallorca-JGA (2025), Mallorca-2018, Hochzeit, Oktoberfest, Alpen-Rennrad |
| `Themen/` | Arbeit-Projekte, Firmenwagen, Haus-Garten-Koi, Rennrad-Werkstatt, YouTube-Verkleidung |
| `Nachlieferung/` | gezielt gelieferte Motive, Dateiname = Inhalt |
| `Portraits/` | noch 1 Foto nicht zugeordnet (P-6) |
| `Sonstiges/`, `_Videos/`, `_Nicht-verwenden/` | Rest, Videos/GIFs, aussortierte Bilder |

Dateinamen mit `Name1-Name2__` vorne zeigen, wer auf dem Bild ist (von Hermann bestätigt).

## Feste Regeln und Entscheidungen

- **Keine Gesichtserkennung.** Claude ordnet Personen nicht anhand ihrer Gesichter zu, auch nicht mit Referenzfotos. Wer auf einem Bild ist, sagt Hermann. Claude sortiert nach Szene und Inhalt.
- **Kinder und Partnerinnen** nur anonymisiert (Silhouette, Text, Gag), nie mit echtem Foto. **Ausnahmen: Vicky (Viktoria), Robins Frau, und Robins Eltern** dürfen gezeigt werden.
- **Ton:** darf ruhig frech sein, Vicky versteht Spaß.
- **Firmennamen** (PlanOrg, Dedalus, Bugatti) nur im Text, keine Logos. Die Karten sind nur für privaten Gebrauch, nicht zum Verkauf (Fan Content Policy). **Eigene Rückseite**, nicht die Magic-Rückseite.
- **In Bild-Prompts „Fantasy-Sammelkartenspiel“ schreiben, nicht „Magic“.** Rahmen und Text kommen aus dem Magic Set Editor, nie aus dem Bildgenerator. Der Kartenspruch darf als Inspiration in den Prompt, aber nicht ins Bild.
- **Bildformate:** Kartenbild 1536 × 1024 (quer), Vollbild-Land 1024 × 1536 (hochkant). Gesichter und wichtige Motive mindestens 10 % vom Bildrand entfernt.
- **Kartensatz (ENTSCHIEDEN 03.11.):** Rahmen M15 Altered, kein Hologramm-Oval, automatischer Erinnerungstext aus, Grundländer randlos. Druck über eine Online-Kartendruckerei.
- **Druckformat:** 63,5 × 88,9 mm plus 3 mm Beschnitt = 822 × 1122 px bei 300 dpi. Ecken außerhalb der Rundung sind schwarz.
- **Dateien nicht löschen**, ohne dass Hermann es ausdrücklich will (ein Löschversuch wurde abgelehnt). Verworfenes wandert in `_verworfen/`.

## Zuordnung Person → Karten (Kurzfassung, Details in `Kartenpool.csv`)

**Robin**
- Mightform Harmonizer = Der Zinseszins
- Llanowar Elves = Siebträger auf Knopfdruck
- Opt = Rendite-Spezialisten Gold (PDF)
- Stock Up
- Elusive Otter = Arena, Runde 100
- Bounce Off = Wiesn-Ablenkung
- Sapling Nursery = Oktoberfest
- Impractical Joke (Exemplar 2) = Robins Joker

**Hermann**
- Sunderflock = Hermanns Luftschloss
- Prismari Charm = Themencocktail
- Eddymurk Crab = Das eingestaubte Rennrad
- Flow State = „Da les ich mich mal ein“
- Esper Origins = Der Puzzle-Adventskalender

**Paul**
- Surrak = Paul, nicht diskutierbar
- Pompous Battlemage = „Das ist die einzig logische Meinung“
- Burst Lightning = Pauls Ausraster
- Wild Ride = Zocken mit Spielgeld
- Traumatic Critique = Pauls Feedbackgespräch
- Hard-Hitting Question = „Geht das nicht effizienter?“

**Johann**
- Icetill Explorer = Johann der Heimwerker
- Slickshot Show-Off = Klippenspringer von Mallorca
- Spell Snare = Das Glas ist halb leer
- Impractical Joke (Exemplar 1) = Helge-Schneider-Zitat („Richtig, richtig, Popichtig.“)
- Carnivorous Cultivator = Johann im Kundentermin
- Ba Sing Se = Johanns Haus

**Max**
- Lumbering Worldwagon = Bugatti
- Mossborn Hydra = Der Turbolader
- Colorstorm Stallion = Die kesse Sohle
- Keen-Eyed Curator = Max im Sternerestaurant
- Sleight of Hand = Max philosophiert
- Torpor Orb = Max zieht den Stecker

**Gruppe**
- Earthbender Ascension = Projekt „Zur erfolgreichen Praxis“
  - 4 Quest-Marken = 4 Meilensteine: SEO-Referenzen → Vertrieb schulen und Gebiete → Werbekampagne → REICHTUM!
  - Bilder: Aachen/Hermann, Leipzig/Paul, München/Robin, Jena/Johann
- Hearth Elemental = Lagerfeuer im Garten in Jena
- Vibrant Outburst = Seifenblasenkanone
- Sazh's Chocobo = Der ETF-Sparplan
- Meltstrider's Resolve = LoL, Runde 20 (V4 = „John Wolv“)

**Länder**

| Karte | Ort |
|---|---|
| Forest | Garten in Jena |
| Island | Mallorca (JGA) |
| Mountain | Alpenpass |
| Riverpyre Verge | Saaleufer |
| Steam Vents | Johanns Sauna |
| Spirebluff Canal | Kroatische Küste |
| Multiversal Passage | WhatsApp-Gruppe (Tasse) |
| Fabled Passage | A9 München–Jena |
| Elven Passage | Flughafen Palma |
| Demolition Field | Das Baugutachten |
| Escape Tunnel | Der Weg zum Pool |

## Stand und nächste Schritte (03.11.2026)

**Fertig:** Deckwahl, Pool, Deckabgleich, Flavortexte, Planungstabelle, Türchenplan, alle 150 Bilder (abgenommen), Kartensatz im MSE (153 Karten), Druckdaten der Vorderseiten, Packliste.

**Stand 03.11. abends:** Rückseite, Fortschrittsleiste, Spielmarken, Sonder- und Ersatzkarten sind fertig. Die Druckdaten haben genau 180 Karten, die Prüfung ist grün.

**Offen** (Details und Zeitplan in `Projektstand.md`):
1. **MPC-Bestellung bis Fr 06.11.** (spätestens Mo 09.11.), nach `Druck/Bestellanleitung.md`. Hermann bestellt selbst.
2. **Kalender/Display-Box** besorgen (Bastelladen) und Ummantelung gestalten, dazu **Boosterhüllen** (falt- und klebbar). In Druck geben bis etwa 13.11.
3. **Bau-Sheets** für Tür 17 und Tür 24 (dabei festlegen, welche 12 Hauptdeck-Karten für „mit Gutachter“ rausgehen), Münz-Legende, Kleinigkeit 2 für Tür 23.
4. Packen am 21./22.11., Versand nach München am Mo 23.11.
5. **Vor dem Verschenken:** Testspiel, Mischtest, Humor-Blindtest.

## Technische Hinweise

- Windows. **PowerShell** ist die Hauptsprache der Werkzeuge. Python 3.14 ist inzwischen installiert (`py`), wird aber nur vom Skill `grafikdesign` (Entwürfe rendern) genutzt.
- **In PowerShell ist `R` ein Alias für Invoke-History.** Eigene Funktionen nie `R` nennen.
- **PowerShell unterscheidet bei Variablen nicht zwischen Groß- und Kleinschreibung:** `$h` und `$H` sind dieselbe Variable.
- **Skripte mit Umlauten als UTF-8 mit BOM speichern.** Windows PowerShell 5.1 liest Dateien ohne BOM als ANSI, dann kommt es zu Parserfehlern oder verstümmelten Prompts.
- CSVs mit Umlauten immer mit `-Encoding UTF8` einlesen.
- Übersichtsbögen mit Vorschaubildern lassen sich per PowerShell mit `System.Drawing` erzeugen (oder `kontaktbogen.ps1` aus dem Skill `grafikdesign`).
- Robins RAW-Datei (NEF) lässt sich über `System.Windows.Media.Imaging` (WIC) in JPG umwandeln.
- Die Scryfall-API (`/cards/collection`, `/cards/named`) ist per `Invoke-RestMethod` erreichbar.
- MTGGoldfish-Downloads blockiert Cloudflare. Decklisten-Durchschnitte stammen von decklistdata.com bzw. den Archetyp-Seiten von MTGGoldfish.
- **OpenAI-API-Key** ist nur 7 Tage gültig. Vor neuen Bildern `ki_bild.ps1 -Pruefen` (Skill `grafikdesign`) laufen lassen. Der Key steht als `OPEN_API_KEY` (Tippfehler) in den Benutzervariablen, die Skripte akzeptieren auch `OPENAI_API_KEY`.
- Magic Set Editor liegt unter `../MagicSetEditor/` (Full-Magic-Pack), die Schriften Beleren, MPlantin und Matrix sind für den Benutzer installiert.
