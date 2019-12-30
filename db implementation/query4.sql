/* 4. This query returns all venue ratings that have been responded to by the venue. */
SELECT *
FROM VenueRating R
WHERE R.ResponseDescription IS NOT NULL;