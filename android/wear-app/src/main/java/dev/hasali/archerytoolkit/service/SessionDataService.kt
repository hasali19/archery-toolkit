package dev.hasali.archerytoolkit.service

import android.content.Intent
import com.google.android.horologist.data.WearDataLayerRegistry
import com.google.android.horologist.datalayer.grpc.server.BaseGrpcDataService
import dev.hasali.archerytoolkit.presentation.MainActivity
import dev.hasali.archerytoolkit.proto.SessionServiceGrpcKt
import dev.hasali.archerytoolkit.proto.StartSessionResponse

class SessionDataService : BaseGrpcDataService<SessionServiceGrpcKt.SessionServiceCoroutineImplBase>() {

    override val registry by lazy {
        WearDataLayerRegistry.fromContext(application, lifecycleScope)
    }

    override fun buildService(): SessionServiceGrpcKt.SessionServiceCoroutineImplBase {
        return object : SessionServiceGrpcKt.SessionServiceCoroutineImplBase() {
            override suspend fun startSession(
                request: dev.hasali.archerytoolkit.proto.StartSessionRequest,
            ): StartSessionResponse {
                val intent = Intent(application, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    putExtra("sessionId", request.sessionId)
                }
                application.startActivity(intent)
                return StartSessionResponse.getDefaultInstance()
            }
        }
    }
}
