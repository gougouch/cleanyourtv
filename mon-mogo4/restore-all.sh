#!/usr/bin/env bash
# Remet le XGIMI MoGo 4 exactement comme avant le nettoyage (valeurs relevées le 2026-11-23,
# firmware UKNV.260910.001, dans backup/avant/).
#
# Usage, depuis la racine du dépôt :
#   TV_HOST=<ip du projecteur> mon-mogo4/restore-all.sh
#
# Ce que ça fait, dans l'ordre :
#   1. paquets + Home + animations : tools/restore.sh avec la liste appliquée et le launcher d'origine
#   2. coupe le service d'accessibilité du launcher (sinon Home reste redirigé)
#   3. économiseur d'écran et délais de veille d'origine
#   4. échelles d'animation d'origine (0.5, déjà la valeur d'usine sur ce projecteur)
#   5. mode de luminosité (rempli en Phase 5 si une clé settings est utilisée)
# Les apps installées (launcher, Aerial Views, XStreaming, Luminosité) restent installées :
# Paramètres → Applications pour les supprimer si tu veux.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${TV_HOST:?Indique l’IP du projecteur : TV_HOST=<ip> mon-mogo4/restore-all.sh}"
export TV_HOST
TV="tools/venv/bin/python -I tools/tv.py"

echo "== 1. Paquets et Home (tools/restore.sh)"
tools/restore.sh mon-mogo4/debloat.txt com.google.android.apps.tv.launcherx

echo "== 2. Accessibilité : valeur d'origine (vide, désactivée)"
$TV "settings put secure enabled_accessibility_services ''"
$TV "settings put secure accessibility_enabled 0"

echo "== 3. Économiseur et veille d'origine"
$TV "settings put secure screensaver_enabled 1"
$TV "settings put secure screensaver_components com.google.android.apps.tv.dreamx/.service.Backdrop"
$TV "settings put secure screensaver_activate_on_sleep 1"
$TV "settings put secure screensaver_activate_on_dock 1"
$TV "settings put system screen_off_timeout 600000"
$TV "settings put secure sleep_timeout 1800000"
$TV "settings put secure attentive_timeout -1"

echo "== 4. Animations d'origine"
$TV "settings put global window_animation_scale 0.5"
$TV "settings put global transition_animation_scale 0.5"
$TV "settings put global animator_duration_scale 0.5"

echo "== 4b. Netflix de nouveau autorisé en arrière-plan (valeur d'origine : default/allow)"
$TV "cmd appops set com.netflix.ninja RUN_ANY_IN_BACKGROUND default"

echo "== 5. Mode de luminosité"
# (Phase 5 : la clé et sa valeur d'origine seront ajoutées ici si on en utilise une.)

echo "== Vérification"
$TV "cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME"
$TV "pm list packages -d --user 0"
echo "Terminé. Home doit répondre par com.google.android.apps.tv.launcherx/.home.HomeActivity."
