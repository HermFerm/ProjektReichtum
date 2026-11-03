# Erweitert ein Kartenbild nach oben und zu den Seiten (Outpainting), damit das Motiv tiefer im Bild sitzt.
# Gedacht für Vollbild-Länder, bei denen die Namensleiste Köpfe verdeckt.
#   1. Bild verkleinern (-Skala) und unten mittig auf eine transparente Fläche gleicher Größe setzen
#   2. OpenAI /v1/images/edits malt die transparenten Ränder aus (Maske = Transparenz)
#   3. Die Originalpixel werden mit weichem Übergang wieder darübergelegt: Gesichter bleiben exakt unverändert,
#      auch wenn das Modell das ganze Bild neu rechnet.
# Ergebnis: Bilder/<Name>_versuchN.png (überschreibt nie), Protokoll in Bilder/_Protokoll.csv
# Aufruf: powershell -ExecutionPolicy Bypass -File Werkzeuge\Bild-erweitern.ps1 -Bilder "Forest_8,Forest_9" [-Skala 0.9] [-Szene "..."]
param(
  [Parameter(Mandatory)] [string[]]$Bilder,
  [double]$Skala = 0.9,
  [int]$Uebergang = 28,
  [string]$Szene = 'verzauberter Garten in Jena: mehr Blätterdach, Laternen und Lichtstimmung',
  [string]$Modell = 'gpt-image-2.5-sunburst',
  [string]$Qualitaet = 'high',
  [double]$PreisTextEin = 5, [double]$PreisBildEin = 8, [double]$PreisAus = 30
)
$ErrorActionPreference = 'Stop'
$Bilder = @($Bilder | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Drawing, System.Net.Http
$root = Split-Path $PSScriptRoot -Parent

$key = $null
foreach ($n in 'OPENAI_API_KEY', 'OPEN_API_KEY') { foreach ($s in 'Process', 'User') { $v = [Environment]::GetEnvironmentVariable($n, $s); if ($v -and -not $key) { $key = $v } } }
if (-not $key) { throw 'Kein API-Key (OPENAI_API_KEY / OPEN_API_KEY).' }
$client = New-Object System.Net.Http.HttpClient
$client.Timeout = [TimeSpan]::FromMinutes(10)
$client.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue('Bearer', $key)

$tmp = Join-Path $env:TEMP 'ProjektReichtum-erweitern'
New-Item -ItemType Directory -Force $tmp | Out-Null

function Get-Lage($w, $h) {
  $sw = [int]($w * $Skala); $sh = [int]($h * $Skala)
  @{ w = $sw; h = $sh; x = [int](($w - $sw) / 2); y = $h - $sh }
}

foreach ($name in $Bilder) {
  $quelle = Join-Path $root "Bilder\$name.png"
  if (-not (Test-Path $quelle)) { Write-Warning "$name fehlt"; continue }
  $n = 1; do { $n++; $ziel = Join-Path $root "Bilder\${name}_versuch$n.png" } while (Test-Path $ziel)

  # 1. Leinwand mit verkleinertem Original unten mittig
  $orig = New-Object System.Drawing.Bitmap -ArgumentList $quelle
  $W = $orig.Width; $H = $orig.Height; $L = Get-Lage $W $H
  $lw = New-Object System.Drawing.Bitmap -ArgumentList $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($lw); $g.Clear([System.Drawing.Color]::Transparent); $g.InterpolationMode = 'HighQualityBicubic'
  $g.DrawImage($orig, $L.x, $L.y, $L.w, $L.h); $g.Dispose()
  $lwPfad = Join-Path $tmp "$name-leinwand.png"; $lw.Save($lwPfad, [System.Drawing.Imaging.ImageFormat]::Png); $lw.Dispose()

  # 2. Ausmalen lassen
  $prompt = "Erweitere dieses Gemälde nahtlos in die transparenten Bereiche oben und an den Seiten. Szene: $Szene. " +
  'Gleicher Malstil, gleiches Licht, gleiche Farben, Übergänge unsichtbar. Der vorhandene Bildinhalt bleibt exakt so, wie er ist. ' +
  'Keine zusätzlichen Personen, keine Gesichter, kein Text, keine Logos.'
  $inhalt = New-Object System.Net.Http.MultipartFormDataContent
  $inhalt.Add((New-Object System.Net.Http.StringContent($Modell)), 'model')
  $inhalt.Add((New-Object System.Net.Http.StringContent($prompt, [Text.Encoding]::UTF8)), 'prompt')
  $inhalt.Add((New-Object System.Net.Http.StringContent("${W}x${H}")), 'size')
  $inhalt.Add((New-Object System.Net.Http.StringContent($Qualitaet)), 'quality')
  foreach ($feld in 'image[]', 'mask') {
    $bc = New-Object System.Net.Http.ByteArrayContent -ArgumentList (, [IO.File]::ReadAllBytes($lwPfad))
    $bc.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('image/png')
    $inhalt.Add($bc, $feld, "$name.png")
  }
  Write-Host "→ $name (Skala $Skala) ..."
  $t0 = Get-Date
  $resp = $client.PostAsync('https://api.openai.com/v1/images/edits', $inhalt).Result
  $body = $resp.Content.ReadAsStringAsync().Result
  if (-not $resp.IsSuccessStatusCode) { Write-Warning "$name fehlgeschlagen ($([int]$resp.StatusCode))`n$body"; $orig.Dispose(); continue }
  $r = $body | ConvertFrom-Json
  $rohPfad = Join-Path $tmp "$name-roh.png"
  [IO.File]::WriteAllBytes($rohPfad, [Convert]::FromBase64String($r.data[0].b64_json))

  # 3. Original mit weichem Rand (oben, links, rechts) wieder darüberlegen
  $roh = New-Object System.Drawing.Bitmap -ArgumentList $rohPfad
  $erg = New-Object System.Drawing.Bitmap -ArgumentList $W, $H
  $g = [System.Drawing.Graphics]::FromImage($erg); $g.InterpolationMode = 'HighQualityBicubic'
  $g.DrawImage($roh, 0, 0, $W, $H)
  $klein = New-Object System.Drawing.Bitmap -ArgumentList $L.w, $L.h
  $gk = [System.Drawing.Graphics]::FromImage($klein); $gk.InterpolationMode = 'HighQualityBicubic'; $gk.DrawImage($orig, 0, 0, $L.w, $L.h); $gk.Dispose()
  $F = $Uebergang; $px = [System.Drawing.GraphicsUnit]::Pixel
  # Kern ohne Randstreifen voll deckend
  $g.DrawImage($klein, (New-Object System.Drawing.Rectangle ($L.x + $F), ($L.y + $F), ($L.w - 2 * $F), ($L.h - $F)), $F, $F, ($L.w - 2 * $F), ($L.h - $F), $px)
  # Randstreifen pixelweise ausblenden: Deckkraft wächst von außen nach innen
  for ($i = 0; $i -lt $F; $i++) {
    $cm = New-Object System.Drawing.Imaging.ColorMatrix; $cm.Matrix33 = ($i + 1) / ($F + 1)
    $ia = New-Object System.Drawing.Imaging.ImageAttributes; $ia.SetColorMatrix($cm)
    $streifen = @(
      @($i, $i, ($L.w - 2 * $i), 1),                 # oben
      @($i, ($i + 1), 1, ($L.h - $i - 1)),           # links
      @(($L.w - 1 - $i), ($i + 1), 1, ($L.h - $i - 1))  # rechts
    )
    foreach ($s in $streifen) {
      $g.DrawImage($klein, (New-Object System.Drawing.Rectangle ($L.x + $s[0]), ($L.y + $s[1]), $s[2], $s[3]), $s[0], $s[1], $s[2], $s[3], $px, $ia)
    }
    $ia.Dispose()
  }
  $g.Dispose()
  $erg.Save($ziel, [System.Drawing.Imaging.ImageFormat]::Png)
  $erg.Dispose(); $roh.Dispose(); $klein.Dispose(); $orig.Dispose()

  $u = $r.usage
  $kosten = ($u.input_tokens_details.text_tokens * $PreisTextEin + $u.input_tokens_details.image_tokens * $PreisBildEin + $u.output_tokens * $PreisAus) / 1e6
  Write-Host ("   gespeichert: {0}  ({1} s, ca. {2:N3} $)" -f (Split-Path $ziel -Leaf), [int]((Get-Date) - $t0).TotalSeconds, $kosten)
  [pscustomobject][ordered]@{
    Zeit = (Get-Date).ToString('yyyy-MM-dd HH:mm'); Datei = (Split-Path $ziel -Leaf); Modell = $Modell; Qualitaet = $Qualitaet
    Vorlagen = "Bilder/$name.png (erweitert, Skala $Skala)"; TokensText = $u.input_tokens_details.text_tokens; TokensBildEin = $u.input_tokens_details.image_tokens
    TokensAus = $u.output_tokens; KostenUSD = [math]::Round($kosten, 4); Prompt = $prompt
  } | Export-Csv (Join-Path $root 'Bilder\_Protokoll.csv') -Delimiter ';' -NoTypeInformation -Encoding UTF8 -Append
}
