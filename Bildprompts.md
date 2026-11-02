# Bildprompts für ChatGPT – Fotos im Stil von Fantasy-Kartenillustrationen

Stand: 30.10.2026. Grundlage sind die Flavornamen in `Kartenpool.csv`.

## Arbeitsablauf

1. **Pro Person einen eigenen ChatGPT-Chat anlegen**, zum Beispiel „Karten Robin“. So bleibt das Gesicht über alle Karten hinweg gleich.
2. **Erste Nachricht im Chat:** den Stilblock unten und 2–3 gute Porträtfotos der Person hochladen. Dazu schreiben: *„Erstelle zuerst ein Charakterblatt dieser Person in diesem Stil (Kopf frontal + seitlich, Ganzkörper). Das ist die Referenz für alle weiteren Bilder.“*
3. **Danach pro Karte:** das passende Foto (falls vorhanden) und den Kartenprompt einfügen.
4. **Ergebnis speichern** unter `Bilder/<Karte>_<Exemplar>.png`, zum Beispiel `Bilder/Sunderflock_2.png`.
5. **Prüfliste** unten abhaken. Wenn etwas nicht passt, im selben Chat nachbessern, etwa: „Gesicht näher am Foto, sonst gleich lassen“.

**Formate** (die Größen bietet ChatGPT so an):

- **Kartenbild:** quer, 1536 × 1024. Wird auf den Bildbereich der Karte zugeschnitten (etwa 57 × 42 mm).
- **Vollbild-Land:** hoch, 1024 × 1536. Wird auf die ganze Karte zugeschnitten (63 × 88 mm plus Beschnitt).

**Wichtig:**

- Rahmen, Kartenname und Text **nicht** von ChatGPT erzeugen lassen. Das macht später das Kartenprogramm (z. B. Magic Set Editor).
- Fotos von Freunden werden an OpenAI hochgeladen. Am besten nur Bilder nehmen, mit denen die Jungs einverstanden wären.
- Kinder und Partnerinnen nie als Foto hochladen. Wenn sie vorkommen sollen, nur als Silhouette oder von hinten.
- **Ausnahme: Vicky** (Robins Frau) darf mit echtem Foto vorkommen, z. B. bei der Wiesn-Ablenkung (V2) oder am Lagerfeuer.

---

## Stilblock (einmal pro Chat als Erstes einfügen)

```
Du bist Illustrator für ein Fantasy-Sammelkartenspiel. Verwandle meine Fotos in Kartenillustrationen mit diesen festen Regeln:
- Stil: gemalte, detailreiche Fantasy-Illustration (digitale Ölmalerei), dramatisches Licht, satte Farben, leichter Pinselduktus, keine Fotooptik, kein Comic, kein 3D-Render.
- Personen: Gesichter klar wiedererkennbar wie auf meinen Fotos (Gesichtsform, Frisur, Bart, Brille), aber gemalt und leicht heroisch überhöht.
- Welt: Alltagsdinge werden in eine Fantasywelt übersetzt (Auto → magisches Gefährt, Handy → leuchtendes Artefakt, Garten → verzauberter Hain), bleiben aber erkennbar – darin liegt der Witz.
- Komposition: Hauptmotiv mittig bis leicht oben, ruhige Ränder (wird beschnitten), kein Text, keine Schrift, keine Logos, keine Wasserzeichen, kein Kartenrahmen.
- Format: wenn nicht anders angegeben 1536×1024 quer.
Bestätige kurz und warte auf das erste Motiv.
```

---

## Kartenprompts

Die Anzahl in Klammern ist die Zahl der Exemplare. Bei 4 Exemplaren bekommt jedes eine eigene Variante (V1–V4), damit kein Bild doppelt vorkommt.

### Robin

**Der Zinseszins** – *Mightform Harmonizer* (4)
```
Robin als Druide in einem goldenen Hain. Aus jedem Erdboden-Feld, das er berührt, wächst ein Baum aus Goldmünzen, jeder doppelt so groß wie der vorige. Er hält ein leuchtendes Tablet wie ein Zauberbuch, auf dem eine steile Kurve glüht. Warmes Morgenlicht, ehrfürchtige Stimmung.
V1 Setzling · V2 junger Baum · V3 großer Baum · V4 gigantischer Goldbaum über den Wolken.
```

