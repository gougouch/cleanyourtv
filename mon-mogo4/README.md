# Mon XGIMI MoGo 4 : nettoyé, épuré, réversible

XGIMI MoGo 4 (WK08K, carte `altai`, MediaTek), Google TV / Android 14, firmware
`UKNV.260910.001.16312074` (plus récent que la liste testée `examples/xgimi-mogo-4`, UKNV.260612.001).
Fait le 2026-11-23. Le détail de chaque commande est dans [JOURNAL.md](JOURNAL.md).

## Résultat

| | Avant | Après |
|---|---|---|
| Mémoire disponible (MemAvailable, 3 min après le démarrage, Paramètres ouverts) | 593 Mo | **667 Mo (+74 Mo)** |
| Paquets désactivés | 0 | 21 |
| Accueil | Google TV (pubs, recommandations) | Clean Your TV : dock de 6 apps seul en bas, tableaux CC0 en fond (un par heure), boutons ronds sans texte |
| Économiseur | Backdrop Google, 10 min | Aerial Views (vidéos 1080p + 51 tableaux du domaine public), 6 min |
| Mise en veille | 30 min | 25 min |
| Animations | 0.5 (d'usine) | 0.5 (inchangé) |
| Volume en appui long | continu | cran par cran (prix du raccourci de la touche Shortcut) |

## Ce qui a été désactivé (`pm disable-user`, rien de désinstallé côté système)

| Paquet | À quoi il servait |
|---|---|
| fusion.android.tv.demo | Démo magasin |
| com.xgimi.atvwifiverify | Vérification Wi-Fi d'usine |
| com.xgimi.minitvfactory | Menu d'usine XGIMI |
| com.xgimi.bugreportsender | Envoi de rapports de bugs à XGIMI |
| com.google.android.feedback | Avis Google |
| com.android.tv.feedbackconsent | Consentement aux diagnostics |
| com.mstar.android.tv.disclaimercustomization | Écran d'avertissement du premier démarrage |
| com.android.adservices.api | Services publicitaires Google (Privacy Sandbox) |
| com.android.ondevicepersonalization.services | Personnalisation publicitaire |
| com.android.federatedcompute.services | Apprentissage fédéré pour la pub |
| com.google.android.partnersetup | Attribution des installations (RLZ) |
| com.google.android.play.games | Play Jeux |
| com.google.android.youtube.tvmusic | YouTube Music |
| com.google.android.marvin.talkback | TalkBack (lecture d'écran) |
| com.google.android.katniss | Assistant Google / Gemini |
| com.google.android.tv.assistant | Voyant et mot-clé de l'Assistant |
| com.google.android.tv.remote.service | Téléphone comme télécommande (pas la télécommande Bluetooth) |
| com.xgimi.doubanfm | Appli musique XGIMI |
| com.orange.owtv.tv | Orange TV |
| com.google.android.syncadapters.calendar | Synchro Google Agenda |
| com.google.android.apps.tv.dreamx | Économiseur Backdrop et panneau Google Home |

Gardés exprès : **setupwraith** (le Wi-Fi utilisé lui appartient : le désactiver couperait le Wi-Fi),
**l'accueil Google `launcherx`** (XGIMI le réactive tout seul, la redirection du nouveau launcher
tient Home), Disney+, et tout ce qui gère focus, trapèze, HDMI, télécommande, Chromecast, clavier, Play.

Ouverture des apps : précompilation `cmd package compile -m speed` testée sur les 7 apps (mesures dans
JOURNAL.md) : pas de gain mesurable sauf Stremio (≈ −15 %), seule app gardée précompilée ; les autres remises
au mode par défaut (`compile --reset`).

Autre réglage : Netflix interdit en arrière-plan (`appops RUN_ANY_IN_BACKGROUND ignore`). Netflix
est dans la liste blanche système du firmware, donc il revient quand même à chaque démarrage.

## Apps installées

| App | Source | Rôle |
|---|---|---|
| Clean Your TV launcher (`com.gathin.tvhome`) | ce dépôt, compilé ici | Accueil ; `HOME_KEY_SERVICE=1`, `stock_home_redirect` |
| Aerial Views 1.8.6 | release GitHub theothernt/AerialViews | Économiseur |
| XStreaming 2.12.1 | release GitHub Geocld/XStreaming | Xbox Remote Play (dans la grille, pas dans le dock) |

Supprimées (installées par moi auparavant) : Better xCloud, Button Mapper.
Mini-app `eco-toggle/` : compilée et testée, puis désinstallée (l'appui long de la touche Shortcut
ouvre directement la page XGIMI). Gardée ici comme source.

## Configuration du launcher : [theme/config.json](theme/config.json)

- Dock : Netflix, YouTube, Prime Video, CANAL, Stremio, Disney+ (6 colonnes), seul en bas (`rows_below_dock: 0`),
  les autres apps en dessous (flèche bas). Boutons ronds sans texte (`icon_only_buttons`, `icon_only_inputs`,
  `wifi_label_width: 0`), dock à 70 % d'opacité.
- Fond : les 51 tableaux, préparés par `tools/wallpaper_prep.py <dossier> mon-mogo4/theme/wallpapers --brightness 0.45`
  (1280×720, < 300 Ko, ≈ 2 Mo en mémoire), un nouveau toutes les heures avec sa légende (`wallpapers/captions.txt`).
  Les .jpg ne sont pas dans git : les régénérer depuis les liens de [aerial/CREDITS.md](aerial/CREDITS.md).
- `key_filter: true`, `stock_home_redirect: com.google.android.apps.tv.launcherx`.
- Touche **Shortcut** (`KEY_F14`, scancode 184) : appui court = couper le son ;
  appui long = page XGIMI « Mode luminosité » (`com.xgimi.misckey/.activity.GtvBrightnessActivity`).
  Le mode Éco/Standard n'est stocké dans aucun réglage Android (vérifié par diff), d'où la page.
- Pour retrouver le volume continu : `key_filter: false` et retirer les deux lignes `app_keys`,
  puis `tools/theme.sh mon-mogo4/theme` (la touche Shortcut redevient « silence » XGIMI).

## Économiseur Aerial Views

- `screensaver_components = com.neilturner.aerialviews/.ui.screensaver.DreamActivity`
- `screen_off_timeout = 360000` (6 min : le minimum sur Google TV, 5 min ne démarre jamais)
- `sleep_timeout = 1500000` (veille à 25 min)
- Dans l'app : **tableaux seuls** (sources vidéo Apple, Amazon, Jetson, Robin Fourcade désactivées : démarrage et sortie
  plus rapides, aucun streaming), horloge seule ; source « Stockage local » filtrée sur
  le dossier `Economiseur` (`/sdcard/Pictures/Economiseur`, 51 œuvres CC0 : [aerial/CREDITS.md](aerial/CREDITS.md)).
