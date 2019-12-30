/*17. This query returns events bookmarked more than 2 times. */
SELECT B.EventID
FROM BookMark B
GROUP BY B.EventID
HAVING COUNT(*) > 2;