**Robins Siebträger: Knopf drücken** – *Llanowar Elves* (4)
```
Robin als entspannter Waldelf, der mit einem Finger einen leuchtenden Knopf an einer magischen Espresso-Maschine aus Wurzelholz drückt. Aus dem Auslauf fließt grün-goldene Mana-Energie als „braunes Gold“ in eine Tasse. Er lehnt sich zurück, völlig tiefenentspannt.
V1 Morgenkaffee · V2 nach dem Rennrad im Trikot · V3 im Büro mit Anzug-Rüstung · V4 mit Arena-Tablet in der anderen Hand.
```

**Rendite-Spezialisten Gold** – *Opt* (4)
```
Robin als Gelehrter in einem Turm voller Schriftrollen, er verteilt magische Pergamente mit goldenem Siegel, die wie Brieftauben zu vier Freunden fliegen. Bläuliches Kerzenlicht, Atmosphäre einer Bibliothek.
V1–V4: je eine andere „Ausgabe“: Winter-, Frühlings-, Sommer-, Herbststimmung.
```

**Stock Up – Sparplan ausgeführt** – *Stock Up* (1)
```
Robin in einer Schatzkammer, ruhig und zufrieden, legt Münze für Münze auf einen ordentlichen, stetig wachsenden Stapel. Ein magisches Uhrwerk tickt im Hintergrund. Blau-goldenes Licht, Gelassenheit statt Gier.
```

**Arena, Runde 100** – *Elusive Otter* (4)
```
Ein verschmitzter Otter mit Robins Gesichtszügen und Frisur sitzt nachts auf einem Kissen und spielt auf einem leuchtenden Tablet, um ihn schweben kleine magische Duell-Karten. Ein Zähler aus Licht zeigt Runden-Striche an der Wand.
V1–V4: Uhrzeit-Stimmung 20 Uhr, 23 Uhr, 2 Uhr, Sonnenaufgang (Augenringe werden größer).
```

**Wiesn-Ablenkung** – *Bounce Off* (2)
```
Fantasy-Volksfest mit riesigem Festzelt, Robin in Lederhosen-Rüstung dreht sich mitten im Prosten verdutzt um, sein Krug wird von einem Wirbelwind aus Blau-Magie davongetragen. Im Vordergrund nur von hinten angeschnitten: eine Frauenfigur im Dirndl, die Schleife deutlich sichtbar. Fröhlich-frech, nicht anzüglich.
V2: Eine Frau in Dirndl von hinten mit verschränkten Armen und einer Maß – nur Silhouette, kein Gesicht.
```

**Oktoberfest** – *Sapling Nursery* (2)
```
Ein verzauberter Biergarten, in dem aus jedem Stück Erde ein Baumriese wächst, dessen Krone wie ein schäumender Maßkrug geformt ist. Robin in der Mitte hebt jubelnd den Krug. Lampions, Abendlicht, Volksfeststimmung.
```

### Hermann

**Hermanns Luftschloss** – *Sunderflock* (4)
```
Ein prächtiges, schwebendes Schloss aus Wolken, Zahnrädern, Kaffeedampf und Cocktailgläsern hoch über einer Landschaft. Auf dem Balkon steht Hermann, verträumt lächelnd, mit einem Bauplan in der Hand. Unter dem Schloss sieht man, dass es auf sehr dünnen Fäden hängt. Blau-violetter Himmel, Sonnenuntergang.
V1 im Bau · V2 fertig · V3 mit Kreditbriefen als Wolken · V4 seine Freunde schauen kopfschüttelnd von unten zu.
```

**Themencocktail nach Sonderwunsch** – *Prismari Charm* (4)
```
Hermann als Alchemist-Barkeeper hinter einer Gartenbar aus Holz bei Lagerfeuerlicht, vor ihm drei magische Cocktails: einer blau mit Wirbel, einer feuerrot mit Funken, einer schillernd mit Wellen. Er schüttelt einen Shaker, aus dem Zauberfunken sprühen.
V1–V4: verschiedene Cocktail-Themen (Mallorca-Sonnenuntergang, Jena-Lagerfeuer, Hochzeit, Winter).
```

**Das eingestaubte Rennrad** – *Eddymurk Crab* (4)
```
Eine riesige, freundliche Krabbe aus Moos, Staub und Spinnweben, die sich langsam aus einer Garage erhebt; auf ihrem Panzer hängt ein komplett eingestaubtes Rennrad. Im Hintergrund schaut Hermann schuldbewusst mit einer Tasse Espresso zu. Blau-grünes Licht, humorvoll.
V1–V4: Staubschicht wird mit jeder Variante dicker, V4 mit Pflanzen, die aus den Speichen wachsen.
```

