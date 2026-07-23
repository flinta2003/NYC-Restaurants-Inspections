# NYC-Restaurants-Inspections
## ETL Process
In this project I had the opportunity to build a fully functional pipeline that extract data from the *DOHMH New York City Restaurant Inspection Results*
database by an API call. The data is available for anyone on the NYC OpenData website, please reach the website on the link below.
`https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j/about_data`

#### Data Cleaning
After the extraction of the data **Python's Pandas library was used for the transformation**, let me mention some of the steps which were
- all variables were set to the correct data type;
- false NA values (such as "N/A" strings) were removed;
- redundant columns were dropped;
- data columns got the proper date format.

#### Optimizing Data Structure
This Database contains several hundred thousand observations thus I thought splitting the database was necessary to be able to store it efficiently, it can be clearly seen that about half of the columns in the dataset connected directly to restaurants unique identifier named *camis*. I made a new table with these columns in which the camis became the unique identifier of the table. This table contains the columns can be seen below and only one record belongs to each restaurant.
```
["dba", "boro", "building", "street", "zipcode", "phone", "cuisine_description", "latitude",
 "longitude", "community_board", "council_district", "census_tract", "bin", "bbl", "nta"]
```
After creating the table for restaurants data these variables were deleted from the original table that contains the inspections data, only the unique identifier for restaurants was kept in this table to be able to match each restaurant with the inspections.

In addition, I realized in the variable *cuisine_description* there were several cases when multiple labels belonged to a restaurant. Fortunately these labels were separated by */* every time thus after splitting the values I created a separate record for each cuisine type of a restaurant.

Finally, all the transformed data were loaded into a database file in which tables were made for them previously. **If you would like to see the detailed ETL process** please don't hesitate to **look at the python code**.

## Analysing the Dataset
**While observing the dataset numerous questions arose that I was able to answer. Firstly I made SQL queries to get the correct structure and aggregation of the data**. First and foremost I have to mention that the data is aggregated by years as well in all queries since the database contains data of several years.

In the followings I will explain briefly what all of the queries were made for:

1. **Typical Inspections:** The most typical inspections types are displayed with the help of this query. Beside those types of inspections that can be seen in the *inspections type* column it is significant to emphasize inspections often happen in multiple round to check if the restaurant fixed the issues. The types of each round can be seen in the *inspection round* column.

2. **Cuisine Borough Pattern:** This query help to show the connection among the cuisine of the restaurant, the neighbourhood where the restaurant is and the number of critical violations that were found during the inspection. Thanks to this query the riskyness of each type of cuisine can also be seen beside the boroughs' riskyness.

3. **Risky Boroughs Critical Ratio & Average Score:** These queries evaluate the riskiness of dining out across NYC boroughs by calculating the average inspection scores and the proportion of different violation types (Critical, Not Critical, Not Applicable) per borough and year.

4. **Franchise Safetyness:** Ordinarily many franchises operate in big cities alongside independent restaurants. In my opinion it is worth looking closely whether these franchise restaurants are safer for eating out or not. Since there were no information in the dataset if a restaurant is a part of a franchise or not I had to use a support table in which I collected parts of the most well known franchises names and if a restaurant's name consisted of any value in this table it is said to be a franchise restaurant.

You can see the difference among franchise and independent restaurants on a time series chart where the average scores and the ratio of critical violations can be seen for all years.

5.**Risky Areas:** Presumably there are parts of New York where it can be more dangerous to eat out. In my last query I collected the geolocation of all the restaurants and the critical violation number belongs to each restaurants thus users can examine the number of critical violations for each restaurant yearly.

Altogether it can be said this project provided an opportunity to be able to do this data analysis from the extranction of the data to making visualizations.




