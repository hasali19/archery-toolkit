package dev.hasali.archery

import android.app.Application
import app.cash.sqldelight.driver.android.AndroidSqliteDriver
import dev.hasali.archery.db.AppDatabase
import dev.hasali.archery.repository.SessionRepository

class ArcheryApplication : Application() {
    val database: AppDatabase by lazy {
        val driver = AndroidSqliteDriver(
            schema = AppDatabase.Schema,
            context = this,
            name = "archery_toolkit",
            callback = object : AndroidSqliteDriver.Callback(AppDatabase.Schema) {
                override fun onOpen(db: androidx.sqlite.db.SupportSQLiteDatabase) {
                    db.execSQL("PRAGMA foreign_keys = ON")
                }
            },
        )
        AppDatabase(driver)
    }

    val sessionRepository: SessionRepository by lazy {
        SessionRepository(database)
    }
}
