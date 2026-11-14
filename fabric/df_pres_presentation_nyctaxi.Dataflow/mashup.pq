[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Append"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared #"stg nyctaxi_yellow" = let
  Source = Fabric.Warehouse(null),
  Navigation = Source{[workspaceId = "ae92e6a7-82d4-4420-a0e7-0aa4664ddfe6"]}[Data],
  #"Navigation 1" = Navigation{[warehouseId = "a8c2191d-e825-44df-98fb-825183a7afb7"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "stg", Item = "nyctaxi_yellow"]}[Data],
  #"Removed columns" = Table.RemoveColumns(#"Navigation 2", {"RatecodeID", "store_and_fwd_flag", "fare_amount", "extra", "mta_tax", "tip_amount", "tolls_amount", "improvement_surcharge", "congestion_surcharge", "Airport_fee"}),
  #"Inserted conditional column" = Table.AddColumn(#"Removed columns", "vendor", each if [VendorID] = 1 then "Creative Mobile Technologies" else if [VendorID] = 2 then "Verifone" else "Unknown"),
  #"Reordered columns" = Table.ReorderColumns(#"Inserted conditional column", {"VendorID", "vendor", "tpep_pickup_datetime", "tpep_dropoff_datetime", "passenger_count", "trip_distance", "PULocationID", "DOLocationID", "payment_type", "total_amount"}),
  #"Removed columns 1" = Table.RemoveColumns(#"Reordered columns", {"VendorID"}),
  #"Inserted conditional column 1" = Table.AddColumn(#"Removed columns 1", "Custom", each if [payment_type] = 1 then "Credit Card" else if [payment_type] = 2 then "Cash" else if [payment_type] = 3 then "No Charge" else if [payment_type] = 4 then "Dispute" else if [payment_type] = 5 then "Unknown" else if [payment_type] = 6 then "Voided Trip" else "Unknown"),
  #"Renamed columns" = Table.RenameColumns(#"Inserted conditional column 1", {{"Custom", "payment_method"}}),
  #"Removed columns 2" = Table.RemoveColumns(#"Renamed columns", {"payment_type"}),
  #"Reordered columns 1" = Table.ReorderColumns(#"Removed columns 2", {"vendor", "tpep_pickup_datetime", "tpep_dropoff_datetime", "passenger_count", "trip_distance", "PULocationID", "DOLocationID", "payment_method", "total_amount"}),
  #"Renamed columns 1" = Table.RenameColumns(#"Reordered columns 1", {{"PULocationID", "pu_location_id"}, {"DOLocationID", "do_location_id"}}),
  #"Calculated date" = Table.TransformColumns(#"Renamed columns 1", {{"tpep_pickup_datetime", each DateTime.Date(_), type nullable date}, {"tpep_dropoff_datetime", each DateTime.Date(_), type nullable date}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Calculated date", {{"vendor", type text}, {"payment_method", type text}})
in
  #"Changed column type";
shared #"stg taxi_zone_lookup" = let
  Source = Fabric.Warehouse(null),
  Navigation = Source{[workspaceId = "ae92e6a7-82d4-4420-a0e7-0aa4664ddfe6"]}[Data],
  #"Navigation 1" = Navigation{[warehouseId = "a8c2191d-e825-44df-98fb-825183a7afb7"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "stg", Item = "taxi_zone_lookup"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"LocationID", Int64.Type}})
in
  #"Changed column type";
shared pu_borough_zone = let
  Source = Table.NestedJoin(#"stg nyctaxi_yellow", {"pu_location_id"}, #"stg taxi_zone_lookup", {"LocationID"}, "stg taxi_zone_lookup", JoinKind.LeftOuter),
  #"Expanded stg taxi_zone_lookup" = Table.ExpandTableColumn(Source, "stg taxi_zone_lookup", {"Borough", "Zone"}, {"Borough", "Zone"}),
  #"Reordered columns" = Table.ReorderColumns(#"Expanded stg taxi_zone_lookup", {"vendor", "tpep_pickup_datetime", "tpep_dropoff_datetime", "passenger_count", "trip_distance", "pu_location_id", "Borough", "Zone", "do_location_id", "payment_method", "total_amount"})
in
  #"Reordered columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Merge_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "vendor", DestinationColumnName = "vendor"], [SourceColumnName = "tpep_pickup_datetime", DestinationColumnName = "tpep_pickup_datetime"], [SourceColumnName = "tpep_dropoff_datetime", DestinationColumnName = "tpep_dropoff_datetime"], [SourceColumnName = "pu_borough", DestinationColumnName = "pu_borough"], [SourceColumnName = "pu_zone", DestinationColumnName = "pu_zone"], [SourceColumnName = "do_borough", DestinationColumnName = "do_borough"], [SourceColumnName = "do_zone", DestinationColumnName = "do_zone"], [SourceColumnName = "payment_method", DestinationColumnName = "payment_method"], [SourceColumnName = "passenger_count", DestinationColumnName = "passenger_count"], [SourceColumnName = "trip_distance", DestinationColumnName = "trip_distance"], [SourceColumnName = "total_amount", DestinationColumnName = "total_amount"]}], DynamicSchema = false, UpdateMethod = [Kind = "Append"], TypeSettings = [Kind = "Table"]]]}]
shared Merge = let
  Source = Table.NestedJoin(pu_borough_zone, {"do_location_id"}, #"stg taxi_zone_lookup", {"LocationID"}, "stg taxi_zone_lookup", JoinKind.LeftOuter),
  #"Expanded stg taxi_zone_lookup" = Table.ExpandTableColumn(Source, "stg taxi_zone_lookup", {"Borough", "Zone"}, {"Borough.1", "Zone.1"}),
  #"Reordered columns" = Table.ReorderColumns(#"Expanded stg taxi_zone_lookup", {"vendor", "tpep_pickup_datetime", "tpep_dropoff_datetime", "passenger_count", "trip_distance", "pu_location_id", "Borough", "Zone", "do_location_id", "Borough.1", "Zone.1", "payment_method", "total_amount"}),
  #"Renamed columns" = Table.RenameColumns(#"Reordered columns", {{"Borough", "pu_borough"}, {"Zone", "pu_zone"}, {"Borough.1", "do_borough"}, {"Zone.1", "do_zone"}}),
  #"Removed columns" = Table.RemoveColumns(#"Renamed columns", {"pu_location_id", "do_location_id"}),
  #"Reordered columns 1" = Table.ReorderColumns(#"Removed columns", {"vendor", "tpep_pickup_datetime", "tpep_dropoff_datetime", "pu_borough", "pu_zone", "do_zone", "do_borough", "payment_method", "passenger_count", "trip_distance", "total_amount"})
in
  #"Reordered columns 1";
shared DefaultDestination = Fabric.Warehouse([CreateNavigationProperties = false]){[workspaceId = "ae92e6a7-82d4-4420-a0e7-0aa4664ddfe6"]}[Data]{[warehouseId = "a8c2191d-e825-44df-98fb-825183a7afb7"]}[Data];
shared Merge_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "ae92e6a7-82d4-4420-a0e7-0aa4664ddfe6"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "a8c2191d-e825-44df-98fb-825183a7afb7"]}[Data],
  Navigation_3 = Navigation_2{[Schema = "dbo"]}[Data],
  TableNavigation = Navigation_3{[Name = "nyctaxi_yellow"]}[Data]
in
  TableNavigation;
