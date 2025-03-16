**CONFIGURE SCHEMA HR ON EDB POSTGRES ADVANCED SERVER 17**

> The HR (Human Resources) schema is a sample schema provided by Oracle Corporation for educational and demonstration purposes within Oracle Database.
> It serves as a simplified model of a company's Human Resources department, containing tables and data that represent information about employees, departments, work locations, job titles, and employment history.

![edb postgres logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Postgresql_17/images/hr_schema.jpg)

###### SCRIPT HR OBJECTS AND DATA 

    [root@ol9pgedb ~]# /usr/edb/edbplus/edbplus.sh enterprisedb/enterprisedb@192.168.18.21:5444/edb 
    Connected to EnterpriseDB 17.4.0 (192.168.18.21:5444/edb) AS enterprisedb

    edb*Plus (Build 41.3.0)
    Copyright (c) 2008-2024, EnterpriseDB Corporation.  All rights reserved.

    SQL> begin
    dbms_output.put_line('Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved. '); dbms_output.put_line('Permission is hereby granted, free of charge, to any person obtaining '); dbms_output.put_line('a copy of this software and associated documentation files (the '); dbms_output.put_line('"Software"), to deal in the Software without restriction, including '); dbms_output.put_line('without limitation the rights to use, copy, modify, merge, publish, '); dbms_output.put_line('distribute, sublicense, and/or sell copies of the Software, and to '); dbms_output.put_line('permit persons to whom the Software is furnished to do so, subject to '); dbms_output.put_line('the following conditions: '); dbms_output.put_line(' '); dbms_output.put_line('The above copyright notice and this permission notice shall be '); dbms_output.put_line('included in all copies or substantial portions of the Software. '); dbms_output.put_line(' '); dbms_output.put_line('THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, '); dbms_output.put_line('EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF '); dbms_output.put_line('MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND '); dbms_output.put_line('NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE '); dbms_output.put_line('LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION '); dbms_output.put_line('OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION '); dbms_output.put_line('WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. '); end; /

    SQL> CREATE TABLE regions ( region_id NUMBER CONSTRAINT region_id_nn NOT NULL , CONSTRAINT reg_id_pk PRIMARY KEY (region_id) , region_name VARCHAR2(25) );

