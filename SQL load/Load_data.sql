COPY public.CovidDeaths
FROM 'D:\\SQL_project_data_analysis\\project_sql\\Covid 19\\CovidDeaths.csv'
DELIMITER ','
CSV HEADER;

COPY public.CovidVaccinations
FROM 'D:\\SQL_project_data_analysis\\project_sql\\Covid 19\\CovidVaccinations.csv'
DELIMITER ','
CSV HEADER;
