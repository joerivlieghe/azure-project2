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


--Create dim_date table
IF EXISTS (SELECT * FROM sys.external_tables WHERE name = 'dim_date')
BEGIN
    DROP EXTERNAL TABLE dim_date;
END

CREATE EXTERNAL TABLE dim_date_external
WITH (
    LOCATION = 'dim_date',
	DATA_SOURCE = [joerivlieghe2_joerivlieghe_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
)
AS
SELECT
    CONVERT(INT, FORMAT(CAST(date_value AS DATETIME2), 'yyyyMMdd')),
    d.DateValue AS DateValue,
    YEAR(d.DateValue) AS Year,
    DATEPART(QUARTER, d.DateValue) AS Quarter,
    MONTH(d.DateValue) AS Month,
    DAY(d.DateValue) AS Day,
    DATEPART(WEEKDAY, d.DateValue) AS DayOfWeek,
    DATEPART(DAYOFYEAR, d.DateValue) AS DayOfYear,
    CASE WHEN DATEPART(WEEKDAY, d.DateValue) IN (1, 7) THEN 0 ELSE 1 END AS Weekday,
    DATEPART(WEEK, d.DateValue) AS WeekOfYear,
    CASE WHEN DATEPART(WEEKDAY, d.DateValue) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
FROM
    (SELECT DISTINCT DateValue FROM
        (SELECT start_at AS DateValue FROM staging_trip
         UNION
         SELECT ended_at AS DateValue FROM staging_trip) AS t) AS d;
