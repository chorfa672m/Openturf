USE [odaf]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ************** Create PointDataSummary Table ***************** */

CREATE TABLE [PointDataSummary](
	[Id] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Guid] [nvarchar](100),
	[Name] [nvarchar](255) DEFAULT ('') NOT NULL,
	[Description] [nvarchar](4000) NOT NULL,
	[Latitude] [decimal](10, 5) NOT NULL,
	[Longitude] [decimal](10, 5) NOT NULL,
	[LayerId] [nvarchar](40) NOT NULL,
	[Tag] [nvarchar](max) NULL,
	[RatingCount] [int] DEFAULT (0) NOT NULL,
	[RatingTotal] [bigint] DEFAULT (0) NOT NULL,
	[CommentCount] [int] DEFAULT (0) NOT NULL,
	[CreatedOn] [smalldatetime] DEFAULT GETUTCDATE(),
	[ModifiedOn] [smalldatetime] DEFAULT GETUTCDATE(),
	[CreatedById] [bigint] DEFAULT (0) NOT NULL
)

GO

/* **************** Create PointDataComment Table *************** */

CREATE TABLE [PointDataComment](
	[Id] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Text] [nvarchar](4000) NOT NULL,
	[CreatedOn] [smalldatetime] DEFAULT GETUTCDATE(),
	[CreatedById] [bigint] NOT NULL,
	[SummaryId] [bigint] NOT NULL)

GO

ALTER TABLE PointDataComment
ADD CONSTRAINT [FK_PointDataComment_PointDataSummary] FOREIGN KEY([SummaryId]) REFERENCES [dbo].[PointDataSummary] ([Id])

GO

/* ****************** Create UserRole Table ****************** */

CREATE TABLE [UserRole](
	[Code] [smallint] NOT NULL PRIMARY KEY,
	[Name] [nvarchar](20) NOT NULL
)

/* Bit-flag Enum */
INSERT UserRole VALUES(0, 'Member')
INSERT UserRole VALUES(1, 'Moderator')
INSERT UserRole VALUES(2, 'Administrator')

GO

/* ******************* Create UserAccess Table ******************* */

CREATE TABLE [UserAccess](
	[Code] [smallint] NOT NULL PRIMARY KEY,
	[Name] [nvarchar](20) NOT NULL
)

/* Normal Enum */
INSERT UserAccess VALUES(0, 'Normal')
INSERT UserAccess VALUES(1, 'Pending')
INSERT UserAccess VALUES(2, 'Deleted')
INSERT UserAccess VALUES(3, 'Banned')

GO

/* ************** Create OAuthAccount Table ************ */

CREATE TABLE [OAuthAccount](
	[Id] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[user_id] [bigint]  NOT NULL,
	[screen_name] [nvarchar](30) NOT NULL,
	[oauth_token] [nvarchar](255) NOT NULL,
	[oauth_token_secret] [nvarchar](255) NOT NULL,
	[oauth_service_id] [int] DEFAULT(1) NOT NULL,
	[UserRole] [smallint] DEFAULT (0) NOT NULL,
	[UserAccess] [smallint] DEFAULT (0) NOT NULL,
	[LastAccessedOn] [smalldatetime] NOT NULL,
	[TokenExpiry] [smalldatetime] NOT NULL,
	[profile_image_url] [nvarchar](255) DEFAULT ('') NOT NULL
)

GO

/* Foreign Keys */

ALTER TABLE OAuthAccount
ADD CONSTRAINT [FK_OAuthAccount_UserRole] FOREIGN KEY([UserRole]) REFERENCES [dbo].[UserRole] ([Code])

ALTER TABLE OAuthAccount
ADD CONSTRAINT [FK_OAuthAccount_UserAccess] FOREIGN KEY([UserAccess]) REFERENCES [dbo].[UserAccess] ([Code])

/* Alter existing tables PointDataSummary and PointDataComment with FK for OAuthAccount */

ALTER TABLE PointDataSummary
ADD CONSTRAINT [FK_PointDataSummary_OAuthAccount] FOREIGN KEY([CreatedById]) REFERENCES [dbo].[OAuthAccount] ([Id])

ALTER TABLE PointDataComment
ADD CONSTRAINT [FK_PointDataComment_OAuthAccount] FOREIGN KEY([CreatedById]) REFERENCES [dbo].[OAuthAccount] ([Id])

GO

/* Add system default OAuthAccount */

SET IDENTITY_INSERT OAuthAccount ON -- turn off temporarily

INSERT INTO OAuthAccount (Id, user_id, screen_name, oauth_token, oauth_token_secret, UserRole, UserAccess, LastAccessedOn, TokenExpiry, oauth_service_id) 
	VALUES(0, 0, 'system', '', '', 2, 0, GETUTCDATE(), GETUTCDATE(), 1)

