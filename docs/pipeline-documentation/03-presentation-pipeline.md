# 03 – Presentation Pipeline



#### Overview

The **pl\_pres\_processing\_nyctaxi** pipeline processes the transformed NYC Yellow Taxi data and records execution metadata.



#### Pipeline Flow

1. **Run Dataflow Gen2** – Executes the data transformation logic, including cleaning the taxi trip data and enriching pickup and drop-off details using the taxi zone lookup data.
2. **Load the presentation table** – The Dataflow Gen2 output is stored in the Warehouse presentation table **dbo.nyctaxi\_yellow**.
3. **Log pipeline run metadata** – After the Dataflow Gen2 activity succeeds, a Stored Procedure records the run details in the Metadata Processing Log table.



#### Metadata Processing Log

The Stored Procedure updates the following fields in the Metadata Processing Log table:

* **Pipeline Run ID**
* **Table Processed**
* **Rows Processed**
* **Latest Processed Pickup**
* **Processed DateTime**



#### Execution Dependency

The Stored Procedure runs only after the Dataflow Gen2 activity completes successfully. This ensures that the metadata is logged after the presentation data has been processed and loaded.



#### Output

* **Presentation table:** **dbo.nyctaxi\_yellow**
* **Execution log:** Metadata Processing Log table

