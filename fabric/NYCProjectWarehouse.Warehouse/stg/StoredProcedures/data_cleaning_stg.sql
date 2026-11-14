CREATE PROCEDURE stg.data_cleaning_stg 
@start_date DATETIME2,
@end_date DATETIME2
as
DELETE FROM stg.nyctaxi_yellow 
WHERE tpep_pickup_datetime <@start_date 
or tpep_pickup_datetime > @end_date;

GO