- Photos copiées par ADB : lancer un scan média, sinon l'app ne les voit pas
  (`am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Pictures/Economiseur/<fichier>`).

## Tout annuler

Depuis la racine du dépôt, débogage sans fil activé sur le projecteur :

```bash
python3 -m venv tools/venv && tools/venv/bin/pip install -r tools/requirements.txt   # une fois
TV_HOST=<ip du projecteur> mon-mogo4/restore-all.sh
```

Il remet les paquets et Home (via `tools/restore.sh`), coupe le service d'accessibilité du launcher,
remet Backdrop (10 min, veille 30 min), les animations et Netflix en arrière-plan. Les apps installées
restent : Paramètres → Applications pour les supprimer. L'enregistrement d'annulation vit dans
`~/.cleanyourtv/` sur l'ordinateur qui a lancé `disable.sh` : le garder.

## Après une mise à jour XGIMI

Une mise à jour peut réactiver des paquets, ajouter des préinstallations et retirer le service
d'accessibilité du launcher.

1. Activer le débogage sans fil (Paramètres → Système → Options pour les développeurs), accepter
   la fenêtre « Autoriser le débogage ».
2. Récupérer ce fork : `git clone https://github.com/gougouch/cleanyourtv` (ou `git pull`), puis le venv.
3. Voir ce qui a bougé :
   `TV_HOST=<ip> tools/venv/bin/python -I tools/check.py mon-mogo4/debloat.txt`
   (code 0 = rien n'a bougé, 1 = des paquets sont revenus).
4. Réappliquer la liste : `TV_HOST=<ip> tools/venv/bin/python -I tools/check.py --fix mon-mogo4/debloat.txt`
5. Remettre le service et la config du launcher : `TV_HOST=<ip> tools/theme.sh mon-mogo4/theme`
   (si le launcher a disparu : `TV_HOST=<ip> HOME_KEY_SERVICE=1 STOCK_LAUNCHER=none launcher/build-and-install.sh`,
   puis le `theme.sh`).
6. Vérifier : Home, touche Shortcut, économiseur (`settings get secure screensaver_components`).
7. Couper le débogage sans fil.
