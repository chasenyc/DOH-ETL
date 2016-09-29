# DOH-ETL
Lightweight ETL for extracting CSV data from NYC DOHMH.

#### Instructions
Clone this repository and then:

`bundle install`

and then:

`ruby etl.rb`

#### Design considerations
I tried to keep this ETL as flexible as possible, allowing to just edit `Loader#setup_db` with the columns needed. `Loader.rb` dynamically creates the `insert or replace` purely based on the data passed into it. With a quick addition to the extractor to filter only certain keys one would be able to only store requested columns. The following code would need to be added to the extractor:

```
  def transform_data(row)
    filter_row(row) // new code
    sanitize_input(row)
    add_full_address(row)

    return row
  end

  @columns = [
    "CAMIS", "DBA", "BORO", "BUILDING", "STREET", "ZIPCODE", "PHONE",
    "CUISINE DESCRIPTION", "INSPECTION DATE", "SCORE", "GRADE"
  ]
  def filter_row(row)
    row.select! { |k, v| @columns.include?(k) }
  end
```
When it came to the choice of database and its design I went with sqlite for fairly simple reasons, it is fast and it is convenient for transferring to another project. I chose not to include an auto-incrementing primary key id and rather opted to have a composite primary key of `camis`(the restaurants unique identifier), `inspection_date`, and `violation_code`. The assumption is that no restaurant will receive the same violation code on the same date more than once. By using this composite primary key it allows my `Loader.rb` to remain fairly idempotent when utilizing `insert or replace`.

I would have also liked to add some cli progress bars as these processes do tend to take some time; however, I decided my time was better spent elsewhere.

#### Schema
Below is the schema for `database.db` which contains one table:

`dohmh_inspections`

column name  | data type | details
-------------|-----------|----------------------
`camis` | int(10) | NOT NULL
`dba` | varchar(255) | DEFAULT NULL
`address` | varchar(255) | DEFAULT NULL
`boro`| varchar(255) | DEFAULT NULL
`building` | int(10)| NOT NULL
`street` | varchar(255)| DEFAULT NULL
`zipcode` | int(10)| NOT NULL
`phone` | varchar(10) | DEFAULT NULL
`action` | varchar(255) | DEFAULT NULL
`violation_code` | varchar(255) | DEFAULT NULL
`violation_description` | varchar(255) | DEFAULT NULL
`critical_flag` | varchar(255) | DEFAULT NULL
`cuisine_description` | varchar(255) | DEFAULT NULL
`inspection_date` | timestamp | NOT NULL
`score` | int(10) | DEFAULT NULL
`grade` | varchar(10) | DEFAULT NULL
`grade_date` | timestamp | DEFAULT NULL
`inspection_type` | varchar(255) | DEFAULT NULL
`record_date` | timestamp | DEFAULT NULL
`created_at` | timestamp | NOT NULL, DEFAULT CURRENT_TIMESTAMP
`updated_at` | timestamp | NOT NULL, DEFAULT CURRENT_TIMESTAMP
`PRIMARY KEY (camis, inspection_date, violation_code)`
