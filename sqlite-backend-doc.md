# Swear Jar App - SQLite Backend Structure

## Overview

This document outlines the SQLite database architecture for the Swear Jar mobile application. The app will use SQLite as its primary data storage solution during the initial development phase, with potential migration to cloud-based solutions in future releases.

## Database Schema

### Tables Structure

```sql
-- Users table
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    display_name TEXT,
    avatar_path TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active TIMESTAMP,
    streak_days INTEGER DEFAULT 0,
    total_swears INTEGER DEFAULT 0,
    total_fine REAL DEFAULT 0.0
);

-- Swear words dictionary
CREATE TABLE swear_dictionary (
    word_id INTEGER PRIMARY KEY AUTOINCREMENT,
    word TEXT NOT NULL UNIQUE,
    severity TEXT CHECK(severity IN ('mild', 'moderate', 'severe')) NOT NULL,
    default_fine REAL NOT NULL,
    is_custom BOOLEAN DEFAULT 0
);

-- User custom words and settings
CREATE TABLE user_words (
    user_word_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    word_id INTEGER NOT NULL,
    custom_fine REAL,
    is_active BOOLEAN DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES swear_dictionary(word_id) ON DELETE CASCADE,
    UNIQUE(user_id, word_id)
);

-- Swear log entries
CREATE TABLE swear_logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    word_id INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mood TEXT CHECK(mood IN ('angry', 'frustrated', 'surprised', 'amused', 'stressed', 'other')) NOT NULL,
    worth_it BOOLEAN NOT NULL,
    context TEXT,
    fine_amount REAL NOT NULL,
    location TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES swear_dictionary(word_id) ON DELETE CASCADE
);

-- User settings
CREATE TABLE user_settings (
    setting_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE,
    notifications_enabled BOOLEAN DEFAULT 1,
    dark_mode BOOLEAN DEFAULT 1,
    reminder_time TEXT, -- stored as HH:MM
    share_stats BOOLEAN DEFAULT 0,
    auto_location BOOLEAN DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Streak history for analytics
CREATE TABLE streak_history (
    streak_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    streak_length INTEGER NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    is_current BOOLEAN DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Daily summaries (generated nightly for analytics)
CREATE TABLE daily_summaries (
    summary_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    date TEXT NOT NULL, -- YYYY-MM-DD format
    swear_count INTEGER DEFAULT 0,
    total_fine REAL DEFAULT 0.0,
    most_common_word_id INTEGER,
    most_common_mood TEXT,
    clean_day BOOLEAN DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (most_common_word_id) REFERENCES swear_dictionary(word_id) ON DELETE SET NULL,
    UNIQUE(user_id, date)
);
```

### Indexes

```sql
-- Indexes for performance optimization
CREATE INDEX idx_swear_logs_user_timestamp ON swear_logs(user_id, timestamp);
CREATE INDEX idx_swear_logs_word_id ON swear_logs(word_id);
CREATE INDEX idx_daily_summaries_user_date ON daily_summaries(user_id, date);
CREATE INDEX idx_user_words_user_id ON user_words(user_id);
```

## Data Access Layer

The app will use a repository pattern to abstract database operations. Key components include:

### DatabaseHelper Class

```kotlin
// Example in Kotlin
class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {
    
    companion object {
        private const val DATABASE_NAME = "swear_jar.db"
        private const val DATABASE_VERSION = 1
    }

    override fun onCreate(db: SQLiteDatabase) {
        // Create tables using the schema defined above
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // Handle database migrations
    }
}
```

### Repository Classes

Each primary entity will have a dedicated repository:

- UserRepository
- SwearLogRepository
- DictionaryRepository
- SettingsRepository
- AnalyticsRepository

## Authentication & User Management

Since SQLite is a local database, the initial version will use a simplified authentication approach:

1. First-time users will create a local profile that is stored in the users table
2. Multi-user support will be handled through profile switching (no password protection in initial version)
3. Device-level security (screen lock, biometrics) is recommended to users for protecting sensitive data

### User Creation Process

```kotlin
fun createUser(username: String, displayName: String?, avatarPath: String?): Long {
    val db = databaseHelper.writableDatabase
    val values = ContentValues().apply {
        put("username", username)
        put("display_name", displayName)
        put("avatar_path", avatarPath)
        put("created_at", System.currentTimeMillis())
        put("last_active", System.currentTimeMillis())
    }
    return db.insert("users", null, values)
}
```

