# Prüfung vor dem Druck:
#   1. Decks: 60 Karten je Variante, Sideboard 12, höchstens 4 gleiche (Grundländer ausgenommen, Landfall inkl. Sideboard)
#   2. Scryfall frisch laden: Oracle-Änderungen seit dem Cache (Daten/scryfall.json) und Standard-Legalität
#   3. Kartensatz (Karten/Projekt-Reichtum.mse-set) Feld für Feld gegen die frischen Oracle-Daten:
#      Regeltext, Manakosten, Typzeile, Stärke/Widerstand, Abenteuer-/Saga-Seiten
#   4. Druckdaten: Anzahl und Format der Vorderseiten, Rückseite vorhanden
# Aufruf: powershell -ExecutionPolicy Bypass -File Werkzeuge\Pruefung.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path $PSScriptRoot -Parent
$fehler = New-Object System.Collections.ArrayList
function Fehler($t) { [void]$script:fehler.Add($t); Write-Host "  FEHLER: $t" -ForegroundColor Red }
function OK($t) { Write-Host "  ok: $t" -ForegroundColor Green }
$grundland = 'Forest', 'Island', 'Mountain'

# ---------- 1. Decks
Write-Host "`n1. Decks"
$rows = Import-Csv "$root\Planungstabelle.csv" -Delimiter ';' -Encoding UTF8
$varianten = [ordered]@{
  'Izzet Prowess'       = @('Prowess+Spellementals', 'Prowess')
  'Izzet Spellementals' = @('Prowess+Spellementals', 'Spellementals')
  'Landfall Standard'   = @('Landfall Stock+Anti-Izzet')
}
foreach ($v in $varianten.Keys) {
  $k = @($rows | Where-Object { $_.Deck -in $varianten[$v] })
  if ($k.Count -eq 60) { OK "$v hat 60 Karten" } else { Fehler "$v hat $($k.Count) Karten statt 60" }
  foreach ($g in ($k | Where-Object { $_.Karte -notin $grundland } | Group-Object Karte | Where-Object Count -gt 4)) { Fehler "$v enthält $($g.Count) × $($g.Name)" }
}
$sb = @($rows | Where-Object Deck -eq 'Anti-Izzet')
if ($sb.Count -eq 12) { OK 'Landfall-Sideboard hat 12 Karten' } else { Fehler "Sideboard hat $($sb.Count) statt 12 Karten" }
$lf = @($rows | Where-Object { $_.Deck -in 'Landfall Stock+Anti-Izzet', 'Anti-Izzet' })
$zuViel = @($lf | Where-Object { $_.Karte -notin $grundland } | Group-Object Karte | Where-Object Count -gt 4)
if ($zuViel) { foreach ($g in $zuViel) { Fehler "Landfall + Sideboard: $($g.Count) × $($g.Name)" } } else { OK 'Landfall + Sideboard: keine Karte öfter als 4-mal' }
if ($rows.Count -eq 150) { OK 'Pool hat 150 Karten' } else { Fehler "Pool hat $($rows.Count) Karten" }

# ---------- 2. Scryfall frisch
Write-Host "`n2. Scryfall (frisch geladen)"
$h = @{ 'User-Agent' = 'ProjektReichtum/1.0'; 'Accept' = 'application/json' }
$namen = @($rows.Karte | Select-Object -Unique)
$body = @{ identifiers = @($namen | ForEach-Object { @{ name = $_ } }) } | ConvertTo-Json -Depth 4
$r = Invoke-RestMethod 'https://api.scryfall.com/cards/collection' -Method Post -Headers $h -ContentType 'application/json' -Body ([Text.Encoding]::UTF8.GetBytes($body))
if ($r.not_found) { Fehler "Scryfall kennt nicht: $($r.not_found | ConvertTo-Json -Compress)" }
$frisch = @{}; foreach ($c in $r.data) { $frisch[$c.name] = $c; foreach ($f in $c.card_faces) { $frisch[$f.name] = $c } }
$cache = @{}; foreach ($c in (Get-Content "$root\Daten\scryfall.json" -Encoding UTF8 -Raw | ConvertFrom-Json)) { $cache[$c.name] = $c }
function Kern($c) {
  # vergleichbare Oracle-Felder einer Karte (inkl. Seiten) als Text
  $teile = @($c.oracle_text, $c.mana_cost, $c.type_line, $c.power, $c.toughness)
  foreach ($f in $c.card_faces) { $teile += $f.oracle_text, $f.mana_cost, $f.type_line, $f.power, $f.toughness }
  ($teile | ForEach-Object { "$_" }) -join '|'
}
$geaendert = 0
foreach ($c in $r.data) {
  if ($c.legalities.standard -ne 'legal') { Fehler "$($c.name) ist in Standard '$($c.legalities.standard)'" }
  if (-not $cache.ContainsKey($c.name)) { Fehler "$($c.name) fehlt im Cache"; continue }
  if ((Kern $c) -ne (Kern $cache[$c.name])) { $geaendert++; Fehler "$($c.name): Oracle-Daten haben sich seit dem Cache geändert -> MSE-Set-erzeugen.ps1 -Aktualisieren" }
}
if (-not ($fehler | Where-Object { $_ -match 'Standard' })) { OK "alle $($r.data.Count) Karten sind Standard-legal" }
if ($geaendert -eq 0) { OK 'keine Oracle-Änderungen seit dem Cache' }

