# 04 – Orchestration Pipeline



#### Overview

The master orchestration pipeline coordinates the staging and presentation pipelines for the NYC Yellow Taxi data. It ensures that the presentation pipeline starts only after the staging pipeline succeeds.

**Pipeline:** **pl\_orchestration\_nyctaxi**





#### Pipeline Flow

1. **Run the staging pipeline**

   * Starts the staging pipeline to ingest the monthly taxi Parquet file from the Lakehouse.
   * Loads the data into the Warehouse staging table: **stg.nyctaxi\_yellow**.



2. **Run the presentation pipeline on success**

   * The presentation pipeline runs only when the staging pipeline completes successfully.
   * It executes the transformation process and stores the cleaned and enriched data in the Warehouse presentation table: **dbo.nyctaxi\_yellow**.
   * The presentation pipeline then executes its stored procedure to record run metadata in the Metadata Processing Log table.



#### Pipeline Triggering

The orchestration pipeline can be started in either of the following ways:



* **Scheduled trigger:** Run the pipeline on a configured date or time when the next monthly dataset is expected to arrive.



* **Event-based trigger:** Start the pipeline when a new monthly Parquet file is added to the Lakehouse folder **Files/nyctaxi\_yellow**.



For the event-based approach, the intended OneLake event is **FileCreated**. The event condition should match the taxi dataset folder and Parquet files so that unrelated Lakehouse files do not start the pipeline.



Each month is delivered as one Parquet file. The event-based trigger is therefore intended to start the orchestration pipeline when that monthly file is created.





### End-to-End Flow


Event-based Trigger (When a new files is added)
  │
  ▼
pl\_orchestration\_nyctaxi
  │
  ▼
Staging Pipeline
  │
  ├── Load monthly data into stg.nyctaxi\_yellow  
  │
  ▼ (On Success)
Presentation Pipeline
  │
  ├── Transform and enrich the data
  ├── Load data into dbo.nyctaxi\_yellow
  └── Log execution metadata in the Metadata Processing Log


#### Outcome

The orchestration pipeline coordinates the two processing stages in the required order: staging first, followed by presentation on successful completion. It can be initiated by a schedule or by the arrival of a new monthly Parquet file in the Lakehouse.

