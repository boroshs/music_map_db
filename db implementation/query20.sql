/*20.This query returns the number of events a user has attended at one venue. */
SELECT A.UserName, E.Venue, COUNT(*)
FROM Attend A, Event E
WHERE A.EventID = E.EventID
GROUP BY A.UserName, E.Venue;