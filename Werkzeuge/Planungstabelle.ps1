# Erzeugt Planungstabelle.csv und Tuerchenplan.md aus Kartenpool.csv, Flavortexte.md und Bildauftraege.md.
# Die Verteilung ist deterministisch: gleiche Eingaben ergeben dieselbe Tabelle.
# Aufruf: powershell -ExecutionPolicy Bypass -File Werkzeuge\Planungstabelle.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$de = [cultureinfo]'de-DE'

$pool = Import-Csv "$root\Kartenpool.csv" -Delimiter ';' -Encoding UTF8

# --- Flavortexte: Schlüssel "Karte|Exemplar"
$flavor = @{}
$cur = $null
foreach ($l in Get-Content "$root\Flavortexte.md" -Encoding UTF8) {
  if ($l -match '^## Entscheidungen') { break }
  if ($l -match '^\*\*(.+?)\*\* – \*(.+?)\*(.*)\[\d+\]') {
    $cur = @{ Name = $matches[1]; Karte = $matches[2]; FixEx = $null }
    if ($matches[3] -match 'Exemplar (\d+)') { $cur.FixEx = [int]$matches[1] }
    continue
  }
  if ($cur -and $l -match '^(\d+)\. (?:\*\((.+?)\)\* )?(.+)$') {
    $ex = if ($cur.FixEx) { $cur.FixEx } else { [int]$matches[1] }
    $flavor["$($cur.Karte)|$ex"] = @{ Name = $cur.Name; Label = $matches[2]; Text = $matches[3] }
  }
}

# --- Motive der Vollbild-Grundländer
$motiv = @{ 'Mountain|1' = 'Rennradtour über die Alpen (Gruppe/Alpen-Rennrad/Robin-Paul__IMG-20260606-WA0012.jpg)' }
$curB = $null
foreach ($l in Get-Content "$root\Bildauftraege.md" -Encoding UTF8) {
  if ($l -match '^\*\*(Forest|Island|Mountain) = ') { $curB = $matches[1]; continue }
  if ($l -match '^(---|## )') { $curB = $null; continue }
  if ($curB -and $l -match '^\| (\d+) \| `([^`]+)` \| (.+?) \|$') {
    $motiv["$curB|$($matches[1])"] = "$($matches[3]) ($($matches[2]))"
  }
}

# --- Exemplare. Phase 1 = Länderpaket, A = Duell 1 (Tür 2–16), B = Module und Sideboard
$copies = New-Object System.Collections.ArrayList
foreach ($p in $pool) {
  $phase = if ($p.Typ -eq 'Basic Land') { '1' } elseif ($p.Gruppe -in 'Modul Spellementals', 'Landfall Sideboard') { 'B' } else { 'A' }
  $farbe = if ($p.Gruppe -like 'Landfall*') { 'G' } else { 'I' }
  for ($i = 0; $i -lt [int]$p.Anzahl; $i++) {
    [void]$copies.Add([pscustomobject]@{ Karte = $p.Karte; Ex = 0; Gruppe = $p.Gruppe; Deck = $p.Varianten
        Person = $p.Person; Flavorname = $p.Flavorname; Idee = $p.'Warum die Mechanik passt / Flavor-Idee'
        Phase = $phase; Farbe = $farbe; Tuer = $(if ($phase -eq '1') { 1 } else { 0 }); FixEx = $null })
  }
}

# --- Kontingent pro Tür: I = Izzet-Karten, G = grüne Karten
$quota = @{}
foreach ($d in 2..16) { $quota[$d] = @{ I = 4; G = 3 } }
foreach ($d in 3, 8, 10, 15) { $quota[$d] = @{ I = 3; G = 3 } }
foreach ($d in 7, 14) { $quota[$d] = @{ I = 3; G = 4 } }
$quota[18] = @{ I = 3; G = 3 }; $quota[19] = @{ I = 4; G = 2 }; $quota[21] = @{ I = 3; G = 3 }
$quota[22] = @{ I = 4; G = 2 }; $quota[24] = @{ I = 4; G = 2 }

