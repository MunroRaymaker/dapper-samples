USE [DAPPERSAMPLE.MDF]
GO

/****** Object:  StoredProcedure [dbo].[GetUser]    Script Date: 08-07-2020 07:52:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[GetUser]
@id INT 
AS
SELECT (
	SELECT	
		u.Id,
		u.FirstName,
		u.LastName,
		u.EMailAddress AS 'EmailAddress',
		(SELECT JSON_QUERY(REPLACE(REPLACE((SELECT [Tag] FROM dbo.[UserTags] t WHERE t.UserId = u.Id FOR JSON PATH), '{"Tag":', ''), '}', ''))) AS Tags,
		JSON_QUERY((SELECT r.[value] as [RoleName] FROM dbo.[Users] ur CROSS APPLY STRING_SPLIT(Roles, ',') AS r WHERE ur.Id = u.Id FOR JSON AUTO)) AS Roles,
		c.Id AS 'Company.Id',
		c.CompanyName AS 'Company.CompanyName',
		c.Street AS 'Company.Address.Street',
		c.City AS 'Company.Address.City',
		c.[State] AS 'Company.Address.State',
		c.Country AS 'Company.Address.Country',
		JSON_QUERY(u.CustomData, '$.Preferences') AS Preferences
	FROM
		dbo.[Users] u
	LEFT JOIN
		dbo.[Companies] c ON u.CompanyId = c.Id
	WHERE
		u.id = @id
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) as [object]
GO