**„Da les ich mich mal ein“** – *Flow State* (2)
```
Hermann sitzt im Schneidersitz in einem Strudel aus schwebenden Büchern, Bauplänen, Kaffeebohnen und Cocktailrezepten, die Augen leuchten blau, völlig vertieft. Ruhiges, meditatives Licht.
```

**Der Puzzle-Adventskalender** – *Esper Origins* (3)
```
Ein magischer Adventskalender aus Holz, dessen Türchen aus Puzzleteilen bestehen; aus einem geöffneten Türchen steigt ein Geistwesen aus leuchtenden Karten empor. Hermann zündet daneben eine Kerze an. Warmes Winterlicht, Schneeflocken.
```

### Paul

**Paul, nicht diskutierbar** – *Surrak, Elusive Hunter* (2)
```
Paul als unaufhaltsamer Jäger in Rennrad-Rüstung, der einen steilen Bergpass hochstürmt; Gegenzauber von Gegnern zerplatzen wirkungslos an ihm wie Seifenblasen. Entschlossener Blick, grüne Kraftaura.
```

**„Das ist die einzig logische Meinung“** – *Pompous Battlemage* (2)
```
Paul als selbstbewusster Kampfmagier auf einem kleinen Podest, eine Hand erhoben, über ihm schwebt ein leuchtendes Flipchart; eine Gruppe Zuhörer nickt hypnotisiert mit leuchtenden Augen. Rotes Feuerlicht, leicht ironische Heldenpose.
```

**Pauls Ausraster** – *Burst Lightning* (4)
```
Paul, aus dessen Kopf ein Blitz schießt, mitten in einer Situation, die gerade eskaliert; die Umgebung wird von roter Energie erfasst. Humorvoll überzeichnet, nicht wütend-bedrohlich.
V1 Konzern-Meeting · V2 kaputte Fahrradkette · V3 Stau · V4 (Kicker) im Auto, auf der Rückbank nur zwei kleine Silhouetten mit Zöpfen, von hinten.
```

**Zocken mit Spielgeld** – *Wild Ride* (3)
```
Paul reitet lachend auf einem feurigen, wilden Bullen aus roter Energie über ein Börsenparkett aus Kristall, um ihn fliegen Münzen und brennende Kurs-Pfeile. Rasante Bewegung, Geschwindigkeit.
V1 Pfeile nach oben · V2 Pfeile nach unten, Paul fällt · V3 er steigt wieder auf.
```

**Pauls Feedbackgespräch** – *Traumatic Critique* (3)
```
Paul als ruhiger, aber unerbittlicher Inquisitor an einem langen Tisch, vor ihm ein Gegenüber, das unter einem Strahl aus blau-roter Energie zusammenschrumpft. Auf dem Tisch ein Kaffee aus dem Siebträger. Ernst, aber mit Augenzwinkern.
```

**„Geht das nicht effizienter?“** – *Hard-Hitting Question* (2)
```
Paul zeigt mit dem Finger auf ein umständliches, wackeliges Gerät aus Zahnrädern, und eine grüne Kraftwelle schießt aus seinem Finger und bringt es zum Einsturz. Hermann steht daneben mit Schraubenschlüssel und offenem Mund.
```

### Johann

**Johann der Heimwerker** – *Icetill Explorer* (4)
```
Johann als zäher Abenteurer mit Werkzeuggürtel, der ein halb verfallenes, mit Efeu bewachsenes Haus mit grüner Erdmagie wieder aufrichtet; Steine schweben zurück an ihren Platz. Im Garten im Hintergrund: Koi-Teich und Pool.
V1–V4: Dach, Wände, Teich, Sauna.
```

**Klippenspringer von Mallorca** – *Slickshot Show-Off* (4)
```
Johann im Sprung von einer hohen Mittelmeerklippe, in perfekter Pose, mit Flammenspur wie ein Phönix; unten türkisblaues Wasser, oben jubelnde Freunde als kleine Figuren.
V1–V4: Klippe jedes Mal höher, V4 Wolken unter ihm.
```

**Das Glas ist halb leer** – *Spell Snare* (2)
```
Johann blickt skeptisch auf ein magisches Glas, dessen Inhalt in einem blauen Wirbel verschwindet; neben ihm hält Hermann ein offensichtlich leeres Glas strahlend hoch. Humorvolle Gegensätze.
```

**Helge-Schneider-Zitat** – *Impractical Joke* (2)
```
Johann als exzentrischer Barde mit Hut und Instrument auf einer kleinen Bühne, sein Lied erzeugt chaotische rote Funkenschnörkel, das Publikum aus Fantasywesen lacht und fällt um. Absurd, warm, verspielt. (Keine echte Person außer Johann darstellen.)
```

