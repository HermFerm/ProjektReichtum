# Erzeugt das Magic-Set-Editor-Set (Karten/Projekt-Reichtum.mse-set) aus Planungstabelle.csv, den Bildern
# und den Oracle-Daten von Scryfall (Cache: Daten/scryfall.json, mit -Aktualisieren neu laden).
# Danach exportiert es alle Karten als PNG nach Karten/png/ (Dateiname = Tür_Karte_Exemplar).
# Aufruf: powershell -ExecutionPolicy Bypass -File Werkzeuge\MSE-Set-erzeugen.ps1 [-Aktualisieren] [-Nur "Opt,Forest"] [-OhneExport]
param([switch]$Aktualisieren, [string[]]$Nur, [switch]$OhneExport)
$ErrorActionPreference = 'Stop'
$Nur = @($Nur | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
Add-Type -AssemblyName System.Drawing
$root = Split-Path $PSScriptRoot -Parent
$mse = Join-Path (Split-Path $root -Parent) 'MagicSetEditor\mse.com'
$illustrator = 'Hermann & KI'

# --- Oracle-Daten (Scryfall), gecacht
$cache = "$root\Daten\scryfall.json"
$rows = Import-Csv "$root\Planungstabelle.csv" -Delimiter ';' -Encoding UTF8
if ($Aktualisieren -or -not (Test-Path $cache)) {
  New-Item -ItemType Directory -Force (Split-Path $cache) | Out-Null
  $h = @{ 'User-Agent' = 'ProjektReichtum/1.0'; 'Accept' = 'application/json' }
  $ids = @($rows.Karte | Select-Object -Unique | ForEach-Object { @{ name = $_ } })
  $body = @{ identifiers = $ids } | ConvertTo-Json -Depth 4
  $r = Invoke-RestMethod 'https://api.scryfall.com/cards/collection' -Method Post -Headers $h -ContentType 'application/json' -Body ([Text.Encoding]::UTF8.GetBytes($body))
  if ($r.not_found) { throw "Scryfall kennt nicht: $($r.not_found | ConvertTo-Json -Compress)" }
  ConvertTo-Json -InputObject @($r.data) -Depth 10 | Set-Content $cache -Encoding UTF8
}
$oracle = @{}
foreach ($c in (Get-Content $cache -Encoding UTF8 -Raw | ConvertFrom-Json)) { $oracle[$c.name] = $c; foreach ($f in $c.card_faces) { if ($c.layout -in 'adventure', 'prepare', 'transform') { $oracle[$f.name] = $c } } }

# --- Text-Helfer
function ConvertTo-Sym([string]$t) {
  # {2}{G} -> <sym>2G</sym>; zusammenhängende Symbole in einem Tag
  [regex]::Replace($t, '(\{[^}]+\})+', { param($m) '<sym>' + ($m.Value -replace '[{}]', '' -replace '/', '/') + '</sym>' })
}
function Get-Kosten([string]$t) { $t -replace '[{}]', '' }
function Get-Block($name, [string]$text, $tabs = 1) {
  $p = "`t" * $tabs
  if (-not $text) { return "$p${name}:" }
  $zeilen = ($text -split "`n")
  if ($zeilen.Count -eq 1) { return "$p${name}: $text" }
  "$p${name}:`n" + (($zeilen | ForEach-Object { "$p`t$_" }) -join "`n")
}
function Split-Typ([string]$typ) {
  $teile = $typ -split ' — ', 2
  @{ super = $teile[0]; sub = $(if ($teile.Count -gt 1) { $teile[1] } else { '' }) }
}
$rar = @{ common = 'common'; uncommon = 'uncommon'; rare = 'rare'; mythic = 'mythic rare'; special = 'special' }

# --- Bildzuschnitt auf das Bildfeld der Vorlage (MSE streckt sonst)
$bildTmp = Join-Path $env:TEMP 'ProjektReichtum-mse'
Remove-Item $bildTmp -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $bildTmp | Out-Null
# $fx/$fy: Lage des Ausschnitts im Bild, 0 = links/oben, 0,5 = mittig, 1 = rechts/unten
function Save-Zuschnitt($quelle, $ziel, [double]$ratio, [int]$maxBreite, [double]$fx = 0.5, [double]$fy = 0.5) {
  $img = [System.Drawing.Image]::FromFile($quelle)
  try {
    $w = $img.Width; $h = $img.Height
    if ($w / $h -gt $ratio) { $cw = [int]($h * $ratio); $ch = $h } else { $cw = $w; $ch = [int]($w / $ratio) }
    $ow = [math]::Min($cw, $maxBreite); $oh = [int]($ow / $ratio)
    $bmp = New-Object System.Drawing.Bitmap -ArgumentList $ow, $oh
    $g = [System.Drawing.Graphics]::FromImage($bmp); $g.InterpolationMode = 'HighQualityBicubic'
    $g.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, $ow, $oh), [int](($w - $cw) * $fx), [int](($h - $ch) * $fy), $cw, $ch, [System.Drawing.GraphicsUnit]::Pixel)
    $bmp.Save($ziel, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
  } finally { $img.Dispose() }
}
$format = @{ normal = 316 / 231; basic = 375 / 523; saga = 152 / 381; token = 317 / 289 }
# Fokus pro Bildformat (Standard) und pro Karte (Schlüssel = notes-ID, z. B. '02_Esper Origins_1_Rueckseite').
# Vollbild-Länder: Ausschnitt ganz oben, damit die Köpfe unter der Namensleiste bleiben (unten ist nur Boden).
# Esper-Rückseiten (schmaler Saga-Streifen): der Geist über dem Kalender ist die Kreatur der Rückseite.
$fokusFormat = @{ basic = @(0.5, 0.0) }
$fokusKarte = @{
  '02_Esper Origins_1_Rueckseite' = @(0.66, 0.5)
  '03_Esper Origins_2_Rueckseite' = @(0.76, 0.5)
  '08_Esper Origins_3_Rueckseite' = @(0.72, 0.5)
}

