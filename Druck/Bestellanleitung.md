# Bestellanleitung MakePlayingCards (MPC)

Stand 03.11.2026. Ziel: **Bestellung bis Fr 06.11. (spätestens Mo 09.11.), Versand Express.**
Punkte, die ich (Claude) nur aus der Recherche kenne und nicht im Shop gesehen habe, sind mit ⚠ markiert. Dort bitte genau hinschauen.

## 0. Vorher

1. Prüfung laufen lassen. Ganz unten muss „Alles in Ordnung.“ stehen:
   `powershell -ExecutionPolicy Bypass -File Werkzeuge\Pruefung.ps1`
2. Dateien bereitlegen:
   - `Druck/vorderseiten/`: **180 PNG** (150 Karten, 3 Saga-Beilegkarten, 14 Spielmarken, 5 Titel-/Trennkarten, 8 Ersatzkarten)
   - `Druck/rueckseite.png`: eine Rückseite für alle
   - Format jeweils 822 × 1122 px bei 300 dpi. Das ist genau die MPC-Vorlage für 63,5 × 88,9 mm mit Beschnitt.

## 1. Produkt wählen

- Seite: makeplayingcards.com → Custom Game Cards → **„Blank Cards – Traditional size (63.5 × 88.9 mm)“**
  (Direktlink laut Recherche: `makeplayingcards.com/design/custom-blank-card-traditional-size.html`) ⚠
- Nicht das Produkt „63 × 88 mm“ nehmen. Dessen Vorlage hat andere Pixelmaße.

## 2. Optionen

| Option | Auswahl | Warum |
|---|---|---|
| Kartenkarton | **S33 Superior Smooth** (schwarzer Kern) | Kommt Magic-Karten am nächsten. Der schwarze Kern macht die Karte blickdicht. |
| Anzahl | **180 Karten** (Stufe „bis 180“), 1 Deck | Wir haben genau 180. |
| Druck | beidseitig farbig | Vorder- und Rückseite sind bedruckt |
| Oberfläche | Standard/glatt, **kein Leinen (Linen)** | Leinen fühlt sich wie Pokerkarten an |
| Ecken | abgerundet (Standard) | |
| Verpackung | die günstigste (z. B. Folie) | Die Karten wandern ohnehin in die Booster. |

## 3. Vorderseiten hochladen

1. Für die Vorderseite **„unterschiedliche Bilder“** wählen ⚠
2. Alle 180 Dateien aus `Druck/vorderseiten/` auf einmal markieren und hochladen. Sie dürfen automatisch auf die Plätze verteilt werden. Die Reihenfolge ist egal, denn das Sortieren übernimmt die Packliste.
3. Kontrollieren:
   - Jedes Bild ist **genau einmal** belegt, insgesamt 180, kein Platz bleibt leer.
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
- Erwartete Kosten: etwa 48 $ für die Karten plus Express-Versand, grob 50–80 € gesamt. Steuern/Zoll für DE im Warenkorb prüfen ⚠
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

- Zählen (180) und mit `Druck/Packliste.csv` nach Türen sortieren. Die Spalte „Tür“ sagt, wohin jede Karte gehört.
- Die Ersatzkarten erkennst du an der kleinen Aufschrift „ERSATZ“ unten im schwarzen Rand. Sie gehören ins „Ersatzteillager“ in Tür 17.
- Mischtest: Rückseiten von 10 zufälligen Karten vergleichen. Sie müssen gleich aussehen.
