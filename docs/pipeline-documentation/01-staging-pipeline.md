# 01 - Staging Pipeline



#### Overview

The staging pipeline ingests monthly NYC Yellow Taxi trip data from the **NYCProjectLakehouse** into the Fabric Warehouse staging table **stg.nyctaxi\_yellow**. It uses an initial run to load January 2024 and establish processing metadata, followed by dynamic runs that determine and load subsequent months without manually changing the source file for each run.

## 

#### Initial Run — January 2024



**Pipeline Variables**

1. v\_date: string type, stores the start date of the month being processed in the processing window.
2. v\_end\_date: string type, stores the end date of the month being processed in the processing window.



1. **Copy January data**

   * Source: Project Lakehouse, Parquet trip data.
   * Set **v\_date** to `2024-01` for the initial run.
   * Copy the data into **stg.nyctaxi\_yellow** in the Project Warehouse, using **v\_date** and dynamic content.
   * The staging table is auto-created on this initial load, using insert behavior.



2. **Calculate the end date**

   * Set **v\_end\_date** by using the first day of **v\_date** and adding one month using pipeline expression builder \& dynamic content.
   * For January 2024, the processing window is `2024-01-01` to `2024-02-01`.



3. **Run the staging cleanup procedure**

   * Execute the custom stored procedure against **stg.nyctaxi\_yellow** to remove any outliers from the staging data.
   * Pass the start and end dates derived from **v\_date** and **v\_end\_date** to define the processing window.



4. **Log processing metadata**

   * Execute a stored procedure to write the pipeline run details to the processing log table.
   * The logged details include:

     * Pipeline Run ID
     * Pipeline trigger time
     * Table processed (**stg.nyctaxi\\\_yellow**)
     * Latest processed pickup date/time (**MAX(pickup\_datetime)**)
     * Number of rows (**COUNT(\*)**)

## 

#### Dynamic Runs — February 2024 Onward



After the initial run, the pipeline uses the processing log to identify the latest processed pickup date and determine the next month to load.

5. **Retrieve the latest processed date**

   * Use a Script activity to query the processing log table.
   * Retrieve the latest processed pickup date recorded by the previous run.
6. **Set v\_date dynamically**

   * Populate **v\_date** using the output returned by the Script activity.
   * Use this value to identify the next monthly Parquet file to process.
7. **Load the next month's data**

   * Use **v\_date** dynamically in the Copy activity to select the next month's source file.
   * Run a pre-copy script to delete the previous month's records from **stg.nyctaxi\_yellow** before loading the new month.
   * Insert the new month's data into the existing staging table; the table is not recreated.



The dynamic process is repeated for subsequent monthly files. It is designed to accommodate future months without manually changing the source configuration for each run.

