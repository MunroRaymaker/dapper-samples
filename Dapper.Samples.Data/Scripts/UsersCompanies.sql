USE [DAPPERSAMPLE.MDF]
GO

/****** Object:  View [dbo].[UsersCompanies]    Script Date: 08-07-2020 07:55:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[UsersCompanies]
AS
SELECT 
	u.Id AS UserId,
	FirstName,
	LastName,
	EmailAddress,
	c.Id AS CompanyId,
	c.CompanyName,
	c.[Street], 
	c.City, 
	c.[State], 
	c.Country
FROM 
	dbo.[Users] u 
INNER JOIN 
	dbo.[Companies] c ON u.CompanyId = c.Id

GO

