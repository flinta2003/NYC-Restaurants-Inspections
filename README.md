# NYC-Restaurants-Inspections
## ETL Process
In this project I had the opportunity to build a fully functional pipeline that extract data from the *DOHMH New York City Restaurant Inspection Results*
database by an API call. The data is available for anyone on the NYC OpenData website, please reach the website on the link below.
`https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j/about_data`

After the extraction of the data **Python's Pandas library were used for the transformation**, let me mention some of the steps which were
- all variables were set to the correct data type,
- false NA-s (like "N/A" strings) were deleted,
- redundant columns were dropped
- data columns got the proper date format

This Database contains several hundred thousand observations thus I thought splitting the database is necessary to be able to store it efficiently, it can be clearly seen that about half of the columns in the database connects directly to restaurants unique identifier named *camis*. I made a new table with these columns in which the camis became the unique identifier of the table. This table contains the columns can be seen below and only one record belongs to each restaurants.
```
["dba", "boro", "building", "street", "zipcode", "phone", "cuisine_description", "latitude",
 "longitude", "community_board", "council_district", "census_tract", "bin", "bbl", "nta"]
```
After creating the table for restaurants data these variables were deleted from the original table that contains the inspections data, only the unique identifier for restaurants were kept in this table to be able to match each restaurant with the inspections.

In addition, I realized in the variable *cuisine_description* there are several cases when more labels belongs to a restaurants. Fortunately these labels were separated by */* every time thus after splitting the values I could create their own record for every kind of cuisine of a restaurant.

Finally, all the transformed data were loaded into a database file in which I made tables for them previously. If you would like to see the detailed ETL process please don't hesitate to look at the python code.

## Query making

