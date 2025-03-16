**CONFIGURE SCHEMA HR ON EDB POSTGRES ADVANCED SERVER 17**

> The HR (Human Resources) schema is a sample schema provided by Oracle Corporation for educational and demonstration purposes within Oracle Database.
> It serves as a simplified model of a company's Human Resources department, containing tables and data that represent information about employees, departments, work locations, job titles, and employment history.

![edb postgres logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Postgresql_17/images/hr_schema.jpg)

###### TO CREATE HR SCHEMA ON YOUR DATABASE

    1. Download the SQL files in this repository, using either the Git commands or manually downloading them (view file > raw > save as).

    2. Connect to your database (container database).

    3. Run script 01, which changes to the pluggable database and creates the new HR user.

[01 account.sql](https://github.com/danilo01arrudal/Documentation/blob/main/Postgresql_17/scripts/01%20account.sql) 

    4. Connect to the database as the new HR user.

    5. Run script 02 to create the tables.

[02 create tables.sql](https://github.com/danilo01arrudal/Documentation/blob/main/Postgresql_17/scripts/02%20create%20tables.sql)

    6. Run script 03 to populate the tables.

[03 populate.sql](https://github.com/danilo01arrudal/Documentation/blob/main/Postgresql_17/scripts/03%20populate.sql)

    7. Run script 04 to create indexes and comments.

[04 others.sql](https://github.com/danilo01arrudal/Documentation/blob/main/Postgresql_17/scripts/04%20others.sql)
