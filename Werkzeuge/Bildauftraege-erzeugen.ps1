# Erzeugt die Auftragsdateien für Bildgenerator.ps1 (eine JSON-Datei pro Chat) aus
# Bildprompts.md (Grundprompt pro Karte), Planungstabelle.csv (Exemplare, Personen, Sprüche)
# und der Foto-Zuordnung unten (übernommen aus Bildauftraege.md).
# Robins Karten fehlen absichtlich: die macht Hermann in ChatGPT.
# Aufruf: powershell -ExecutionPolicy Bypass -File Werkzeuge\Bildauftraege-erzeugen.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$alle5 = 'Hermann', 'Robin', 'Paul', 'Johann', 'Max'

# --- Grundprompts aus Bildprompts.md: Schlüssel = Oracle-Name
$prompts = @{}
$cur = $null; $inBlock = $false; $buf = @()
foreach ($l in Get-Content "$root\Bildprompts.md" -Encoding UTF8) {
  if ($l -match '^\*\*.+?\*\* – \*(.+?)\*') { $cur = $matches[1]; continue }
  if ($l -match '^```') {
    if ($inBlock) { if ($cur) { $prompts[$cur] = ($buf -join "`n").Trim() }; $cur = $null; $buf = @() }
    $inBlock = -not $inBlock; continue
  }
  if ($inBlock) { $buf += $l }
}
$vollbild = @{ Forest = 'Wald/Hain (verzauberter Garten in Jena)'; Island = 'Meeresküste (Mallorca)'; Mountain = 'Gebirgspass (Alpen)' }

# --- Chat pro Karte (wie in Bildauftraege.md); Schlüssel "Karte" oder "Karte|Exemplar"
$chat = @{}
foreach ($k in 'Sunderflock', 'Prismari Charm', 'Eddymurk Crab', 'Flow State', 'Esper Origins') { $chat[$k] = 'Hermann' }
foreach ($k in 'Surrak, Elusive Hunter', 'Pompous Battlemage', 'Burst Lightning', 'Wild Ride', 'Traumatic Critique') { $chat[$k] = 'Paul' }
foreach ($k in 'Slickshot Show-Off', 'Icetill Explorer', 'Impractical Joke', 'Carnivorous Cultivator') { $chat[$k] = 'Johann' }
foreach ($k in 'Colorstorm Stallion', 'Mossborn Hydra', 'Torpor Orb', 'Sleight of Hand', 'Keen-Eyed Curator') { $chat[$k] = 'Max' }
foreach ($k in 'Hearth Elemental', 'Vibrant Outburst', 'Earthbender Ascension', "Sazh's Chocobo", "Meltstrider's Resolve",
  'Spell Snare', 'Hard-Hitting Question', 'Lumbering Worldwagon', 'Sunderflock|4', 'Keen-Eyed Curator|2') { $chat[$k] = 'Gruppe' }
foreach ($k in 'Riverpyre Verge', 'Steam Vents', 'Spirebluff Canal', 'Multiversal Passage', 'Fabled Passage', 'Elven Passage',
  'Ba Sing Se', 'Demolition Field', 'Escape Tunnel', 'Forest', 'Island', 'Mountain') { $chat[$k] = 'Laender' }
foreach ($k in 'Mightform Harmonizer', 'Llanowar Elves', 'Opt', 'Stock Up', 'Elusive Otter', 'Bounce Off', 'Sapling Nursery', 'Impractical Joke|2') { $chat[$k] = 'Robin' }

# --- Personen (Charakterblätter), wenn nicht die Chat-Person
$personen = @{
  'Hearth Elemental' = $alle5; 'Lumbering Worldwagon' = $alle5; 'Sunderflock|4' = $alle5
  'Vibrant Outburst' = 'Paul', 'Johann'; "Sazh's Chocobo" = 'Robin', 'Hermann'; "Meltstrider's Resolve" = 'Robin', 'Johann'
  'Spell Snare' = 'Johann', 'Hermann'; 'Hard-Hitting Question' = 'Paul', 'Hermann'; 'Keen-Eyed Curator|2' = 'Max', 'Robin'
  'Earthbender Ascension|1' = 'Hermann'; 'Earthbender Ascension|2' = 'Paul'; 'Earthbender Ascension|3' = 'Robin'; 'Earthbender Ascension|4' = 'Johann'
}

