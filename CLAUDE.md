# Projekt Reichtum – Übergabe für Claude

Diese Datei liest Claude Code automatisch, wenn es in diesem Ordner gestartet wird. Sie enthält alles, was in den bisherigen Sitzungen (30.10.–02.11.2026) erarbeitet wurde. **Lies zu Beginn jeder Sitzung zusätzlich `Projektstand.md`.**

## Worum es geht

Hermann Ziege (der Nutzer, „der Schenker“) baut für seinen Freund **Robin Reich** einen **Magic-the-Gathering-Adventskalender** mit 24 Türchen für Dezember 2026.

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
- **Matchup-Daten** (decklistdata.com, 29.04.–26.10.2026): Prowess gegen Landfall 49 : 51, Elementals gegen Landfall 53 : 47.
- **Flavor-Name-Prinzip** (wie bei den Godzilla- bzw. Universes-Within-Karten):
  - Eigener Name, eigenes Bild und eigener Flavortext.
  - Der Oracle-Name steht klein darunter.
  - **Regeltext und Schlüsselwörter bleiben exakt wie bei Scryfall.**
- **Türchenplan:**
  - Tür 1: Länderpaket (19 Standardländer mit Gruppenfotos)
  - Tür 2–16: 15 Booster mit 6–7 Karten
  - Tür 17: Bau-Sheet für Duell 1
  - Tür 18–22: Module (ohne Tür 20)
  - Tür 20: Spielmarken
  - Tür 23: Kleinigkeit
  - Tür 24: letzter Booster und Bau-Sheet für alle 4 Varianten

## Dateien

| Datei | Inhalt |
|---|---|
| `Projektstand.md` | **Hauptdokument:** Ziel, Entscheidungen, Deckliste, Türchenplan, Verlauf, nächste Schritte |
| `Kartenpool.csv` | alle 150 Karten mit Person, Flavorname und Begründung, warum die Mechanik passt (Trennzeichen `;`) |
| `Bildprompts.md` | ChatGPT-Stilblock und Prompt pro Karte (V1–V4 bei 4er-Karten) |
| `Bildauftraege.md` | welches Foto in welchen von 7 ChatGPT-Chats für welche Karte/Variante – 150 Bilder |
| `Foto-Wunschliste.md` | Wunschliste und Abgleich: Fotobasis ist vollständig, offen ist nur das echte Seifenblasen-Foto |
| `Fotos/` | sortierte Fotos (siehe unten). Sie sind im privaten Repo `HermFerm/gamedev-studio` (Ordner `gamedesign/TCG/ProjektReichtum`), **außer** `_Videos/`, `_Nicht-verwenden/` und `Sonstiges/`, die nur auf Hermanns erstem Rechner liegen (siehe `.gitignore`). |
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
- **Kinder und Partnerinnen** nur anonymisiert (Silhouette, Text, Gag), nie mit echtem Foto. **Ausnahme: Vicky (Viktoria), Robins Frau**, darf mit echtem Foto vorkommen.
- **Ton:** darf ruhig frech sein, Vicky versteht Spaß.
- **Firmennamen** (PlanOrg, Dedalus, Bugatti) nur im Text, keine Logos. Die Karten sind nur für privaten Gebrauch, nicht zum Verkauf (Fan Content Policy). Sie bekommen eine eigene Rückseite oder kommen in blickdichte Hüllen.
- **In ChatGPT-Prompts „Fantasy-Sammelkartenspiel“ schreiben, nicht „Magic“.** Rahmen und Text kommen später aus dem Kartenprogramm (z. B. Magic Set Editor), nicht aus ChatGPT.
- **Bildformate in ChatGPT:**
  - Kartenbild: 1536 × 1024, quer
  - Vollbild-Land: 1024 × 1536, hochkant
  - Die Auflösung der Ausgangsfotos ist unkritisch, weil ChatGPT das Bild neu erzeugt.
- **Dateien nicht löschen**, ohne dass Hermann es ausdrücklich will (ein Löschversuch wurde abgelehnt).

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
- Impractical Joke (Exemplar 1) = Helge-Schneider-Zitat
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

## Offene Punkte / nächste Schritte

1. **Hermann erzeugt die Bilder in ChatGPT** nach `Bildauftraege.md`. Ablage unter `Bilder/<Karte>_<Exemplar>.png`, Charakterblätter unter `Bilder/_Charakterblatt_<Name>.png`.
2. **Flavortexte schreiben:** pro Exemplar ein eigener Insider, bei 4er-Karten also 4 verschiedene. Grundlage: `Kartenpool.csv` und die Gang-Beschreibung. Das kann Claude parallel erledigen.
3. **Zu bestätigen:** Ist `Fotos/Gruppe/Oktoberfest/IMG-20250920-WA0006.jpg` Robin mit Vicky (für die Wiesn-Ablenkung V2)? Wer ist auf `Fotos/Portraits/IMG_20250601_201027.jpg` (P-6)?
4. **Optional:** das echte Foto der Seifenblasenkanonen von der Hochzeit. Dann wird die Karte neu gestaltet.
5. **Decklisten abgleichen:** Die bisherigen Anzahlen sind aus Durchschnitten gerundet. Vor dem Druck mit je einer aktuellen 5-0-Liste abgleichen, Oracle-Texte per Scryfall-API prüfen.
6. **Produktion:**
   - Magic Set Editor
   - Druck mit 300 dpi
   - Hüllen mit einer echten Karte dahinter
   - eigene Rückseite
   - Spielmarken (3/4-Baumwesen, Stallion-Kopien, +1/+1- und Quest-Zählmarken, Erdbändigen)
7. **Prüfliste vor dem Verschenken:**
   - Oracle-Abgleich
   - 60 Karten je Variante, höchstens 4 gleiche
   - Testspiel durch eine dritte Person
   - Mischtest: Die Karten dürfen sich nicht unterscheiden lassen.
   - Humor-Blindtest an 10 Karten

## Technische Hinweise

- Windows. Python ist **nicht** installiert, für Skripte PowerShell nutzen.
- **In PowerShell ist `R` ein Alias für Invoke-History.** Eigene Funktionen nie `R` nennen.
- CSVs mit Umlauten immer mit `-Encoding UTF8` einlesen.
- Übersichtsbögen mit Vorschaubildern lassen sich per PowerShell mit `System.Drawing` erzeugen.
- Robins RAW-Datei (NEF) lässt sich über `System.Windows.Media.Imaging` (WIC) in JPG umwandeln.
- Die Scryfall-API (`/cards/collection`, `/cards/named`) ist per `Invoke-RestMethod` erreichbar.
- MTGGoldfish-Downloads blockiert Cloudflare. Decklisten-Durchschnitte stammen von decklistdata.com bzw. den Archetyp-Seiten von MTGGoldfish.
