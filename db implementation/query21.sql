/*21. This query returns pairs of performer and venue photo photopaths for each event. The photos are drawn from all the photos in the database*/
SELECT E.EventID, AllPP.PhotoPath as 'Performer Photo', AllVP.PhotoPath as 'Venue Photo'
FROM Event E, (SELECT * FROM SelfPerformerPhoto
					    UNION
						SELECT PP.PhotoID, PP.Performer, PP.PhotoPath FROM PerformerPhoto PP) AllPP,
					   (SELECT * FROM SelfVenuePhoto
					   UNION
					   SELECT VP.PhotoPath, VP.Venue, VP.PhotoPath FROM VenuePhoto VP) AllVP
WHERE AllPP.Performer = E.Performer AND AllVP.Venue = E.Venue AND AllPP.PhotoPath <AllVP.PhotoPath