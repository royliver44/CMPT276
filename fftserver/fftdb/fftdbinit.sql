--fftdbcreate.sql
--Adds 4 posts to the Food For Thought forums database
--Group 6
--Written by Jordan Ehrenholz

use fftdb;
INSERT INTO Users (Name, Password) values ('anon', 'none');
INSERT INTO Users (Name, Password, Reputation) values ('jehrenho', 'fftrox', 6);
INSERT INTO Users (Name, Password, Reputation) values ('dwayne_johnson', 'yolo', 3);
INSERT INTO Users (Name, Password, Reputation) values ('jack', '1234', 3);
INSERT INTO Users (Name, Password) values ('jill', '4321');
INSERT INTO Posts (AuthorID, Body) values (2, 'My name is Jordan and I am building a server!');
INSERT INTO PostsByUser (UserID, PostID) values (2, 1);
INSERT INTO Posts (AuthorID, Body) values (3, 'Can you smell what the rock is cooking!!');
INSERT INTO PostsByUser (UserID, PostID) values (3, 2);
INSERT INTO Posts (AuthorID, Body) values (4, 'I fell down');
INSERT INTO PostsByUser (UserID, PostID) values (1, 3);
INSERT INTO Posts (AuthorID, Body) values (2, 'I should probably add more testing posts');
INSERT INTO PostsByUser (UserID, PostID) values (2, 4);
