package dev.hasali.archery.data

enum class DistanceUnit { Metres, Yards }

data class DistanceValue(val value: Int, val unit: DistanceUnit)

data class RoundDistance(
    val distanceValue: DistanceValue,
    val arrowsPerEnd: Int,
    val ends: Int,
    val firstArrowIndex: Int,
    val firstEndIndex: Int,
) {
    val arrows get() = arrowsPerEnd * ends
    val lastArrowIndex get() = firstArrowIndex + arrows - 1
}

data class RoundDetails(
    val id: String?,
    val displayName: String,
    val scoringSystem: ScoringSystem,
    val distances: List<RoundDistance>,
)

data class Session(
    val id: Int,
    val startTime: Long,
    val roundDetails: RoundDetails,
    val scores: List<Score>,
    val isCompetition: Boolean,
)
