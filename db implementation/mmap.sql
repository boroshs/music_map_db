/* Delete tables if they already exist */
DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS Performer;
DROP TABLE IF EXISTS GeneralUser;
DROP TABLE IF EXISTS Venue;
DROP TABLE IF EXISTS SelfPerformerPhoto;
DROP TABLE IF EXISTS SelfVenuePhoto;
DROP TABLE IF EXISTS PerformerPhoto;
DROP TABLE IF EXISTS VenuePhoto;
DROP TABLE IF EXISTS PerformerRating;
DROP TABLE IF EXISTS VenueRating;
DROP TABLE IF EXISTS BookMark;
DROP TABLE IF EXISTS Attend;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Comment;
DROP TABLE IF EXISTS TopLevel;
DROP TABLE IF EXISTS Response;

/* This table holds information about the user. */
/* completeness assertion problem */
CREATE TABLE User (
	UserName VARCHAR(32),
	Password CHARACTER(60) NOT NULL,
	Email VARCHAR(255) NOT NULL UNIQUE,
	PRIMARY KEY(UserName) /*,
	CHECK (EXISTS (SELECT * 
			       FROM Performer P, GeneralUser G, Venue V
			       WHERE UserName = P.UserName OR UserName = G.UserName
			       OR UserName = V.UserName))*/
);

/* This table holds information about the general user. */
/* 1/3 subclass of User*/
/* disjointness assertion problem */
CREATE TABLE GeneralUser (
	UserName VARCHAR(32),
	PRIMARY KEY(UserName),
	FOREIGN KEY(UserName) REFERENCES User(UserName) ON DELETE CASCADE ON UPDATE CASCADE /*,
	CHECK (NOT EXISTS (SELECT * FROM Performer P WHERE UserName = P.UserName)),
	CHECK (NOT EXISTS (SELECT * FROM Venue V WHERE UserName = V.UserName))*/
);

/* This table holds information about performers. */
/* 2/3 subclass of User*/
/* disjointness assertion problem */
CREATE TABLE Performer (
	UserName VARCHAR(32),
	Name VARCHAR(255) NOT NULL,
    Description TEXT,
	PRIMARY KEY(UserName),
	FOREIGN KEY(UserName) REFERENCES User(UserName) ON DELETE CASCADE ON UPDATE CASCADE /*,
	CHECK (NOT EXISTS (SELECT * FROM GeneralUser GU WHERE UserName = GU.UserName)),
	CHECK (NOT EXISTS (SELECT * FROM Venue V WHERE UserName = V.UserName))*/
);

/* This table holds information about a venue. */
/* 3/3 subclass of User*/
/* disjointness assertion problem */
CREATE TABLE Venue (
	UserName VARCHAR(32),
	Name VARCHAR(255) NOT NULL,
	Longitude DECIMAL(9,6) NOT NULL,
    Latitude DECIMAL(9,6) NOT NULL,
	Description TEXT,
	PRIMARY KEY(UserName),
	FOREIGN KEY(UserName) REFERENCES USER(UserName) ON DELETE CASCADE ON UPDATE CASCADE /*,
	CHECK (NOT EXISTS (SELECT * FROM Performer P WHERE UserName = P.UserName)),
	CHECK (NOT EXISTS (SELECT * FROM GeneralUser GU WHERE UserName = GU.UserName))*/
);

/* This table holds information about photos of performers uploaded by the performer. */
/* 1/4 photo table */
CREATE TABLE SelfPerformerPhoto(
	PhotoID INTEGER PRIMARY KEY AUTOINCREMENT,
	Performer VARCHAR(32) NOT NULL, 
	PhotoPath VARCHAR(255) NOT NULL UNIQUE,
	FOREIGN KEY(Performer) REFERENCES Performer(UserName) ON DELETE CASCADE ON UPDATE CASCADE
);

/* This table holds information about photos of venues uploaded by the venue. */
/* 2/4 photo table */
CREATE TABLE SelfVenuePhoto(
	PhotoID INTEGER PRIMARY KEY AUTOINCREMENT,
	Venue VARCHAR(32) NOT NULL, 
	PhotoPath VARCHAR(255) NOT NULL UNIQUE,
	FOREIGN KEY(Venue) REFERENCES Venue(UserName) ON DELETE CASCADE ON UPDATE CASCADE
);

/* This table holds information about photos of performers uploaded by a general user. */
/* 3/4 photo table */
CREATE TABLE PerformerPhoto(
	PhotoID INTEGER PRIMARY KEY AUTOINCREMENT,
	UserName VARCHAR(32) NOT NULL, 
	Performer VARCHAR(32) NOT NULL, 
	PhotoPath VARCHAR(255) NOT NULL UNIQUE,
	FOREIGN KEY(UserName) REFERENCES GeneralUser(UserName) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(Performer) REFERENCES Performer(UserName) ON DELETE CASCADE ON UPDATE CASCADE
);

