# 02 - Transformation Logic (Dataflow Gen 2)



#### Overview

The transformation is performed using **Dataflow Gen2** in Microsoft Fabric. It takes the NYC Yellow Taxi trip data from the Warehouse staging table, enriches the trip records with taxi zone reference information, and prepares the result for the presentation layer.



#### Input Tables

* **stg.nyctaxi\_yellow** — monthly NYC Yellow Taxi trip data loaded by the staging pipeline.
* **stg.taxi\_zone\_lookup** — reference data used to map taxi location IDs to zone names and boroughs.



#### Transformation Steps

1. **Load the source data**

   * Read the trip data from **stg.nyctaxi\_yellow**.
   * Read the taxi zone reference data from **stg.taxi\_zone\_lookup**.
2. **Enrich pickup information**

   * Merge the trip data with **stg.taxi\_zone\_lookup** using the pickup location ID.
   * Expand the matched zone name and borough fields to add descriptive pickup information to each trip.
3. **Enrich drop-off information**

   * Merge the pickup-enriched data with **stg.taxi\_zone\_lookup** again, this time using the drop-off location ID.
   * Expand the matched zone name and borough fields to add descriptive drop-off information to each trip.
4. **Prepare the final transformed output**

   * The resulting **dropoff\_merged** query contains the trip data enriched with pickup and drop-off zone names and boroughs.
   * The Dataflow Gen2 output is stored in the Warehouse presentation table **dbo.nyctaxi\_yellow**.



#### Output

**dbo.nyctaxi\_yellow** — the presentation-layer trip table containing the transformed trip records and enriched pickup/drop-off location details, ready for analytical use.

