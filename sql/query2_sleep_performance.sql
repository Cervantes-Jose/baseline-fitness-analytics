SELECT
    ws.date AS session_date,
    SUM(
        (se.sets->0->>'weight')::numeric *
        (se.sets->0->>'reps')::numeric *
        jsonb_array_length(se.sets)
    ) AS total_volume,
    (
        SELECT me.value
        FROM measurement_entries me
        JOIN measurements m ON m.id = me.measurement_id
        WHERE me.user_id = ws.user_id
        AND m.name = 'Sleep Score'
        AND me.date::date = ws.date::date - INTERVAL '1 day'
        LIMIT 1
    ) AS prior_sleep_score
FROM workout_sessions ws
JOIN session_exercises se
    ON se.session_id = ws.id
    AND se.user_id = ws.user_id
WHERE ws.user_id = 'analytics-user-uuid'
GROUP BY ws.date, ws.user_id
ORDER BY ws.date;