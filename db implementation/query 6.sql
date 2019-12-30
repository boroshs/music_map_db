/* 13.This query returns top level comments for an event ordered by most upvotes, then date. */
SELECT *
FROM Comment C, TopLevel TL
WHERE C.CommentID = TL.CommentID AND
	   C.EventID = EVENT_NUM
ORDER BY C.Upvote DESC, C.DateTime DESC;