# --- Fotos als Vorlage (Pfade unter Fotos/)
$fotos = @{
  'Prismari Charm|1' = 'Gruppe/Mallorca-JGA/Hermann-Robin__IMG_20250601_201109.jpg'
  'Prismari Charm|2' = 'Gruppe/Garten-Jena/Hermann__IMG-20220815-WA0004.jpg'
  'Prismari Charm|3' = 'Gruppe/Hochzeit/Hermann-Robin-Johann-Paul__IMG-20250914-WA0015.jpg'
  'Prismari Charm|4' = 'Gruppe/Garten-Jena/Hermann__333A6388.jpg'
  'Eddymurk Crab'    = 'Themen/Rennrad-Werkstatt/Hermann-Rennrad__IMAG0093.jpg'
  'Esper Origins|1'  = 'Nachlieferung/Advents-Puzzle.jpg'
  'Esper Origins|2'  = 'Nachlieferung/Advents_Puzzle_mit_Finger.jpg'
  'Esper Origins|3'  = 'Nachlieferung/Advents-Puzzle.jpg', 'Nachlieferung/Advents_Puzzle_mit_Finger.jpg'
  'Surrak, Elusive Hunter|1' = 'Gruppe/Alpen-Rennrad/Paul__IMG-20260726-WA0024.jpg'
  'Surrak, Elusive Hunter|2' = 'Gruppe/Alpen-Rennrad/Paul__IMG-20260606-WA0021.jpg'
  'Pompous Battlemage' = 'Nachlieferung/Paul_gestikuliert.png'
  'Burst Lightning'    = 'Nachlieferung/Paul_Genervt.jpg'
  'Traumatic Critique' = 'Paul/Paul_portrait_05.jpg'
  'Hard-Hitting Question' = 'Nachlieferung/Paul_gestikuliert.png'
  'Slickshot Show-Off|1' = 'Nachlieferung/Johann_im_Sprung_3.png'
  'Slickshot Show-Off|2' = 'Nachlieferung/Johann_im_Sprung_2.png'
  'Slickshot Show-Off|3' = 'Nachlieferung/Johann_im_Sprung_1.png'
  'Slickshot Show-Off|4' = 'Gruppe/Mallorca-JGA/Johann__IMG-20250531-WA0001.jpg'
  'Colorstorm Stallion'  = 'Nachlieferung/Max_Tanzen.png'
  'Mossborn Hydra'       = 'Themen/Rennrad-Werkstatt/Max__IMG-20260425-WA0006.jpg'
  'Torpor Orb'           = 'Themen/Rennrad-Werkstatt/Max__IMG-20260425-WA0006.jpg'
  'Keen-Eyed Curator'    = 'Nachlieferung/Max_im_Restaurant.jpg'
  'Lumbering Worldwagon' = 'Themen/Rennrad-Werkstatt/Max__IMG-20260425-WA0006.jpg'
  'Hearth Elemental'     = 'Gruppe/Garten-Jena/Vicky-Robin-Johann__IMG-20230813-WA0049.jpg', 'Gruppe/Garten-Jena/Robin-Vicky__IMG_20250809_234522.jpg'
  'Vibrant Outburst'     = 'Nachlieferung/Seifenblasen_ersatz.jpg', 'Gruppe/Hochzeit/Paul__IMG-20250905-WA0021.jpg'
  "Meltstrider's Resolve" = 'Nachlieferung/Johann_und_Robin_zocken_zwar_Poolbilliard_aber_als_Sinnbild.jpg'
  "Meltstrider's Resolve|4" = 'Themen/YouTube-Verkleidung/Johann__IMG-20250531-WA0087.jpg'
  'Multiversal Passage'  = 'Themen/Arbeit-Projekte/Johann__IMG-20210902-WA0005.jpg'
  # Länder: Foto nur beim ersten Exemplar, sonst gleichen sich die Varianten an
  'Riverpyre Verge|1'    = 'Themen/Saaleufer__IMG_20180808_125351-EFFECTS.jpg'
  'Elven Passage|1'      = 'Gruppe/Mallorca-JGA/IMG-20250602-WA0001.jpg'
  'Ba Sing Se|1'         = 'Themen/Haus-Garten-Koi/IMG-20260717-WA0016.jpg'
  'Escape Tunnel|1'      = 'Gruppe/Garten-Jena/333A6404.jpg'
}

