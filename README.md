# ecommerce-analytics

## Overview
Multi-dimensional analysis of account creation and email campaign performance. The query consolidates account-level and email-level metrics, ranks markets by performance, and filters results to top-10 countries by user acquisition or email volume.

## Data Model

**Input**: 6 source tables (account, session, email_sent, email_open, email_visit, session_params)

**Output**: 13 dimensions and metrics aggregated across date, country, send_interval, account_verification, and subscription_status

**Rows**: Top-10 countries by either account_cnt or sent_msg volume

**Performance**: BigQuery Standard SQL, optimized for large-scale aggregation

## Output Schema

| Field | Type | Definition |
|-------|------|-----------|
| date | DATE | Account creation date (accounts) / email send date (emails) |
| country | STRING | User location |
| send_interval | STRING | Email frequency preference |
| is_verified | BOOLEAN | Account verification status |
| is_unsubscribed | BOOLEAN | Active subscription status |
| account_cnt | INT64 | Count of accounts created |
| sent_msg | INT64 | Count of emails sent |
| open_msg | INT64 | Count of emails opened |
| visit_msg | INT64 | Count of email clicks |
| total_country_account_cnt | INT64 | Aggregate accounts by country |
| total_country_sent_cnt | INT64 | Aggregate emails by country |
| rank_total_country_account_cnt | INT64 | Country rank by account volume |
| rank_total_country_sent_cnt | INT64 | Country rank by email volume |

## Key Findings

- **Primary Markets**: USA, India, Canada lead in account acquisition
- **Email Volume**: Concentration in established markets aligns with account distribution
- **Segmentation**: Verified accounts show higher engagement; send_interval preference correlates with subscription retention

## Visualization

<img width="627" height="509" alt="Screenshot 2026-06-08 at 11 49 02" src="https://github.com/user-attachments/assets/878d756b-613d-4894-bcdd-f1335127e089" />


## Technology Stack

- **Data Warehouse**: Google BigQuery
- **Query Language**: BigQuery Standard SQL
- **BI Tool**: Looker Studio
