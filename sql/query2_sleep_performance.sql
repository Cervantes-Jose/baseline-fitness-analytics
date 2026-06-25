SELECT
    ws.date AS session_date,
    SUM(
        (se.sets->0->>'weight')::numeric *
        (se.sets->0->>'reps')::numeric *
        jsonb_array_length(se.sets)
    ) AS total_volume,
    (
    SELECT AVG(daily_protein)
    FROM (
        SELECT SUM(fe.protein) AS daily_protein
        FROM food_entries fe
        WHERE fe.user_id = ws.user_id
        AND fe.date::date BETWEEN ws.date::date - INTERVAL '2 days' AND ws.date::date - INTERVAL '1 day'
        GROUP BY fe.date
    ) daily_totals
) AS avg_prior_protein
FROM workout_sessions ws
JOIN session_exercises se
    ON se.session_id = ws.id
    AND se.user_id = ws.user_id
WHERE ws.user_id = 'a883829b-0653-431b-b138-c425431efbd7'
GROUP BY ws.date, ws.user_id
ORDER BY ws.date;