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
IF OBJECT_ID('dbo.dim_date') IS NOT NULL
BEGIN
    DROP EXTERNAL TABLE dbo.dim_date;
END

GO


CREATE EXTERNAL TABLE dbo.dim_date(
    DateKey INT,
    DateValue DATE,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT,
    WeekOfYear INT,
    DayOfWeek INT
)
	WITH (
	LOCATION = 'dim_date',
	DATA_SOURCE = [joerivlieghe2_joerivlieghe_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)

-- Step 2: Define the start and end dates for the range
DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME

SET @StartDate = (SELECT MIN(TRY_CONVERT(datetime, left(start_at, 19))) FROM staging_trip)
SET @EndDate = DATEADD(year, 5, (SELECT MAX(TRY_CONVERT(datetime, left(start_at, 19))) FROM staging_trip))

-- Step 3: Populate the dim_date table
DECLARE @Date DATE = @StartDate;

WHILE @Date <= @EndDate
BEGIN
    INSERT INTO dim_date (DateKey, DateValue, Year, Quarter, Month, Day, WeekOfYear, DayOfWeek)
    VALUES (
        CONVERT(INT, FORMAT(@Date, 'yyyyMMdd')),
        @Date,
        YEAR(@Date),
        DATEPART(QUARTER, @Date),
        MONTH(@Date),
        DAY(@Date),
        DATEPART(WEEK, @Date),
        DATEPART(WEEKDAY, @Date)        
    );

    SET @Date = DATEADD(DAY, 1, @Date);
END;

GO

SELECT TOP 100 * FROM dbo.dim_date