# --- Besondere Tage: feste Setzungen (Ex = feste Exemplarnummer, sonst nach Türreihenfolge)
$doorsB = @(18, 19, 21, 22, 24)
$themen = @{ 6 = 'Nikolaus: Robins Stiefel'; 24 = 'Heiligabend: alle zusammen' }
$fixes = @(
  # Nikolaus (So 06.12.): nur Robin-Karten, dazu das einzige Stock Up als „Geschenk“
  @{ Tuer = 6; Karte = 'Stock Up' }, @{ Tuer = 6; Karte = 'Impractical Joke'; Ex = 2 },
  @{ Tuer = 6; Karte = 'Elusive Otter' }, @{ Tuer = 6; Karte = 'Opt' },
  @{ Tuer = 6; Karte = 'Mightform Harmonizer' }, @{ Tuer = 6; Karte = 'Llanowar Elves' }, @{ Tuer = 6; Karte = "Sazh's Chocobo" },
  # Heiligabend (Do 24.12.): Karten, auf denen die Gruppe zusammen ist
  @{ Tuer = 24; Karte = 'Sunderflock'; Ex = 4 }, @{ Tuer = 24; Karte = 'Hearth Elemental'; Ex = 4 },
  @{ Tuer = 24; Karte = 'Prismari Charm'; Ex = 4 }, @{ Tuer = 24; Karte = 'Colorstorm Stallion'; Ex = 3 },
  @{ Tuer = 24; Karte = 'Lumbering Worldwagon' }, @{ Tuer = 24; Karte = "Meltstrider's Resolve"; Ex = 4 }
)
foreach ($f in $fixes) {
  $ph = if ($f.Tuer -in $doorsB) { 'B' } else { 'A' }
  $c = $copies | Where-Object { $_.Karte -eq $f.Karte -and $_.Phase -eq $ph -and $_.Tuer -eq 0 } | Select-Object -First 1
  if (-not $c) { throw "Feste Setzung nicht möglich: $($f.Karte) in Tür $($f.Tuer)" }
  $c.Tuer = $f.Tuer; $c.FixEx = $f.Ex; $quota[$f.Tuer][$c.Farbe]--
  if ($quota[$f.Tuer][$c.Farbe] -lt 0) { throw "Tür $($f.Tuer) ist überbucht ($($c.Farbe))" }
}

function Test-Belegt($tuer, $karte) {
  @($copies | Where-Object { $_.Tuer -eq $tuer -and $_.Karte -eq $karte }).Count -gt 0
}

# Wie viele Karten in Tür $tuer lagen schon in einer anderen Tür mit $karte zusammen?
function Get-Overlap($tuer, $karte) {
  $mit = @($copies | Where-Object { $_.Karte -eq $karte -and $_.Tuer -gt 1 } | ForEach-Object { $_.Tuer })
  if (-not $mit) { return 0 }
  $partner = @($copies | Where-Object { $_.Tuer -in $mit -and $_.Karte -ne $karte } | ForEach-Object { $_.Karte })
  @($copies | Where-Object { $_.Tuer -eq $tuer -and $_.Karte -in $partner }).Count
}

# Jede Karte wird gleichmäßig über die Türen ihrer Phase gestreut (Abstand n/k),
# der Startpunkt rückt pro Karte um den goldenen Schnitt weiter.
# Unter den freien Türen gewinnt die mit dem kleinsten Wert aus Abstand zum Ziel + Wiederholungen.
function Verteile($phase, $doors) {
  $n = $doors.Count
  $offset = 0.0
  # Reihenfolge: viele Exemplare zuerst (fest gesetzte mitgezählt), bei Gleichstand die schon eingeschränkten
  $gruppen = $copies | Where-Object { $_.Phase -eq $phase -and $_.Tuer -eq 0 } | Group-Object Karte |
    Sort-Object @{ e = { $k = $_.Name; @($copies | Where-Object { $_.Phase -eq $phase -and $_.Karte -eq $k }).Count }; Descending = $true },
      @{ e = { $k = $_.Name; @($copies | Where-Object { $_.Karte -eq $k -and $_.Tuer -ne 0 }).Count }; Descending = $true }, Name
  foreach ($g in $gruppen) {
    $k = $g.Count
    for ($i = 0; $i -lt $k; $i++) {
      $c = $g.Group[$i]
      $target = ($offset + $i * $n / $k) % $n
      $kandidaten = for ($idx = 0; $idx -lt $n; $idx++) {
        $d = $doors[$idx]
        if ($quota[$d][$c.Farbe] -le 0 -or (Test-Belegt $d $c.Karte)) { continue }
        $ov = Get-Overlap $d $c.Karte
        if ($n -le 5) {
          # Wenige Türen: die mit dem meisten freien Platz zuerst, sonst geht die Rechnung am Ende nicht auf
          $score = -10 * $quota[$d][$c.Farbe] + $ov
        } else {
          $dist = [math]::Abs($idx - $target); $dist = [math]::Min($dist, $n - $dist)
          $score = $dist + 1.5 * $ov
        }
        [pscustomobject]@{ Tuer = $d; Score = $score }
      }
      $best = ($kandidaten | Sort-Object Score, Tuer | Select-Object -First 1).Tuer
      if (-not $best) { throw "Keine freie Tür für $($c.Karte)" }
      $c.Tuer = $best; $quota[$best][$c.Farbe]--
    }
    $offset = ($offset + 0.618 * $n) % $n
  }
}
Verteile 'A' (2..16)
Verteile 'B' $doorsB