/* This table holds information about photos of venues uploaded by a general user. */
/* 4/4 photo table */
CREATE TABLE VenuePhoto(
	PhotoID INTEGER PRIMARY KEY AUTOINCREMENT,
	UserName VARCHAR(32) NOT NULL, 
	Venue VARCHAR(32) NOT NULL, 
	PhotoPath VARCHAR(255) NOT NULL UNIQUE, 
	FOREIGN KEY(UserName) REFERENCES GeneralUser(UserName) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(Venue) REFERENCES Venue(UserName) ON DELETE CASCADE ON UPDATE CASCADE
);

/* This table holds ratings corresponding to a performer. */
/* 1/2 rating table */
CREATE TABLE PerformerRating (
	UserName VARCHAR(32), 
	Performer VARCHAR(32), 
	Rating TINYINT NOT NULL,
	DateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	UpdateDateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	Upvote INT NOT NULL DEFAULT 0,
	View INT NOT NULL DEFAULT 0,
	Description TEXT,
	ResponseDateTime DATETIME,
	ResponseDescription TEXT,
	PRIMARY KEY(UserName, Performer),
	FOREIGN KEY(UserName)  REFERENCES GeneralUser(UserName) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(Performer) REFERENCES Performer(UserName) ON DELETE	CASCADE ON UPDATE CASCADE,
    CHECK(Rating >= 0 AND Rating <= 5)
);

/* This table holds ratings corresponding to a venue. */
/* 2/2 rating table */
CREATE TABLE VenueRating (
	UserName VARCHAR(32),
	Venue VARCHAR(32),  
	Rating TINYINT NOT NULL,
	DateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	UpdateDateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	Upvote INT NOT NULL DEFAULT 0,
	View INT NOT NULL DEFAULT 0,
	Description TEXT,
	ResponseDateTime DATETIME,
	ResponseDescription TEXT,
	PRIMARY KEY (UserName, Venue), 
	FOREIGN KEY(UserName) REFERENCES GeneralUser(UserName) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(Venue) REFERENCES Venue(UserName) ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK (Rating >= 0 AND Rating <= 5)
);

/* This table holds information about an event. */
CREATE TABLE Event (
	EventID INTEGER PRIMARY KEY AUTOINCREMENT,
	Performer VARCHAR(32) NOT NULL,
	Venue VARCHAR(32) NOT NULL,
	DateTime DATETIME NOT NULL,
	Genre VARCHAR(255),
	Cost INT, /* store cost in cents */
	FOREIGN KEY(Performer) REFERENCES Performer(UserName) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(Venue) REFERENCES Venue(UserName) ON DELETE CASCADE ON UPDATE CASCADE	
);

/* This table holds information about events attended by users. */
CREATE TABLE Attend (
	UserName VARCHAR(32),
	EventID INT,
	PRIMARY KEY(UserName, EventID),
	FOREIGN KEY(UserName)  REFERENCES GeneralUser(UserName) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(EventID) REFERENCES Event(EventID) ON DELETE CASCADE ON UPDATE CASCADE
);

/* This table holds information about events bookmarked by users. */
/* no bookmarks past event date assertion problem */
CREATE TABLE BookMark (
    UserName VARCHAR(32),
    EventID INT,
    Priority INT NOT NULL DEFAULT 0,
    PRIMARY KEY (UserName, EventID),
    FOREIGN KEY(UserName) REFERENCES GeneralUser(UserName) ON DELETE
    CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (Priority >= 0 AND Priority <= 10)
    /* CHECK (NOT EXISTS (SELECT *
			     FROM Event E
			     WHERE EventID = E.EventID AND 
  			     E.DateTime > CURRENT_TIMESTAMP)*/
);

/* This table holds information about a general comment. */
/* completeness assertion problem */
CREATE TABLE Comment (
	CommentID INTEGER PRIMARY KEY AUTOINCREMENT,
	UserName VARCHAR(32) NOT NULL,
	EventID INT NOT NULL,
	DateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	UpdateDateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	Description TEXT NOT NULL,
	Upvote INT NOT NULL DEFAULT 0,
	View INT NOT NULL DEFAULT 0,
	FOREIGN KEY(UserName) REFERENCES User(UserName) ON DELETE CASCADE ON UPDATE CASCADE,
    	FOREIGN KEY(EventID) REFERENCES Event(EventID) ON DELETE CASCADE ON UPDATE CASCADE /*,
	CHECK (EXISTS (SELECT * 
			       FROM TopLevel T, Response R
			       WHERE CommentID = T.CommentID OR CommentID = R.CommentID))*/
);

/* This table holds information about top level comments. */
/* 1/2 comment subclass */
/* disjointness assertion problem */
CREATE TABLE TopLevel(
	CommentID INT, 
	PRIMARY KEY(CommentID), 
	FOREIGN KEY(CommentID) REFERENCES Comment(CommentID) ON DELETE CASCADE ON UPDATE CASCADE /*,
	CHECK (NOT EXISTS (SELECT * FROM Response R WHERE CommentID = R.CommentID))*/
);

