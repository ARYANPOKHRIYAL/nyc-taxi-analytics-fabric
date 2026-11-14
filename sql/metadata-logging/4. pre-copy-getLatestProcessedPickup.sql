-- Retrieve the latest pickup datetime processed for the staging table.

SELECT TOP 1 latest_processed_pickup
FROM metadata.processing_log
WHERE table_processed = 'staging_nyctaxi_yellow'
ORDER BY latest_processed_pickup DESC;