**Johann im Kundentermin** – *Carnivorous Cultivator* (4)
```
Johann als charmanter Waldläufer mit Ranken, die freundlich, aber unausweichlich einen Kunden umschlingen, der lächelnd einen Vertrag aus Blättern unterschreibt. Grünes Licht.
V1–V4: Kunde aus verschiedenen Branchen (Bäcker, Handwerker, Arzt, Gastronom).
```

**Johanns Haus** – *Ba Sing Se* (3) · Land
```
Ein großes, leicht baufälliges Haus als Festung in einer grünen Landschaft, mit Gerüst, Koi-Teich, Pool und dampfender Sauna; aus dem Boden steigen Erdmauern, die es stützen. Keine Personen.
```

**Das Baugutachten** – *Demolition Field* (1) · Land
```
Ein Gutachter-Golem aus Stein mit Klemmbrett zerbricht mit einem Stempel ein wackliges Gebäude; Staubwolke, Goldlicht. Keine echten Personen.
```

**Der Weg zum Pool** – *Escape Tunnel* (2) · Land
```
Ein verwunschener Pfad durch einen Garten, der in einem Tunnel aus Ranken zu einem leuchtend blauen Pool führt. Abendlicht, Glühwürmchen. Keine Personen.
```

### Max

**Bugatti (Prototyp)** – *Lumbering Worldwagon* (1)
```
Ein gewaltiges, magisch-mechanisches Gefährt mit Hypercar-Silhouette, aber aus Erde, Wurzeln und Messing; Max schraubt mit Ingenieursbrille am offenen Motor, vier Freunde schieben hinten an. Kroatische Küste im Hintergrund. Kein Markenlogo.
```

**Der Turbolader** – *Mossborn Hydra* (4)
```
Eine mehrköpfige Hydra aus Moos und Chrom, deren Köpfe wie Turbinen aussehen; Max steht davor und dreht an einem riesigen Ventil, und mit jeder Drehung wächst ein neuer Kopf. Grüner und kupferner Glanz.
V1–V4: 1, 2, 4, 8 Köpfe.
```

**Die kesse Sohle** – *Colorstorm Stallion* (3)
```
Max tanzt auf einer Hochzeitstanzfläche einen wilden, eleganten Tanz, aus seinen Schuhen sprühen blau-rote Funken, und aus den Funken entstehen leuchtende Pferde-Geister, die mittanzen. Festliche Lichterketten, Seifenblasen in der Luft.
```

**Max im Sternerestaurant** – *Keen-Eyed Curator* (2)
```
Max als eleganter Waschbär-Gourmet (Max' Gesichtszüge erkennbar) mit Monokel an einem edlen Tisch, vor ihm vier winzige, kunstvoll angerichtete Gänge, die magisch leuchten. Robin sitzt ihm gegenüber und hebt das Glas.
```

**Max philosophiert** – *Sleight of Hand* (4)
```
Max sitzt an einem Lagerfeuer, zwischen seinen Händen schweben zwei leuchtende Gedankenkugeln (eine mit Zahnrädern, eine mit Sternen); er betrachtet sie nachdenklich. Blaues und warmes Licht gemischt.
V1–V4: unterschiedliche Gedankenpaare (Motor/Universum, Fahrrad/Zeit, Essen/Kunst, Technik/Freundschaft).
```

**Max zieht den Stecker** – *Torpor Orb* (2)
```
Ein schwebender Messing-Orb voller Zahnräder, an dem Max einen leuchtenden Stecker zieht; um ihn herum erstarren magische Kreaturen mitten in der Bewegung. Kühles Licht.
```

### Gruppe

**Projekt „Zur erfolgreichen Praxis“** – *Earthbender Ascension* (4)
```
Ein magischer Turm, der aus der Erde wächst, mit vier leuchtenden Stockwerken (SEO-Schriftrollen, Vertriebskarte, Werbe-Feuerwerk, Schatzkammer ganz oben). Im Vordergrund steht die jeweilige Person vor dem Wahrzeichen ihrer Stadt, kein Text.
V1 Hermann vor dem Aachener Dom · V2 Paul vor dem Völkerschlachtdenkmal in Leipzig · V3 Robin vor der Münchner Frauenkirche · V4 Johann vor dem JenTower in Jena, kommt gerade erst den Weg herauf.
```