/* This table holds information about users who bookmarked an event. */
/* 2/2 comment subclass */
/* disjointness assertion problem */
CREATE TABLE Response(
	CommentID INT, 
	RespondeeID INT NOT NULL,
	PRIMARY KEY(CommentID),
	FOREIGN KEY(CommentID) REFERENCES Comment(CommentID) ON DELETE CASCADE ON UPDATE CASCADE,
	/* If the comment the response is responding to is deleted, delete the entire chain */
	FOREIGN KEY(RespondeeID) REFERENCES Comment(CommentID) ON DELETE CASCADE ON UPDATE CASCADE /*, 
	CHECK (NOT EXISTS (SELECT * FROM TopLevel T WHERE CommentID = T.CommentID)) */
);

INSERT INTO User (UserName, Password, Email) VALUES('GeoffRen', '$2b$12$GPBNbk5H6EJOkJ5rdg3PW.AO7v/vYvHhsUZJhQco77.QPDW2oR6em', 'geoff.ren@vanderbilt.edu');
INSERT INTO User (UserName, Password, Email) VALUES ('ShamitaNagalla', '$2b$12$z9Y3VAJp0W4n5ZQlnOjPKOBUO/.cDsmuKAG.9DjwsZAH7WsPkGtR2', 'shamita.nagalla@vanderbilt.edu');
INSERT INTO User (UserName, Password, Email) VALUES('ShaonBorosha', '$2b$12$zgmKEqYDtYCRM1sRFC8Od.p/F9Y/98xbnMsArUY7TA50/2OhIJPxq', 'shaon.borosha@vanderbilt.edu');
INSERT INTO User (UserName, Password, Email) VALUES ('LebronJames', '$2b$12$iF6a9EW.IJU2GTjf/tCaIeX8J6RxV3rCqBa9bcByXllzOfhbMRpRC', 'lebron.james@gmail.com');
INSERT INTO User (UserName, Password, Email) VALUES ('CathyWilla', '$2b$12$oVqcsci6ChvD8Us0Yc9p6utxw83cU13qwnSP1vFfquTxpKCSmgPza', 'cw@mail.gov');
INSERT INTO User (UserName, Password, Email) VALUES ('Puckett’s', '$2b$12$muVk1ZlMMHAZEqOjTopYuuSQtJFPrvGeLcj9z8mhC/gVn8pgs6t42', 'pucketts.@restaurant.com');
INSERT INTO User (UserName, Password, Email) VALUES ('ExitIn', '$2b$12$w8fPKHHNMTuoIMpeE2BH5.c0DSxzR6U.z4oz4rgl4pSIiQVzdYcRe', 'exit@in.com');
INSERT INTO User (UserName, Password, Email) VALUES ('Bluebird', '$2b$12$tk5y1h2GqEJ5HttOLQOGWeNtLgRgWcPWhs5225k/UUS6BcWbY6S6m', 'blue.bird@nest.com');
INSERT INTO User (UserName, Password, Email) VALUES ('TaylorSwift', '$2b$12$z9Y3VAJp0W4n5ZQlnOjPKOBUO/.cDsmuKAG.9DjwsZAH7WsPkGtR2', 'taylorswift@music.com');
INSERT INTO User (UserName, Password, Email) VALUES ('RollingStones', '$2b$12$tbbmeTdhH3y/dT7rPA6xr.PTDF90pG9HrziCtXhehj691gxbYajNq', 'rollingstones@music.com');
INSERT INTO User (UserName, Password, Email) VALUES ('KanyeWest', '$2b$12$zgmKEqYDtYCRM1sRFC8Od.p/F9Y/98xbnMsArUY7TA50/2OhIJPxq', 'kanyewest@music.com');
INSERT INTO User (UserName, Password, Email) VALUES ('Metallica', '$2b$12$EizVNDudVBTnVlz5sFcIzOHrfVeeGaB0xVxm.oECav1tGZRiNUWJa','metallica@metallica.com');
INSERT INTO User (UserName, Password, Email) VALUES ('Acme','$2b$12$FSclaEzha06QWo4aJ4QBweudirHo7oOg4C5x3CacRdGA/TbvAU5Qe','acme@feed.seed');

INSERT INTO GeneralUser (UserName) VALUES ('GeoffRen');
INSERT INTO GeneralUser (UserName) VALUES ('ShamitaNagalla');
INSERT INTO GeneralUser (UserName) VALUES ('ShaonBorosha');
INSERT INTO GeneralUser (UserName) VALUES ('LebronJames');
INSERT INTO GeneralUser (UserName) VALUES ('CathyWilla');

INSERT INTO PERFORMER (UserName, Name, Description) VALUES
('TaylorSwift','Taylor Swift','I am Taylor Swift and ‘I am Taylor Swift and I like to hold concerts that you can’t afford to get into if you live in Nashville');
INSERT INTO PERFORMER (UserName, Name, Description) VALUES
('KanyeWest', 'Kanye West', 'I am Kanye West and I have a God complex');
INSERT INTO PERFORMER (UserName, Name, Description) VALUES
('RollingStones', 'Rolling Stones', NULL);
INSERT INTO PERFORMER (UserName, Name, Description) VALUES
('Metallica', 'Metallica', NULL);

