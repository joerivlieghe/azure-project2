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



--Create dim_time table

IF OBJECT_ID('dbo.dim_time') IS NOT NULL
BEGIN
    DROP EXTERNAL TABLE dbo.dim_time
    ;
END

GO


CREATE EXTERNAL TABLE dbo.dim_time
(
    date_id DATE,
    year INT,
    quarter INT,
    month INT,
    day_of_week INT,
    day_of_month INT,
    WeekOfYear INT
)
	WITH (
	LOCATION = 'dim_time',
	DATA_SOURCE = [joerivlieghe2_joerivlieghe_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)


-- insert dates from other tables into dim_time

INSERT INTO dim_time

SELECT 
TRY_CONVERT(DATETIME, LEFT(st.start_at, 10)) as date_id
FROM staging_trip as st
UNION
SELECT
TRY_CONVERT(DATETIME, LEFT(st.ended_at, 10)) as date_id
FROM staging_trip as st
UNION
SELECT
TRY_CONVERT(DATETIME, LEFT(sp.date, 10)) as date_id
FROM staging_payment as sp
UNION
SELECT
TRY_CONVERT(DATETIME, LEFT(sr.birthday, 10)) as date_id
FROM staging_rider as sr
UNION
SELECT
TRY_CONVERT(DATETIME, LEFT(sa.start_date, 10)) as date_id
FROM staging_account as sa
UNION
SELECT
TRY_CONVERT(DATETIME, LEFT(sa.end_date, 10)) as date_id
FROM staging_account as sa
GO


-- add all necessary values into dim_time

ALTER TABLE dim_time

ADD Year INTEGER
UPDATE dim_time

SET Year = DATEPART(year, date_id)

ALTER TABLE dim_time

ADD  Quarter INTEGER
UPDATE dim_time

SET Quarter = DATEPART(quarter, date_id)

ALTER TABLE dim_time

ADD  Month INTEGER
UPDATE dim_time

SET Month = DATEPART(month, date_id)

ALTER TABLE dim_time

ADD  day_of_week INTEGER
UPDATE dim_time

SET day_of_week = DATEPART(weekday, date_id)

ALTER TABLE dim_time

ADD  day_of_month INTEGER
UPDATE dim_time

SET day_of_month = DATEPART(day, date_id)

ALTER TABLE dim_time

ADD  WeekOfYear INTEGER
UPDATE dim_time

SET WeekOfYear = DATEPART(iso_week, date_id)