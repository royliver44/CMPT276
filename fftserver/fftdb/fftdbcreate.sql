CREATE DATABASE fftdb;
USE fftdb;
CREATE TABLE Users(
ID int AUTO_INCREMENT NOT NULL,
Name varchar(32) NOT NULL,
Password varchar(32) NOT NULL,
Reputation int DEFAULT 0 NOT NULL,
Ticket int DEFAULT 0 NOT NULL,
CreationTime timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
Alive boolean DEFAULT 1 NOT NULL,
PRIMARY KEY (ID)
);
CREATE TABLE Posts(
ID int AUTO_INCREMENT NOT NULL,
AuthorID int NOT NULL,
Body varchar(1024) NOT NULL,
CreationTime timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
LoveCount int DEFAULT 0 NOT NULL,
PRIMARY KEY (ID)
);
CREATE TABLE Replies(
ID int NOT NULL,
AuthorID int NOT NULL,
CreationTime timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
BodyText varchar(1024) NOT NULL
);
CREATE TABLE PostsByUser(
UserID int NOT NULL,
PostID int NOT NULL
);
CREATE TABLE RepliesByPost(
PostID int NOT NULL,
ReplyID int NOT NULL
);
CREATE TABLE RepliesByParentReplies(
ParentID int NOT NULL,
ChildID int NOT NULL
);
CREATE TABLE LoveByUser(
UserID int NOT NULL,
PostID int NOT NULL,
LoveState int NOT NULL
);
CREATE TABLE FollowersByUser(
UserID int NOT NULL,
FollowerID int NOT NULL
);
CREATE TABLE SharesByPost(
PostID int NOT NULL,
UserID int NOT NULL
);