INSERT INTO VENUE (UserName, Name, Longitude, Latitude, Description) VALUES
('Puckett’s', 'Puckett’s Grocery & Restaurant', 36.163225, -86.780460, NULL);
INSERT INTO VENUE (UserName, Name, Longitude, Latitude, Description) VALUES
('ExitIn', 'Exit/In', 36.151384, -86.804395, 'We are really close to campus!');
INSERT INTO VENUE (UserName, Name, Longitude, Latitude, Description) VALUES
('Bluebird', 'The Bluebird Cafe', 36.102054, -86.816736, 'Good luck getting tickets!');
INSERT INTO VENUE (UserName, Name, Longitude, Latitude, Description) VALUES
('Acme', 'Acme Feed & Seed', 36.161998, -86.774402, 'We are pretty cool');

INSERT INTO SelfPerformerPhoto (PhotoID,Performer,PhotoPath) VALUES
(NULL, 'TaylorSwift', 'c:\somepath\taylor1.jpg');
INSERT INTO SelfPerformerPhoto (PhotoID,Performer,PhotoPath) VALUES
(NULL, 'TaylorSwift', 'c:\somepath\taylor2.jpg');
INSERT INTO SelfPerformerPhoto (PhotoID,Performer,PhotoPath) VALUES
(NULL, 'KanyeWest', 'c:\somepath\kanye1.jpg');

INSERT INTO SelfVenuePhoto (PhotoID, Venue, PhotoPath) VALUES
(NULL, 'ExitIn', 'c:\somepath\exit1.jpg');
INSERT INTO SelfVenuePhoto (PhotoID, Venue, PhotoPath) VALUES
(NULL, 'ExitIn', 'c:\somepath\exit2.jpg');
INSERT INTO SelfVenuePhoto (PhotoID, Venue, PhotoPath) VALUES
(NULL, 'Bluebird', 'c:\somepath\bluebird.jpg');

INSERT INTO PerformerPhoto (PhotoID, UserName,Performer,PhotoPath) VALUES
(NULL, 'GeoffRen', 'TaylorSwift','c:\somepath\geoffswift1.jpg');
INSERT INTO PerformerPhoto (PhotoID, UserName,Performer,PhotoPath) VALUES
(NULL, 'GeoffRen', 'TaylorSwift','c:\somepath\geoffswift2.jpg');
INSERT INTO PerformerPhoto (PhotoID, UserName,Performer,PhotoPath) VALUES
(NULL, 'GeoffRen', 'KanyeWest','c:\somepath\geoffwest1.jpg');
INSERT INTO PerformerPhoto (PhotoID, UserName,Performer,PhotoPath) VALUES
(NULL, 'ShamitaNagalla', 'KanyeWest','c:\somepath\sham1.jpg');
INSERT INTO PerformerPhoto (PhotoID, UserName,Performer,PhotoPath) VALUES
(NULL, 'ShamitaNagalla', 'KanyeWest','c:\somepath\sham2.jpg');
INSERT INTO PerformerPhoto (PhotoID, UserName,Performer,PhotoPath) VALUES
(NULL, 'ShamitaNagalla', 'KanyeWest','c:\somepath\sham3.jpg');
INSERT INTO PerformerPhoto (PhotoID, UserName,Performer,PhotoPath) VALUES
(NULL, 'ShamitaNagalla', 'KanyeWest','c:\somepath\sham4.jpg');
INSERT INTO PerformerPhoto (PhotoID, UserName,Performer,PhotoPath) VALUES
(NULL, 'ShaonBorosha', 'TaylorSwift','c:\somepath\shaon1.jpg');

INSERT INTO VenuePhoto (PhotoID, UserName,Venue,PhotoPath) VALUES
(NULL, 'GeoffRen', 'ExitIn','c:\somepath\geoffexitin1.jpg');
INSERT INTO VenuePhoto (PhotoID, UserName,Venue,PhotoPath) VALUES
(NULL, 'GeoffRen', 'ExitIn','c:\somepath\geoffexitin2.jpg');
INSERT INTO VenuePhoto (PhotoID, UserName,Venue,PhotoPath) VALUES
(NULL, 'GeoffRen', 'Bluebird','c:\somepath\geoffbird1.jpg');
INSERT INTO VenuePhoto (PhotoID, UserName,Venue,PhotoPath) VALUES
(NULL, 'ShamitaNagalla', 'Bluebird','c:\somepath\shambird1.jpg');
INSERT INTO VenuePhoto (PhotoID, UserName,Venue,PhotoPath) VALUES
(NULL, 'ShamitaNagalla', 'Bluebird','c:\somepath\shambird2.jpg');
INSERT INTO VenuePhoto (PhotoID, UserName,Venue,PhotoPath) VALUES
(NULL, 'ShamitaNagalla', 'Bluebird','c:\somepath\shambird3.jpg');
INSERT INTO VenuePhoto (PhotoID, UserName,Venue,PhotoPath) VALUES
(NULL, 'ShamitaNagalla', 'Bluebird','c:\somepath\shambird4.jpg');
INSERT INTO VenuePhoto (PhotoID, UserName,Venue,PhotoPath) VALUES
(NULL, 'ShaonBorosha', 'ExitIn','c:\somepath\shaonexit1.jpg');

