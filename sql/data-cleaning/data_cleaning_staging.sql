-- Deletes staging records outside the month currently being processed.

CREATE PROCEDURE stg.data_cleaning_stg
    @start_date DATETIME2,
    @end_date   DATETIME2
AS
BEGIN
    DELETE FROM stg.nyctaxi_yellow
    WHERE tpep_pickup_datetime < @start_date
       OR tpep_pickup_datetime > @end_date;
END;
