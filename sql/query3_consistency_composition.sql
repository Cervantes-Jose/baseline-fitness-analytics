WITH weekly_sessions AS (
    SELECT
        DATE_TRUNC('week', date::date) AS week_start,
        user_id,
        COUNT(DISTINCT id) AS sessions_that_week
    FROM workout_sessions
    WHERE user_id = 'analytics-user-uuid'
    GROUP BY DATE_TRUNC('week', date::date), user_id
),
weekly_weight AS (
    SELECT
        DATE_TRUNC('week', me.date::date) AS week_start,
        me.value AS weight
    FROM measurement_entries me
    JOIN measurements m ON m.id = me.measurement_id
    WHERE me.user_id = 'analytics-user-uuid'
    AND m.name = 'Weight'
),
weekly_bodyfat AS (
    SELECT
        DATE_TRUNC('week', me.date::date) AS week_start,
        me.value AS bodyfat
    FROM measurement_entries me
    JOIN measurements m ON m.id = me.measurement_id
    WHERE me.user_id = 'analytics-user-uuid'
    AND m.name = 'Body Fat'
)
SELECT
    ws.week_start,
    ws.sessions_that_week,
    ww.weight AS weekly_weight,
    wb.bodyfat AS weekly_bodyfat
FROM weekly_sessions ws
LEFT JOIN weekly_weight ww ON ww.week_start = ws.week_start
LEFT JOIN weekly_bodyfat wb ON wb.week_start = ws.week_start
ORDER BY ws.week_start;