INSERT INTO Event(EventID,Performer,Venue,Datetime,Genre,Cost) VALUES
(NULL, 'TaylorSwift', 'ExitIn', '2009-01-01 20:00:00', 'Country',100000);
INSERT INTO Event(EventID,Performer,Venue,Datetime,Genre,Cost) VALUES
(NULL, 'TaylorSwift', 'Bluebird', '2009-02-01 20:00:00', 'Country',100000);
INSERT INTO Event(EventID,Performer,Venue,Datetime,Genre,Cost) VALUES
(NULL, 'TaylorSwift', 'Acme', '2009-03-01 20:00:00', 'Country',100000);
INSERT INTO Event(EventID,Performer,Venue,Datetime,Genre,Cost) VALUES
(NULL, 'KanyeWest', 'ExitIn', '2008-01-01 20:00:00', 'Hip-Hop',1000);
INSERT INTO Event(EventID,Performer,Venue,Datetime,Genre,Cost) VALUES
(NULL, 'KanyeWest', 'Bluebird', '2008-02-01 20:00:00', 'Hip-Hop',1000);
INSERT INTO Event(EventID,Performer,Venue,Datetime,Genre,Cost) VALUES
(NULL, 'TaylorSwift', 'Acme', '2020-03-01 20:00:00', 'Country',100000);
INSERT INTO Event(EventID,Performer,Venue,Datetime,Genre,Cost) VALUES
(NULL, 'Metallica', 'ExitIn', '2007-01-01 20:00:00', 'Metal',100);
INSERT INTO Event(EventID,Performer,Venue,Datetime,Genre,Cost) VALUES
(NULL, 'Metallica', 'ExitIn', '2020-01-01 20:00:00', 'Metal',100);
INSERT INTO Event(EventID,Performer,Venue,Datetime,Genre,Cost) VALUES
(NULL, 'Metallica', 'ExitIn', '2020-01-02 20:00:00', 'Metal',100);

INSERT INTO Attend (UserName, EventID) VALUES ('GeoffRen', 1);
INSERT INTO Attend (UserName, EventID) VALUES ('GeoffRen', 2);
INSERT INTO Attend (UserName, EventID) VALUES ('GeoffRen', 3);
INSERT INTO Attend (UserName, EventID) VALUES ('GeoffRen', 4);
INSERT INTO Attend (UserName, EventID) VALUES ('GeoffRen', 5);
INSERT INTO Attend (UserName, EventID) VALUES ('GeoffRen', 6);
INSERT INTO Attend (UserName, EventID) VALUES ('ShamitaNagalla', 3);
INSERT INTO Attend (UserName, EventID) VALUES ('ShamitaNagalla', 6);
INSERT INTO Attend (UserName, EventID) VALUES ('ShamitaNagalla', 5);
INSERT INTO Attend (UserName, EventID) VALUES ('ShaonBorosha', 2);
INSERT INTO Attend (UserName, EventID) VALUES ('ShaonBorosha', 4);
INSERT INTO Attend (UserName, EventID) VALUES ('LebronJames', 1);
INSERT INTO Attend (UserName, EventID) VALUES ('LebronJames', 2);
INSERT INTO Attend (UserName, EventID) VALUES ('LebronJames', 3);
INSERT INTO Attend (UserName, EventID) VALUES ('LebronJames', 6);

