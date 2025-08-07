# Lead-Conversion-And-Campaign-Effectiveness-Report 
**A Funnel Performance Analysis Using Power BI & SQL**


##  Project Overview
This project analyzes a lead generation and marketing funnel dataset to evaluate the performance of seasonal campaigns across platforms, understand user behavior, and identify key factors influencing lead conversion and customer retention. The analysis focuses on platform effectiveness (TikTok vs Instagram), lead source (Ads vs Organic), demographic behavior, marketing touchpoints, and funnel efficiency from signup to purchase.

## Problem Statement  
Marketing teams invest heavily in lead generation, but often struggle to connect lead generation efforts to long-term conversion and customer retention. This project analyzes lead behavior, campaign effectiveness, touchpoint impact, and time-to-convert—helping uncover **what works**, **what doesn’t**, and **how to improve performance** across the funnel.


## 📁 Dataset Overview  
 This dataset contains 15 Columns and 270,154 rows of data.

| Column                     | Description                                               |
|---------------------------|-----------------------------------------------------------|
| Lead ID                   | Unique identifier for each lead                           |
| Gender / Age              | Demographic information                                   |
| Lead Source               | Origin of lead (Ads or Organic)                           |
| Lead Platform             | Platform (TikTok or Instagram)                            |
| Sign-Up & Purchase Dates  | Timestamps for signup and first purchase                  |
| Campaign (Signup/Purchase)| Seasonal campaigns: Spring, Summer, Fall, Winter          |
| Total Purchase            | Revenue generated (currency amount)                       |
| Lead Status               | Funnel stage: Signup, Convert, Retention                  |
| Signup & Purchase Touchpoints | Number of interactions before signup/purchase       |


## Tools & Technologies Used  
- **Power BI** – To build dashboards, custom visuals, slicers and interactions  
- **SQL** – Joins, aggregations, funnel queries  
- **Power Query** – For Data cleaning, formatting, feature creation and restructure data for modelling to optimize performance speed.
- **DAX** –Employed to create measures, KPIs, time intelligence, inactive relationships, date table and calculated columns 

##  Data Preparation Highlights  
Data Cleaning: This process of data cleaning carried out in this project includes:
-Handling missing numeric values
-Merging first and last name columns together into a new fullname columns
-Handling inconsistencies such as incorrect spelling
-Grouping:
  - **Age** column into intervals;  15–21, 22–28, 29–35, 36+
  - **Days to Convert**: Bins (e.g. 5–10, 11–20…)  
  - **Touchpoints**: Binned for visual distributions
    
Data Processing: With Power Bi's Dax functionalities, I created calculated measures to show valuable metrics, customized and design visuals to aid clarity in understanding trends.
-standardizing specific data fields; Created `Days to Convert`: `Purchase Date - Signup Date`  
- Created the date (calendar) table with appropriate columns such as date, year, month etc
- Filtered rows with blank purchase info for accurate conversion metrics

Data Modeling: Modeling this data allows for multiple tables with lesser column information to speed up processing time, reduce redundancy and increase efficiency.
  - The date column in the date (calendar) table i created was linked to Signup Date as the active relationship
  - Date column in the date (calendar) table was also inked to Purchase Date but as an inactive elationship which is made active for analysis  using DAX's `USERELATIONSHIP()` function  

## SQL Highlights
SQL was used for data transformation, metric calculation, and funnel insights before visualizing in Power BI.

**Sample Query Snippet**
- --calculate retention %YoY change
```
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

```
This query calculate the retention Year-over-year change


##  Dashboard Overview  

The Power BI dashboard consists of **three analytical pages**, each answering a key business question.


###  Page 1: Lead Generation & Campaign Insight
**Business Goal:**  
This page helps to understand where leads come from, who they are, and how effective campaigns are in bringing them in.

**Key Visuals & Insights:**
- **Leads by Campaign**: Even signup distribution, but performance varies post-signup  
- **Lead Source & Platform**: Balanced across Ads/Organic and TikTok/Instagram  
- **Age Group**: Largest group is 22–28 (32%)  
- **Signup Touchpoint Distribution**: Most users signup after 7+ interactions  
- **Signup Trends**: December and May drive peaks
- **Touchpoints by Campaign**: Spring/Fall require more effort to sign up leads  

**What's Working:**  
- TikTok Ads & Instagram Organic deliver volume  
- Younger age groups (22–28) engage better
- Most users sign up after more than 7 touchpoints, indicating that nurturing and repeated engagement are critical to lead capture. Very few leads convert with minimal interaction.

