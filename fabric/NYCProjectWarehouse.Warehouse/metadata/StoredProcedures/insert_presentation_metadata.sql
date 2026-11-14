CREATE PROCEDURE metadata.insert_presentation_metadata
    @pipeline_run_id VARCHAR(255),                      -- parameters defined(fetched from the pipeline run)
    @table_name VARCHAR(255),
    @processed_date DATETIME2
AS
    INSERT INTO metadata.processing_log(pipeline_run_id, table_processed, rows_processed, latest_processed_pickup, processed_datetime)
    SELECT
        @pipeline_run_id as pipeline_run_id,
        @table_name as table_processed,
        COUNT(*) as rows_processed,
        MAX(tpep_pickup_datetime) as latest_processed_pickup,
        @processed_date as processed_datetime
        FROM dbo.nyctaxi_yellow;

GO