# Fortschrittsleiste für „Zur erfolgreichen Praxis“ (Earthbender Ascension): 4 Quest-Marken = 4 Meilensteine.
# Wird unten ins Bild gemalt, weil die Textbox voll ist. Auf die Felder lassen sich die Quest-Marken legen.
$meilensteine = @('SEO-Referenzen', 'Vertrieb', 'Werbekampagne', 'REICHTUM!')
$schriften = New-Object System.Drawing.Text.PrivateFontCollection
$schriften.AddFontFile("$env:LOCALAPPDATA\Microsoft\Windows\Fonts\beleren-bold_P1.01.ttf")
function Add-Fortschritt($pfad) {
  $tmpBmp = New-Object System.Drawing.Bitmap -ArgumentList $pfad
  $bmp = New-Object System.Drawing.Bitmap -ArgumentList $tmpBmp; $tmpBmp.Dispose()   # Datei freigeben, damit sie überschrieben werden kann
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
  $bildB = $bmp.Width; $bildH = $bmp.Height
  $lh = [int]($bildH * 0.105); $y0 = $bildH - $lh - [int]($bildH * 0.04); $m = [int]($bildB * 0.035)
  $spitze = [int]($lh * 0.38); $luecke = 6
  $sw = ($bildB - 2 * $m - 3 * $luecke - $spitze) / 4
  $gold = [System.Drawing.Color]::FromArgb(255, 226, 189, 98)
  $rand = New-Object System.Drawing.Pen ($gold, 3)
  $fmt = New-Object System.Drawing.StringFormat; $fmt.Alignment = 'Center'; $fmt.LineAlignment = 'Center'
  # Eine gemeinsame Schriftgröße für alle Felder: so groß, dass der längste Begriff in ein Feld passt
  $platzFeld = $sw - $spitze * 0.55
  $groesse = $lh * 0.46
  do {
    $font = New-Object System.Drawing.Font ($schriften.Families[0], [float]$groesse, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $breiteste = ($meilensteine | ForEach-Object { $g.MeasureString("4 $_", $font).Width } | Measure-Object -Maximum).Maximum
    $groesse -= 1
  } while ($breiteste -gt $platzFeld -and $groesse -gt 10)
  for ($i = 0; $i -lt 4; $i++) {
    $x = $m + $i * ($sw + $luecke)
    $pkt = @(
      (New-Object System.Drawing.PointF $x, $y0), (New-Object System.Drawing.PointF ($x + $sw), $y0),
      (New-Object System.Drawing.PointF ($x + $sw + $spitze), ($y0 + $lh / 2)), (New-Object System.Drawing.PointF ($x + $sw), ($y0 + $lh)),
      (New-Object System.Drawing.PointF $x, ($y0 + $lh)))
    if ($i -gt 0) { $pkt += New-Object System.Drawing.PointF ($x + $spitze), ($y0 + $lh / 2) }
    $letztes = $i -eq 3
    $fuellung = if ($letztes) { New-Object System.Drawing.Drawing2D.LinearGradientBrush ((New-Object System.Drawing.PointF 0, $y0), (New-Object System.Drawing.PointF 0, ($y0 + $lh)), [System.Drawing.Color]::FromArgb(240, 252, 230, 160), [System.Drawing.Color]::FromArgb(240, 190, 140, 45)) }
    else { New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(195, 18, 32, 22)) }
    $g.FillPolygon($fuellung, [System.Drawing.PointF[]]$pkt); $g.DrawPolygon($rand, [System.Drawing.PointF[]]$pkt)
    # Text zwischen Kerbe und Spitze
    $text = "$($i + 1) $($meilensteine[$i])"
    $links = $x + $(if ($i -gt 0) { $spitze * 0.9 } else { 10 }); $rechts = $x + $sw + $spitze * 0.35
    $platz = $rechts - $links
    $farbe = if ($letztes) { [System.Drawing.Color]::FromArgb(255, 70, 42, 6) } else { [System.Drawing.Color]::FromArgb(255, 245, 232, 200) }
    $g.DrawString($text, $font, (New-Object System.Drawing.SolidBrush $farbe), (New-Object System.Drawing.RectangleF $links, $y0, $platz, $lh), $fmt)
  }
  $g.Dispose(); $bmp.Save($pfad, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}

# --- Karten bauen
$karten = New-Object System.Collections.ArrayList
$nr = 0
function Add-Karte($felder, $bild, $bildFormat, $stil) {
  $script:nr++
  $img = "image$($script:nr)"
  $fok = @(0.5, 0.5)
  if ($fokusFormat.ContainsKey($bildFormat)) { $fok = $fokusFormat[$bildFormat] }
  if ($fokusKarte.ContainsKey("$($felder['notes'])")) { $fok = $fokusKarte["$($felder['notes'])"] }
  Save-Zuschnitt (Join-Path $root $bild) (Join-Path $bildTmp $img) $format[$bildFormat] $(if ($bildFormat -eq 'basic') { 1000 } else { 1264 }) $fok[0] $fok[1]
  if ($felder['alias'] -eq 'Earthbender Ascension') { Add-Fortschritt (Join-Path $bildTmp $img) }
  # Kein Hologramm-Oval: es verdeckt bei vollen Textboxen die letzte Zeile
  $z = @('card:', "`thas styling: false", "`tstylesheet: $stil", "`timage: $img", "`tillustrator: $illustrator", "`tcard stamp: none")
  # Karten mit Stärke-Feld: Leerzeile am Ende hält die letzte Textzeile frei vom P/T-Kasten (MSE verkleinert dann die Schrift)
  if ($felder['power'] -and $felder['flavor text'] -and $stil -ne 'm15-token') { $felder['flavor text'] = $felder['flavor text'] + "`n" + [char]0xA0 }
  foreach ($k in @($felder.Keys)) { if ($null -ne $felder[$k] -and "$($felder[$k])" -ne '') { $z += Get-Block $k $felder[$k] } }
  [void]$script:karten.Add(($z -join "`n"))
}

foreach ($r in $rows | Sort-Object { [int]$_.'Tür' }, Karte, { [int]$_.Exemplar }) {
  if ($Nur -and $r.Karte -notin $Nur) { continue }
  $id = '{0:D2}_{1}_{2}' -f [int]$r.'Tür', $r.Karte, $r.Exemplar
  $flavor = if ($r.Flavortext) { "<i-flavor>$($r.Flavortext)</i-flavor>" } else { '' }

  if ($r.Karte -in 'Forest', 'Island', 'Mountain') {
    Add-Karte ([ordered]@{ name = $r.Flavorname; alias = $r.Karte; 'super type' = 'Basic Land'; 'sub type' = $r.Karte; rarity = 'basic land'; notes = $id }) $r.Bilddatei 'basic' 'm15-full-art-basic-land-symbol'
    continue
  }

  $o = $oracle[$r.Karte]
  if (-not $o) { throw "Keine Oracle-Daten für $($r.Karte)" }
  $rarity = $rar[$o.rarity]

  if ($o.layout -in 'adventure', 'prepare') {
    $f1 = $o.card_faces[0]; $f2 = $o.card_faces[1]; $t1 = Split-Typ $f1.type_line; $t2 = Split-Typ $f2.type_line
    Add-Karte ([ordered]@{
        name = $r.Flavorname; alias = $f1.name; 'casting cost' = (Get-Kosten $f1.mana_cost)
        'super type' = $t1.super; 'sub type' = $t1.sub; 'rule text' = (ConvertTo-Sym $f1.oracle_text); 'flavor text' = $flavor
        power = $f1.power; toughness = $f1.toughness; rarity = $rarity
        'name 2' = $f2.name; 'casting cost 2' = (Get-Kosten $f2.mana_cost); 'super type 2' = $t2.super; 'sub type 2' = $t2.sub
        'rule text 2' = (ConvertTo-Sym $f2.oracle_text); notes = $id
      }) $r.Bilddatei 'normal' 'm15-adventure'
    continue
  }

  if ($o.layout -eq 'transform') {
    # Vorderseite normal; die Rückseite (Saga) als eigene Beilegkarte im selben Türchen
    $f1 = $o.card_faces[0]; $f2 = $o.card_faces[1]; $t1 = Split-Typ $f1.type_line; $t2 = Split-Typ $f2.type_line
    Add-Karte ([ordered]@{
        name = $r.Flavorname; alias = $f1.name; 'casting cost' = (Get-Kosten $f1.mana_cost)
        'super type' = $t1.super; 'sub type' = $t1.sub; 'rule text' = (ConvertTo-Sym $f1.oracle_text); 'flavor text' = $flavor
        rarity = $rarity; notes = $id
      }) $r.Bilddatei 'normal' 'm15-altered'
    $kap = [regex]::Matches($f2.oracle_text, '(?m)^(I+V?|IV|V)\s+—\s+(.+)$')
    $reminder = ($f2.oracle_text -split "`n")[0]
    $saga = [ordered]@{
      name = "$($r.Flavorname) – geöffnet"; alias = $f2.name; 'super type' = $t2.super; 'sub type' = $t2.sub
      'rule text' = (ConvertTo-Sym $reminder); power = $f2.power; toughness = $f2.toughness; rarity = $rarity; notes = "${id}_Rueckseite"
    }
    for ($i = 0; $i -lt $kap.Count; $i++) { $saga["level $($i + 1) text"] = (ConvertTo-Sym $kap[$i].Groups[2].Value) }
    Add-Karte $saga $r.Bilddatei 'saga' 'm15-saga'
    continue
  }

  $t = Split-Typ $o.type_line
  Add-Karte ([ordered]@{
      name = $r.Flavorname; alias = $o.name; 'casting cost' = (Get-Kosten $o.mana_cost)
      'super type' = $t.super; 'sub type' = $t.sub; 'rule text' = (ConvertTo-Sym $o.oracle_text); 'flavor text' = $flavor
      power = $o.power; toughness = $o.toughness; rarity = $rarity; notes = $id
    }) $r.Bilddatei 'normal' 'm15-altered'
}

# --- Spielmarken (Spielmarken.csv): Token und Spielhilfen, Dateiname <Tür>_Token-<Marke>_<Exemplar>
# Mit -Nur auswählbar über "Spielmarken" (alle) oder den Markennamen (z. B. "Treefolk").
$marken = if (Test-Path "$root\Spielmarken.csv") { Import-Csv "$root\Spielmarken.csv" -Delimiter ';' -Encoding UTF8 } else { @() }
foreach ($t in $marken) {
  if ($Nur -and 'Spielmarken' -notin $Nur -and $t.Marke -notin $Nur) { continue }
  $flavor = if ($t.Flavortext) { "<i-flavor>$($t.Flavortext)</i-flavor>" } else { '' }
  Add-Karte ([ordered]@{
      name = $t.Flavorname; 'card color' = $t.Farbe; 'super type' = $t.Supertyp; 'sub type' = $t.Untertyp
      'rule text' = (ConvertTo-Sym $t.Regeltext); 'flavor text' = $flavor; power = $t.'Stärke'; toughness = $t.Widerstand
      rarity = 'common'; notes = ('{0:D2}_Token-{1}_{2}' -f [int]$t.'Tür', $t.Marke, $t.Exemplar)
    }) $t.Bilddatei 'token' 'm15-token'
}

# --- Set-Datei schreiben und packen
$kopf = @"
mse version: 2.6.0
game: magic
stylesheet: m15-altered
set info:
	title: Projekt Reichtum
	description: Adventskalender 2026 – private Geschenk-Edition, nicht zum Verkauf.
	artist: $illustrator
	copyright: Projekt Reichtum 2026 · Privat, nicht zum Verkauf
	automatic reminder text:
	set code: PR
"@
if (Test-Path "$root\Karten\Set-Symbol.mse-symbol") { $kopf += "`n`tsymbol: symbol1"; Copy-Item "$root\Karten\Set-Symbol.mse-symbol" (Join-Path $bildTmp 'symbol1') }
$set = $kopf + "`n" + ($karten -join "`n") + "`n"
[IO.File]::WriteAllText((Join-Path $bildTmp 'set'), $set, (New-Object Text.UTF8Encoding $false))
New-Item -ItemType Directory -Force "$root\Karten" | Out-Null
$ziel = "$root\Karten\Projekt-Reichtum.mse-set"
if ($Nur) { $ziel = "$root\Karten\Test.mse-set" }
Remove-Item "$ziel.zip", $ziel -ErrorAction SilentlyContinue
Compress-Archive -Path "$bildTmp\*" -DestinationPath "$ziel.zip"; Move-Item "$ziel.zip" $ziel
"Set geschrieben: $ziel ($($karten.Count) Karten)"

if (-not $OhneExport) {
  $png = "$root\Karten\png"; if ($Nur) { $png = "$root\Karten\png-test" }
  Remove-Item $png -Recurse -Force -ErrorAction SilentlyContinue; New-Item -ItemType Directory -Force $png | Out-Null
  Push-Location $png
  try { & $mse --export-images $ziel '{card.notes}.png' 2>&1 | Where-Object { $_ } | Select-Object -Last 20 } finally { Pop-Location }
  "Exportiert: $(@(Get-ChildItem $png -Filter *.png).Count) PNG nach $png"
}
