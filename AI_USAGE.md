# AI Usage

I used an AI assistant (Claude, by Anthropic) while doing this project. This file explains what it helped with and how the work was checked.

## What the AI helped with

| Part of the project | How AI was used |
|---|---|
| Understanding the brief | Explaining the requirements and planning the steps (Excel → SQL → Power BI → report → GitHub) |
| Data profiling | Finding the data problems: duplicates, extra spaces in product and channel names, missing states |
| Excel workbook | Building the cleaned workbook, the cleaning log and the summary formulas |
| SQL | Writing the 12 queries and the comments that explain them |
| Power BI | Building the dashboard (measures, charts, slicers, layout) on my laptop |
| Report and README | Drafting the analysis report, findings, recommendations and this README |

## How the work was verified

- **Row counts:** checked that 5,000 rows became 4,975 after removing the 25 exact duplicates.
- **Same numbers everywhere:** the KPIs were calculated three separate ways – Excel formulas (Summary sheet), SQL queries, and Power BI measures – and all gave the same results (4,975 total, 310 open, 4,665 closed, 90.1% timely, 8.8 days average).
- **SQL tested:** every query was run against the cleaned data and the output is saved in `sql/sql_outputs.txt`.
- **Business rules checked:** open complaints are excluded from timely % and average response time, as the brief requires.
- **Data checks:** confirmed that the timely Yes/No flag matches the response and due dates, and that no response date is before the received date.
- **Dashboard checked:** confirmed the slicers filter all visuals and the monthly chart is sorted by month, not by value.
- **Interpretation:** the report points out that complaint counts depend on company size, that a timely reply does not mean the customer was satisfied, and that October 2026 is a partial month.

## My understanding

I reviewed each step so that I can explain the cleaning decisions, the SQL queries, the DAX measures and the findings in my own words.
