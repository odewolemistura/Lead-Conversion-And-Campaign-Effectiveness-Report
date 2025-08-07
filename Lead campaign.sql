select * from Lead_campaign

--checking datatype
SELECT c.name AS ColumnName, t.name AS DataType
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('lead_campaign')

--calculating the days from signup to purchase
UPDATE Lead_campaign
SET [Days to Convert] = DATEDIFF(day,[signed up date],[first purchase date])

--merging and dropping the name columns
ALTER TABLE lead_campaign
ADD [Full Name] varchar(250)

UPDATE Lead_campaign
SET [full name] = CONCAT([first name],' ',[last name])

ALTER TABLE lead_campaign
DROP COLUMN [first name], [last name]

--GROUPING THE AGE AND UPDATING THE TABLE
ALTER TABLE Lead_campaign
ADD [Age Group] varchar(50)

UPDATE Lead_campaign
SET [Age Group] = 
      CASE WHEN Age <= 15 THEN '0-14'
	   WHEN Age <=21 THEN '15-21'
	   WHEN Age <=28 THEN '22-28'
	   WHEN Age <=35 THEN '29-35'
	  ELSE '36+' END

--DATA ANALYSIS
-- Calculate Total Revenue
SELECT sum([Total Purchase]) AS Total_Revenue FROM lead_campaign;

--calculate revenue %YoY change
WITH cte_current AS (
         SELECT year([First Purchase Date]) as Current_year,
                sum([total purchase]) as Current_revenue
        FROM Lead_campaign
        GROUP BY year([First Purchase Date])
        HAVING year([First Purchase Date]) IS NOT NULL
),
cte_previous AS (
    SELECT current_year, Current_revenue,
       LAG(current_revenue) OVER (ORDER BY Current_year) AS previous_revenue
FROM cte_current)
SELECT current_year, Current_revenue,
       format((current_revenue - Previous_revenue)*1.0 /previous_revenue, 'p') AS YoY
FROM cte_previous

--calculate Total_retetion
SELECT COUNT(*)
FROM lead_campaign
WHERE [Lead Status] = 'Retention'

--calculate retention %YoY change
WITH YearlyRetention AS (
   SELECT year([first purchase date]) as Current_year, COUNT(*) as Retention_num
   FROM lead_campaign
   WHERE [Lead Status] = 'Retention'
   GROUP BY year([first purchase date])
   HAVING year([first purchase date]) IS NOT NULL
), 
cte AS (
SELECT current_year, Retention_num,
   LAG(Retention_num) OVER(ORDER BY Current_year) AS Previous_year
FROM YearlyRetention
)
SELECT current_year, Retention_num,
     format((Retention_num*1.0 - previous_year)/previous_year,'p') AS YoY
FROM cte

--Total Leads/ signups
SELECT COUNT(*) FROM lead_campaign;

--calculate leads YoY%
WITH YearlyLeads AS (
SELECT	year([Signed Up Date]) AS current_yr,
       COUNT(*) AS total_Leads
FROM Lead_campaign
GROUP BY year([Signed Up Date])
HAVING year([Signed Up Date]) IS NOT NULL
),
cte AS (
SELECT current_yr, Total_Leads,
      LAG(Total_Leads) OVER (ORDER BY current_yr) AS previous_leads
FROM YearlyLeads
)
SELECT *,
       FORMAT((Total_Leads *1.0 -previous_leads)/previous_leads, 'P') AS YoY
FROM cte

--Total conversion (leads whp converted to one or multiple purchases)
SELECT count(*)
FROM Lead_campaign
WHERE [Lead Status] IN ('Convert','Retention')

--calculate total conversion YoY%
WITH YearlyConversion AS (
SELECT year([First Purchase Date]) AS Curreny_yr,
       count(*) as Total_Conversion
FROM Lead_campaign
WHERE [Lead Status] IN ('Convert','Retention')
GROUP BY year([First Purchase Date])
HAVING year([First Purchase Date]) IS NOT NULL
),
cte AS (
  SELECT *,
         LAG(Total_Conversion) OVER (ORDER BY Curreny_yr) AS PrevConversion
 FROM YearlyConversion)
SELECT *,
  FORMAT((Total_Conversion-PrevConversion)*1.0/ PrevConversion, 'P') AS YoY
