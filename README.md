## Overall
This project purpose is to create a database in Oracle that can store the information of a **fabric agency**. The database consists of many different queries for example customers, products, categories,... with complex relationship.
Here is the EER diagram of the project:
![Fabric agency EER diagram](https://scontent.fsgn5-3.fna.fbcdn.net/v/t1.15752-9/494823023_725762366789044_4965925042143907614_n.png?_nc_cat=104&ccb=1-7&_nc_sid=9f807c&_nc_ohc=AbbAIiGDhb4Q7kNvwFh9KxN&_nc_oc=Adnb8DBmy5UFlVuD6aBk9plwfti4QGk9QOWQzfSsE_F8rMUpL_MIk4PMfoTcH_-uTe0&_nc_zt=23&_nc_ht=scontent.fsgn5-3.fna&oh=03_Q7cD2QGbC7figo0p9Bp-T5yDfrVzZqOcAObmVYg5HCLlLG7lIw&oe=6858F442)

We'll utilize HTML, CSS for the website design and Python flask to attach the Database to it.

## Requirements & Extra Information
Oracle Listener Port : 1521
Python required packages: flask, cx-Oracle
Password for database connection: 32432707

You should use Oracle since there is a slight difference in the syntax of SQL accross applications.


Modify this line in main.py on your own: "connection = cx_Oracle.connect("system/32432707@localhost:1521/xe")"
