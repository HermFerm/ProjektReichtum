# Erzeugt Kartenbilder über die OpenAI-Bild-API (/v1/images/edits) aus einer Auftragsdatei (JSON).
# Der Stilblock aus Bildprompts.md wird jedem Prompt automatisch vorangestellt.
# Vorhandene Bilder werden übersprungen; mit -Neu entsteht ein weiterer Versuch als <Name>_versuch2.png usw.
# Nie wird etwas überschrieben. Aufträge ohne Vorlagen laufen über /v1/images/generations.
# Aufruf: powershell -ExecutionPolicy Bypass -File Werkzeuge\Bildgenerator.ps1 -Auftraege Werkzeuge\Bildauftraege\Hermann.json [-Nur "Sunderflock_1,Opt_2"] [-Neu]
param(
  [Parameter(Mandatory)] [string]$Auftraege,
  [string[]]$Nur,
  [switch]$Neu,
  [string]$Modell = 'gpt-image-2.5-sunburst',
  [ValidateSet('low', 'medium', 'high', 'xhigh', 'max', 'auto')] [string]$Qualitaet = 'high'
)
$ErrorActionPreference = 'Stop'
$Nur = @($Nur | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })  # -File übergibt "a,b" als einen Text
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Drawing, System.Net.Http
$root = Split-Path $PSScriptRoot -Parent

# Key: OPENAI_API_KEY, sonst OPEN_API_KEY; aus dem Prozess oder direkt aus den Benutzervariablen
$key = foreach ($n in 'OPENAI_API_KEY', 'OPEN_API_KEY') {
  foreach ($s in 'Process', 'User') { $v = [Environment]::GetEnvironmentVariable($n, $s); if ($v) { $v; break } }
}
$key = @($key)[0]
if (-not $key) { throw 'Kein API-Key gefunden (OPENAI_API_KEY).' }

# Stilblock: erster Codeblock nach "## Stilblock", ohne die Chat-Anweisung am Ende
$md = Get-Content "$root\Bildprompts.md" -Encoding UTF8 -Raw
if ($md -notmatch '(?s)## Stilblock.*?```\r?\n(.*?)```') { throw 'Stilblock nicht gefunden' }
$stil = ($matches[1] -split '\r?\n' | Where-Object { $_ -and $_ -notmatch '^Bestätige' }) -join "`n"
$stil = $stil -replace 'Verwandle meine Fotos', 'Verwandle die mitgeschickten Fotos'