**Lagerfeuer im Garten in Jena** – *Hearth Elemental* (4)
```
Ein riesiges, gutmütiges Feuerelementar wächst aus einem Lagerfeuer in einem nächtlichen Garten, um es herum sitzen fünf Freunde mit Cocktails und lachen. Funken, Sterne, warme Sommernacht.
V1–V4: jeweils ein anderer Freund im Vordergrund (Hermann am Shaker, Johann mit Gin, Max erzählt, Paul gestikuliert).
```

**Seifenblasenkanone** – *Vibrant Outburst* (2)
```
Paul und Johann schreiten in festlicher Kleidung durch einen Kirchengang und feuern aus riesigen magischen Kanonen Seifenblasen, die als blau-rote Energiekugeln explodieren; das Publikum ist vor Staunen erstarrt. Jubelnde, epische Stimmung.
```

**Der ETF-Sparplan** – *Sazh's Chocobo* (4)
```
Ein flauschiger, gelber Laufvogel, der auf einer grünen Weide steht und mit jedem Schritt, den er auf neues Land setzt, etwas größer und goldener wird; Robin und Hermann füttern ihn geduldig mit kleinen Münzen.
V1–V4: Küken · Jungvogel · stattlich · riesig und golden.
```

**LoL, Runde 20** – *Meltstrider's Resolve* (4)
```
Robin und Johann als zwei Champions in einer magischen Arena, Rücken an Rücken kämpfend, umgeben von leuchtenden Fähigkeiten-Effekten; im Vordergrund leere Bierflaschen und ein Laptop-Glimmen. Nachtstimmung.
```

### Länder

**Saaleufer Jena** – *Riverpyre Verge* (4)
```
Fluss bei Nacht, am Ufer ein Lagerfeuer, Lichter einer kleinen Stadt im Hintergrund, Wasser und Feuer spiegeln sich. Keine Personen.
```

**Johanns Sauna** – *Steam Vents* (4)
```
Eine Holzsauna am Rand eines Gartens mit dampfenden Vulkanquellen ringsum, Dampfschwaden steigen in den Sternenhimmel. Keine Personen.
```

**Kroatische Küste** – *Spirebluff Canal* (4)
```
Steile Felsküste an der Adria mit türkisem Wasser und einer Werkstatt-Halle aus Glas auf der Klippe. Keine Personen.
```

**WhatsApp-Gruppe „Projekt Reichtum“** – *Multiversal Passage* (2)
```
Ein magisches Portal aus fünf ineinander verschlungenen Leuchtringen, durch das man fünf verschiedene Welten sieht (Garten, Meer, Berge, Stadt, Schatzkammer). Keine Schrift, kein Logo.
```

**A9 München–Jena** – *Fabled Passage* (4)
```
Eine magische Fernstraße, die sich durch Wälder und Hügel windet, ein leuchtendes Gefährt fährt in den Sonnenuntergang Richtung einer fernen Gartenlaterne.
```

**Flughafen Palma** – *Elven Passage* (3)
```
Ein magisches Luftschiff-Terminal an einer Mittelmeerküste, ein Luftschiff hebt in Richtung untergehender Sonne ab. Keine Personen.
```

**Vollbild-Länder (hochkant 1024×1536):** Für jedes Grundland ein eigenes Foto, denn da sind eure echten Gruppenfotos der Star.
```
Verwandle dieses Gruppenfoto in eine gemalte Fantasy-Landschaft im festgelegten Stil, hochkant 1024×1536. Die Personen bleiben erkennbar, aber die Umgebung wird zu [Wald/Hain | Meeresküste | Gebirgspass]. Das untere Drittel ruhig halten (dort kommt später ein Mana-Symbol hin).
```

- **Forest** (13): Garten in Jena, Ordner `Gruppe/Garten-Jena`
- **Island** (5): Mallorca, Ordner `Gruppe/Mallorca-JGA`
- **Mountain** (1): Alpen, Ordner `Gruppe/Alpen-Rennrad`

---

## Prüfliste pro Bild

- [ ] Gesicht ist erkennbar. Jemand aus der Gruppe sagt ohne Hinweis: „Das ist X.“
- [ ] Das Bild sieht gemalt aus, nicht wie ein gefiltertes Foto.
- [ ] Kein Text, kein Logo, kein Kartenrahmen im Bild.
- [ ] Das Hauptmotiv ist nicht am Rand, damit beim Zuschneiden nichts Wichtiges verloren geht.
- [ ] Der Stil passt zu den bisherigen Bildern (Bilder nebeneinanderlegen).
- [ ] Kinder und Partnerinnen sind höchstens als Silhouette zu sehen.