SET IDENTITY_INSERT OAuthAccount OFF -- turn back on

GO

/* *************** Create OAuthClientApp Table ****************** */

CREATE TABLE [OAuthClientApp](
	[Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Guid] [nvarchar](255) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Comment] [nvarchar](255) DEFAULT ('') NOT NULL,
	[ConsumerKey] [nvarchar](255) NOT NULL,
	[ConsumerSecret] [nvarchar](255) NOT NULL,
	[CallbackUrl] [nvarchar](1000) NOT NULL,
	[AppUrl] [nvarchar](1000) NOT NULL,
	[oauth_service_name] [nvarchar](50) DEFAULT ('Twitter') NOT NULL,
	[CreatedOn] [smalldatetime] DEFAULT GETUTCDATE()
)

GO

/* *********************************************************************** 

   Below, add your Twitter app keys that are allowed to use ODAF. 
   Register at http://twitter.com/oauth_clients/new 
   Generate a Guid for each client that you want to give access. 
   This app guid is used to identify the client app in authentication calls. 
   
   The sample app record below is just an example, and does NOT work 
   
************************************************************************* */


INSERT INTO OAuthClientApp (Guid, Name, Comment, ConsumerKey, ConsumerSecret, CallbackUrl, AppUrl) 
	VALUES('398E5663-3B80-4832-A7F9-325ECFDA1017', 'NitobiOpenData', 'localhost test', 
	'Cpaycrrf635OWMm9SCeGcA', 'ai038TL7Sxali5qDQK7FSbdlmXTh7BqCcnaJHCMz4jc', 
	'http://bit.ly/a1DEju', 'https://twitter.com/oauth_clients/details/70740')
INSERT INTO OAuthClientApp (Guid, Name, Comment, ConsumerKey, ConsumerSecret, CallbackUrl, AppUrl) 
	VALUES('D5B672D4-7B1C-46cc-8643-FBE8334F4ADF', 'VanGuide', 'staging in the cloud', 
	'cQBwvcwaUeYkoj7BkEVNw', 'IMUVXbVGKEkPAFR5CHJK4Kdh9yz98eBAAdfuVYQFtw', 
	'http://vanguide.cloudapp.net/User/AuthorizeReturn', 'https://twitter.com/oauth_clients/details/73569')

GO

/* Alter existing table OAuthAccount with FK for OAuthClientApp */

ALTER TABLE [OAuthAccount]
ADD CONSTRAINT [FK_OAuthAccount_OauthServiceId] FOREIGN KEY([oauth_service_id]) REFERENCES [dbo].[OAuthClientApp] ([Id])

GO

/* ****************** Create PointDataLayer Table ********************/

CREATE TABLE [PointDataLayer](
	[Id] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Guid] [nvarchar](255) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[IsSystem] [bit] DEFAULT (0),
	[CreatedOn] [smalldatetime] DEFAULT GETUTCDATE()
)

GO

/* *********************************************************************** 
 
 The Guids here correspond to the ATOM entries in the ATOM feeds of the
 app (where we get the KML sources from).
 All of them are 'system' layers, to differentiate them from user
 generated layers.
 
************************************************************************* */

INSERT PointDataLayer(Guid, Name, IsSystem) VALUES('2C8B8CF2-90DB-45f0-B8B4-A3D96DBEAFC3', 'Communities', 1)
INSERT PointDataLayer(Guid, Name, IsSystem) VALUES('0C244261-26E3-49f9-8EE5-140145E90B6C', 'Firehalls', 1)
INSERT PointDataLayer(Guid, Name, IsSystem) VALUES('F29526CF-9A53-44c8-B71A-2D4EAA739F2F', 'Fountains', 1)
INSERT PointDataLayer(Guid, Name, IsSystem) VALUES('25259A77-E237-4701-9213-69A8AC5A87DA', 'Libraries', 1)
INSERT PointDataLayer(Guid, Name, IsSystem) VALUES('059AEBD2-4960-4500-868D-E57AC8DBE329', 'Parks', 1)
INSERT PointDataLayer(Guid, Name, IsSystem) VALUES('0D06E24C-C8F7-4236-94BF-64A06760B4A1', 'Schools', 1)
INSERT PointDataLayer(Guid, Name, IsSystem) VALUES('0D06E24C-C8F7-4236-94BF-64A06760B421', 'Translink Stops', 1)
INSERT PointDataLayer(Guid, Name, IsSystem) VALUES('8C4A5ECA-9A7F-4274-919E-A22D02BE9C71','All Impark Parking Lots', 1)
INSERT PointDataLayer(Guid, Name, IsSystem) VALUES('89BBDE65-B700-4473-8370-7239DA5CC98B', 'Metro Impark Parking Lots', 1)

GO
