#!/usr/bin/env python
# coding: utf-8

# ## ETL Process on NYC Restaurants Data

# In[1]:


import requests
import numpy as np
import pandas as pd
import sqlite3

pd.set_option('display.max_columns', None)

#Connecting to SQL
connector = sqlite3.connect("NY_Restaurants.db")
cursor = connector.cursor()


# In[ ]:


#Making the tables in SQLite

cursor.execute("""
CREATE TABLE restaurants (
camis INTEGER,
dba TEXT,
boro TEXT CHECK (boro IN ('Manhattan', 'Bronx', 'Brooklyn', 'Queens', 'Staten Island')),
building TEXT,
street TEXT,
zipcode INTEGER,
phone INTEGER,
cuisine_description TEXT,
latitude REAL,
longitude REAL,
community_board INTEGER,
council_district INTEGER,
census_tract INTEGER,
bin INTEGER,
bbl INTEGER,
nta TEXT,
PRIMARY KEY (camis)
)
""")
connector.commit()

cursor.execute("""
    CREATE TABLE inspections (
    inspection_id INTEGER,
    restaurant_id INTEGER,
    grade TEXT CHECK (grade IN ('N', 'A', 'B', 'C', 'Z', 'P')),
    grade_date INTEGER,
    inspection_date INTEGER,
    action TEXT,
    violation_code TEXT,
    violation_description TEXT,
    critical_flag TEXT CHECK (critical_flag IN ('Critical', 'Not Critical', 'Not Applicable')),
    score INTEGER,
    inspection_type TEXT,
    PRIMARY KEY (inspection_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(camis)
    )
""")
connector.commit()

cursor.execute("""
CREATE TABLE cuisine_types (
id INTEGER,
restaurant_id INTEGER NOT NULL,
cuisine_type TEXT,
PRIMARY KEY (id),
FOREIGN KEY (restaurant_id) REFERENCES restaurants(camis)
)
""")
connector.commit()


# ### Data Extraction wiht API

# In[29]:


#Downloading new data

data = []
limit = 50000
offset = 0

while True:
    response = requests.get("https://data.cityofnewyork.us/resource/43nn-pn8j.json", params = {"$limit": limit, "$offset": offset, "$order":":id"})
    round = response.json()

    if not round: break
    data.extend(round)

    offset += limit

data = pd.DataFrame(data)


# ### Data Cleaning

# In[31]:


data.drop(columns = ["location", "record_date"] , inplace = True) # redundand column

data["phone"] = data["phone"].str.replace (" ", "", regex = False)
data["phone"] = data["phone"].where((~data["phone"].str.startswith(("0", "1"), na=False)) &
                                    (~data["phone"].str.contains("_", na=False)) &
                                    (data["phone"].str.len() == 10), np.nan)

#Date handling
data[["inspection_date", "grade_date"]] = data[["inspection_date", "grade_date"]].apply(pd.to_datetime, errors = "coerce")
data[["inspection_date", "grade_date"]] = data[["inspection_date", "grade_date"]].map(lambda x: x.to_julian_date() if pd.notnull(x) else None)
data[["inspection_date", "grade_date"]] = np.floor(data[["inspection_date", "grade_date"]]).astype("Int64")

data["inspection_date"] = data["inspection_date"].where(data["inspection_date"] != 2415020, np.nan)
data[["dba", "building", "street"]] = data[["dba", "building", "street"]].replace("N/A", None) #False NA-s
data["cuisine_description"] = data["cuisine_description"].replace('Not Listed/Not Applicable', 'Other')
data["boro"] = data["boro"].replace("0", None)

data["inspection_type"] = data["inspection_type"].str.title().str.strip().str.replace(r"\s*/\s*", " / ", regex = True)

data[["latitude", "longitude"]] = data[["latitude", "longitude"]].apply(pd.to_numeric)
data[["camis", "zipcode", "score", "community_board", "council_district", "census_tract", "bin", "bbl"]] = data[["camis", "zipcode", "score", "community_board", "council_district", "census_tract", "bin", "bbl"]].apply(pd.to_numeric).astype("Int64")


# ### Data Loading

# In[33]:


#Making a dataframe for each tables
restaurants_variables = ["dba", "boro", "building", "street", "zipcode", "phone", "cuisine_description", "latitude",
                         "longitude", "community_board", "council_district", "census_tract", "bin", "bbl", "nta"]
restaurants = data[["camis"] + restaurants_variables].copy()
restaurants.drop_duplicates(subset = "camis", keep = "last", inplace = True)

inspections = data.drop(columns = restaurants_variables)
inspections.rename(columns = {"camis": "restaurant_id"}, inplace = True)


restaurants.to_sql("restaurants", connector, if_exists = "append", index = False)
inspections.to_sql("inspections", connector, if_exists = "append", index = False)


# In[34]:


# Cuisine types correction

cuisine_types = restaurants[["camis", "cuisine_description"]].copy()
cuisine_types["cuisine_description"] = cuisine_types["cuisine_description"].str.split("/")
cuisine_types = cuisine_types.explode("cuisine_description")
cuisine_types["cuisine_description"] = cuisine_types["cuisine_description"].str.strip()
cuisine_types.rename(columns = {"camis": "restaurant_id", "cuisine_description": "cuisine_type"}, inplace = True)

cuisine_types.to_sql("cuisine_types", connector, if_exists = "append", index = False)


# ### Table Reset

# In[27]:


cursor.execute("DELETE FROM restaurants")
cursor.execute("DELETE FROM inspections")
cursor.execute("DELETE FROM cuisine_types")
connector.commit()


# In[ ]:


connector.close()

