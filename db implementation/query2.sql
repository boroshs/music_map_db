/* 2. This query returns all events that have yet to happen. */
SELECT *
FROM Event E
WHERE E.DateTime > CURRENT_TIMESTAMP;