/* While this template provides a good starting point for using Wear Compose, you can always
 * take a look at https://github.com/android/wear-os-samples/tree/main/ComposeStarter to find the
 * most up to date changes to the libraries and their usages.
 */

package dev.hasali.archery.presentation

import android.content.Context
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Backspace
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Outline
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material3.AppScaffold
import androidx.wear.compose.material3.Icon
import androidx.wear.compose.material3.IconButton
import androidx.wear.compose.material3.IconButtonDefaults
import androidx.wear.compose.material3.LocalContentColor
import androidx.wear.compose.material3.Text
import androidx.wear.compose.material3.touchTargetAwareSize
import androidx.wear.compose.ui.tooling.preview.WearPreviewDevices
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataItem
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.Wearable
import dev.hasali.archery.presentation.theme.AndroidTheme
import java.nio.ByteBuffer
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sign
import kotlin.math.sin
import kotlin.math.sqrt
import androidx.core.net.toUri

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            WearApp()
        }
    }
}

private data class WearScore(val id: Int, val label: String, val color: Color) {
    val foregroundColor: Color
        get() = if (color.luminance() > 0.5) Color.Black else Color.White
}

private fun parseEndScores(dataItem: DataItem): List<WearScore> {
    val dataMap = DataMapItem.fromDataItem(dataItem).dataMap
    val labels = dataMap.getStringArray("endScoreLabels") ?: return emptyList()
    val colors = dataMap.getIntegerArrayList("endScoreColors") ?: return emptyList()
    if (labels.size != colors.size) return emptyList()
    return labels.zip(colors).map { (label, color) -> WearScore(0, label, Color(color)) }
}

private fun parseKeyboardScores(dataItem: DataItem): List<WearScore> {
    val dataMap = DataMapItem.fromDataItem(dataItem).dataMap
    val ids = dataMap.getIntegerArrayList("keyboardScoreIds") ?: return emptyList()
    val labels = dataMap.getStringArray("keyboardScoreLabels") ?: return emptyList()
    val colors = dataMap.getIntegerArrayList("keyboardScoreColors") ?: return emptyList()
    if (ids.size != labels.size || ids.size != colors.size) return emptyList()
    return ids.indices.map { i -> WearScore(ids[i], labels[i], Color(colors[i])) }
}

private fun sendScoreMessage(context: Context, path: String, payload: ByteArray) {
    Wearable.getNodeClient(context).connectedNodes.addOnSuccessListener { nodes ->
        val node = nodes.firstOrNull() ?: return@addOnSuccessListener
        Wearable.getMessageClient(context).sendMessage(node.id, path, payload)
    }
}

