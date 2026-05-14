USE AP;
GO

-- Exercise 1: Rename Federal Express to FedUP, reassign UPS Invoices, 
-- and delete UPS vendor.
BEGIN TRAN;
BEGIN TRY 
	UPDATE Vendors 
	SET VendorName = 'FedUP'
	WHERE VendorName = 'Federal Express Corporation'

	UPDATE Invoices 
	SET 
		VendorID = (
			SELECT VendorID
			FROM Vendors 
			WHERE VendorName = 'FedUP'
		)
	WHERE 
		VendorID = (
			SELECT VendorID 
			FROM Vendors
			WHERE VendorName = 'United Parcel Service'
		);

	DELETE FROM  Vendors 
	WHERE VendorName = 'United Parcel Service';

	COMMIT TRAN;
END TRY
BEGIN CATCH	
	ROLLBACK TRAN;
	PRINT 'Error:' + ERROR_MESSAGE();
END CATCH;

-- test
SELECT 
	VendorID, 
	VendorName
FROM VendorS
WHERE VendorName = 'FedUP';


-- Exercise 2: Archive paid invoices and remove them from the Invoices table.
BEGIN TRAN;
BEGIN TRY

	INSERT INTO InvoiceArchive
	SELECT * 
	FROM Invoices 
	WHERE 
		PaymentTotal > 0 
		AND NOT EXISTS (
			SELECT 1 FROM InvoiceArchive 
			WHERE 
				InvoiceArchive.InvoiceID = Invoices.InvoiceID
		);

	DELETE FROM Invoices 
	WHERE 
		PaymentTotal > 0 
		AND EXISTS (
			SELECT 1 FROM InvoiceArchive 
			WHERE 
				InvoiceArchive.InvoiceID = Invoices.InvoiceID
		);

		COMMIT TRAN;
END TRY 
BEGIN CATCH	
	ROLLBACK TRAN;
	PRINT 'Error:' + ERROR_MESSAGE();
END CATCH;

-- TEST
SELECT COUNT(*) AS ArchCount 
FROM InvoiceArchive;

SELECT COUNT(*) AS RemaingCount 
FROM Invoices 
Where PaymentTotal > 0;