# ---------- 3. Kartensatz gegen Oracle
Write-Host "`n3. Kartensatz gegen Oracle"
function ConvertTo-Sym([string]$t) { [regex]::Replace($t, '(\{[^}]+\})+', { param($m) '<sym>' + ($m.Value -replace '[{}]', '') + '</sym>' }) }
function Typ($super, $sub) { if ($sub) { "$super — $sub" } else { $super } }
$tmp = Join-Path $env:TEMP 'ProjektReichtum-pruefung'
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$root\Karten\Projekt-Reichtum.mse-set" "$tmp.zip" -Force
Expand-Archive "$tmp.zip" $tmp -Force; Remove-Item "$tmp.zip"
# Set-Datei lesen: Karten beginnen mit "card:", Felder mit einem Tab, mehrzeilige Werte mit zwei Tabs
$karten = @(); $akt = $null; $feld = $null
foreach ($z in [IO.File]::ReadAllLines("$tmp\set", [Text.Encoding]::UTF8)) {
  if ($z -eq 'card:') { if ($akt) { $karten += $akt }; $akt = @{}; $feld = $null; continue }
  if (-not $akt) { continue }
  if ($z -match '^\t([^\t:][^:]*):\s?(.*)$') { $feld = $matches[1]; $akt[$feld] = $matches[2]; continue }
  if ($z -match '^\t\t(.*)$' -and $feld) { $akt[$feld] = $(if ($akt[$feld]) { $akt[$feld] + "`n" + $matches[1] } else { $matches[1] }); continue }
  if ($z -notmatch '^\t') { if ($akt) { $karten += $akt }; $akt = $null }
}
if ($akt) { $karten += $akt }
$geprueft = 0
foreach ($k in $karten) {
  $id = $k['notes']; $alias = $k['alias']
  if ($k['stylesheet'] -eq 'm15-token' -or -not $alias -or $alias -in $grundland) { continue }
  $c = $frisch[$alias]
  if (-not $c) { Fehler "$id`: keine Oracle-Daten für '$alias'"; continue }
  $soll = @{}
  if ($id -match '_Rueckseite$') {
    $f = $c.card_faces[1]; $t = $f.type_line -split ' — ', 2
    $soll['rule text'] = ConvertTo-Sym (($f.oracle_text -split "`n")[0])
    $kap = [regex]::Matches($f.oracle_text, '(?m)^(I+V?|IV|V)\s+—\s+(.+)$')
    for ($i = 0; $i -lt $kap.Count; $i++) { $soll["level $($i + 1) text"] = ConvertTo-Sym $kap[$i].Groups[2].Value }
    $soll['typ'] = $f.type_line; $soll['power'] = $f.power; $soll['toughness'] = $f.toughness
  } elseif ($c.layout -in 'adventure', 'prepare', 'transform') {
    $f = $c.card_faces[0]
    $soll['rule text'] = ConvertTo-Sym $f.oracle_text; $soll['casting cost'] = $f.mana_cost -replace '[{}]', ''
    $soll['typ'] = $f.type_line; $soll['power'] = $f.power; $soll['toughness'] = $f.toughness
    if ($c.layout -ne 'transform') {
      $f2 = $c.card_faces[1]
      $soll['name 2'] = $f2.name; $soll['rule text 2'] = ConvertTo-Sym $f2.oracle_text; $soll['casting cost 2'] = $f2.mana_cost -replace '[{}]', ''
      $soll['typ 2'] = $f2.type_line
    }
  } else {
    $soll['rule text'] = ConvertTo-Sym $c.oracle_text; $soll['casting cost'] = $c.mana_cost -replace '[{}]', ''
    $soll['typ'] = $c.type_line; $soll['power'] = $c.power; $soll['toughness'] = $c.toughness
  }
  $ist = @{}
  foreach ($key in $soll.Keys) { $ist[$key] = $k[$key] }
  $ist['typ'] = Typ $k['super type'] $k['sub type']
  if ($soll.ContainsKey('typ 2')) { $ist['typ 2'] = Typ $k['super type 2'] $k['sub type 2'] }
  foreach ($key in $soll.Keys) {
    $a = "$($soll[$key])".Trim(); $b = "$($ist[$key])".Trim()
    if ($a -ne $b) { Fehler "$id [$key]`n      Scryfall: $a`n      Karte:    $b" }
  }
  $geprueft++
}
OK "$geprueft Karten verglichen (ohne Grundländer und Spielmarken)"
$fl = @($karten | Where-Object { $_['flavor text'] -and ($_['flavor text'] -replace '<[^>]+>', '').Length -gt 0 }).Count
Write-Host "  Info: $($karten.Count) Karten im Set, davon $fl mit Flavortext"

