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

--Create fact_trip table
IF OBJECT_ID('dbo.fact_trip') IS NOT NULL
BEGIN
    DROP EXTERNAL TABLE dbo.fact_trip;
END

GO


CREATE EXTERNAL TABLE dbo.fact_trip
	WITH (
	LOCATION = 'fact_trip',
	DATA_SOURCE = [joerivlieghe2_joerivlieghe_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
AS
SELECT 
    st.trip_id,
    st.rider_id,
    st.rideable_type,
    st.start_at AS start_time,
    st.ended_at AS end_time,
    DATEDIFF(second, st.start_at, st.ended_at) / 60.0 AS duration
    st.start_station_id,
    st.end_station_id,
    (DATEDIFF(year, sr.birthday,
    CONVERT(Datetime, SUBSTRING([started_at], 1, 19),120)) - (
        CASE WHEN MONTH(sr.birthday) > MONTH(CONVERT(Datetime, SUBSTRING([st.started_at], 1, 19),120))
        OR MONTH(sr.birthday) =
            MONTH(CONVERT(Datetime, SUBSTRING([st.started_at], 1, 19),120))
        AND DAY(sr.birthday) >
            DAY(CONVERT(Datetime, SUBSTRING([st.started_at], 1, 19),120))
        THEN 1 ELSE 0 END
    )) AS [rider_age]
FROM
    staging_trip st
JOIN staging_rider sr ON st.rider_id = sr.rider_id

GO