# --- Zusätzliche Hinweise pro Karte oder Exemplar
$landDynamik = 'Aufregende, dynamische Szene mit Bewegung, Wetter und Magie, dramatische Perspektive. Keine Personen. Jedes Exemplar unterscheidet sich deutlich in Tageszeit, Wetter und Blickwinkel.'
$hinweis = @{
  'Eddymurk Crab|1' = 'Nur eine hauchdünne Staubschicht, kaum Moos, keine Spinnweben – das Rad glänzt noch. Hermann steht nah an der Bildmitte, nicht am Rand.'
  'Eddymurk Crab|2' = 'Deutliche Staubschicht, erste Spinnweben, etwas Moos.'
  'Eddymurk Crab|3' = 'Dicke Staubschicht, viel Moos und Spinnweben.'
  'Eddymurk Crab|4' = 'Das Rad ist fast unter Moos verschwunden, aus den Speichen wachsen Pflanzen.'
  'Prismari Charm'  = 'Das Foto ist Vorlage für Ort, Stimmung und Getränk; im Vordergrund steht nur Hermann.'
  'Esper Origins'   = 'Die Puzzlebilder vom Foto dürfen als leuchtende Kacheln im Kalender erscheinen.'
  'Surrak, Elusive Hunter' = 'Trikot und Pose aus dem Foto übernehmen.'
  'Pompous Battlemage' = 'Gestik aus dem Foto übernehmen.'
  'Burst Lightning'    = 'Gesichtsausdruck wie auf dem Foto.'
  'Traumatic Critique' = 'Die Kaffeetasse vom Foto als Requisite.'
  'Hard-Hitting Question' = 'Pauls Gestik aus dem Foto übernehmen.'
  'Slickshot Show-Off' = 'Körperhaltung aus dem Foto übernehmen. Sportlicher, sicherer Urlaubs-Klippensprung ins tiefe Wasser: fröhlich, lachend, Freunde jubeln – Abenteuer und Spaß, keine Gefahr.'
  'Slickshot Show-Off|4' = 'Siegerpose ganz oben auf der Klippe wie auf dem Foto, Wolken unter ihm.'
  'Colorstorm Stallion' = 'Leuchtstab und Fliege aus dem Foto übernehmen; der Leuchtstab wird zum Zauberstab, aus dem die Pferde-Geister springen.'
  'Mossborn Hydra' = 'Schraub-Haltung aus dem Foto übernehmen.'
  'Torpor Orb' = 'Haltung aus dem Foto übernehmen.'
  'Keen-Eyed Curator' = 'Das Restaurant-Foto als Vorlage für Ort und Stimmung.'
  'Keen-Eyed Curator|1' = 'Max sitzt allein am Tisch, ohne Gegenüber.'
  'Lumbering Worldwagon' = 'Max schraubt (Haltung wie auf dem Foto), die vier anderen schieben hinten an.'
  'Hearth Elemental' = 'Die Fotos zeigen nur die Kulisse (Garten, Lagerfeuer). Die fünf Freunde nach den Charakterblättern einsetzen, keine weiteren Personen.'
  'Vibrant Outburst' = 'Foto 1 gibt die Stimmung, Foto 2 die Seifenblasen-Pistole als Vorlage.'
  'Earthbender Ascension' = 'Pro Bild nur diese eine Person, Gesicht und Frisur exakt wie auf dem Charakterblatt.'
  'Icetill Explorer|3' = 'Johann repariert mit Erdmagie die Steinumrandung eines Koi-Teichs mit orange-weißen Kois und Seerosen. Im Bild ist nur Johann, keine weiteren Personen.'
  'Multiversal Passage|2' = 'Die PDFs im Spruch nur als fliegende Pergamentrollen mit rotem Wachssiegel zeigen, auf keinen Fall Datei- oder App-Symbole.'
  "Meltstrider's Resolve|1" = 'Das Foto ist nur ein Sinnbild für die beiden als Team.'
  "Meltstrider's Resolve|2" = 'Das Foto ist nur ein Sinnbild für die beiden als Team.'
  "Meltstrider's Resolve|3" = 'Das Foto ist nur ein Sinnbild für die beiden als Team.'
  "Meltstrider's Resolve|4" = 'Das Foto ist die Vorlage für Johanns Verkleidung und Pose.'
  'Sunderflock|4' = 'Hermann steht auf dem Balkon, seine vier Freunde stehen unten und schauen kopfschüttelnd hoch.'
  'Multiversal Passage' = 'Neue Idee: Das Portal wächst aus der Tasse auf dem Foto. Vom Foto nur die Tasse übernehmen: keine Personen, keine Hände, keine Logos oder Dateisymbole. Ein Schriftzug darf höchstens als goldene, unlesbare Gravur angedeutet sein.'
  'Earthbender Ascension|4' = 'Johann mit seinem markanten Schnurrbart, genau wie auf dem Charakterblatt – nicht Robin. Kopf und Körper zeigen in dieselbe Richtung: Er steigt den Weg zum Turm hinauf und schaut dabei nach vorn, natürliche Haltung, kein verdrehter Kopf.'
  # Länder: aufgeregt und abwechslungsreich, jedes Exemplar mit eigenem Wetter, Licht und Blickwinkel
  'Riverpyre Verge' = $landDynamik; 'Steam Vents' = $landDynamik; 'Spirebluff Canal' = $landDynamik
  'Elven Passage' = $landDynamik; 'Ba Sing Se' = $landDynamik; 'Escape Tunnel' = $landDynamik
  'Riverpyre Verge|1' = 'Das Foto (Fluss unter einer Steinbrücke) ist Vorlage für die Landschaft. Nacht: Das Lagerfeuer lodert hoch, ein Funkenwirbel stiebt über den Fluss und spiegelt sich im Wasser.'
  'Riverpyre Verge|2' = 'Gewitter über der Saale: Ein Blitz schlägt in den Fluss, Gischt spritzt, am Ufer trotzt ein magisches Feuer dem peitschenden Regen. Blick flussabwärts.'
  'Riverpyre Verge|3' = 'Sommerfest-Nacht: Feuerwerk über den Lichtern von Jena, die Saale führt Hochwasser und reißt Laternenboote mit, Flammen tanzen auf dem Wasser. Weitwinkel von oben.'
  'Riverpyre Verge|4' = 'Winter: Eisschollen treiben auf der Saale, ein Feuer am Ufer bringt das Eis zum Zischen, Dampfwirbel steigen auf, grünes Polarlicht am Himmel. Tiefe Perspektive knapp über dem Wasser.'
  'Steam Vents|1' = 'Hinter der Sauna bricht ein Vulkan aus, Lavaströme glühen, Dampfgeysire schießen hoch. Die Sauna steht trotzig im Vordergrund.'
  'Steam Vents|2' = 'Schneesturm in der Nacht: Die Sauna glüht warm, direkt daneben schießt ein mächtiger Geysir in den Sternenhimmel, Schneeflocken verdampfen in der Luft.'
  'Steam Vents|3' = 'Aufguss-Explosion: Eine gewaltige Dampfwolke sprengt die Saunatür auf, Eukalyptus-Dampfgeister wirbeln heraus; im Pool davor schauen orange-weiße Kois pikiert aus dem Wasser.'
  'Steam Vents|4' = 'Gewitter über einem Vulkankrater: Die Sauna steht auf einem Felsvorsprung am Kraterrand, Blitze und Lavafontänen ringsum. Dramatische Untersicht.'
  'Spirebluff Canal|1' = 'Sturm: Riesige Brandungswellen peitschen gegen die Klippe, Blitze über dem Meer, die Glas-Werkstatthalle leuchtet trotzig.'
  'Spirebluff Canal|2' = 'Feierabend im Sonnenuntergang: Ein magisches Hypercar-Gefährt aus Messing (ohne Logo) rast die kurvige Küstenstraße entlang, Funken und Lichtspuren hinter sich.'
  'Spirebluff Canal|3' = 'Früher Morgen: Ein Luftschiff landet an der Klippe, Möwenschwärme stieben auf, Gischt glitzert im ersten Sonnenlicht. Blick vom Meer aus nach oben.'
  'Spirebluff Canal|4' = 'Nacht: Biolumineszente Leuchtquallen und ein magischer Meeresstrudel unter der Klippe, die Glashalle strahlt, Feuerwerk über der Bucht.'
  'Elven Passage|1' = 'Das Foto (Sonnenuntergang am Hotel) ist Vorlage für die Stimmung. Rush-Hour am Terminal: viele Luftschiffe starten gleichzeitig, Wimpel knattern im Wind, Mövenschwärme.'
  'Elven Passage|2' = 'Eine dunkle Gewitterfront zieht über die Bucht von Palma, ein Luftschiff kämpft sich mit flatternden Segeln durch Böen und Blitze.'
  'Elven Passage|3' = 'Nacht: Feuerwerk über der Kathedrale von Palma, ein Luftschiff hebt mit einem Schwarm leuchtender Laternen ab. Blick von oben auf das Terminal.'
  'Ba Sing Se|1' = 'Den Koi-Teich vom Foto als Vorlage. Gewaltige Erdmauern brechen aus dem Boden und richten sich um das Haus auf, Staub und Steinbrocken fliegen.'
  'Ba Sing Se|2' = 'Sturm: Regen peitscht, Blitze zucken, aber magische Erdpfeiler stützen das wankende Haus samt Gerüst. Dramatische Untersicht.'
  'Ba Sing Se|3' = 'Nacht: Die Sauna dampft, der Pool leuchtet, die Festungsmauern glühen grün vor Erdmagie, eine Sternschnuppe zieht über das Dach. Weiter Blick von der Seite.'
  'Escape Tunnel|1' = 'Der Pool mit dem Einhorn vom Foto als Vorlage. Am Ende des Rankentunnels spritzt eine riesige Wasserfontäne aus dem Pool, als wäre gerade jemand hineingesprungen (die Person selbst ist nicht zu sehen).'
  'Escape Tunnel|2' = 'Nacht: Der Pool leuchtet magisch türkis, das aufblasbare Einhorn ist lebendig geworden und galoppiert über das Wasser, Glühwürmchen-Schwärme wirbeln durch den Tunnel.'
}
$ersatzPrompt = @{
  "Meltstrider's Resolve|4" = 'Johann als wilder Krieger nach dem „John Wolv“-Foto: nackter Oberkörper, Jeans, lange Klingen in den Händen, entschlossener Blick. Er steht in einer magischen Arena Rücken an Rücken mit Robin, beide umgeben von grünen Kampfeffekten. Episch, dramatisches Gegenlicht.'
}
$charakterRefs = @{
  Paul   = 'Paul/Paul_portrait_02.jpg', 'Paul/Paul_portrait_04.jpg', 'Nachlieferung/Paul_Genervt.jpg'
  Johann = 'Johann/Johann_ref_01.jpg', 'Johann/Johann_portrait_07.jpg', 'Johann/Johann_portrait_04.jpg'
  Max    = 'Max/Max_ref_01.jpg', 'Max/Max_portrait_04.jpg', 'Max/Max_portrait_03.jpg'
  Hermann = 'Hermann/Hermann_ref_01.jpg', 'Hermann/Hermann_portrait_01.jpg', 'Hermann/Hermann_portrait_11.jpg'
}
function Get-Wert($tab, $karte, $ex) { if ($tab.ContainsKey("$karte|$ex")) { $tab["$karte|$ex"] } elseif ($tab.ContainsKey($karte)) { $tab[$karte] } }

