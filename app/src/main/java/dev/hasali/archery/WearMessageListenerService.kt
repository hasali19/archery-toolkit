package dev.hasali.archery

import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService
import dev.hasali.archery.repository.SessionRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.nio.ByteBuffer

class WearMessageListenerService : WearableListenerService() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    private lateinit var sessionRepository: SessionRepository

    override fun onCreate() {
        super.onCreate()
        sessionRepository = (application as ArcheryApplication).sessionRepository
    }

    override fun onDestroy() {
        serviceScope.cancel()
        super.onDestroy()
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        val buffer = ByteBuffer.wrap(messageEvent.data)
        val sessionId = buffer.int

        when (messageEvent.path) {
            "/score/add" -> {
                val scoreId = buffer.int
                serviceScope.launch {
                    val session = sessionRepository.getSession(sessionId)
                    sessionRepository.insertScore(sessionId, session.scores.size, scoreId)
                }
            }
            "/score/delete-last" -> {
                serviceScope.launch {
                    val session = sessionRepository.getSession(sessionId)
                    if (session.scores.isNotEmpty()) {
                        sessionRepository.deleteScore(sessionId, session.scores.size - 1)
                    }
                }
            }
        }
    }
}
