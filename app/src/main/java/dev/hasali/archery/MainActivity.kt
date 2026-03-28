package dev.hasali.archery

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import dev.hasali.archery.ui.AppNavigation
import dev.hasali.archery.ui.theme.ArcheryTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            ArcheryTheme {
                AppNavigation(app = application as ArcheryApplication)
            }
        }
    }
}