### Session Management

The app will maintain the current user's ID in SharedPreferences for persistence across app restarts.

## Data Migration & Backup

### Local Backup

The app will implement a backup mechanism that exports the database to a JSON file which can be:
- Saved to external storage (with user permission)
- Shared via system share sheet
- Used for data migration in future cloud implementations

### Import/Export

```kotlin
// Export database to JSON
fun exportDatabase(outputStream: OutputStream) {
    val db = databaseHelper.readableDatabase
    val jsonObject = JSONObject()
    
    // Export users table
    val usersCursor = db.query("users", null, null, null, null, null, null)
    jsonObject.put("users", cursorToJsonArray(usersCursor))
    usersCursor.close()
    
    // Export other tables...
    
    outputStream.write(jsonObject.toString(2).toByteArray())
    outputStream.close()
}

// Import database from JSON
fun importDatabase(inputStream: InputStream) {
    val jsonString = inputStream.bufferedReader().use { it.readText() }
    val jsonObject = JSONObject(jsonString)
    
    // Process and insert data into tables
}
```

## Data Integrity & Optimization

### Transactions

Critical operations that touch multiple tables will be wrapped in transactions:

```kotlin
fun logSwear(userId: Long, wordId: Long, mood: String, worthIt: Boolean, context: String?, location: String?): Long {
    val db = databaseHelper.writableDatabase
    var logId: Long = -1
    
    db.beginTransaction()
    try {
        // 1. Insert swear log
        val logValues = ContentValues().apply {
            put("user_id", userId)
            put("word_id", wordId)
            put("mood", mood)
            put("worth_it", if (worthIt) 1 else 0)
            put("context", context)
            put("location", location)
            put("fine_amount", getFineAmount(userId, wordId))
            put("timestamp", System.currentTimeMillis())
        }
        logId = db.insert("swear_logs", null, logValues)
        
        // 2. Update user totals
        val fineAmount = getFineAmount(userId, wordId)
        db.execSQL("""
            UPDATE users 
            SET total_swears = total_swears + 1,
                total_fine = total_fine + ?,
                streak_days = 0
            WHERE user_id = ?
        """, arrayOf(fineAmount, userId))
        
        // 3. Update daily summary
        updateDailySummary(db, userId, wordId, fineAmount, mood)
        
        db.setTransactionSuccessful()
    } finally {
        db.endTransaction()
    }
    
    return logId
}
```

### Data Pruning

For performance reasons, the app will implement data pruning strategies:

1. Daily summaries will consolidate detailed logs older than 30 days
2. Users can configure automatic pruning of detailed logs older than a specified period
3. Export will be suggested before any pruning operations

## Streak Calculation Logic

The streak calculation will run nightly and on app start:

```kotlin
fun updateUserStreak(userId: Long) {
    val db = databaseHelper.writableDatabase
    
    // Get the date of last swear
    val lastSwearCursor = db.rawQuery("""
        SELECT date(timestamp/1000, 'unixepoch', 'localtime') as last_swear_date
        FROM swear_logs
        WHERE user_id = ?
        ORDER BY timestamp DESC
        LIMIT 1
    """, arrayOf(userId.toString()))
    
    var lastSwearDate: String? = null
    if (lastSwearCursor.moveToFirst()) {
        lastSwearDate = lastSwearCursor.getString(0)
    }
    lastSwearCursor.close()
    
    // Calculate clean days
    val formatter = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
    val today = formatter.format(Date())
    
    if (lastSwearDate == null || lastSwearDate < today) {
        // No swears today - update streak
        db.execSQL("""
            UPDATE users 
            SET streak_days = streak_days + 1,
                last_active = ?
            WHERE user_id = ?
        """, arrayOf(System.currentTimeMillis(), userId))
    }
}
```

## Edge Cases & Considerations

### Offline Operation

As SQLite is a local database, the app will function fully offline. Key considerations:

1. **Time Zone Changes**: The app will use device local time for all timestamps to ensure consistent streak tracking regardless of time zone changes.

2. **Daylight Saving Time**: All streak and "clean day" calculations will be based on calendar days rather than 24-hour periods to avoid DST transition issues.