# Fotos vor dem Hochladen verkleinern (lange Seite max. 1536 px, EXIF-Drehung angewendet)
$tmp = Join-Path $env:TEMP 'ProjektReichtum-upload'
New-Item -ItemType Directory -Force $tmp | Out-Null
function Get-Upload($pfad) {
  $img = [System.Drawing.Image]::FromFile($pfad)
  try {
    if ($img.PropertyIdList -contains 0x112) {
      switch ($img.GetPropertyItem(0x112).Value[0]) { 3 { $img.RotateFlip('Rotate180FlipNone') } 6 { $img.RotateFlip('Rotate90FlipNone') } 8 { $img.RotateFlip('Rotate270FlipNone') } }
    }
    $s = [math]::Min(1.0, 1536.0 / [math]::Max($img.Width, $img.Height))
    [int]$bw = [math]::Round($img.Width * $s); [int]$bh = [math]::Round($img.Height * $s)
    $bmp = New-Object System.Drawing.Bitmap -ArgumentList $bw, $bh
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = 'HighQualityBicubic'
    $g.DrawImage($img, 0, 0, $bmp.Width, $bmp.Height)
    $ziel = Join-Path $tmp (([IO.Path]::GetFileNameWithoutExtension($pfad)) + '.png')
    $bmp.Save($ziel, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    $ziel
  } finally { $img.Dispose() }
}

$client = New-Object System.Net.Http.HttpClient
$client.Timeout = [TimeSpan]::FromMinutes(10)
$client.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue('Bearer', $key)

$protokoll = "$root\Bilder\_Protokoll.csv"
$jobs = Get-Content (Join-Path $root $Auftraege) -Encoding UTF8 -Raw | ConvertFrom-Json
$summe = 0.0
foreach ($job in $jobs) {
  $name = [IO.Path]::GetFileNameWithoutExtension($job.ziel)
  if ($Nur -and $name -notin $Nur) { continue }

  $ziel = Join-Path $root $job.ziel
  if ((Test-Path $ziel) -and -not $Neu) { Write-Host "   $name ist schon vorhanden, übersprungen"; continue }
  $n = 1
  while (Test-Path $ziel) { $n++; $ziel = Join-Path $root ($job.ziel -replace '\.png$', "_versuch$n.png") }

  $bilder = @($job.bilder | Where-Object { $_ })
  $fehlt = @($bilder | Where-Object { -not (Test-Path (Join-Path $root $_)) })
  if ($fehlt) { Write-Warning "$name übersprungen, Vorlage fehlt: $($fehlt -join ', ')"; continue }

  $prompt = "$stil`n`nMotiv:`n$($job.prompt)"
  if ($bilder.Count -eq 0) {
    $json = @{ model = $Modell; prompt = $prompt; size = $job.format; quality = $Qualitaet } | ConvertTo-Json
    $inhalt = New-Object System.Net.Http.StringContent($json, [Text.Encoding]::UTF8, 'application/json')
    $url = 'https://api.openai.com/v1/images/generations'
  } else {
    $inhalt = New-Object System.Net.Http.MultipartFormDataContent
    $inhalt.Add((New-Object System.Net.Http.StringContent($Modell)), 'model')
    $inhalt.Add((New-Object System.Net.Http.StringContent($prompt, [Text.Encoding]::UTF8)), 'prompt')
    $inhalt.Add((New-Object System.Net.Http.StringContent($job.format)), 'size')
    $inhalt.Add((New-Object System.Net.Http.StringContent($Qualitaet)), 'quality')
    foreach ($b in $bilder) {
      $up = Get-Upload (Join-Path $root $b)
      $bc = New-Object System.Net.Http.ByteArrayContent -ArgumentList (, [IO.File]::ReadAllBytes($up))
      $bc.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('image/png')
      $inhalt.Add($bc, 'image[]', [IO.Path]::GetFileName($up))
    }
    $url = 'https://api.openai.com/v1/images/edits'
  }

  Write-Host "→ $name ($($bilder.Count) Vorlagen) ..."
  $t0 = Get-Date
  try { $resp = $client.PostAsync($url, $inhalt).Result }
  catch { Write-Warning "$name fehlgeschlagen: $($_.Exception.InnerException.Message)"; continue }
  $body = $resp.Content.ReadAsStringAsync().Result
  if (-not $resp.IsSuccessStatusCode) { Write-Warning "$name fehlgeschlagen ($([int]$resp.StatusCode)): $body"; continue }

  $r = $body | ConvertFrom-Json
  [IO.File]::WriteAllBytes($ziel, [Convert]::FromBase64String($r.data[0].b64_json))
  $u = $r.usage
  $kosten = $u.input_tokens_details.text_tokens * 5e-6 + $u.input_tokens_details.image_tokens * 8e-6 + $u.output_tokens * 30e-6
  $summe += $kosten
  $dauer = [int]((Get-Date) - $t0).TotalSeconds
  Write-Host ("   gespeichert: {0}  ({1} s, ca. {2:N3} $)" -f (Split-Path $ziel -Leaf), $dauer, $kosten)

  [pscustomobject][ordered]@{
    Zeit = (Get-Date).ToString('yyyy-MM-dd HH:mm'); Datei = (Split-Path $ziel -Leaf); Modell = $Modell; Qualitaet = $Qualitaet
    Vorlagen = ($job.bilder -join ' | '); TokensText = $u.input_tokens_details.text_tokens; TokensBildEin = $u.input_tokens_details.image_tokens
    TokensAus = $u.output_tokens; KostenUSD = [math]::Round($kosten, 4); Prompt = $job.prompt
  } | Export-Csv $protokoll -Delimiter ';' -NoTypeInformation -Encoding UTF8 -Append
}
Write-Host ("Summe: ca. {0:N2} $" -f $summe)
