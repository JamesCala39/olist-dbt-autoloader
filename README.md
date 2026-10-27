# Olist Autoloader Data Warehouse Project

This project is a Databricks project creating a Data Warehouse using Databricks autoloader. The dataset used is the Olist Brazilian E-commerce Dataset found on kaggle containing 9 csv files. The warehouse is made using medallion architecture. After autoloading the bronze tables, the silver tables are staged using dbt and followed up with the creation of gold tables for aggegrations.

The kaggle dataset can be found here:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective 
Develop a modern data warehouse using Databricks to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
  -  **Data Sources**: Import data from one dataset provided as multiple CSV files.
  -  **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
  -  **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
  -  **Scope**: Focus on the latest dataset onlyl historization of data is not required
  -  **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

### BI: Analytics & Reporting (Data Analytics)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
  - **Customer Behavior**
  - **Product Performance**
  - **Sales Trends**

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.

## About Me

My name is James Calabrese. A Computer Science graduate from Stockton University studying and researching the Data Engineering landscape.