@Composable
fun WearApp() {
    val context = LocalContext.current
    var isSessionActive by remember { mutableStateOf<Boolean?>(null) }
    var sessionId by remember { mutableStateOf(0) }
    var currentEndScores by remember { mutableStateOf(emptyList<WearScore>()) }
    var keyboardScores by remember { mutableStateOf(emptyList<WearScore>()) }

    DisposableEffect(Unit) {
        val dataClient = Wearable.getDataClient(context)
        val listener = DataClient.OnDataChangedListener { events ->
            for (event in events) {
                if (event.dataItem.uri.path == "/active-session") {
                    if (event.type == DataEvent.TYPE_DELETED) {
                        isSessionActive = false
                        sessionId = 0
                        currentEndScores = emptyList()
                        keyboardScores = emptyList()
                    } else {
                        isSessionActive = true
                        sessionId = DataMapItem.fromDataItem(event.dataItem).dataMap.getInt("sessionId")
                        currentEndScores = parseEndScores(event.dataItem)
                        keyboardScores = parseKeyboardScores(event.dataItem)
                    }
                }
            }
        }
        dataClient.addListener(listener)
        dataClient.getDataItems("wear://*/active-session".toUri())
            .addOnSuccessListener { items ->
                isSessionActive = items.count > 0
                if (items.count > 0) {
                    val item = items[0]
                    sessionId = DataMapItem.fromDataItem(item).dataMap.getInt("sessionId")
                    currentEndScores = parseEndScores(item)
                    keyboardScores = parseKeyboardScores(item)
                }
                items.release()
            }
        onDispose {
            dataClient.removeListener(listener)
        }
    }

    AndroidTheme {
        AppScaffold {
            when (isSessionActive) {
                null -> {}
                false -> Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier.fillMaxSize(),
                ) {
                    Text("No session active")
                }

                true -> {
                    val scores = currentEndScores
                    val possibleScores = keyboardScores

                    val screenWidthAtOffset = @Composable { offset: Dp ->
                        val screenHeight = LocalConfiguration.current.screenHeightDp / 2
                        val radius = LocalConfiguration.current.smallestScreenWidthDp / 2
                        (sqrt((radius * radius) - (screenHeight - offset.value) * (screenHeight - offset.value)) * 2).dp
                    }

                    Box(modifier = Modifier.fillMaxSize()) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            modifier = Modifier.fillMaxSize()
                        ) {
                            val offset = 32.dp
                            val width = screenWidthAtOffset(offset) - 8.dp

                            Spacer(Modifier.height(offset))

                            val scoreSize = width / 6 - 2.dp

                            Row(
                                horizontalArrangement = Arrangement.Center,
                                modifier = Modifier
                                    .width(width)
                                    .height(scoreSize)
                                    .align(Alignment.CenterHorizontally),
                            ) {
                                for (score in scores) {
                                    Box(
                                        contentAlignment = Alignment.Center,
                                        modifier = Modifier
                                            .padding(horizontal = 1.dp)
                                            .size(scoreSize)
                                            .clip(CircleShape)
                                            .background(score.color)
                                    ) {
                                        BasicText(
                                            text = score.label,
                                            color = { score.foregroundColor },
                                            autoSize = TextAutoSize.StepBased(maxFontSize = 14.sp),
                                        )
                                    }
                                }
                            }

                            Spacer(Modifier.height(4.dp))

                            val bottomHeight = 48.dp
                            val minOffset =
                                min(offset.value + scoreSize.value + 4, bottomHeight.value)
                            val mainWidth = screenWidthAtOffset(minOffset.dp)

                            BoxWithConstraints(
                                modifier = Modifier
                                    .weight(1f)
                                    .width(mainWidth)
                            ) {
                                val width = constraints.maxWidth
                                val buttonWidth = with(LocalDensity.current) {
                                    (width / 4).toDp()
                                }
                                val buttonHeight = with(LocalDensity.current) {
                                    (constraints.maxHeight / 3).toDp()
                                }
                                Column(
                                    horizontalAlignment = Alignment.CenterHorizontally,
                                    verticalArrangement = Arrangement.Bottom,
                                    modifier = Modifier.fillMaxSize(),
                                ) {
                                    for (scoresRow in possibleScores.chunked(4)) {
                                        Row {
                                            for (score in scoresRow) {
                                                CompositionLocalProvider(LocalContentColor provides score.foregroundColor) {
                                                    Box(
                                                        contentAlignment = Alignment.Center,
                                                        modifier = Modifier
                                                            .size(buttonWidth, buttonHeight)
                                                            .padding(2.dp)
                                                            .clip(SquircleShape())
                                                            .background(score.color)
                                                            .clickable {
                                                                val payload = ByteBuffer.allocate(8)
                                                                    .putInt(sessionId)
                                                                    .putInt(score.id)
                                                                    .array()
                                                                sendScoreMessage(context, "/score/add", payload)
                                                            }
                                                    ) {
                                                        val contentColor = LocalContentColor.current
                                                        BasicText(
                                                            text = score.label,
                                                            color = { contentColor },
                                                            autoSize = TextAutoSize.StepBased(
                                                                maxFontSize = 18.sp
                                                            ),
                                                        )
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Box(
                                modifier = Modifier.height(bottomHeight),
                                contentAlignment = Alignment.Center
                            ) {
                                IconButton(
                                    modifier = Modifier.touchTargetAwareSize(IconButtonDefaults.SmallButtonSize),
                                    onClick = {
                                        val payload = ByteBuffer.allocate(4).putInt(sessionId).array()
                                        sendScoreMessage(context, "/score/delete-last", payload)
                                    },
                                ) {
                                    Icon(
                                        imageVector = Icons.AutoMirrored.Default.Backspace,
                                        contentDescription = null,
                                        modifier = Modifier.size(IconButtonDefaults.SmallIconSize),
                                    )
                                }
                            }
                        }
                    }

                }
            }
        }
    }
}

class SquircleShape : Shape {
    override fun createOutline(
        size: Size,
        layoutDirection: LayoutDirection,
        density: Density
    ): Outline {
        val path = Path()
        val n = 3f

        val steps = 100
        val a = size.width / 2
        val b = size.height / 2

        for (i in 0..steps) {
            val t = (2 * PI * i / steps).toFloat()
            val cosT = cos(t)
            val sinT = sin(t)

            val x = a + a * sign(cosT) * abs(cosT).pow(2 / n)
            val y = b + b * sign(sinT) * abs(sinT).pow(2 / n)

            if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
        }

        path.close()
        return Outline.Generic(path)
    }
}

@WearPreviewDevices
@Composable
fun DefaultPreview() {
    WearApp()
}