$rows = Import-Csv "$root\Planungstabelle.csv" -Delimiter ';' -Encoding UTF8
$anzahl = @{}; foreach ($g in $rows | Group-Object Karte) { $anzahl[$g.Name] = $g.Count }
$jobs = @{}
foreach ($c in 'Hermann', 'Paul', 'Johann', 'Max') {
  $jobs[$c] = New-Object System.Collections.ArrayList
  [void]$jobs[$c].Add([ordered]@{
      ziel = "Bilder/_Charakterblatt_$c.png"; format = '1536x1024'
      bilder = @($charakterRefs[$c] | ForEach-Object { "Fotos/$_" })
      prompt = "Charakterblatt von $c (die Person auf allen drei Fotos) im festgelegten Stil: nebeneinander Kopf frontal, Kopf im Profil und Ganzkörper stehend, auf ruhigem, hellem Hintergrund. Gesicht, Frisur, Bart, Brille und Statur exakt wie auf den Fotos. Schlichte dunkle Kleidung. Das Blatt ist die Referenz für alle weiteren Bilder von $c. Ausnahmsweise darf das Motiv bis an die Ränder gehen."
    })
}
foreach ($c in 'Gruppe', 'Laender') { $jobs[$c] = New-Object System.Collections.ArrayList }

foreach ($r in $rows | Sort-Object Karte, { [int]$_.Exemplar }) {
  $k = $r.Karte; $ex = [int]$r.Exemplar
  $ch = Get-Wert $chat $k $ex
  if (-not $ch) { throw "Kein Chat für $k" }
  if ($ch -eq 'Robin') { continue }

  $fotoListe = @(Get-Wert $fotos $k $ex | Where-Object { $_ } | ForEach-Object { "Fotos/$_" })
  if ($k -in 'Forest', 'Island', 'Mountain') {
    if ($r.Insider -notmatch '\(([^)]+)\)\s*$') { throw "Kein Foto für $k $ex" }
    $datei = $matches[1]
    $pfad = if ($datei -match '/') { "Fotos/$datei" } elseif ($k -eq 'Forest') { "Fotos/Gruppe/Garten-Jena/$datei" } else { "Fotos/Gruppe/Mallorca-JGA/$datei" }
    $motivText = $r.Insider -replace '\s*\([^)]+\)\s*$', ''
    $umgebung = $vollbild[$k]
    [void]$jobs[$ch].Add([ordered]@{
        ziel = $r.Bilddatei; format = '1024x1536'; bilder = @($pfad)
        prompt = "Verwandle dieses Gruppenfoto in eine gemalte Fantasy-Landschaft im festgelegten Stil, hochkant. Die Personen bleiben erkennbar, Haltung und Anordnung wie auf dem Foto, aber die Umgebung wird zu $umgebung. Das untere Drittel ruhig halten (dort kommt später ein Mana-Symbol hin). Motiv: $motivText."
      })
    continue
  }

  $leute = @(if ($personen.ContainsKey("$k|$ex")) { $personen["$k|$ex"] } elseif ($personen.ContainsKey($k)) { $personen[$k] } elseif ($ch -in $alle5) { $ch })
  $blaetter = @($leute | ForEach-Object { "Bilder/_Charakterblatt_$_.png" })
  $basis = Get-Wert $ersatzPrompt $k $ex
  if (-not $basis) { $basis = $prompts[$k] }
  if (-not $basis) { throw "Kein Prompt in Bildprompts.md für $k" }

  $teile = @($basis, '')
  $n = $anzahl[$k]
  if ($n -gt 1) {
    if ($basis -match '\bV\d') { $teile += "Dies ist Variante V$ex von $n." }
    else { $teile += "Dies ist Exemplar $ex von ${n}: Variiere Situation, Perspektive und Lichtstimmung gegenüber den anderen Exemplaren." }
  }
  $h = @((Get-Wert $hinweis $k $ex), $(if ($hinweis.ContainsKey("$k|$ex") -and $hinweis.ContainsKey($k)) { $hinweis[$k] })) | Where-Object { $_ }
  $teile += $h
  if ($blaetter) {
    $teile += "Die ersten $($blaetter.Count) Bilder sind Charakterblätter ($($leute -join ', ') in dieser Reihenfolge): Gesichter exakt so übernehmen."
  }
  if ($fotoListe) { $teile += "Die weiteren Fotos sind Vorlage für Ort, Pose, Kleidung oder Gegenstände." }
  if ($r.Flavortext) { $teile += "Das Bild soll zum Kartenspruch passen (den Spruch NICHT ins Bild schreiben): $($r.Flavortext)" }

  [void]$jobs[$ch].Add([ordered]@{
      ziel = $r.Bilddatei; format = '1536x1024'
      bilder = @($blaetter + $fotoListe)
      prompt = ($teile | Where-Object { $_ -ne $null }) -join "`n"
    })
}

New-Item -ItemType Directory -Force "$PSScriptRoot\Bildauftraege" | Out-Null
foreach ($c in $jobs.Keys) {
  ConvertTo-Json -InputObject @($jobs[$c]) -Depth 5 | Set-Content "$PSScriptRoot\Bildauftraege\$c.json" -Encoding UTF8
  "{0,-8} {1,3} Aufträge" -f $c, $jobs[$c].Count
}
