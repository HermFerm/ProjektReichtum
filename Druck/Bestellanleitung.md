# Bestellanleitung MakePlayingCards (MPC)

Stand 03.11.2026. Ziel: **Bestellung bis Fr 06.11. (spätestens Mo 09.11.), Versand Express.**
Punkte, die ich (Claude) nur aus der Recherche kenne und nicht im Shop gesehen habe, sind mit ⚠ markiert. Dort bitte genau hinschauen.

## 0. Vorher

1. Prüfung laufen lassen. Ganz unten muss „Alles in Ordnung.“ stehen:
   `powershell -ExecutionPolicy Bypass -File Werkzeuge\Pruefung.ps1`
2. Dateien bereitlegen. Es sind **zwei Decks** mit derselben Rückseite (ENTSCHIEDEN 04.11.):
   - **Deck 1 „normal“:** `Druck/vorderseiten/`, **144 PNG**
   - **Deck 2 „Holo“:** `Druck/holo/`, **36 PNG**: eine besondere Karte pro Booster (Tür 1–24), alle 14 Spielmarken und die Titelkarte
   - `Druck/rueckseite.png`: eine Rückseite für beide Decks
   - Format jeweils 822 × 1122 px bei 300 dpi. Das ist genau die MPC-Vorlage für 63,5 × 88,9 mm mit Beschnitt.
   - Zusammen 180 Karten: 150 Karten, 3 Saga-Beilegkarten, 14 Spielmarken, 5 Titel-/Trennkarten, 8 Ersatzkarten.

Die Schritte 1–5 machst du **zweimal**, einmal pro Deck. Beide Decks kommen in denselben Warenkorb.

## 1. Produkt wählen

- Seite: makeplayingcards.com → Custom Game Cards → **„Blank Cards – Traditional size (63.5 × 88.9 mm)“**
  (Direktlink laut Recherche: `makeplayingcards.com/design/custom-blank-card-traditional-size.html`) ⚠
- Nicht das Produkt „63 × 88 mm“ nehmen. Dessen Vorlage hat andere Pixelmaße.

## 2. Optionen

| Option | Auswahl | Warum |
|---|---|---|
| Kartenkarton | **S33 Superior Smooth** (schwarzer Kern) | Kommt Magic-Karten am nächsten. Der schwarze Kern macht die Karte blickdicht. |
| Anzahl | Deck 1: **144 Karten**, Deck 2: **36 Karten**, je 1 Deck | Beide Stufen sind genau voll. |
| Druck | Deck 1: beidseitig farbig. Deck 2: **„Holographic foil (front)“** (Preis laut Konfigurator 30,65 €) | Holo nur vorne, die Rückseite bleibt gleich |
| Oberfläche | Standard/glatt, **kein Leinen (Linen)** | Leinen fühlt sich wie Pokerkarten an |
| Ecken | abgerundet (Standard) | |
| Verpackung | die günstigste (z. B. Folie) | Die Karten wandern ohnehin in die Booster. |

## 3. Vorderseiten hochladen

1. Für die Vorderseite **„unterschiedliche Bilder“** wählen ⚠
2. Deck 1: alle 144 Dateien aus `Druck/vorderseiten/` auf einmal markieren und hochladen. Deck 2: die 36 aus `Druck/holo/`. Sie dürfen automatisch auf die Plätze verteilt werden. Die Reihenfolge ist egal, denn das Sortieren übernimmt die Packliste.
3. Kontrollieren:
   - Jedes Bild ist **genau einmal** belegt, also 144 bzw. 36, kein Platz bleibt leer.
   - Beim Holo-Deck wirklich „Holographic (front)“ gewählt, nicht „front & back“.
   - Bei der Bildeinpassung **nichts zuschneiden oder zoomen** lassen („Fit“ statt „Fill“, falls gefragt) ⚠

## 4. Rückseite hochladen

- **„Gleiches Bild für alle Rückseiten“** wählen und `Druck/rueckseite.png` hochladen ⚠

## 5. Vorschau prüfen (5 Minuten, lohnt sich)

Stichprobe ansehen, die Schnittlinie wird im Editor angezeigt:
- eine normale Karte, z. B. `18_Sunderflock_1`: Die Schnittlinie liegt im schwarzen Rand, kein Text wird abgeschnitten.
- ein Vollbild-Land, z. B. `01_Forest_9`: Der Name oben ist komplett sichtbar.
- eine Spielmarke, z. B. `17_Token-Treefolk_1`
- eine Trennkarte, z. B. `17_Trennkarte-Betongold_1`: Der Linienrahmen liegt innerhalb der Schnittlinie.
- die Rückseite: Rahmen ringsum gleichmäßig.

## 6. Warenkorb und Versand

- Versand: **Express** (laut MPC 3 Tage Fertigung + 2–3 Tage Transport). Standard ist für unseren Termin zu knapp.
- Erwartete Kosten: Deck 1 (144, S33) grob 40–45 $ (geschätzt aus der Preisstaffel) plus Holo-Deck 30,65 € plus Express-Versand. Steuern/Zoll für DE im Warenkorb prüfen ⚠
- Ob die Holo-Fertigung länger dauert, zeigt der Warenkorb bzw. das Lieferdatum. Liegt es nach dem 20.11., melde dich, dann überlegen wir, ob wir auf Holo verzichten.
- Lieferadresse: zu dir. Packen und Versand an Robin übernimmst du.

## 7. Nach der Bestellung

- Datum und Bestellnummer in `Projektstand.md` eintragen, Sendungsnummer notieren.
- **E-Mails von MPC täglich prüfen**, auch den Spam-Ordner. Eine Rückfrage oder Ablehnung kommt per Mail, und jeder Tag zählt.
- Kommt eine **Ablehnung wegen Urheberrecht**, freundlich antworten (MPC schreibt auf Englisch):

  > Hello, these are fan-made custom cards for a private, non-commercial Christmas gift for a friend.
  > All artwork, card names, the set symbol and the card back are original; no official logos, set symbols,
  > copyright lines or card backs are used. The cards will not be sold. Could you please release the order?
  > Thank you!

  Hilft das nicht innerhalb von 1–2 Tagen: stornieren und **Plan B PrinterStudio.de** (gleiches System, Euro, Steuern inklusive, gleiche Dateien, Karton „Super“ ≈ S33).
  Wenn es ganz knapp wird: MeinSpiel.de (Deutschland, 3–7 Werktage, aber Spielkartenkarton mit runderen Ecken).

## 8. Wenn die Karten da sind

- Zählen (144 + 36) und mit `Druck/Packliste.csv` nach Türen sortieren. Die Spalte „Tür“ sagt, wohin jede Karte gehört, die Spalte „Druck“, ob sie aus dem Holo-Deck kommt.
- Die Holo-Karte jedes Boosters am besten als **letzte Karte** in den Booster legen, wie bei echten Boostern.
- Die Ersatzkarten erkennst du an der kleinen Aufschrift „ERSATZ“ unten im schwarzen Rand. Sie gehören ins „Ersatzteillager“ in Tür 17.
- Mischtest: Rückseiten von 10 zufälligen Karten vergleichen. Sie müssen gleich aussehen.
