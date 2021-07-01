/******************************************************************************************************/
/******************************************************************************************************/
/*INPUT VARIABLES*/
/******************************************************************************************************/
/******************************************************************************************************/
/*folder location of datasets*/
libname mylib "C:\Users\gelly\Desktop\Github\LondonHousing\Raw Data";
/*artificial working directory*/
libname temp "C:\Users\gelly\Documents\All Data\Temp";

/*input housing*/
%let inputHousing = C:\Users\gelly\Desktop\Github\LondonHousing\Raw Data\London Housing.csv;
/*input crime*/
%let inputCrime = C:\Users\gelly\Desktop\Github\LondonHousing\Raw Data\London Crime.csv;

/******************************************************************************************************/
/******************************************************************************************************/
/*IMPORT LONDON DATA*/
/******************************************************************************************************/
/******************************************************************************************************/
/*obtain london housing data*/
proc import out = temp.housing
    file = "&inputHousing"
    dbms = csv REPLACE;
    getnames = yes;
	guessingrows = max;
run;

/*obtain crime*/
proc import out = temp.crime
    file = "&inputCrime"
    dbms = csv REPLACE;
    getnames = yes;
	guessingrows = 10000;
run;

proc sql;
	CREATE TABLE temp.finalData AS
	SELECT distinct crime.borough, housing.date, housing.average_price, housing.houses_sold, crime.major_category, crime.minor_category, crime.value
	FROM temp.housing as housing
	JOIN temp.crime as crime
	ON upper(housing.area) = upper(crime.borough) AND
		year(housing.date) = crime.year AND
	    month(housing.date) = crime.month;
quit;

proc sql;
	CREATE TABLE temp.finalData AS
	SELECT distinct borough, date, average_price, houses_sold, sum(value) as totalCrime
	FROM temp.finalData
	GROUP BY borough, date;
quit;

/******************************************************************************************************/
/******************************************************************************************************/
/*EXPORT DATA TO STATA AND CSV FORMAT*/
/******************************************************************************************************/
/******************************************************************************************************/
proc export data = temp.finalData
    outfile = "C:\Users\gelly\Desktop\Github\LondonHousing\London Merged Data.csv"
    dbms = csv
    replace;
run;
