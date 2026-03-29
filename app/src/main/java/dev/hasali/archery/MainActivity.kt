package dev.hasali.archery

import android.Manifest
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import dev.hasali.archery.ui.AppNavigation
import dev.hasali.archery.ui.theme.ArcheryTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ActivityResultContracts.RequestPermission().also { contract ->
                val launcher = registerForActivityResult(contract) {}
                launcher.launch(Manifest.permission.POST_NOTIFICATIONS)
            }
        }

        setContent {
            ArcheryTheme {
                AppNavigation(app = application as ArcheryApplication)
            }
        }
    }
}