FROM cte;

 -- Calculate overall conversion rate
WITH TotalSignup AS (
    SELECT COUNT(*) AS Total_signup
    FROM Lead_campaign
),
TotalConversion AS (
    SELECT COUNT(*) AS Total_conversion
    FROM Lead_campaign
    WHERE [Lead Status] IN ('Convert', 'Retention')
)
SELECT 
    CAST(tc.Total_conversion AS FLOAT) * 100.0 / NULLIF(ts.Total_signup, 0) AS Conversion_Rate_Percent
FROM TotalSignup ts
CROSS JOIN TotalConversion tc;

--Retention rate
WITH TotalConversion AS (
    SELECT COUNT(*) AS Total_conversion
    FROM Lead_campaign
    WHERE [Lead Status] IN ('Convert', 'Retention')
),
TotalRetention AS (
    SELECT COUNT(*) AS Total_retention
    FROM Lead_campaign
    WHERE [Lead Status] IN ('Retention')
)
SELECT
FORMAT((tr.Total_retention*1.0/tc.Total_conversion),'P') AS Retention_Rate_Percent
FROM TotalRetention tr
CROSS JOIN TotalConversion tc

--Avg Purchase Touch Points
SELECT CAST(Avg([Purchase Touch Points]) AS DEC(5,2)) AS [Avg Purchase Touch Points]
FROM Lead_campaign
WHERE [Lead Status] IN ('Convert','Retention')

--Avg signup Touch Points
SELECT CAST(Avg([Sign Up Touch Points]) AS DEC(5,2)) AS [Avg signup Touch Points]
FROM Lead_campaign

--What is the distribution of leads by platform and source (Ads vs Organic)?
SELECT [lead platform], [lead source], count([lead id]) as [Total leads]
FROM Lead_campaign
GROUP BY [lead platform], [lead source]

--How many leads fall into each age group and gender segment?
SELECT [Age Group], [Gender], count([lead id]) as [total leads]
FROM Lead_campaign
GROUP BY [Age Group], [Gender]

--What is the monthly trend of lead signups?
SELECT count([lead id]) AS [Total leads], datename(month, [signed up date]) AS Month
FROM Lead_campaign
GROUP BY  datename(month, [signed up date])

--What is the distribution of signup touchpoints — how many interactions did leads have before signing up?
SELECT count([Lead id]), 
       CASE WHEN [Sign Up Touch Points] >= 3 THEN '1-3'
	        WHEN [Sign Up Touch Points] >= 6 THEN '4-6'
			ELSE'7+' END AS [Signup touchpoint interval]
FROM Lead_campaign
GROUP BY CASE WHEN [Sign Up Touch Points] >= 3 THEN '1-3'
	        WHEN [Sign Up Touch Points] >= 6 THEN '4-6'
			ELSE '7+' END

--How many conversions occurred from each campaign?
SELECT count([lead id])as [Number of lead], [First Purchase Campaign]
FROM Lead_campaign
WHERE [Lead Status] IN ('convert','retention')
GROUP BY [First Purchase Campaign]

--What is the lead funnel performance (Signup → Convert → Retention)?
SELECT count([lead id]) as [Number of lead], [lead status]
FROM Lead_campaign
GROUP BY [lead status]

--What is the average number of days to convert per campaign?
SELECT [Signed Up Campaign], avg([days to convert]) AS [Average days to convert]
FROM lead_campaign
GROUP BY [Signed Up Campaign]

--What is the conversion rate by age group and gender?
  

--Which first purchase campaigns generated the highest total purchases?
SELECT [first purchase campaign], sum([total purchase]) AS Revenue
FROM Lead_campaign
WHERE [First purchase date] IS NOT NULL
GROUP BY [first purchase campaign]

--What is the average number of purchase touchpoints per campaign?
SELECT [first purchase campaign], 
       CAST(avg([Purchase Touch Points]) AS DEC(10,2)) AS [Avg Purchase Touch Points]
FROM Lead_campaign
WHERE [First purchase date] IS NOT NULL
GROUP BY [first purchase campaign];