# ---------- 4. Druckdaten
Write-Host "`n4. Druckdaten"
# Zwei MPC-Decks (ENTSCHIEDEN 04.11.): normal 144 Karten, Holo („Holographic foil (front)“) 36 Karten
$normal = @(Get-ChildItem "$root\Druck\vorderseiten" -Filter *.png)
$holo = @(Get-ChildItem "$root\Druck\holo" -Filter *.png -ErrorAction SilentlyContinue)
$vs = $normal + $holo
$sonder = @(Get-ChildItem "$root\Karten\sonder" -Filter *.png -ErrorAction SilentlyContinue).Count
$ersatz = @($vs | Where-Object { $_.BaseName -match '_Ersatz$' }).Count
$soll = $karten.Count + $sonder + $ersatz
if ($vs.Count -eq $soll) { OK "$($vs.Count) Vorderseiten = $($karten.Count) aus dem Set + $sonder Sonderkarten + $ersatz Ersatzkarten" } else { Fehler "$($vs.Count) Vorderseiten, erwartet $soll" }
if ($normal.Count -eq 144) { OK 'normales Deck: 144 Karten (MPC-Stufe bis 144 voll)' } else { Fehler "normales Deck hat $($normal.Count) statt 144 Karten" }
if ($holo.Count -eq 36) { OK 'Holo-Deck: 36 Karten (MPC-Stufe bis 36 voll)' } else { Fehler "Holo-Deck hat $($holo.Count) statt 36 Karten" }
$doppelt = @($holo | Where-Object { Test-Path (Join-Path "$root\Druck\vorderseiten" $_.Name) })
if ($doppelt) { Fehler "in beiden Decks: $($doppelt.Name -join ', ')" } else { OK 'keine Karte in beiden Decks' }
$ohneHolo = @(Import-Csv "$root\Planungstabelle.csv" -Delimiter ';' -Encoding UTF8 | Where-Object { [int]$_.'Tür' -gt 1 } | ForEach-Object { [int]$_.'Tür' } | Select-Object -Unique |
  Where-Object { $t = '{0:D2}_' -f $_; -not ($holo | Where-Object { $_.Name.StartsWith($t) -and $_.Name -notmatch 'Token|Titelkarte|Trennkarte' }) })
if ($ohneHolo) { Fehler "Booster ohne Holo-Karte: Tür $($ohneHolo -join ', ')" } else { OK 'jeder Booster hat eine Holo-Karte' }
$falsch = 0
foreach ($f in $vs + @(Get-Item "$root\Druck\rueckseite.png" -ErrorAction SilentlyContinue)) {
  if (-not $f) { continue }
  $b = [System.Drawing.Image]::FromFile($f.FullName)
  if ($b.Width -ne 822 -or $b.Height -ne 1122 -or [math]::Round($b.HorizontalResolution) -ne 300) { $falsch++; Fehler "$($f.Name): $($b.Width)×$($b.Height) @ $($b.HorizontalResolution) dpi" }
  $b.Dispose()
}
if (Test-Path "$root\Druck\rueckseite.png") { OK 'Rückseite vorhanden' } else { Fehler 'Druck/rueckseite.png fehlt' }
if ($falsch -eq 0) { OK 'alle Druckbilder 822 × 1122 px, 300 dpi' }

Write-Host ''
if ($fehler.Count) { Write-Host "$($fehler.Count) Fehler." -ForegroundColor Red; exit 1 } else { Write-Host 'Alles in Ordnung.' -ForegroundColor Green }
