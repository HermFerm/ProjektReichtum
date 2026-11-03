# Macht aus Karten/png/ druckfertige Einzelbilder für Online-Kartendruckereien (z. B. MakePlayingCards, Printerstudio):
# 63,5 × 88,9 mm (2,5 × 3,5 Zoll) bei 300 dpi plus 3 mm Beschnitt rundum = 822 × 1122 px.
# Der Kartenrand ist schwarz, deshalb wird der Beschnitt schwarz aufgefüllt (auch die runden Ecken).
# Ergebnis: Druck/vorderseiten/<Tür>_<Karte>_<Exemplar>.png und Druck/Packliste.csv
param([int]$Breite = 822, [int]$Hoehe = 1122)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path $PSScriptRoot -Parent
$quelle = "$root\Karten\png"
$ziel = "$root\Druck\vorderseiten"
Remove-Item $ziel -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $ziel | Out-Null

# Kartenfläche ohne Beschnitt: 750 × 1050 px (2,5 × 3,5 Zoll); MSE liefert 750 × 1046, also mittig einsetzen
$innenB = 750; $innenH = 1050
$n = 0
foreach ($f in Get-ChildItem $quelle -Filter *.png | Sort-Object Name) {
  $img = New-Object System.Drawing.Bitmap -ArgumentList $f.FullName
  # MSE exportiert die runden Ecken weiß: alles außerhalb der Kartenrundung (Radius ca. 3 mm) schwarz färben.
  # Dieser Bereich wird beim Rundstanzen ohnehin abgeschnitten; innerhalb der Rundung bleibt das Bild unangetastet.
  $rad = 38
  foreach ($ecke in @(@(0, 0, 1, 1), @(($img.Width - 1), 0, -1, 1), @(0, ($img.Height - 1), 1, -1), @(($img.Width - 1), ($img.Height - 1), -1, -1))) {
    $cx = $ecke[0] + $ecke[2] * $rad; $cy = $ecke[1] + $ecke[3] * $rad
    for ($i = 0; $i -lt $rad; $i++) { for ($j = 0; $j -lt $rad; $j++) {
        $x = $ecke[0] + $ecke[2] * $i; $y = $ecke[1] + $ecke[3] * $j
        if ([math]::Sqrt(($x - $cx) * ($x - $cx) + ($y - $cy) * ($y - $cy)) -gt $rad - 1) {
          # Randlose Grundländer: Ecke mit der Bildfarbe an der Rundung füllen (wird gespiegelt), sonst transparent = schwarz
          if ($f.Name -match '_(Forest|Island|Mountain)_' -and $ecke[3] -eq 1) { $img.SetPixel($x, $y, $img.GetPixel([int]($ecke[0] + $ecke[2] * $rad), [int]($ecke[1] + $ecke[3] * ($rad / 2)))) }
          else { $img.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
        }
      } }
  }
  $bmp = New-Object System.Drawing.Bitmap -ArgumentList $Breite, $Hoehe
  $bmp.SetResolution(300, 300)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear([System.Drawing.Color]::Black)
  $g.InterpolationMode = 'HighQualityBicubic'
  # Vollbild-Grundländer sind oben und seitlich randlos: Beschnitt mit dem gestreckten Bild füllen statt schwarz,
  # sonst blitzt bei ungenauem Schnitt ein schwarzer Streifen
  $s = [math]::Min($innenB / $img.Width, $innenH / $img.Height)
  $w = [int]($img.Width * $s); $h = [int]($img.Height * $s)
  $x0 = [int](($Breite - $w) / 2); $y0 = [int](($Hoehe - $h) / 2)
  if ($f.Name -match '_(Forest|Island|Mountain)_') {
    # Kartenkante oben, links, rechts nach außen spiegeln (unten ist der Rand schwarz)
    $k = New-Object System.Drawing.Bitmap -ArgumentList $w, $h
    $gk = [System.Drawing.Graphics]::FromImage($k); $gk.InterpolationMode = 'HighQualityBicubic'; $gk.DrawImage($img, 0, 0, $w, $h); $gk.Dispose()
    $b = [math]::Max($x0, $y0) + 2; $px = [System.Drawing.GraphicsUnit]::Pixel
    function Spiegel($src, $ul, $ur, $ll) { $g.DrawImage($k, [System.Drawing.Point[]]@($ul, $ur, $ll), $src, $px) }
    $P = { param($x, $y) New-Object System.Drawing.Point $x, $y }
    $R = { param($x, $y, $rw, $rh) New-Object System.Drawing.Rectangle $x, $y, $rw, $rh }
    Spiegel (& $R 0 0 $w $b) (& $P $x0 $y0) (& $P ($x0 + $w) $y0) (& $P $x0 ($y0 - $b))                       # oben
    Spiegel (& $R 0 0 $b $h) (& $P $x0 $y0) (& $P ($x0 - $b) $y0) (& $P $x0 ($y0 + $h))                       # links
    Spiegel (& $R ($w - $b) 0 $b $h) (& $P ($x0 + $w + $b) $y0) (& $P ($x0 + $w) $y0) (& $P ($x0 + $w + $b) ($y0 + $h))  # rechts
    Spiegel (& $R 0 0 $b $b) (& $P $x0 $y0) (& $P ($x0 - $b) $y0) (& $P $x0 ($y0 - $b))                       # Ecke oben links
    Spiegel (& $R ($w - $b) 0 $b $b) (& $P ($x0 + $w + $b) $y0) (& $P ($x0 + $w) $y0) (& $P ($x0 + $w + $b) ($y0 - $b))  # Ecke oben rechts
    # unterer Bereich (schwarzer Kartenrand) bleibt schwarz
    $g.FillRectangle([System.Drawing.Brushes]::Black, 0, [int]($y0 + $h * 0.9), $Breite, $Hoehe)
    $k.Dispose()
  }
  $g.DrawImage($img, $x0, $y0, $w, $h)
  $bmp.Save((Join-Path $ziel $f.Name), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose(); $img.Dispose(); $n++
}

# Sonderkarten (Titel- und Trennkarten aus Entwuerfe/Sonderkarten/bau_sonderkarten.py) sind schon im Druckformat
foreach ($f in Get-ChildItem "$root\Karten\sonder" -Filter *.png -ErrorAction SilentlyContinue) {
  $b = New-Object System.Drawing.Bitmap -ArgumentList $f.FullName
  $c = New-Object System.Drawing.Bitmap -ArgumentList $b; $b.Dispose(); $c.SetResolution(300, 300)
  $c.Save((Join-Path $ziel $f.Name), [System.Drawing.Imaging.ImageFormat]::Png); $c.Dispose(); $n++
}

# Ersatzkarten für Tür 17 („Ersatzteillager“): Kopie einer fertigen Druckkarte mit kleiner Aufschrift ERSATZ
# im schwarzen Rand unten (zwischen Illustrator-Zeile und Copyright), damit sie nicht versehentlich ins Deck geraten.
# Auswahl: die drei Einzelstücke im Hauptdeck (Mountain, Stock Up, Demolition Field) und die meistgespielten Karten.
$ersatz = @('Mountain_1', 'Stock Up_1', 'Demolition Field_1', 'Forest_1', 'Island_1', 'Opt_1', 'Burst Lightning_1', 'Llanowar Elves_1')
$ersatzTuer = 17
$schrift = New-Object System.Drawing.Font ('Arial', 15, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
foreach ($e in $ersatz) {
  $vorlage = Get-ChildItem $ziel -Filter "*_$e.png" | Where-Object { $_.BaseName -match "^\d+_$([regex]::Escape($e))$" } | Select-Object -First 1
  if (-not $vorlage) { throw "Ersatzkarte: keine Druckkarte für $e" }
  $b = New-Object System.Drawing.Bitmap -ArgumentList $vorlage.FullName
  $c = New-Object System.Drawing.Bitmap -ArgumentList $b; $b.Dispose(); $c.SetResolution(300, 300)
  $g = [System.Drawing.Graphics]::FromImage($c); $g.TextRenderingHint = 'AntiAliasGridFit'
  $fmt = New-Object System.Drawing.StringFormat; $fmt.Alignment = 'Center'; $fmt.LineAlignment = 'Center'
  $g.DrawString('ERSATZ', $schrift, (New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 200, 170, 90))), (New-Object System.Drawing.RectangleF 300, 1034, 140, 24), $fmt)
  $g.Dispose()
  $c.Save((Join-Path $ziel ('{0:D2}_{1}_Ersatz.png' -f $ersatzTuer, $e)), [System.Drawing.Imaging.ImageFormat]::Png); $c.Dispose(); $n++
}

# Packliste: welche Karte in welches Türchen
$rows = Import-Csv "$root\Planungstabelle.csv" -Delimiter ';' -Encoding UTF8
$marken = if (Test-Path "$root\Spielmarken.csv") { Import-Csv "$root\Spielmarken.csv" -Delimiter ';' -Encoding UTF8 } else { @() }
$liste = foreach ($f in Get-ChildItem $ziel -Filter *.png | Sort-Object Name) {
  if ($f.BaseName -notmatch '^(\d+)_(.+)_(\d+)(_Rueckseite|_Ersatz)?$') { continue }
  $tuer = [int]$matches[1]; $karte = $matches[2]; $ex = $matches[3]; $rs = $matches[4] -eq '_Rueckseite'; $ers = $matches[4] -eq '_Ersatz'
  if ($ers) {
    $o = $rows | Where-Object { $_.Karte -eq $karte -and $_.Exemplar -eq $ex } | Select-Object -First 1
    [pscustomobject][ordered]@{ 'Tür' = $tuer; Datei = $f.Name; Karte = $karte; Exemplar = $ex; Flavorname = "$($o.Flavorname) (Ersatzkarte)"; Deck = 'Ersatz' }
    continue
  }
  if ($karte -match '^(Titelkarte|Trennkarte-.+)$') {
    [pscustomobject][ordered]@{ 'Tür' = $tuer; Datei = $f.Name; Karte = $karte; Exemplar = $ex; Flavorname = ''; Deck = 'Sonderkarte' }
    continue
  }
  # MSE lässt Satzzeichen (', Komma) im Dateinamen weg, darum ohne sie vergleichen
  $schluessel = $karte -replace '[^\p{L}\p{N}]', ''
  $r = $rows | Where-Object { [int]$_.'Tür' -eq $tuer -and ($_.Karte -replace '[^\p{L}\p{N}]', '') -eq $schluessel -and $_.Exemplar -eq $ex } | Select-Object -First 1
  # Spielmarken (Datei <Tür>_Token-<Marke>_<Exemplar>) stehen in Spielmarken.csv
  if (-not $r -and $karte -match '^Token-(.+)$') {
    $m = $marken | Where-Object { [int]$_.'Tür' -eq $tuer -and $_.Marke -eq $matches[1] -and $_.Exemplar -eq $ex } | Select-Object -First 1
    if ($m) { $r = [pscustomobject]@{ Karte = "Spielmarke $($m.Marke)"; Flavorname = $m.Flavorname; Deck = 'Spielmarke' } }
  }
  [pscustomobject][ordered]@{
    'Tür' = $tuer; Datei = $f.Name; Karte = $(if ($r) { $r.Karte } else { $karte }); Exemplar = $ex
    Flavorname = $(if ($r) { $r.Flavorname } else { '' }) + $(if ($rs) { ' (Saga-Rückseite, Beilegkarte)' } else { '' })
    Deck = $(if ($r) { $r.Deck } else { '' })
  }
}
$liste | Export-Csv "$root\Druck\Packliste.csv" -Delimiter ';' -NoTypeInformation -Encoding UTF8
"Druckbilder: $n ($Breite × $Hoehe px, 300 dpi) in $ziel"