# --- Exemplarnummer steigt mit der Tür; feste Nummern aus $fixes bleiben reserviert
foreach ($g in $copies | Group-Object Karte) {
  $frei = @(1..$g.Count | Where-Object { $_ -notin @($g.Group | ForEach-Object { $_.FixEx }) })
  $i = 0
  foreach ($c in $g.Group | Where-Object { -not $_.FixEx } | Sort-Object Tuer) { $c.Ex = $frei[$i]; $i++ }
  foreach ($c in $g.Group | Where-Object { $_.FixEx }) { $c.Ex = $c.FixEx }
}

$personEx = @{ 'Impractical Joke|1' = 'Johann'; 'Impractical Joke|2' = 'Robin'
  'Earthbender Ascension|1' = 'Hermann'; 'Earthbender Ascension|2' = 'Paul'
  'Earthbender Ascension|3' = 'Robin'; 'Earthbender Ascension|4' = 'Johann' }

$rows = foreach ($c in $copies | Sort-Object Tuer, @{ e = { $_.Farbe }; Descending = $true }, Karte, Ex) {
  $key = "$($c.Karte)|$($c.Ex)"
  $f = $flavor[$key]
  if ($c.Phase -ne '1' -and -not $f) { throw "Kein Flavortext für $key" }
  $insider = if ($c.Phase -eq '1') { $motiv[$key] } elseif ($f.Label) { $f.Label } else { $c.Idee }
  [pscustomobject][ordered]@{
    'Tür'        = $c.Tuer
    'Datum'      = (Get-Date -Year 2026 -Month 12 -Day $c.Tuer).ToString('ddd dd.MM.', $de)
    'Karte'      = $c.Karte
    'Exemplar'   = $c.Ex
    'Flavorname' = $(if ($f) { $f.Name } else { $c.Flavorname })
    'Person'     = $(if ($personEx[$key]) { $personEx[$key] } else { $c.Person })
    'Insider'    = $insider
    'Flavortext' = $(if ($f) { $f.Text } else { '' })
    'Farbe'      = $(if ($c.Farbe -eq 'I') { 'Izzet' } else { 'Grün' })
    'Gruppe'     = $c.Gruppe
    'Deck'       = $c.Deck
    'Bilddatei'  = "Bilder/$($c.Karte)_$($c.Ex).png"
  }
}

