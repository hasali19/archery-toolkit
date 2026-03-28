package dev.hasali.archery.ui

import androidx.compose.runtime.Composable
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import dev.hasali.archery.ArcheryApplication
import dev.hasali.archery.ui.scoring.SessionScoringScreen
import dev.hasali.archery.ui.scoring.SessionScoringViewModelFactory
import dev.hasali.archery.ui.sessions.SessionsScreen
import dev.hasali.archery.ui.sessions.SessionsViewModelFactory

private const val ROUTE_SESSIONS = "sessions"
private const val ROUTE_SESSION_SCORING = "session/{sessionId}"
private const val ARG_SESSION_ID = "sessionId"

@Composable
fun AppNavigation(app: ArcheryApplication) {
    val navController = rememberNavController()

    NavHost(navController = navController, startDestination = ROUTE_SESSIONS) {
        composable(ROUTE_SESSIONS) {
            val vm = viewModel<dev.hasali.archery.ui.sessions.SessionsViewModel>(
                factory = SessionsViewModelFactory(app.sessionRepository),
            )
            SessionsScreen(
                viewModel = vm,
                onNavigateToSession = { sessionId ->
                    navController.navigate("session/$sessionId")
                },
            )
        }

        composable(
            route = ROUTE_SESSION_SCORING,
            arguments = listOf(navArgument(ARG_SESSION_ID) { type = NavType.IntType }),
        ) { backStackEntry ->
            val sessionId = backStackEntry.arguments!!.getInt(ARG_SESSION_ID)
            val vm = viewModel<dev.hasali.archery.ui.scoring.SessionScoringViewModel>(
                factory = SessionScoringViewModelFactory(sessionId, app.sessionRepository),
            )
            SessionScoringScreen(
                viewModel = vm,
                onNavigateBack = { navController.popBackStack() },
            )
        }
    }
}
