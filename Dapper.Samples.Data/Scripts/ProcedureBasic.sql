USE [DAPPERSAMPLE.MDF]
GO

/****** Object:  StoredProcedure [dbo].[ProcedureBasic]    Script Date: 08-07-2020 07:53:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ProcedureBasic]
@email nvarchar(255)
AS
SELECT 
	Id,
	FirstName,
	LastName,
	EMailAddress
FROM 
	dbo.[Users] 
WHERE
	EMailAddress = @email
GO

