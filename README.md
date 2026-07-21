# NYC-Restaurants-Inspections
## ETL Process
In this project I had the opportunity to build a fully functional pipeline that extract data from the *DOHMH New York City Restaurant Inspection Results*
database by an API call. The data is available for anyone on the NYC OpenData website, please reach the website on the link below.
`https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j/about_data`

#### Data Cleaning
After the extraction of the data **Python's Pandas library were used for the transformation**, let me mention some of the steps which were
- all variables were set to the correct data type,
- false NA-s (like "N/A" strings) were deleted,
- redundant columns were dropped
- data columns got the proper date format

#### Optimizing Data Structure
This Database contains several hundred thousand observations thus I thought splitting the database is necessary to be able to store it efficiently, it can be clearly seen that about half of the columns in the database connects directly to restaurants unique identifier named *camis*. I made a new table with these columns in which the camis became the unique identifier of the table. This table contains the columns can be seen below and only one record belongs to each restaurants.
```
["dba", "boro", "building", "street", "zipcode", "phone", "cuisine_description", "latitude",
 "longitude", "community_board", "council_district", "census_tract", "bin", "bbl", "nta"]
```
After creating the table for restaurants data these variables were deleted from the original table that contains the inspections data, only the unique identifier for restaurants were kept in this table to be able to match each restaurant with the inspections.

In addition, I realized in the variable *cuisine_description* there are several cases when more labels belongs to a restaurants. Fortunately these labels were separated by */* every time thus after splitting the values I could create their own record for every kind of cuisine of a restaurant.

Finally, all the transformed data were loaded into a database file in which I made tables for them previously. If you would like to see the detailed ETL process please don't hesitate to look at the python code.

## Analysing the Dataset
**While observing the dataset numerous questions arised that I was able to answer. Firstly I made SQL queries to get the correct structure and aggregation of the data**. First and foremost I have to mention that the data is aggregated by years as well in the all queries since the database contains data of several years.

In the followings I will explain briefly what all the queries were made for:

1. **Typical Inspections:** The most typical inspections type are displayed with the help of this query. Beside those types of inspections that can be seen in the *inspections type* column it is significant to emphasize inspections often happen in multiple round to check if the restaurant fixed the issues. The types of each round can be seen in the *inspection round* column.

2. **Cuisine Borough Pattern:** This query help to show the connection among the cuisine of the restaurant, the neighbourhood where the restaurant is and the number of critical violations that were found during the inspection. Thanks to this query the riskyness of each type of cousine can also be seen beside the boroughs' riskyness.

3. **Risky Boroughs Critical Ratio & Average Score:** There were 2 queries that showed the riskyness of eating out in each boroughs in New York by showing the average scores of restaurants in which authorities found a critical violation, not critical violation or doesn't find any kind of violation (not applicable). Moreover the 2nd query gives information about the proportion of restaurants that belongs to each violation categories in the boroughs of NYC.

4. **Franchise Safetyness:** Ordinary many franchises takes place in big cities beside the independent restaurants. In my opinion it is worth to look closely whether these franchise restaurants are safer for eating out or not. Since there were no information in the dataset if a restaurant is a part of a franchise or not I had to use a support table in which I collected parts of the most well known franchises names and if a restaurant's name consisted of any value in this table it is said to be a franchise restaurant.

You can see the difference among franchise and independent restaurants on a time series chart where the average scores and the ratio of critical violations can be seen for all years.

6.**Risky Areas:** Presumably there are part of New York where it can be more dangerous to eat out. In my last query I collected the geolocation of all the restaurants and the critical violation number belongs to each restaurants.

Altogether it can be said this project provided an opportunity to be able to do this data analysis from the extranction of the data to making visualizations.




