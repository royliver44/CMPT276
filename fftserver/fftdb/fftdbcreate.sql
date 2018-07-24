CREATE DATABASE fftdb;
USE fftdb;
CREATE TABLE Posts(
id int NOT NULL,
posttime timestamp,
reputation int,
location varchar(1024),
authorid int NOT NULL,
authorname varchar(32) NOT NULL,
title varchar(64) NOT NULL,
body varch
);
CREATE TABLE PostsByUser(
userid int NOT NULL,
postid int NOT NULL
);
CREATE TABLE Replies(
id int NOT NULL,
replytime timestamp,
authorid int;
body varchar(1024)
);
CREATE TABLE RepliesByPost(
postid int NOT NULL,
replyid int NOT NULL
);
CREATE TABLE RepliesByParentReplies(
parentid int NOT NULL,
childid int NOT NULL
);
CREATE TABLE Users(
id int NOT NULL,
name varchar(32) NOT NULL,
password varchar(32) NOT NULL
);
CREATE TABLE FollowersByUser(
userid int NOT NULL,
followeeid int NOT NULL
);
CREATE TABLE SharesByPost(
postid int NOT NULL,
userid int NOT NULL
);
CREATE TABLE LikesByUser(
userid int NOT NULL,
postid int NOT NULL
);
