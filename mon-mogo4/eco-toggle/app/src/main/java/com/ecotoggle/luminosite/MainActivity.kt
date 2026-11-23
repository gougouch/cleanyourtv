package com.ecotoggle.luminosite

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import android.widget.Toast

/**
 * Ouvre la page XGIMI « Mode luminosité » (Standard / Éco / Performances) et se ferme.
 *
 * Le mode n'est stocké dans aucun réglage Android sur ce firmware (vérifié par diff, voir
 * mon-mogo4/JOURNAL.md) : il passe par les services matériels XGIMI, qu'on ne pilote pas à
 * l'aveugle. On ouvre donc la page officielle, qui s'affiche en panneau par-dessus l'écran.
 */
class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val page = Intent()
            .setClassName(XGIMI_PACKAGE, XGIMI_BRIGHTNESS_PAGE)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(page)
        } catch (e: ActivityNotFoundException) {
            Toast.makeText(this, R.string.page_introuvable, Toast.LENGTH_LONG).show()
        } catch (e: SecurityException) {
            Toast.makeText(this, R.string.page_introuvable, Toast.LENGTH_LONG).show()
        }
        // Theme.NoDisplay impose de terminer avant onResume.
        finish()
    }

    private companion object {
        const val XGIMI_PACKAGE = "com.xgimi.misckey"
        const val XGIMI_BRIGHTNESS_PAGE = "com.xgimi.misckey.activity.GtvBrightnessActivity"
    }
}