# --- Prüfungen
$fehler = @()
if ($rows.Count -ne 150) { $fehler += "Anzahl $($rows.Count) statt 150" }
foreach ($g in $rows | Group-Object Karte) { if ($g.Count -gt 4 -and $g.Name -notin 'Forest', 'Island') { $fehler += "$($g.Name) $($g.Count)-mal" } }
foreach ($g in $rows | Where-Object { $_.'Tür' -ne 1 } | Group-Object 'Tür', Karte) { if ($g.Count -gt 1) { $fehler += "doppelt: $($g.Name)" } }
$soll = @{ 1 = 19; 18 = 6; 19 = 6; 21 = 6; 22 = 6; 24 = 6 }
foreach ($d in 2..16) { $soll[$d] = $(if ($d -in 3, 8, 10, 15) { 6 } else { 7 }) }
foreach ($d in $soll.Keys) { $ist = @($rows | Where-Object { $_.'Tür' -eq $d }).Count; if ($ist -ne $soll[$d]) { $fehler += "Tür ${d}: $ist statt $($soll[$d])" } }
foreach ($k in $flavor.Keys) { if (-not ($rows | Where-Object { "$($_.Karte)|$($_.Exemplar)" -eq $k })) { $fehler += "Flavortext ohne Karte: $k" } }
if (($rows | Where-Object { $_.Gruppe -notin 'Modul Spellementals', 'Landfall Sideboard' -and $_.'Tür' -gt 16 }).Count) { $fehler += 'Karte für Duell 1 liegt nach Tür 16' }
if ($fehler) { $fehler | ForEach-Object { Write-Warning $_ }; throw 'Prüfung fehlgeschlagen' }

$rows | Export-Csv "$root\Planungstabelle.csv" -Delimiter ';' -NoTypeInformation -Encoding UTF8

# --- Übersicht pro Tür
$extra = @{
  17 = 'Bau-Sheet Duell 1 (Prowess gegen Landfall) und Hüllen → Spielwochenende 19./20.12.'
  20 = 'Kleinigkeit: personalisierte Spielmarken'
  23 = 'Kleinigkeit 2 (offen)'
}
$md = @('# Türchenplan – Karten pro Tür', '',
  'Automatisch erzeugt von `Werkzeuge/Planungstabelle.ps1` aus `Kartenpool.csv`, `Flavortexte.md` und `Bildauftraege.md`. **Nicht von Hand ändern**, sondern die Quellen ändern und das Skript neu starten.', '')
foreach ($d in 1..24) {
  $datum = (Get-Date -Year 2026 -Month 12 -Day $d).ToString('ddd dd.MM.', $de)
  $karten = @($rows | Where-Object { $_.'Tür' -eq $d })
  if ($karten.Count -eq 0) { $md += "## Tür $d – $datum", '', $extra[$d], ''; continue }
  $i = @($karten | Where-Object { $_.Farbe -eq 'Izzet' }).Count
  $md += "## Tür $d – $datum ($($karten.Count) Karten: $i Izzet, $($karten.Count - $i) Grün)", ''
  if ($themen[$d]) { $md += "**$($themen[$d])**", '' }
  if ($d -eq 1) {
    foreach ($g in $karten | Group-Object Karte) { $md += "- $($g.Count) × $($g.Group[0].Flavorname) ($($g.Name))" }
  } else {
    foreach ($r in $karten) { $md += "- **$($r.Flavorname)** – *$($r.Karte)* #$($r.Exemplar) · $($r.Person)" }
  }
  if ($d -eq 24) { $md += '- dazu: Bau-Sheet mit allen 4 Varianten und Umbau-Anleitung fürs Sideboard' }
  $md += ''
}
$md | Set-Content "$root\Tuerchenplan.md" -Encoding UTF8
# --- Abwechslung in Tür 2–16: wie viele gleiche Karten teilen sich zwei Türen?
# (Tür 18–24 ausgenommen: 30 Karten auf 5 Türen, die 4er-Karten liegen zwangsläufig fast überall.)
$tueren = @($rows | Where-Object { $_.'Tür' -in 2..16 } | Group-Object 'Tür')
$max = 0; $haeufig = 0
for ($a = 0; $a -lt $tueren.Count; $a++) {
  for ($b = $a + 1; $b -lt $tueren.Count; $b++) {
    $gemeinsam = @($tueren[$a].Group.Karte | Where-Object { $_ -in $tueren[$b].Group.Karte }).Count
    if ($gemeinsam -gt $max) { $max = $gemeinsam }
    if ($gemeinsam -ge 3) { $haeufig++ }
  }
}
"OK: $($rows.Count) Karten, Planungstabelle.csv und Tuerchenplan.md geschrieben."
"Abwechslung Tür 2–16: höchstens $max gleiche Karten in zwei Türen, $haeufig Türpaare mit 3 oder mehr."