3. **Device Date Manipulation**: To prevent streak manipulation by changing device date:
   - Record actual timestamp in milliseconds for all entries
   - Implement reasonability checks on sequence of timestamps
   - Warn users that manipulating device time may affect streak accuracy

### Data Corruption Protection

1. **Regular integrity checks**:
   ```kotlin
   fun performIntegrityCheck(): Boolean {
       val db = databaseHelper.readableDatabase
       val cursor = db.rawQuery("PRAGMA integrity_check", null)
       cursor.moveToFirst()
       val result = cursor.getString(0)
       cursor.close()
       return result == "ok"
   }
   ```

2. **Automatic backup before database operations** that modify schema or perform batch updates

3. **Write-Ahead Logging (WAL)** to prevent corruption during power loss:
   ```kotlin
   db.enableWriteAheadLogging()
   ```

### Multi-Device Considerations

While the initial version will be single-device, the schema is designed to support future cloud sync by:

1. Using UUID-based IDs that can be synchronized across devices
2. Maintaining timestamps for all operations
3. Implementing optimistic concurrency control for future cloud sync

## Performance Optimizations

1. **Query Optimization**:
   - Prepared statements for frequently used queries
   - Indexed columns for common search paths
   - Limit clause for paginated history views

2. **Batch Operations**:
   - Use transactions for multiple operations
   - Bulk insert for dictionary initialization
   - Delayed writes for non-critical updates

3. **Memory Management**:
   - Close cursors immediately after use
   - Avoid loading large data sets into memory
   - Use CursorLoader or Paging library for list displays

## SQLite Version Compatibility

The app will require SQLite version 3.8.3 or higher (available on Android 5.0+) to support features like:
- Common Table Expressions (WITH clause)
- Window functions for analytics
- JSON functions (future-proofing for data export)

## Migration Path to Cloud Storage

The schema design anticipates a future migration to a cloud database (Firebase/Supabase). Key considerations:

1. UUID generation for all new records to avoid collisions during sync
2. Timestamp tracking for conflict resolution
3. Dirty flag for records pending sync
4. Export/import functionality for initial data migration

## Initial Data Population

On first run, the app will populate the swear_dictionary table with common words and their default severity levels and fines.

```kotlin
fun populateDefaultDictionary() {
    val db = databaseHelper.writableDatabase
    
    db.beginTransaction()
    try {
        // Mild swear words
        val mildWords = arrayOf("damn", "hell", "crap")
        for (word in mildWords) {
            val values = ContentValues().apply {
                put("word", word)
                put("severity", "mild")
                put("default_fine", 0.25)
                put("is_custom", 0)
            }
            db.insertWithOnConflict("swear_dictionary", null, values, SQLiteDatabase.CONFLICT_IGNORE)
        }
        
        // Moderate swear words
        val moderateWords = arrayOf("ass", "bastard", "bitch")
        for (word in moderateWords) {
            val values = ContentValues().apply {
                put("word", word)
                put("severity", "moderate")
                put("default_fine", 0.50)
                put("is_custom", 0)
            }
            db.insertWithOnConflict("swear_dictionary", null, values, SQLiteDatabase.CONFLICT_IGNORE)
        }
        
        // Severe swear words
        val severeWords = arrayOf("f***", "s***")
        for (word in severeWords) {
            val values = ContentValues().apply {
                put("word", word)
                put("severity", "severe")
                put("default_fine", 1.00)
                put("is_custom", 0)
            }
            db.insertWithOnConflict("swear_dictionary", null, values, SQLiteDatabase.CONFLICT_IGNORE)
        }
        
        db.setTransactionSuccessful()
    } finally {
        db.endTransaction()
    }
}
```

## Testing Strategy

The database implementation will be tested using:

1. **Unit Tests**: Testing individual repository methods
2. **Integration Tests**: Testing transaction integrity and data consistency
3. **Performance Tests**: Ensuring acceptable performance with large datasets
4. **Migration Tests**: Testing database version upgrades
5. **Edge Case Tests**: Testing date boundaries, time zone changes, and other edge cases

## Future Considerations

1. **Encryption**: Implement SQLCipher for database encryption in future releases.
2. **Full-text search**: For faster word lookup in larger dictionaries.
3. **Sync engine**: Design for eventual implementation of a sync mechanism with cloud storage.
4. **Analytics export**: Format data for export to analytics platforms.