![image alt](https://github.com/odewolemistura/Lead-Conversion-And-Campaign-Effectiveness-Report/blob/2dfda339df1157e9e7f2b897fbd1d88a067f51c6/Campaign%20Dashboard%20Page1.png)

### Page 2: Funnel Performance & Customer Retention
**Business Goal:**  This page help us nderstand how leads move through the funnel, how long conversion takes, and what drives retention.

**Key Visuals & Insights:**
- **Funnel**: 270k signups → 135k converts → 81k retained  
- **Revenue by Campaign**: Winter is top performer ($9.5M)  
- **Revenue by Age & Gender**: 22–35 dominates; male revenue slightly higher  
- **Avg Days to Convert by campaign**: The Winter campaign delivers the fastest time to purchase, with leads converting in an average of 23.92 days, about 1.5 days quicker than other      campaigns
- **Avg Purchase Touchpoints**: ~10.5 before purchase  
- **Retention by Platform**: TikTok slightly stronger

**What's Working:**  
- ✅ Strong retention rate (60%)  
- ✅ Winter campaign excels in conversion and revenue  
- ✅ Age 22–35 delivers highest value  

**What Needs Improvement:**  
- ⚠️ Conversion rate (50%) – optimize landing pages or retargeting  
- ⚠️ High touchpoint cost – aim for clearer CTAs before 6th touchpoint  
- ⚠️ Spring/Fall underperform in revenue – refresh messaging  


### Page 3: Time-Based Performance Analysis
**Business Goal**  This page hep us spot trends and seasonality in acquisition, conversion, and retention over time.

**Key Visuals & Insights:**
- **Monthly Signups**: December & May highest; Jan/Feb lag  
- **Monthly Conversion Rate**: December peaks (61%), January lowest (41%)  
- **Avg Days to Convert (Monthly)**: Steady (~25 days); lowest in December  
- **Retention (Monthly)**: Fairly stable (~60%) with slight Q4 boost  
- **Avg Purchase Touchpoints (Monthly)**: Peaks in August (~10.5)  
- **Day-of-Week Patterns**: Friday & Sunday are high-performing days


**What's Working:**  
- ✅ December is top month: fast, high-volume conversions  
- ✅ Friday/Sunday campaigns convert better  
- ✅ Retention remains consistent month-to-month  

**What Needs Improvement:**  
- ⚠️ January slump – increase campaigns or promo urgency  
- ⚠️ August effort is higher – revisit ad relevance or lead quality  
- ⚠️ Avg conversion time (25 days) still long – test urgency triggers  

## 📌 Key KPIs & Measures  

| KPI                        | Description                                  |
|---------------------------|----------------------------------------------|
| **Conversion Rate**       | Converts+Retained ÷ Signups                           |
| **Retention Rate**        | Retained ÷ Converts                          |
| **Avg Signup Touchpoints**| AVERAGE(Signup Touchpoints)                  |
| **Avg Purchase Touchpoints**| AVERAGE(Purchase Touchpoints) excluding nulls |
| **Avg Days to Convert**   | AVERAGE(Purchase Date - Signup Date)         |
| **Revenue by Segment**    | SUM(Total Purchase) across Campaign/Age/Platform |
| **Monthly Metrics**       | Via Date table (+ `USERELATIONSHIP()` )        |

---

##  Business Recommendations  

### ✅ Double Down on Winter Campaigns  
- Winter delivers the fastest conversions and highest revenue  
- Suggest allocating more ad budget and exclusive offers here

### ✅ Optimize for Touchpoint Efficiency  
- Purchase requires ~10+ interactions  
- Consider retargeting strategies or improved CTAs after 6+ touches

### ✅ Segment by High-Value Demographics  
- Leads aged 22–35 drive most revenue  
- Tailor messaging, visuals, and offers toward this age group

### ✅ Boost Retention in First Campaigns  
- While conversion is 50%, retention (60%) is a strength  
- Consider welcome-back campaigns for first-time buyers

### ✅ Use Timing to Your Advantage  
- December and May are conversion peaks  
- Launch key campaigns and discounts during these months

### ✅ Focus on TikTok Ads Slightly More  
- While evenly split, TikTok Ads lead in both retention and slightly faster conversion  
- Test more creatives optimized for this platform  

###  Conclusion
This report provides actionable intelligence on the entire lead lifecycle, from sign-up to purchase to retention. Through better campaign timing, more efficient touchpoint strategies, and targeted messaging, the business can significantly improve lead quality, conversion rates, and long-term customer value.

### 🎯 Dataset Limitations
- No Revenue Breakdown by Product/Offer
- Limited to First Purchase Only (No LTV)
- Touchpoint Quality Unknown (just counts, not context)
- Retention Defined Broadly: Based on repeat purchase, not long-term value or frequency
