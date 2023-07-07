IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 FIRST_ROW = 2,
			 USE_TYPE_DEFAULT = FALSE
			))
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'joerivlieghe2_joerivlieghe_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [joerivlieghe2_joerivlieghe_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://joerivlieghe2@joerivlieghe.dfs.core.windows.net' 
	)
GO

--Create fact_payment table
IF OBJECT_ID('dbo.fact_payment') IS NOT NULL
BEGIN
    DROP EXTERNAL TABLE dbo.fact_payment;
END

GO


CREATE EXTERNAL TABLE dbo.fact_payment
	WITH (
	LOCATION = 'fact_payment',
	DATA_SOURCE = [joerivlieghe2_joerivlieghe_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
AS
SELECT 
    sp.payment_id,
    sp.date,
    sp.rider_id,
    sp.amount
FROM
    staging_payment sp

GO