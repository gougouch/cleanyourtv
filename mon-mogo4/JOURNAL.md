# Journal — XGIMI MoGo 4 (WK08K, altai)

Une ligne par commande : heure, ce que fait la commande, son résultat.

## Phase 0 — Préparation (2026-11-23)

| Heure | Commande | Résultat |
|---|---|---|
| 13:24 | `which adb gh brew` | aucun des trois n'est installé |
| 13:24 | téléchargement de `platform-tools-latest-darwin.zip` (dl.google.com) → `~/tools/platform-tools` | OK, adb 37.0.3 |
| 13:24 | téléchargement de `gh_2.105.0_macOS_arm64.zip` (github.com/cli/cli releases) → `~/tools/gh-cli` | OK, gh 2.105.0 |
| 13:25 | ajout de `~/tools/...` au PATH dans `~/.zshrc` | refusé par le garde-fou : on utilise les chemins complets |
| 13:25 | `gh auth status` | pas connecté → à faire par l'utilisateur |
| 13:25 | `git clone https://github.com/Gathin23/cleanyourtv` | OK (commit `fe6cdcef`) ; le fork sera ajouté via `gh repo fork --remote` |
| 13:25 | `adb connect <ip projecteur>:<port>` | `No route to host` |
| 13:26 | `ping <ip projecteur>` / `arp -an` / `ping <ip box>` | projecteur présent dans la table ARP mais pas de réponse ; le routeur répond → veille ou confidentialité « Réseau local » de macOS |
| 13:27 | `python3 -m venv tools/venv && pip install -r tools/requirements.txt` | OK (adb_shell 0.4.4) |
| 13:40 | `gh auth status` | connecté (compte gougouch) |
| 13:40 | `ping <ip projecteur>` | répond, ~250 ms (latence élevée, à surveiller) |
| 13:41 | `gh repo fork --remote` puis `git remote rename origin upstream` + `git remote add origin <fork>` | fork créé, remotes : origin = fork, upstream = Gathin23 |
| 13:43 | `tools/tv.py --probe` | port 5555 ouvert, poignée de main expirée → en attente de « Autoriser le débogage » sur le projecteur |
| 13:46 | « Autoriser le débogage » accepté sur le projecteur ; `tools/tv.py --probe` | OK : WK08K, altai, Android 14 (SDK 34), ro.adb.secure=1 |
| 13:47 | `getprop ro.build.display.id / ro.build.fingerprint` | `UKNV.260910.001.16312074` / `XGIMI/dayao/altai:14/UKNV.260910.001/16312074:user/release-keys`, patch sécurité 2026-09-01 (testé : UKNV.260612.001) |
| 13:48 | `pm list packages`, `-d`, `-3` (--user 0) | 155 paquets, 0 désactivé, 13 apps utilisateur (dont flar2.homebutton, com.redphx.betterxc, stremio, disney+, orange tv) |
| 13:49 | comparaison avec debloat.txt | les 22 paquets de la liste sont présents ; nouveaux non cités : 5 overlays com.mediatek.* (on n'y touche pas) |
| 13:49 | `settings get secure enabled_accessibility_services` | vide, accessibility_enabled 0 |

## Phase 1 — Sauvegarde et mesures « avant » (2026-11-23)

| Heure | Commande | Résultat |
|---|---|---|
| 13:35 | `pm list packages -f/-s/-d/-3 --user 0` → backup/avant/ | 155 / 142 / 0 / 13 |
| 13:35 | `settings list global/system/secure` → backup/avant/ | 375 / 45 / 113 lignes |
| 13:35 | `cmd package resolve-activity ... HOME` | `com.google.android.apps.tv.launcherx/.home.HomeActivity` ; candidats : setupwraith RecoveryActivity (prio 1), tv.settings FallbackHome |
| 13:35 | échelles d'animation | 0.5 / 0.5 / 0.5 (déjà la cible de la Phase 4) |
| 13:35 | économiseur / veille | `screensaver_components` = `com.google.android.apps.tv.dreamx/.service.Backdrop`, screen_off_timeout 600000, sleep_timeout 1800000, attentive_timeout -1 |
| 13:35 | `getprop`, `wm size/density` | 1920x1080, densité 320, pas de forçage |
| 13:38 | création `mon-mogo4/debloat.txt` (copie de la liste MoGo 4, Disney+ commenté) | OK |
| 13:39 | écriture `mon-mogo4/restore-all.sh`, `bash -n` | OK |
| 13:38 | `sync` puis `reboot` | connexion coupée pendant le reboot (normal) ; le projecteur a redémarré |
| 13:40 | débogage sans fil réactivé à la main ; `cat /proc/uptime` | 193 s depuis le démarrage (> 2 min) |
| 13:40 | `cat /proc/meminfo` → backup/avant/proc-meminfo.txt | MemTotal 1 865 124 kB, **MemAvailable 607 676 kB (~593 Mo)**, swap zram utilisé ~350 Mo |
| 13:41 | `dumpsys meminfo` → backup/avant/dumpsys-meminfo.txt | Free 564 250K, Used 1 516 268K ; Paramètres ouverts au 1er plan (111 Mo), Netflix/Canal/Stremio/Prime en arrière-plan, launcherx 74+31 Mo, katniss 36+29 Mo |

## Phase 2 — Nettoyage (2026-11-23)

Méthode : une seule liste `mon-mogo4/debloat.txt` ; les lots à venir sont préfixés `#lotN#` et activés au fur et à mesure (l'enregistrement d'annulation de disable.sh ajoute les nouveaux noms avec leur état d'origine).

| Heure | Commande | Résultat |
|---|---|---|
| 13:42 | `TV_HOST=… tools/disable.sh mon-mogo4/debloat.txt` (lot 1 : 10 paquets) | enregistrement `~/.cleanyourtv/recovery-…-1f546bea.json` (11 paquets, Home = launcherx) copié dans backup/ ; les 10 en `disabled-user` : fusion.android.tv.demo, com.xgimi.atvwifiverify, com.xgimi.minitvfactory, com.xgimi.bugreportsender, com.google.android.feedback, com.android.tv.feedbackconsent, com.mstar.android.tv.disclaimercustomization, com.android.adservices.api, com.android.ondevicepersonalization.services, com.android.federatedcompute.services |
| 13:44 | lot 1 testé par l'utilisateur : focus, trapèze, réglages rapides, volume long, Home, Retour, streaming | tout OK |
| 13:44 | `sed` retire `#lot2#` ; `TV_HOST=… tools/disable.sh mon-mogo4/debloat.txt` (lot 2 : 9 paquets) | enregistrement conservé + 9 noms ajoutés ; désactivés : partnersetup, play.games, youtube.tvmusic, marvin.talkback, katniss, tv.assistant, tv.remote.service, xgimi.doubanfm, orange.owtv.tv ; total 19 désactivés |
| 13:47 | lot 2 testé par l'utilisateur | tout OK |
| 13:48 | `dumpsys wifi` (README MoGo 4, SSID masqués) | 3 réseaux enregistrés ; **le réseau connecté (ID 1, masqué/hidden) a `cname=com.google.android.tungsten.setupwraith`** ; les 2 autres = android.uid.system. → lot 3 NON lancé, pas de FORCE_SETUPWRAITH : il faut d'abord oublier et rejoindre ce réseau sur le projecteur |
| 13:55 | décision utilisateur : setupwraith et launcherx gardés activés (pas de manip Wi-Fi) ; nettoyage arrêté à 19 paquets | `mon-mogo4/debloat.txt` mis à jour (lignes commentées « GARDÉ ») |

## Phase 3 — Launcher (2026-11-23)

| Heure | Commande | Résultat |
|---|---|---|
| 13:54 | Temurin JDK 17 (github.com/adoptium/temurin17-binaries, `OpenJDK17U-jdk_aarch64_mac_hotspot_17.0.21.1_2.tar.gz`) → `~/tools/jdk17` | OK, java 17.0.21.1 avec jlink |
| 13:55 | `commandlinetools-mac-15641748_latest.zip` (dl.google.com) → `~/tools/android-sdk/cmdline-tools/latest` | OK, sdkmanager 21.0 |
| 13:57 | écriture `mon-mogo4/theme/config.json` | dock 6 apps, 6 colonnes, fond noir fixe, key_filter false, stock_home_redirect launcherx |
| 14:00 | `sdkmanager --licenses` (accord de l'utilisateur) puis `sdkmanager "platforms;android-34" "build-tools;34.0.0"` | OK |
| 13:56 | `TV_HOST=… HOME_KEY_SERVICE=1 STOCK_LAUNCHER=none JAVA_HOME=… ANDROID_HOME=… launcher/build-and-install.sh` | compilé (Gradle 8.9), APK poussé (md5 OK), installé, démarrage à froid 1,96 s, compilé en `speed`, launcherx laissé activé, HomeKeyService activé ; permission localisation accordée (nom du Wi-Fi dans la barre) |
| 13:57 | `tools/theme.sh mon-mogo4/theme` | thème appliqué ; accessibilité = `com.gathin.tvhome/.HomeKeyService` seul, lié |
| 13:57 | `input keyevent KEYCODE_HOME` (simulé) | premier plan : `com.gathin.tvhome/.MainActivity` ; capture shots/launcher-1.png OK (dock 6 apps) |
| 14:00 | mémoire après install : `dumpsys meminfo`, `/proc/meminfo` | MemAvailable 643 112 kB ; tvhome 57 Mo, launcherx 112+29 Mo (toujours chargé) |
| 14:02 | checklist télécommande réelle : Home (accueil + depuis une app), volume long (continu), engrenage, touches Netflix/YouTube/Prime puis Home, Retour, Sources/HDMI, focus, trapèze, réglages rapides | **tout OK** (utilisateur) |
| 14:00 | `sync` puis `reboot` (test de tenue) | envoyé |
| 14:04 | après reboot (uptime 165 s) : `logcat -b events \| grep wm_set_resumed_activity` | FallbackHome 14:01:22 → launcherx 14:01:28 → tvhome 14:01:33 (≈5 s d'accueil Google, vu ~1 s par l'utilisateur, icônes grisées) |
| 14:04 | accessibilité après reboot | `com.gathin.tvhome/.HomeKeyService` toujours activé et lié ; 19 paquets désactivés ; launcherx activé (voulu) |
| 14:04 | appui long Home (utilisateur) | ouvre `launcherx/.dashboard.DashboardHandler` (panneau rapide Google TV) — comportement de l'accueil Google laissé activé |
| 14:05 | mémoire → backup/apres-launcher/ | MemAvailable 609 976 kB (avant : 607 676) ; tvhome 84 Mo, launcherx 82+28 Mo, Netflix et Canal démarrent seuls en fond |
| 14:07 | test d'utilisation : `dumpsys accessibility`, `mFocusedApp`, `logcat -b events` | uptime 348 s (≈6 min) ; HomeKeyService toujours lié ; tvhome au 1er plan ; seule app ouverte : YouTube (14:06:25) ; chaque Home passe par launcherx ~0,7–1,2 s avant tvhome. Test plus court que 10 min → à reconfirmer en Phase 7 après une vraie soirée |

## Optimisations mémoire supplémentaires (2026-11-23, à la demande de l'utilisateur)

| Heure | Commande | Résultat |
|---|---|---|
| 14:20 | `appops get launcherx SYSTEM_ALERT_WINDOW` (sauvegardé) | `default` |
| 14:20 | `appops set launcherx SYSTEM_ALERT_WINDOW allow` puis `cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity` | `Success`, mais resolve-activity HOME = toujours launcherx |
| 14:21 | test : YouTube puis `input keyevent KEYCODE_HOME`, `logcat wm_set_resumed_activity` | launcherx s'ouvre d'abord (priorité système 2 contre 0), redirection vers tvhome 0,5 s après → **préférence ignorée sur ce Google TV : étape abandonnée** |
| 14:22 | `appops set launcherx SYSTEM_ALERT_WINDOW default` | remis à la valeur d'origine |
| 14:23 | `cmd appops get com.netflix.ninja RUN_ANY_IN_BACKGROUND` (sauvegardé) | `default: allow` ; `NetflixService` tournait en fond (~104 Mo) |
| 14:23 | `cmd appops set com.netflix.ninja RUN_ANY_IN_BACKGROUND ignore` + `am force-stop com.netflix.ninja` | Netflix ne se relance pas (vérifié 20 s après) ; annulation ajoutée à restore-all.sh |
| 14:24 | ajout de `com.google.android.syncadapters.calendar` à mon-mogo4/debloat.txt + `tools/disable.sh mon-mogo4/debloat.txt` | ajouté à l'enregistrement d'annulation ; 20 paquets désactivés |
| 14:25 | `/proc/meminfo`, `dumpsys meminfo` (sans reboot) | MemAvailable 762 688 kB (≈745 Mo, contre 610 après le launcher) ; catégorie « B Services » (Netflix) disparue |
| 14:30 | checklist (Netflix dock + touche, Home, volume, engrenage, Retour, YouTube, Prime) | **tout OK** (utilisateur) |

## Phase 4 — Optimisations et économiseur (2026-11-23)

| Heure | Commande | Résultat |
|---|---|---|
| 14:30 | animations | déjà 0.5 / 0.5 / 0.5 d'origine → rien à faire |
| 14:31 | README Aerial Views lu (`gh api repos/theothernt/AerialViews/readme`) | méthode ADB : `screensaver_components` + `screen_off_timeout` ; **minimum 6 min (360000) sur Google TV 12+** |
| 14:32 | `gh release download 1.8.6 --repo theothernt/AerialViews` | `aerial-views-1.8.6.apk`, 9 283 524 o (= taille de la release), sha256 cd538992…ef9d, minSdk 24 |
| 14:33 | `tools/b64push.py` → /data/local/tmp puis `pm install -r` | md5 OK, `Success`, fichier temporaire supprimé |
| 14:34 | `settings put secure screensaver_components com.neilturner.aerialviews/.ui.screensaver.DreamActivity` | OK |
| 14:34 | `settings put system screen_off_timeout 360000` (6 min, minimum Google TV) | OK (5 min impossible : l'économiseur ne démarrerait pas) |
| 14:34 | `settings put secure sleep_timeout 1500000` (veille à 25 min) | OK |
| 14:36 | `cmd dreams start-dreaming` | refusé (root requis) → test via le menu de l'app ou l'attente de 6 min |
| 14:37 | `df -h /data` | 19 Go libres sur le projecteur |
| 14:37 | ouverture du menu Aerial Views (captures shots/aerial-*.png) | menu en français ; source « Stockage local ou USB » disponible |
| 14:45 | utilisateur : pas de photos perso → œuvres du domaine public | source retenue : Art Institute of Chicago open access (CC0) ; API du Met = 410 Gone |
| 14:47 | `find_art.py` (API AIC, paysages, domaine public, horizontaux) | 169 candidats |
| 14:50 | `get_art.py` : 51 œuvres sélectionnées (impressionnistes, paysages américains, Whistler, maîtres anciens, estampes japonaises) en 1686 px | 51 JPEG, 34,5 Mo dans ~/tools/downloads/photos/selection (hors dépôt) ; crédits dans mon-mogo4/aerial/CREDITS.md |
| 14:52 | `b64push.py` ×51 → /sdcard/Pictures/Economiseur/ | en cours (arrière-plan) |
| 14:58 | transfert des 51 images | 51 OK, 0 échec, 33 Mo dans /sdcard/Pictures/Economiseur |
| 15:05 | Aerial Views « Tester les paramètres de recherche locale » | 0 fichier : les 51 images étaient `is_pending=1` dans MediaStore (copie via shell) → `am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE` sur chaque fichier |
| 15:08 | scan média des 51 images puis test Aerial Views | 51 trouvées, 51 sélectionnées pour la lecture (source locale + filtre « Economiseur ») |
| 15:10 | navigation à distance dans Aerial Views | erreur : un Retour non pris en compte → interrupteur « stockage local » désactivé par erreur, réactivé aussitôt et vérifié (capture shots/aerial-fix.png). Suite des réglages confiée à l'utilisateur à la télécommande |
| 15:20 | réglages Aerial Views faits par l'utilisateur (1080p HEVC, horloge seule) + test | OK ; logcat : tâche `type=dream` Aerial Views démarrée par le système puis fermée par une touche |
| 15:21 | ajout de `com.google.android.apps.tv.dreamx` à mon-mogo4/debloat.txt + `tools/disable.sh` | ajouté à l'enregistrement d'annulation ; 21 paquets désactivés ; économiseur = Aerial Views |
| 15:30 | vérifications utilisateur : appui long Home (panneau rapide), Home, économiseur seul après 6 min | **tout OK** — Phase 4 validée (veille 25 min à confirmer en Phase 7) |

## Phase 5 — Bouton Éco / Standard (2026-11-23)

| Heure | Commande | Résultat |
|---|---|---|
| 14:50 | dump settings global/system/secure + getprop → backup/eco/avant.txt |     1318 lignes |
| 15:36 | utilisateur : Standard → Éco ; dump → backup/eco/apres.txt ; `diff avant apres` | **0 ligne de différence** (settings global/system/secure + getprop) |
| 15:36 | `logcat -b events \| grep wm_set_resumed_activity` | page du mode = `com.xgimi.misckey/.activity.GtvBrightnessActivity` (pas d'intent-filter) |
| 15:37 | `am start -W -n com.xgimi.misckey/.activity.GtvBrightnessActivity` (depuis le shell) | `Status: ok` : la page s'ouvre directement (panneau latéral) ; Éco sélectionné ; modes Standard / Éco / Performances ; « Commutateur automatique » activé (Standard sur secteur, Éco sur batterie) |
| 15:40 | utilisateur : Éco → Standard ; dump → backup/eco/retour.txt ; `diff apres retour` | seule différence : `init.svc.artd` (sans rapport) → **le mode n'est dans aucun réglage** |
| 15:40 | `service list` | mode probablement géré par les HAL XGIMI `xgimi.hardware.gmpf.*` (IDisplayManager, IDataBaseManager…) : non documentés, on n'y touche pas → **Étape C** (mini-app qui ouvre la page) |
| 15:50 | création de `mon-mogo4/eco-toggle/` (Kotlin, AGP 8.5.2, Kotlin 1.9.24, SDK 34) : une activité Theme.NoDisplay qui ouvre `GtvBrightnessActivity` puis se ferme | `./gradlew assembleRelease` OK, APK 21 Ko, **0 permission** (aapt) |
| 15:52 | `b64push` + `pm install -r` puis lancement via LEANBACK_LAUNCHER | md5 OK, `Success` ; focus = `com.xgimi.misckey/.activity.GtvBrightnessActivity` |
| 15:53 | dock : ajout de `com.ecotoggle.luminosite` (7e), `columns` 7 ; `tools/theme.sh mon-mogo4/theme` | appliqué, capture shots/dock-7.png |
| 15:53 | nom dynamique (activity-alias) | non faisable : le mode n'est lisible dans aucun réglage → l'app ouvre la page, sans Toast de mode |
| 16:00 | `timeout 30 getevent -lt` pendant 6 appuis sur Shortcut | télécommande « XGIMI RC » (/dev/input/event2) : `EV_KEY KEY_F14`, `MSC_SCAN 00070069` |
| 16:01 | `dumpsys window` (mKeyMapping) + settings | touche gérée par XGIMI : réglage global `remote_shortcut=keep_silence` (silence) ; en mode lumière d'ambiance elle règle la couleur (tutoriel `misckey/.activity.GtvRemoteControlActivity`) |
| 16:02 | conclusion étape D | pas de mapping : le launcher fait l'appui long (`hold:`) mais pas le double appui, et `app_keys` exige `key_filter` (perte du volume continu) ; pas d'app de remappage (règle 8). Valeurs possibles de `remote_shortcut` non documentées → non modifié |
| 16:10 | décision utilisateur : raccourci voulu, volume continu sacrifié | `config.json` : `key_filter` true ; `app_keys` = `scan:184:mute` (appui court = couper le son, comme `remote_shortcut=keep_silence`) et `hold:scan:184:com.ecotoggle.luminosite` (appui long = Luminosité) |
| 16:11 | `tools/theme.sh mon-mogo4/theme` | appliqué |
| 16:20 | `config.json` : appui long Shortcut → `com.xgimi.misckey/.activity.GtvBrightnessActivity` directement ; « Luminosité » retirée du dock (6 colonnes) ; `tools/theme.sh` | appliqué |
| 16:20 | `pm uninstall com.ecotoggle.luminosite` (mini-app installée par nous, à la demande de l'utilisateur) | désinstallée ; source gardée dans mon-mogo4/eco-toggle/ |
| 16:25 | test utilisateur, vraie touche : Shortcut appui long → panneau « Mode luminosité » | **OK** — Phase 5 terminée |

## Phase 6 — Xbox Remote Play (2026-11-23)

| Heure | Commande | Résultat |
|---|---|---|
| 16:30 | `dumpsys package com.redphx.betterxc` | Better xCloud 0.24.3, installé le 2026-11-20 (app Xbox qui laggait, à confirmer) |
| 16:30 | `dumpsys wifi` (mWifiInfo, identifiants masqués) | **5 GHz (5500 MHz, canal 100)**, Wi-Fi 5, liaison 585 Mb/s (max 866), RSSI −66 dBm |
| 16:30 | `grep MemAvailable /proc/meminfo` | 692 068 kB (≈676 Mo) |
| 16:31 | `ping -c 30 -i 0.2 <routeur>` depuis le projecteur | 0 % perte, moy. 11,5 ms, **max 210 ms**, mdev 37 ms (pics de latence) |
| 16:32 | README XStreaming lu ; `gh release download v2.12.1 --repo Geocld/XStreaming` | `XStreaming-2.12.1.apk` 84 670 136 o (= release), sha256 45724c70…6e39, paquet com.xstreaming, minSdk 26, Android TV pris en charge |
| 15:07 | `pm uninstall com.redphx.betterxc` (confirmé par l'utilisateur) | voir sortie |
| 16:45 | `b64push.py` XStreaming-2.12.1.apk + `pm install -r` | md5 OK, `Success`, com.xstreaming installé ; MemAvailable 683 640 kB |
| 16:55 | test XStreaming (Remote Play console, utilisateur) | **fonctionne** ; l'app n'affiche pas de statistiques (latence/images perdues/débit non relevables) → XStreaming retenu, XBXPlay non nécessaire |
| 16:56 | dock : ajout de `com.xstreaming` (7e), `columns` 7 ; `tools/theme.sh mon-mogo4/theme` | appliqué |
| 17:00 | `pm uninstall flar2.homebutton` (Button Mapper, confirmé par l'utilisateur) | désinstallé (règle 8 : un seul service d'accessibilité, celui du launcher) |
| 17:00 | dock : XStreaming retiré à la demande de l'utilisateur (reste dans la grille), `columns` 6 ; `tools/theme.sh` | appliqué ; accessibilité = HomeKeyService seul |

## Phase 7 — Validation et fin (2026-11-23)

| Heure | Commande | Résultat |
|---|---|---|
| 15:21 | `sync` puis `reboot` | envoyé |
| 15:24 | après reboot, uptime 184 s, Paramètres ouverts (mêmes conditions qu'en Phase 1) : `/proc/meminfo`, `dumpsys meminfo`, paquets, settings → backup/apres/ | **MemAvailable 683 100 kB (≈667 Mo) contre 607 676 kB (≈593 Mo) avant : +74 Mo** ; 21 paquets désactivés, 14 apps utilisateur |
| 15:24 | état après reboot | HomeKeyService lié ; démarrage : FallbackHome → launcherx (2 s) → tvhome ; animations 0.5 ; économiseur Aerial Views 6 min, veille 25 min |
| 15:25 | Netflix : `cmd appops get … RUN_ANY_IN_BACKGROUND` = ignore, mais relancé au démarrage (`BootCompleteReceiver` puis `SystemJobService`, adj 800 « service B ») | Netflix est dans la **liste blanche système** deviceidle (firmware) : la restriction ne tient qu'entre deux redémarrages ; laissée en place (sans effet négatif) |
| 15:35 | scan des fichiers à commiter (IP, chemins, e-mail) ; IP remplacées par `<ip projecteur>` / `<ip box>` dans ce journal | aucun identifiant restant ; backup/, work/, shots/, build exclus par .gitignore |
| 15:36 | `git checkout -b mogo4-gougouch` ; commit `mon-mogo4/` ; `git push -u origin mogo4-gougouch` | commit 693936e0 poussé sur le fork |

## Optimisations supplémentaires, demande utilisateur (2026-11-23)

| Heure | Commande | Résultat |
|---|---|---|
| 15:45 | TROUBLESHOOTING « Streaming apps take 10–20 seconds » lu | `cmd package compile -m speed -f <app>` (−30 à −50 % mesurés sur une Philips MediaTek), annulation `compile --reset` |
| 15:47 | ouverture à froid ×2 (`am start -W -S`, TotalTime) avant compilation → backup/apres/perf-cold-start-avant-compile.txt | toutes `status=verify` (non compilées) ; Netflix 1083/857 ms, YouTube 1316/1044, Prime 1186/792, Canal 1711/1487, Stremio 4194/3284, Disney+ 1043/634, XStreaming 996/784 |
| 15:55 | `cmd package compile -m speed -f` sur les 7 apps (arrière-plan) | en cours |
| 15:55 | `pm disable --user 0 com.netflix.ninja/com.netflix.ninja.BootCompleteReceiver` | **refusé** : `SecurityException: Shell cannot change component state` |
| 15:55 | `am set-standby-bucket com.netflix.ninja restricted` | sans effet : reste 5 (EXEMPTED, liste blanche système) ; démarrage aussi piloté par `com.mediatek.tv.service/com.mstar.netflixobserver.BootCompletedReceiver` → rien de plus faisable sans root, rien modifié |
| 16:05 | compilation (boucle) | connexion expirée en cours de route ; 5/7 en `status=speed` (Netflix, YouTube, Prime, Canal, Stremio) ; Disney+ et XStreaming relancés en `nohup` sur le projecteur |
| 16:08 | `tools/wallpaper_prep.py ~/tools/downloads/photos/selection mon-mogo4/theme/wallpapers --brightness 0.45` + captions.txt | 51 fonds 1280×720 (3,8 Mo), légendes « Titre — Artiste » ; .jpg exclus de git |
| 16:10 | `config.json` : wallpaper true, rotation 60 min (shuffle), légendes, dock_opacity 70, rows_below_dock 1 ; `tools/theme.sh mon-mogo4/theme` | appliqué (md5 OK) ; capture shots/home-tableaux.png ; tvhome PSS 68 Mo (dont Graphics 27 Mo) |
| 16:20 | `config.json` : rows_below_dock 0, icon_only_buttons, icon_only_inputs, wifi_label_width 0 ; `tools/theme.sh` | appliqué : dock seul, 3 boutons ronds sans texte, glow conservé ; ~4 % du haut de la rangée suivante dépasse en bas (aucune option pour le masquer) |
| 16:22 | Disney+ et XStreaming compilés un par un | 7/7 `status=speed` |
| 16:30 | ouverture à froid ×2 après compilation → backup/apres/perf-cold-start-apres-compile.txt | Netflix 1258/866, YouTube 1464/1048, Prime 1396/876, Canal 2600/1768, Stremio 3529/2777, Disney+ 1349/980, XStreaming 1239/837 → **pas de gain mesurable** (sauf Stremio ≈ −15 %), écarts dans le bruit de mesure |
| 15:56 | `cmd package compile --reset` sur Netflix, YouTube, Prime, Canal, Disney+, XStreaming (Stremio gardé en speed) | `Success` ×6 ; statuts : speed-profile (défaut Android) pour Netflix, YouTube, Prime, Canal, Disney+ ; verify pour XStreaming ; Stremio `speed` |
| 16:40 | essai `always_show_names: true` | n'enlève pas l'aperçu de la rangée suivante (la bande du dock grandit vers le haut) → retiré, thème renvoyé |
| 16:41 | lecture de MainActivity.java (placement du dock) | l'aperçu vient du calcul fixe `BOTTOM_ROOM_DP = 30` sous le dock : aucun réglage de thème ne le supprime (seulement une modification du code du launcher) |
| 16:50 | Aerial Views, une touche à la fois avec capture : sources Apple (139 vidéos), Amazon (85), Jetson Creative (20), Robin Fourcade (18) | **les 4 étaient actives** (streaming réseau) → toutes désactivées ; reste la source locale (51 tableaux) : démarrage/sortie plus rapides, plus de Wi-Fi |
| 16:55 | `config.json` : wallpaper_captions false ; `tools/theme.sh` | légende du tableau retirée de l'accueil (capture shots/home-sans-legende.png) |
| 17:00 | comparaison des processus (dumpsys meminfo après reboot, avant/après) | 136 → 130 ; disparus pour de bon : katniss ×2, dreamx ×2, syncadapters.calendar, tv.remote.service, xgimi.bugreportsender ; ajouté : tvhome |
| 17:01 | `top -b -n 3 -d 3` au repos sur l'accueil → backup/apres/cpu-repos.txt | CPU 84–92 % inoccupé (4 cœurs) ; pas de mesure CPU « avant » (non relevée en Phase 1) |
| 17:02 | `/proc/meminfo`, `dumpsys cpuinfo` après ~1 h de tests | MemAvailable 446 356 kB, zram quasi plein (686/717 Mo) après ouverture de toutes les apps ; CPU récent dominé par le noyau et les services XGIMI (gmpf, misckey, trapèze, codec) ; plus aucun processus Google retiré parmi les consommateurs |
| 17:40 | analyse UI : appui long sur tuile | menu Déplacer / Retirer / Infos sur l'app ; pas de « Fermer » possible (FORCE_STOP_PACKAGES réservé au système) → Infos sur l'app → Forcer l'arrêt |
| 17:42 | analyse UI : bouton Wi-Fi puis Retour (reproduit avec `am start -a android.settings.WIFI_SETTINGS`) | les pages Réseau s'empilent dans la tâche Paramètres (3 empilées), Retour remonte la pile ; `settings_key_clear_task` ne couvre que l'engrenage (bouton et touche), pas le bouton Wi-Fi (MainActivity.openNetworkPill) |
| 17:43 | observation : ordre du dock différent de config.json (YouTube, Stremio, Disney+, Netflix, Prime, CANAL+) | ordre enregistré par le launcher (fichier Order privé, écrit par « Déplacer ») ; Grande Vague : inscriptions derrière l'horloge |
| 17:48 | utilisateur : ordre du dock choisi par lui (gardé), estampes gardées | — |
| 17:49 | météo : add-on `addons/weather` (Open-Meteo, INTERNET, tuile + page plein écran) ; `docs/modules.md` | aucune zone « degrés à côté de l'heure » sans code (le panneau sous l'horloge est réservé à game_day/F1) |
| 17:50 | `config.json` : wifi_status_color, wifi_status_warnings, show_greeting false ; `tools/theme.sh` | appliqué : icône Wi-Fi verte, « BONSOIR » retiré, horloge remontée (capture shots/home-wifi-vert.png) |
