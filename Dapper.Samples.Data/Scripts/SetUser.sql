USE [DAPPERSAMPLE.MDF]
GO

/****** Object:  StoredProcedure [dbo].[SetUser]    Script Date: 08-07-2020 07:52:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[SetUser]
@payload NVARCHAR(MAX)
AS
SET XACT_ABORT ON;

IF ( ISJSON(@payload) != 1 )
	THROW 50000, '@payload is not a valid JSON document', 1;

DECLARE @userId INT, @companyId INT;

BEGIN TRAN;

DECLARE @C AS TABLE (CompanyId INT);

MERGE INTO
	[dbo].[Companies] AS t
USING
	OPENJSON(@payload, '$.Company') WITH 
	(
		Id INT, 
		CompanyName NVARCHAR(100),
		City NVARCHAR(100) '$.Address.City',
		Country NVARCHAR(100) '$.Address.Country',
		[State] NVARCHAR(100) '$.Address.State',
		Street NVARCHAR(100) '$.Address.Street'
	) AS s
ON 
	t.Id = s.Id
WHEN NOT MATCHED THEN 
	INSERT (CompanyName, Street, City, [State], Country)
    VALUES (s.CompanyName, s.Street, s.City, s.[State], s.Country)
WHEN MATCHED THEN
    UPDATE SET 		
		t.CompanyName = s.CompanyName,
        t.Street = s.Street,
        t.City = s.City,
		t.[State] = s.[State],
		t.Country = s.Country
OUTPUT
	[Inserted].Id INTO @C
;	

SELECT TOP(1) @companyId = CompanyId FROM @C;

DECLARE @U AS TABLE (UserId INT);

MERGE INTO 
	dbo.Users AS t
USING
	(
		SELECT 
			Id ,
            FirstName ,
            LastName ,
            EmailAddress ,
            CustomData, 
			@companyId AS CompanyId 
		FROM 
			OPENJSON(@payload) WITH 
			( 
				Id INT ,
				FirstName NVARCHAR(100) ,
				LastName NVARCHAR(100) ,
				EmailAddress NVARCHAR(255) ,
				CustomData NVARCHAR(MAX) '$.Preferences' AS JSON 
			)
	) AS s
ON 
	t.Id = s.Id
WHEN NOT MATCHED THEN 
	INSERT (FirstName, LastName, EMailAddress, CompanyId, CustomData )
    VALUES (s.FirstName, s.LastName, s.EmailAddress, s.CompanyId, JSON_MODIFY('{}', '$.Preferences', JSON_QUERY(s.CustomData)))
WHEN MATCHED THEN
    UPDATE SET 
		t.FirstName = s.FirstName ,
        t.LastName = s.LastName ,
        t.EMailAddress = s.EmailAddress ,
		t.CompanyId = s.CompanyId,
        t.CustomData = JSON_MODIFY(ISNULL(t.CustomData, '{}'), '$.Preferences', JSON_QUERY(s.CustomData))
OUTPUT
	[Inserted].Id INTO @U;

SELECT TOP(1) @userId = UserId FROM @u;

DELETE FROM dbo.[UserTags] WHERE UserId = @userId;

INSERT INTO dbo.[UserTags] 
SELECT 
	@userId AS UserId,
	Tag
FROM 
	OPENJSON(@payload, '$.Tags') WITH
	(
		Tag VARCHAR(100) '$'
	);


WITH cte AS
(
	SELECT
		r2.[value] AS [role]
	FROM
		OPENJSON(@payload, '$.Roles') r
	CROSS APPLY
		OPENJSON(r.[value]) r2
)
UPDATE
	dbo.[Users] 
SET
	Roles = STUFF((SELECT ',' + [role] AS [text()] FROM cte FOR XML PATH('')), 1,1, '')
WHERE
	Id = @userId

COMMIT TRAN;

EXEC dbo.GetUser @userId
GO

