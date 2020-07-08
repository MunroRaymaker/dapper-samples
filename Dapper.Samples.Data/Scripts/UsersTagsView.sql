USE [DAPPERSAMPLE.MDF]
GO

/****** Object:  View [dbo].[UsersTagsView]    Script Date: 08-07-2020 07:56:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[UsersTagsView]
AS
SELECT 
	u.Id,
	FirstName,
	LastName,
	EmailAddress,
	Roles,	
	(SELECT JSON_QUERY(REPLACE(REPLACE((SELECT [Tag] FROM dbo.[UserTags] t WHERE t.UserId = u.Id FOR JSON PATH), '{"Tag":', ''), '}', ''))) AS Tags
FROM 
	dbo.[Users] u 
GO

