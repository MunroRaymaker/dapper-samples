USE [DAPPERSAMPLE.MDF]
GO

/****** Object:  StoredProcedure [dbo].[GetUsersJson]    Script Date: 08-07-2020 07:53:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[GetUsersJson]
AS
SELECT
	JSON_QUERY((
		SELECT 
			u.Id,
			u.FirstName,
			u.LastName,
			u.EmailAddress,
			JSON_QUERY((SELECT [Tag] as [Name] FROM dbo.[UserTags] t WHERE t.UserId = u.Id FOR JSON PATH)) AS Tags
		FROM 
			dbo.Users u 
		WHERE
			ou.Id = u.Id
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	))
FROM
	dbo.Users ou
WHERE
	ou.Id <= 5


GO

