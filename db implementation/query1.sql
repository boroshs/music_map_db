/* QUERIES */
/*1. This query returns performers ordered by their average rating filtered by ratings >= 3 */
SELECT R.Performer, AVG(R.Rating)
FROM PerformerRating R
GROUP BY R.Performer
HAVING AVG(R.Rating) >= 3
ORDER BY AVG(R.Rating);