package dev.hasali.archery.data

data class StandardRound(
    val id: String,
    val displayName: String,
    val scoringSystem: ScoringSystem,
    val distances: List<StandardRoundDistance>,
)

data class StandardRoundDistance(
    val distanceValue: DistanceValue,
    val arrows: Int,
    val defaultArrowsPerEnd: Int,
    val possibleArrowsPerEnd: List<Int>,
)

val standardRounds = listOf(
    StandardRound(
        id = "portsmouth",
        displayName = "Portsmouth",
        scoringSystem = ScoringSystems.metric,
        distances = listOf(
            StandardRoundDistance(
                distanceValue = DistanceValue(20, DistanceUnit.Yards),
                arrows = 60,
                defaultArrowsPerEnd = 3,
                possibleArrowsPerEnd = listOf(3, 6),
            ),
        ),
    ),
    StandardRound(
        id = "frostbite",
        displayName = "Frostbite",
        scoringSystem = ScoringSystems.metric,
        distances = listOf(
            StandardRoundDistance(
                distanceValue = DistanceValue(30, DistanceUnit.Metres),
                arrows = 36,
                defaultArrowsPerEnd = 3,
                possibleArrowsPerEnd = listOf(3, 6),
            ),
        ),
    ),
    StandardRound(
        id = "short_metric_1",
        displayName = "Short Metric I",
        scoringSystem = ScoringSystems.metric,
        distances = listOf(
            StandardRoundDistance(
                distanceValue = DistanceValue(50, DistanceUnit.Metres),
                arrows = 36,
                defaultArrowsPerEnd = 6,
                possibleArrowsPerEnd = listOf(3, 6),
            ),
            StandardRoundDistance(
                distanceValue = DistanceValue(30, DistanceUnit.Metres),
                arrows = 36,
                defaultArrowsPerEnd = 3,
                possibleArrowsPerEnd = listOf(3, 6),
            ),
        ),
    ),
    StandardRound(
        id = "worcester",
        displayName = "Worcester",
        scoringSystem = ScoringSystems.worcester,
        distances = listOf(
            StandardRoundDistance(
                distanceValue = DistanceValue(20, DistanceUnit.Yards),
                arrows = 30,
                defaultArrowsPerEnd = 5,
                possibleArrowsPerEnd = listOf(5),
            ),
            StandardRoundDistance(
                distanceValue = DistanceValue(20, DistanceUnit.Yards),
                arrows = 30,
                defaultArrowsPerEnd = 5,
                possibleArrowsPerEnd = listOf(5),
            ),
        ),
    ),
)

val standardRoundsById = standardRounds.associateBy { it.id }
