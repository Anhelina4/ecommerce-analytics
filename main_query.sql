WITH
 -- Gather categorical data for grouping: date, country, send interval, account verification, and subscription status.
 categorial_data AS (
 SELECT
   s.date,
   sp.country,
   a.id,
   a.send_interval,
   a.is_verified,
   a.is_unsubscribed,
 FROM
   `DA.account` a
 JOIN
   `DA.account_session` acs
 ON
   a.id = acs.account_id
 JOIN
   `DA.session` s
 ON
   acs.ga_session_id = s.ga_session_id
 JOIN
   `DA.session_params` sp
 ON
   acs.ga_session_id = sp.ga_session_id ),
 -- Calculate account metrics: number of accounts created.
 account_metrics AS (
 SELECT
   categorial_data.date,
   categorial_data.country,
   categorial_data.send_interval,
   categorial_data.is_verified,
   categorial_data.is_unsubscribed,
   COUNT(*) AS account_cnt,
   0 AS sent_msg,
   0 open_msg,
   0 AS visit_msg
 FROM
   categorial_data
 GROUP BY
   categorial_data.date,
   categorial_data.country,
   categorial_data.send_interval,
   categorial_data.is_verified,
   categorial_data.is_unsubscribed),
 -- Calculate email metrics: number of emails sent, opened, and clicked.
 email_metrics AS (
 SELECT
   DATE_ADD(categorial_data.date, INTERVAL es.sent_date DAY) AS date,
   categorial_data.country,
   categorial_data.send_interval,
   categorial_data.is_verified,
   categorial_data.is_unsubscribed,
   0 AS account_cnt,
   COUNT(es.id_message) AS sent_msg,
   COUNT(eo.id_message) AS open_msg,
   COUNT(ev.id_message) AS visit_msg
 FROM
   `DA.email_sent` es
 JOIN
   categorial_data
 ON
   es.id_account = categorial_data.id
 LEFT JOIN
   `DA.email_open` eo
 ON
   es.id_message = eo.id_message
 LEFT JOIN
   `DA.email_visit` ev
 ON
   es.id_message = ev.id_message
 GROUP BY
   date,
   categorial_data.country,
   categorial_data.send_interval,
   categorial_data.is_verified,
   categorial_data.is_unsubscribed ),
 -- Union account and email metrics
 unioned_data AS (
 SELECT
   *
 FROM
   account_metrics
 UNION ALL
 SELECT
   *
 FROM
   email_metrics ),
 -- Calculate cumulative metrics for accounts and emails.
 account_email_cummulative_metrics AS (
 SELECT
   date,
   country,
   send_interval,
   is_verified,
   is_unsubscribed,
   SUM(account_cnt) AS account_cnt,
   SUM(sent_msg) AS sent_msg,
   SUM(open_msg) AS open_msg,
   SUM(visit_msg) AS visit_msg
 FROM
   unioned_data
 GROUP BY
   date,
   country,
   send_interval,
   is_verified,
   is_unsubscribed ),
 -- Add total accounts and emails sent per country.
 total_country_metrics AS (
 SELECT
   *,
   SUM(account_cnt) OVER(PARTITION BY country) AS total_country_account_cnt,
   SUM(sent_msg) OVER(PARTITION BY country) AS total_country_sent_cnt,
 FROM
   account_email_cummulative_metrics ),
 -- Rank countries by number of accounts and emails sent.
 ranking AS (
 SELECT
   *,
   DENSE_RANK() OVER(ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
   DENSE_RANK() OVER(ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt,
 FROM
   total_country_metrics )
 -- Filter results to include only countries with rank <= 10
 -- by number of accounts or emails sent.
SELECT
 *
FROM
 ranking
WHERE
 rank_total_country_account_cnt <=10
 OR rank_total_country_sent_cnt <=10
ORDER BY
 rank_total_country_account_cnt ASC
