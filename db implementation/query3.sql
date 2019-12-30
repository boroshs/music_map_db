/* 3. This query returns all performer ratings that have been responded to by the performer. */
SELECT *
FROM PerformerRating R
WHERE R.ResponseDescription IS NOT NULL;