--What is the retention rate by platform and campaign?
WITH Conversions AS (
    SELECT 
        [Lead Platform],
        [Signed Up Campaign],
        COUNT(*) AS Total_conversion
    FROM Lead_campaign
    WHERE [Lead Status] IN ('Convert', 'Retention')
    GROUP BY [Lead Platform], [Signed Up Campaign]
),
Retentions AS (
    SELECT 
        [Lead Platform],
        [Signed Up Campaign],
        COUNT(*) AS Total_retention
    FROM Lead_campaign
    WHERE [Lead Status] = 'Retention'
    GROUP BY [Lead Platform], [Signed Up Campaign]
)
SELECT 
    c.[Lead Platform],
    c.[Signed Up Campaign],
    c.Total_conversion,
    r.Total_retention,
    FORMAT(CAST(r.Total_retention AS FLOAT) / NULLIF(c.Total_conversion, 0), 'P') AS Retention_Rate_Percent
FROM Conversions c
LEFT JOIN Retentions r
    ON c.[Lead Platform] = r.[Lead Platform] 
    AND c.[Signed Up Campaign] = r.[Signed Up Campaign]
ORDER BY c.[Lead Platform], c.[Signed Up Campaign];

--How do monthly leads vary by campaign over time?
SELECT count([lead id]) AS [Total leads], 
            Format([signed up date], 'yyy-MM') AS Month, [signed up campaign]
FROM Lead_campaign
GROUP BY Format([signed up date], 'yyy-MM'), [signed up campaign]
ORDER BY Month

--What are the daily signup trends?
SELECT count([lead id]) AS [Total leads],
       datename(weekday, [signed up date]) AS Day
FROM Lead_campaign
GROUP BY datename(weekday, [signed up date]);

--What is the monthly conversion rate trend?
WITH MonthlySignup AS (
    SELECT 
        Format([Signed Up Date], 'yyy-MM') AS Signup_Month,
        COUNT(*) AS Total_signup
    FROM Lead_campaign
    GROUP BY Format([Signed Up Date], 'yyy-MM')
),
MonthlyConversion AS (
    SELECT 
        Format([Signed Up Date], 'yyy-MM') AS Signup_Month,
        COUNT(*) AS Total_conversion
    FROM Lead_campaign
    WHERE 
      [Lead Status] IN ('Convert', 'Retention')
    GROUP BY Format([Signed Up Date], 'yyy-MM')
)
SELECT 
    s.Signup_Month,
    s.Total_signup,
    c.Total_conversion,
    FORMAT(CAST(c.Total_conversion AS FLOAT) * 100.0 / NULLIF(s.Total_signup, 0), 'N2') + '%' AS Conversion_Rate
FROM MonthlySignup s
LEFT JOIN MonthlyConversion c ON s.Signup_Month = c.Signup_Month
ORDER BY s.Signup_Month;

--What is the retention rate by month?
WITH Conversions AS (
    SELECT 
       Format([first purchase Date], 'yyy-MM') AS [purchase month],
        COUNT(*) AS Total_conversion
    FROM Lead_campaign
    WHERE [Lead Status] IN ('Convert', 'Retention')
    GROUP BY Format([first purchase Date], 'yyy-MM')
),
Retentions AS (
    SELECT 
        Format([first purchase Date], 'yyy-MM') AS [purchase month],
        COUNT(*) AS Total_retention
    FROM Lead_campaign
    WHERE [Lead Status] = 'Retention'
    GROUP BY Format([first purchase Date], 'yyy-MM')
)
SELECT 
    c.[purchase month],
    c.Total_conversion,
    r.Total_retention,
    FORMAT(CAST(r.Total_retention AS FLOAT) / NULLIF(c.Total_conversion, 0), 'P') AS Retention_Rate_Percent
FROM Conversions c
LEFT JOIN Retentions r
    ON c.[purchase month] = r.[purchase month]

-- What is the monthly average of purchase touchpoints?
SELECT 
    FORMAT([First Purchase Date], 'yyyy-MM') AS [Purchase Month], 
    FORMAT(AVG([Purchase Touch Points]),'N2') AS [Avg Purchase Touch Points]
FROM Lead_campaign
WHERE [First Purchase Date] IS NOT NULL
GROUP BY FORMAT([First Purchase Date], 'yyyy-MM')
ORDER BY [Purchase Month];