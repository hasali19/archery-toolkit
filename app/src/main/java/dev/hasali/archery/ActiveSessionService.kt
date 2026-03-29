package dev.hasali.archery

import android.Manifest
import android.app.Notification
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import dev.hasali.archery.data.Session
import dev.hasali.archery.repository.SessionRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class ActiveSessionService : Service() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    private lateinit var sessionRepository: SessionRepository

    override fun onCreate() {
        super.onCreate()

        val application = this.application as ArcheryApplication
        sessionRepository = application.sessionRepository
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val sessionId = intent!!.getIntExtra("sessionId", 0)

        val foregroundServiceType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
        } else {
            0
        }

        ServiceCompat.startForeground(
            this,
            NOTIFICATION_ID,
            buildNotification(),
            foregroundServiceType
        )

        val notificationManager = NotificationManagerCompat.from(this)

        serviceScope.launch {
            if (ActivityCompat.checkSelfPermission(
                    this@ActiveSessionService,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return@launch
            }

            sessionRepository.watchSession(sessionId)
                .collect {
                    notificationManager.notify(NOTIFICATION_ID, buildNotification(it))
                }
        }

        return START_STICKY
    }

    override fun onBind(p0: Intent?): IBinder? {
        return null
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, NotificationChannels.SESSION)
            .setContentTitle("Active Session")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setOnlyAlertOnce(true)
            .build()
    }

    private fun buildNotification(session: Session): Notification {
        val total = session.scores.sumOf { it.value }
        val average = if (session.scores.isEmpty()) 0.0 else total.toDouble() / session.scores.size

        return NotificationCompat.Builder(this, NotificationChannels.SESSION)
            .setContentTitle(session.roundDetails.displayName)
            .setContentText("Total: $total\tAverage: ${"%.2f".format(average)}")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setOnlyAlertOnce(true)
            .build()
    }

    companion object {
        const val NOTIFICATION_ID = 1
    }
}
