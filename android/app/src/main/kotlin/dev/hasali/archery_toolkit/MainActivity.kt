package dev.hasali.archery_toolkit

import androidx.lifecycle.lifecycleScope
import com.google.android.gms.wearable.Wearable
import com.google.android.horologist.data.TargetNodeId
import com.google.android.horologist.data.WearDataLayerRegistry
import dev.hasali.archerytoolkit.proto.SessionServiceGrpcKt
import dev.hasali.archerytoolkit.proto.startSessionRequest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val registry = WearDataLayerRegistry.fromContext(application, lifecycleScope)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "archerytoolkit/wear")
            .setMethodCallHandler { call, result ->
                if (call.method == "startSession") {
                    val sessionId = call.argument<Long>("sessionId")
                        ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "sessionId is required", null)
                    lifecycleScope.launch {
                        try {
                            val nodes = Wearable.getNodeClient(this@MainActivity)
                                .connectedNodes
                                .await()
                            val nodeId = nodes.firstOrNull()?.id
                                ?: throw Exception("No watch connected")
                            val stub = registry.grpcClient(
                                nodeId = TargetNodeId.SpecificNodeId(nodeId),
                                coroutineScope = lifecycleScope,
                            ) {
                                SessionServiceGrpcKt.SessionServiceCoroutineStub(it)
                            }
                            stub.startSession(startSessionRequest { this.sessionId = sessionId })
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("GRPC_ERROR", e.message, null)
                        }
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