INSERT INTO PerformerRating(UserName,Performer,Rating,DateTime,UpdateDateTime,Upvote,View,Description,ResponseDateTime,ResponseDescription) VALUES
('GeoffRen', 'TaylorSwift', 5, '2017-01-01 20:00:00','2017-01-01 20:00:00', 500, 1000, 'Cool stuff', '2017-02-01 11:00:00', 'Thanks!');
INSERT INTO PerformerRating(UserName,Performer,Rating,DateTime,UpdateDateTime,Upvote,View,Description,ResponseDateTime,ResponseDescription) VALUES
('GeoffRen', 'KanyeWest', 4, '2017-05-01 20:00:00','2017-05-01 20:00:00', 4, 25,'Good stuff', NULL, NULL);
INSERT INTO PerformerRating(UserName,Performer,Rating,DateTime,UpdateDateTime,Upvote,View,Description,ResponseDateTime,ResponseDescription) VALUES
('GeoffRen', 'Metallica', 3, '2010-01-01 20:00:00', '2010-01-01 20:00:00', 25, 677, 'Fine stuff', '2011-02-01 11:00:00', 'Yea');
INSERT INTO PerformerRating(UserName,Performer,Rating,DateTime,UpdateDateTime,Upvote,View,Description,ResponseDateTime,ResponseDescription) VALUES
('ShamitaNagalla', 'TaylorSwift', 5, '2017-02-01 20:00:00', '2017-04-01 20:00:00', 43, 142, 'Cool', '2017-05-01 11:00:00', 'Thanks!');
INSERT INTO PerformerRating(UserName,Performer,Rating,DateTime,UpdateDateTime,Upvote,View,Description,ResponseDateTime,ResponseDescription) VALUES
('ShamitaNagalla', 'KanyeWest', 4, '2016-05-01 20:00:00', '2016-05-01 20:00:00', 4, 55,'Good stuff', '2016-06-01 20:00:00', 'Thanks!');
INSERT INTO PerformerRating(UserName,Performer,Rating,DateTime,UpdateDateTime,Upvote,View,Description,ResponseDateTime,ResponseDescription) VALUES
('ShamitaNagalla', 'Metallica', 4, '2010-02-01 20:00:00', '2010-02-01 20:00:00', 0, 0, 'Fine stuff', '2011-03-01 11:00:00', 'Yea');
INSERT INTO PerformerRating(UserName,Performer,Rating,DateTime,UpdateDateTime,Upvote,View,Description,ResponseDateTime,ResponseDescription) VALUES
('ShaonBorosha', 'TaylorSwift', 5, '2017-03-01 20:00:00','2017-03-01 20:00:00', 0, 5, 'Nice', '2017-04-01 11:00:00', 'Thanks!');
INSERT INTO PerformerRating(UserName,Performer,Rating,DateTime,UpdateDateTime,Upvote,View,Description,ResponseDateTime,ResponseDescription) VALUES
('ShaonBorosha', 'KanyeWest', 3, '2016-09-01 20:00:00','2016-09-01 20:00:00', 6, 56,'Good stuff', '2016-10-01 20:00:00', 'Thanks!');
INSERT INTO PerformerRating(UserName,Performer,Rating,DateTime,UpdateDateTime,Upvote,View,Description,ResponseDateTime,ResponseDescription) VALUES
('LebronJames', 'TaylorSwift', 5, '2017-07-01 20:00:00','2017-07-01 20:00:00', 0, 123, 'Great', '2017-09-01 11:00:00', 'Thanks!');

INSERT INTO BookMark VALUES('GeoffRen', 7, 10);
INSERT INTO BookMark VALUES('GeoffRen', 8, 9);
INSERT INTO BookMark VALUES('GeoffRen', 9, 10);
INSERT INTO BookMark VALUES('ShamitaNagalla', 7, 5);
INSERT INTO BookMark VALUES('ShamitaNagalla', 8, 6);
INSERT INTO BookMark VALUES('ShaonBorosha', 7, 1);

