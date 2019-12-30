/* 5. This query returns a sorted list of general users by how many events they’ve attended. */
SELECT U.UserName, U.Email, COUNT(*) 
FROM User U, GeneralUser G, Attend A
WHERE U.UserName = G.UserName AND G.UserName = A.UserName
GROUP BY U.UserName, U.Email
ORDER BY COUNT(*) DESC;