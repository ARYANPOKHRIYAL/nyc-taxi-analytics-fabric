-- Create the metadata schema for pipeline run metadata.
CREATE SCHEMA metadata;

-- Create a table to store pipeline run metadata.
CREATE TABLE metadata.processing_log (
    pipeline_run_id          VARCHAR(255),  -- Pipeline run ID
    table_processed          VARCHAR(255),  -- Table processed in the run
    rows_processed           INT,            -- Number of rows processed
    latest_processed_pickup  DATETIME2(6),   -- Latest pickup datetime processed
    processed_datetime       DATETIME2(6)    -- Date and time of the pipeline run
);