INSERT INTO Comment VALUES(NULL, 'GeoffRen', 1, '2009-01-02 20:00:00', '2009-01-02
20:00:00', 'Toplevel comment for Event 1', 500, 1000);
INSERT INTO Comment VALUES(NULL, 'GeoffRen', 1, '2009-01-03 20:00:00', '2009-02-03
20:00:00', 'Toplevel comment for Event 1', 0, 120);
INSERT INTO Comment VALUES(NULL, 'GeoffRen', 1, '2009-01-03 20:00:00', '2009-03-03
20:00:00', 'Toplevel comment for Event 1', 35, 544);
INSERT INTO Comment VALUES(NULL, 'GeoffRen', 1, '2009-01-03 20:00:00', '2009-04-03 20:00:00', 'Response comment for Comment 1', 0, 4);
INSERT INTO Comment VALUES(NULL, 'GeoffRen', 3, '2009-01-03 20:00:00', '2009-05-03 20:00:00', 'Toplevel comment for Event 3', 12, 1212);
INSERT INTO Comment VALUES(NULL, 'ShamitaNagalla', 2, '2009-01-03 20:00:00', '2009-01-03 20:00:00', 'Toplevel comment for Event 2', 23, 142);
INSERT INTO Comment VALUES(NULL, 'ShamitaNagalla', 3, '2009-01-03 20:00:00', '2009-01-03 20:00:00', 'Toplevel comment for Event 3', 2, 244);
INSERT INTO Comment VALUES(NULL, 'ShamitaNagalla', 4, '2009-01-03 20:00:00', '2009-01-03 20:00:00', 'Toplevel comment for Event 4', 345, 2555);
INSERT INTO Comment VALUES(NULL, 'ShaonBorosha', 2, '2009-01-04 20:00:00', '2009-01-03 20:00:00', 'Response comment for Event 2', 1, 23);
INSERT INTO Comment VALUES(NULL, 'ShaonBorosha', 2, '2009-01-05 20:00:00', '2009-01-03 20:00:00', 'Response comment for Event 2', 4, 22);
INSERT INTO Comment VALUES(NULL, 'ShaonBorosha', 2, '2009-01-06 20:00:00', '2009-01-03 20:00:00', 'Response comment for Event 2', 1, 5);
INSERT INTO Comment VALUES(NULL, 'ShaonBorosha', 2, '2009-01-07 20:00:00', '2009-01-03 20:00:00', 'Response comment for Event 2', 0, 23);

INSERT INTO TopLevel VALUES(1);
INSERT INTO TopLevel VALUES(2);
INSERT INTO TopLevel VALUES(3);
INSERT INTO TopLevel VALUES(5);
INSERT INTO TopLevel VALUES(6);
INSERT INTO TopLevel VALUES(7);
INSERT INTO TopLevel VALUES(8);

INSERT INTO Response VALUES(4, 1);
INSERT INTO Response VALUES(9, 6);
INSERT INTO Response VALUES(10, 9);
INSERT INTO Response VALUES(11, 9);
INSERT INTO Response VALUES(12, 10);

INSERT INTO VenueRating VALUES('GeoffRen', 'ExitIn', 5, '2017-01-01 20:00:00', '2017-01-01 20:00:00', 123, 3141, 'Cool', '2017-02-01 20:00:00', 'Thanks!');
INSERT INTO VenueRating VALUES('GeoffRen', 'Bluebird', 2, '2016-01-01 20:00:00',
'2016-01-01 20:00:00', 123, 3141, 'Fine', '2016-02-01 20:00:00', 'Aww');
INSERT INTO VenueRating VALUES('GeoffRen', 'Acme', 4, '2013-01-01 20:00:00', '2013-01-01
20:00:00', 123, 3141, 'Fine', NULL, NULL);
INSERT INTO VenueRating VALUES('ShamitaNagalla', 'ExitIn', 4, '2017-02-01 20:00:00',
'2017-02-01 20:00:00', 123, 3141, 'Cool', '2017-03-01 20:00:00', 'Thanks!');
INSERT INTO VenueRating VALUES('ShamitaNagalla', 'Acme', 3, '2013-01-01 20:00:00',
'2013-01-01 20:00:00', 123, 3141, 'Fine', NULL, NULL);
INSERT INTO VenueRating VALUES('ShamitaNagalla', 'Bluebird', 4, '2014-01-01 20:00:00',
'2014-01-01 20:00:00', 123, 3141, 'Fine', NULL, NULL);
INSERT INTO VenueRating VALUES('ShaonBorosha', 'ExitIn', 5, '2017-03-01 20:00:00',
'2017-03-01 20:00:00', 123, 3141, 'Cool', '2017-04-01 20:00:00', 'Thanks!');
INSERT INTO VenueRating VALUES('ShaonBorosha', 'Bluebird', 3, '2014-02-01 20:00:00',
'2014-02-01 20:00:00', 123, 3141, 'Fine', '2014-03-01 20:00:00', 'Good enough');
INSERT INTO VenueRating VALUES('LebronJames', 'ExitIn', 5, '2017-04-01 20:00:00',
'2017-04-01 20:00:00', 123, 3141, 'Cool', '2017-05-01 20:00:00', 'Thanks!');

CREATE TRIGGER DeletePerformerDeleteUser
AFTER DELETE ON Performer
BEGIN
	DELETE FROM User
	WHERE UserName = OLD.UserName;
END;

CREATE TRIGGER DeleteGeneralUserDeleteUser
AFTER DELETE ON GeneralUser
BEGIN
	DELETE FROM User
	WHERE UserName = OLD.UserName;
END;

CREATE TRIGGER DeleteVenueDeleteUser
AFTER DELETE ON Venue
BEGIN
	DELETE FROM User
	WHERE UserName = OLD.UserName;
END;






CREATE TRIGGER UpdatePerformerUpdateUser
AFTER UPDATE ON Performer
BEGIN
	UPDATE User
	SET UserName = NEW.UserName;
END;

CREATE TRIGGER UpdateGeneralUserUpdateUser
AFTER UPDATE ON GeneralUser
BEGIN
	UPDATE User
	SET UserName = NEW.UserName;
END;

CREATE TRIGGER UpdateVenueUpdateUser
AFTER UPDATE ON Venue
BEGIN
	UPDATE User
	SET UserName = NEW.UserName;
END;

CREATE TRIGGER DeleteTopLevelDeleteComment
AFTER DELETE ON TopLevel
BEGIN
	DELETE FROM Comment
	WHERE CommentID = OLD.CommentID;
END;

CREATE TRIGGER DeleteResponseDeleteComment
AFTER DELETE ON Response
BEGIN
	DELETE FROM Comment
	WHERE CommentID = OLD.CommentID;
END;

CREATE TRIGGER UpdateTopLevelUpdateComment
AFTER UPDATE ON TopLevel
BEGIN
	UPDATE Comment
	SET CommentID = NEW.CommentID;
END;

CREATE TRIGGER UpdateResponseUpdateComment
AFTER UPDATE ON Response
BEGIN
	UPDATE Comment
	SET CommentID = NEW.CommentID;
END;










CREATE TRIGGER DeleteAttendDeleteVenueRating
AFTER DELETE ON Attend 
WHEN (SELECT COUNT(*) FROM (SELECT E.Venue AS Venue FROM Event E WHERE OLD.EventID = E.EventID) X,
(SELECT E.Venue as Venue FROM Event E, Attend A WHERE A.EventID = E.EventID AND A.UserName = OLD.UserName) Y
WHERE Y.Venue = X.Venue) = 0
BEGIN
DELETE FROM VenueRating WHERE UserName = OLD.UserName AND Venue IN (SELECT E.Venue FROM Event E WHERE E.EventID = OLD.EventID);
END;

CREATE TRIGGER DeleteAttendDeletePerformerRating
AFTER DELETE ON Attend
WHEN (SELECT COUNT(*) FROM (SELECT E.Performer AS Performer FROM Event E WHERE OLD.EventID = E.EventID) X, 
(SELECT E.Performer as Performer FROM Event E, Attend A WHERE A.EventID = E.EventID AND A.UserName = OLD.UserName) Y 
WHERE Y.Performer = X.Performer) = 0
BEGIN
DELETE FROM PerformerRating WHERE UserName = OLD.UserName AND Performer IN (SELECT E.Performer FROM Event E WHERE E.EventID = OLD.EventID);
END;
































CREATE VIEW VenueAnalyticView(UserName, Venue, NumRatings, AvgRating, NumEvents, AvgCost, NumEventComments, AvgEventComments, NumAttendees, AvgAttendees)
AS SELECT V.UserName, V.Name, Rating.NumRatings, Rating.AvgRating, Event.NumEvents, Event.AvgCost, Comment.NumEventComments, Comment.AvgEventComments, Attend.NumAttendees, Attend.AvgAttendees
FROM 
(SELECT R.Venue AS UserName, COUNT(*) AS NumRatings, AVG(R.Rating) AS AvgRating
FROM VenueRating R
GROUP BY R.Venue) Rating,
(SELECT E.Venue AS UserName, COUNT(*) AS NumEvents, AVG(E.Cost) AS AvgCost
FROM Event E
GROUP BY E.Venue) Event,
(SELECT tmp.UserName AS UserName, SUM(tmp.NumComments) AS NumEventComments, AVG(tmp.NumComments) AS AvgEventComments
FROM (SELECT E.Venue AS UserName, COUNT(*) AS NumComments FROM Event E, Comment C WHERE E.EventID = C.EventID GROUP BY E.Venue, E.EventID) tmp
GROUP BY tmp.UserName) Comment,
(SELECT tmp.UserName AS UserName, SUM(tmp.NumAttendees) AS NumAttendees, AVG(tmp.NumAttendees) AS AvgAttendees
FROM (SELECT E.Venue AS UserName, COUNT(*) AS NumAttendees FROM Event E, Attend A WHERE E.EventID = A.EventID GROUP BY E.Venue, E.EventID) tmp
GROUP BY tmp.UserName) Attend,	
Venue V
WHERE V.UserName = Rating.UserName AND V.UserName = Event.UserName AND V.UserName = Comment.UserName AND V.UserName = Attend.UserName;

CREATE VIEW PerformerAnalyticView(UserName, Performer, NumRatings, AvgRating, NumEvents, AvgCost, NumEventComments, AvgEventComments, NumAttendees, AvgAttendees)
AS SELECT P.UserName, P.Name, Rating.NumRatings, Rating.AvgRating, Event.NumEvents, Event.AvgCost, Comment.NumEventComments, Comment.AvgEventComments, Attend.NumAttendees, Attend.AvgAttendees
FROM 
(SELECT R.Performer AS UserName, COUNT(*) AS NumRatings, AVG(R.Rating) AS AvgRating
FROM PerformerRating R
GROUP BY R.Performer) Rating,
(SELECT E.Performer AS UserName, COUNT(*) AS NumEvents, AVG(E.Cost) AS AvgCost
FROM Event E
GROUP BY E.Performer) Event,
(SELECT tmp.UserName AS UserName, SUM(tmp.NumComments) AS NumEventComments, AVG(tmp.NumComments) AS AvgEventComments
FROM (SELECT E.Performer AS UserName, COUNT(*) AS NumComments FROM Event E, Comment C WHERE E.EventID = C.EventID GROUP BY E.Performer, E.EventID) tmp
GROUP BY tmp.UserName) Comment,
(SELECT tmp.UserName AS UserName, SUM(tmp.NumAttendees) AS NumAttendees, AVG(tmp.NumAttendees) AS AvgAttendees
FROM (SELECT E.Performer AS UserName, COUNT(*) AS NumAttendees FROM Event E, Attend A WHERE E.EventID = A.EventID GROUP BY E.Performer, E.EventID) tmp
GROUP BY tmp.UserName) Attend,	
Performer P
WHERE P.UserName = Rating.UserName AND P.UserName = Event.UserName AND P.UserName = Comment.UserName AND P.UserName = Attend.UserName;









CREATE VIEW VenueInformation(UserName, Email, EventID, Attendance)
AS SELECT U.UserName, U.Email, E.EventID, COUNT(*)
FROM User U, Venue V, Attend A, Event E
WHERE U.Username = V.UserName AND A.EventID = E.EventID AND V.UserName = E.Venue
GROUP BY U.UserName, U.Email, E.EventID;


CREATE VIEW UserPreferences(UserName, Email, Venue, Visits) 
AS SELECT U.UserName, U.Email, E.Venue, COUNT(*)
FROM User U, GeneralUser G, Attend A, Event E
WHERE U.UserName = G.UserName AND G.UserName = A.UserName AND E.EventID = A.EventID
GROUP BY U.UserName, U.Email, E.Venue;
    	

