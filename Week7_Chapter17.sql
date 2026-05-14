USE AP;
GO 

-- 1: Cretaes PaymentEntry role and grants table permision.
DROP ROLE IF EXISTS PaymentEntry;
CREATE ROLE PaymentEntry;
GRANT UPDATE ON Invoices TO PaymentEntry;
GRANT UPDATE, INSERT ON InvoiceLineItems TO PaymentEntry;
GRANT SELECT ON SCHEMA::dbo TO PaymentEntry;


-- 2: Creates login AAaron, user Aaron, and assigns to PaymentEntry.
CREATE LOGIN AAaron WITH PASSWORD = 'AAar99999', 
	DEFAULT_DATABASE = AP;

CREATE USER AAaron FOR LOGIN AAaron; 
ALTER ROLE PaymentEntry ADD MEMBER AAaron;


-- 3: Cursor and dynamic SQl to create logings, users, and assign to PaymentEntry. 
CREATE TABLE NewLogins(LoginName varchar(10));
INSERT INTO NewLogins VALUES 
					('BBrown'), ('CChaplin'), ('DDyer'), ('EEbbers');
DECLARE 
	@LoginName varchar(120), 
	@Password varchar(20), 
	@Statement nvarchar(200);

DECLARE NewLogin_Cursor CURSOR FOR 
	SELECT LoginName
	FROM NewLogins;

OPEN NewLogin_Cursor
FETCH NEXT FROM NewLogin_Cursor INTO @LoginName;

WHILE @@FETCH_STATUS = 0
BEGIN 
	SET @Password = LEFT(@LoginName, 4) + '99999';

	SET @Statement = 
					'CREATE LOGIN ' + @LoginName + 
					' WITH PASSWORD = ''' + @Password + ''', DEFAULT_DATABASE = AP';
	EXEC(@Statement);

	SET @Statement = 'CREATE USER ' + @LoginName + ' FOR LOGIN ' + @LoginName;
	EXEC(@Statement);

	SET @Statement = 'ALTER ROLE PaymentEntry ADD MEMBER ' + @LoginName;
	EXEC(@Statement)

	FETCH NEXT FROM NewLogin_Cursor INTO @LoginName;
END; 
CLOSE NewLogin_Cursor;
DEALLOCATE NewLogin_Cursor;


-- 5: Removes all users from PaymentEntry role then drips it.
ALTER ROLE PaymentEntry DROP MEMBER AAaron;
ALTER ROLE PaymentEntry DROP MEMBER BBrown;
ALTER ROLE PaymentEntry DROP MEMBER CChaplin;
ALTER ROLE PaymentEntry DROP MEMBER DDyer;
ALTER ROLE PaymentEntry DROP MEMBER EEbbers;
ALTER ROLE PaymentEntry DROP MEMBER FFalk;
DROP ROLE PaymentEntry;


-- 6: Creates admin schema and grants permissions. 
ALTER USER AAaron WITH DEFAULT_SCHEMA = Admin;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Admin TO AAaron;