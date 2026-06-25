WITH weekly_volume AS (
    SELECT
        DATE_TRUNC('week', ws.date::date) AS week_start,
        ws.user_id,
        SUM(
            (se.sets->0->>'weight')::numeric *
            (se.sets->0->>'reps')::numeric *
            jsonb_array_length(se.sets)
        ) AS total_volume,
        COUNT(DISTINCT ws.id) AS sessions_that_week
    FROM workout_sessions ws
    JOIN session_exercises se
        ON se.session_id = ws.id
        AND se.user_id = ws.user_id
    WHERE ws.user_id = 'analytics-user-uuid'
    GROUP BY DATE_TRUNC('week', ws.date::date), ws.user_id
),
weekly_nutrition AS (
    SELECT
        DATE_TRUNC('week', date::date) AS week_start,
        user_id,
        AVG(daily_protein) AS avg_weekly_protein
    FROM (
        SELECT
            date,
            user_id,
            SUM(protein) AS daily_protein
        FROM food_entries
        WHERE user_id = 'analytics-user-uuid'
        GROUP BY date, user_id
    ) daily
    GROUP BY DATE_TRUNC('week', date::date), user_id
),
weekly_sleep AS (
    SELECT
        DATE_TRUNC('week', me.date::date) AS week_start,
        me.user_id,
        AVG(me.value::numeric) AS avg_sleep_score
    FROM measurement_entries me
    JOIN measurements m ON m.id = me.measurement_id
    WHERE me.user_id = 'analytics-user-uuid'
    AND m.name = 'Sleep Score'
    GROUP BY DATE_TRUNC('week', me.date::date), me.user_id
)
SELECT
    wv.week_start,
    wv.sessions_that_week,
    wv.total_volume,
    wn.avg_weekly_protein,
    ws.avg_sleep_score
FROM weekly_volume wv
LEFT JOIN weekly_nutrition wn
    ON wn.week_start = wv.week_start
    AND wn.user_id = wv.user_id
LEFT JOIN weekly_sleep ws
    ON ws.week_start = wv.week_start
    AND ws.user_id = wv.user_id
ORDER BY wv.week_start;