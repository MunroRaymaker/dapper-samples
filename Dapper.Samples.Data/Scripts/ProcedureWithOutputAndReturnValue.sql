USE [DAPPERSAMPLE.MDF]
GO

/****** Object:  StoredProcedure [dbo].[ProcedureWithOutputAndReturnValue]    Script Date: 08-07-2020 07:54:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ProcedureWithOutputAndReturnValue]
@email nvarchar(255),
@firstName nvarchar(100) output,
@lastName nvarchar(100) output
AS
DECLARE @userId INT
SELECT 
	@userId = Id, 
	@firstName = FirstName, 
	@lastName = LastName 
FROM 
	dbo.[Users] 
WHERE
	EMailAddress = @email
RETURN @userId
GO

