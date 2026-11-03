# Erzeugt das Set-Symbol (Karten/Set-Symbol.mse-symbol): Münze mit Rand und steigender Kurve mit Pfeilspitze.
# MSE-Symbole sind Text: Teile (Formen) mit Bézier-Punkten in 0..1, der erste Teil liegt oben.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$inv = [cultureinfo]::InvariantCulture
function P($x, $y) { '({0},{1})' -f $x.ToString('0.0000', $inv), $y.ToString('0.0000', $inv) }

function Kreis($name, $kombi, $cx, $cy, $r) {
  $k = 0.5523 * $r
  $pkt = @(
    @{ p = (P ($cx + $r) $cy); v = (P 0 (-$k)); n = (P 0 $k) },
    @{ p = (P $cx ($cy + $r)); v = (P $k 0); n = (P (-$k) 0) },
    @{ p = (P ($cx - $r) $cy); v = (P 0 $k); n = (P 0 (-$k)) },
    @{ p = (P $cx ($cy - $r)); v = (P (-$k) 0); n = (P $k 0) })
  $z = @('part:', "`ttype: shape", "`tname: $name", "`tcombine: $kombi")
  foreach ($q in $pkt) { $z += "`tpoint:", "`t`tposition: $($q.p)", "`t`tlock: size", "`t`tline after: curve", "`t`thandle before: $($q.v)", "`t`thandle after: $($q.n)" }
  $z -join "`n"
}
function Vieleck($name, $kombi, $punkte) {
  $z = @('part:', "`ttype: shape", "`tname: $name", "`tcombine: $kombi")
  foreach ($q in $punkte) { $z += "`tpoint:", "`t`tposition: $(P $q[0] $q[1])", "`t`tlock: free", "`t`tline after: line" }
  $z -join "`n"
}

# Kurve als Band: Mittellinie mit halber Breite nach oben/unten versetzt (Gehrung über Winkelhalbierende)
$linie = @(@(0.24, 0.68), @(0.40, 0.52), @(0.51, 0.60), @(0.66, 0.42))
$d = 0.045
$oben = @(); $unten = @()
for ($i = 0; $i -lt $linie.Count; $i++) {
  $a = $linie[[math]::Max(0, $i - 1)]; $b = $linie[[math]::Min($linie.Count - 1, $i + 1)]
  $dx = $b[0] - $a[0]; $dy = $b[1] - $a[1]; $l = [math]::Sqrt($dx * $dx + $dy * $dy)
  $nx = - $dy / $l; $ny = $dx / $l
  $oben += , @(($linie[$i][0] + $nx * $d), ($linie[$i][1] + $ny * $d))
  $unten += , @(($linie[$i][0] - $nx * $d), ($linie[$i][1] - $ny * $d))
}
[array]::Reverse($unten)
$band = $oben + $unten
$spitze = @(@(0.60, 0.33), @(0.78, 0.28), @(0.72, 0.47))

$teile = @(
  (Vieleck 'Pfeilspitze' 'subtract' $spitze),
  (Vieleck 'Kurve' 'subtract' $band),
  (Kreis 'Innen' 'overlap' 0.5 0.5 0.36),
  (Kreis 'Rillenring' 'subtract' 0.5 0.5 0.41),
  (Kreis 'Muenze' 'overlap' 0.5 0.5 0.48)
)
$txt = "mse version: 0.3.6`n" + ($teile -join "`n") + "`n"
New-Item -ItemType Directory -Force "$root\Karten" | Out-Null
[IO.File]::WriteAllText("$root\Karten\Set-Symbol.mse-symbol", $txt, (New-Object Text.UTF8Encoding $false))
"Set-Symbol geschrieben."
