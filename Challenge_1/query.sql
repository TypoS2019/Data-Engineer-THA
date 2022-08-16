CREATE TEMP FUNCTION
  DistinctCOUNT(arr ANY TYPE) AS ( (
    SELECT
      COUNT(DISTINCT x)
    FROM
      UNNEST(arr) AS x) );
SELECT
  a.issue,
  c.product_name,
  c.published_at,
  c.description
FROM (
  SELECT
    DISTINCT issue
  FROM
    UNNEST((
      SELECT
        ARRAY_CONCAT_AGG(REGEXP_EXTRACT_ALL(description, r'[A-Z]{3,3}-[0-9]{4,4}-[0-9]{0,10}')) AS issues
      FROM
        `bigquery-public-data.google_cloud_release_notes.release_notes`
      WHERE
        REGEXP_CONTAINS(description, r'[A-Z]{3,3}-[0-9]{4,4}-[0-9]{0,4}')
        AND release_note_type='SECURITY_BULLETIN'
      LIMIT
        1000 )) AS issue) a
LEFT JOIN (
  SELECT
    DISTINCT issue
  FROM
    UNNEST((
      SELECT
        ARRAY_CONCAT_AGG(REGEXP_EXTRACT_ALL(description, r'[A-Z]{3,3}-[0-9]{4,4}-[0-9]{0,10}')) AS issues
      FROM
        `bigquery-public-data.google_cloud_release_notes.release_notes`
      WHERE
        REGEXP_CONTAINS(description, r'[A-Z]{3,3}-[0-9]{4,4}-[0-9]{0,10}')
        AND (LOWER(description) LIKE '%fixed%'
          OR LOWER(description) LIKE '%fixes%'
          OR LOWER(description) LIKE '%fix%')
        AND release_note_type='SECURITY_BULLETIN'
      LIMIT
        1000 )) AS issue) b
ON
  a.issue = b.issue
LEFT JOIN (
  SELECT
    *
  FROM
    `bigquery-public-data.google_cloud_release_notes.release_notes`
  WHERE
    LOWER(description) NOT LIKE '%fix%'
    AND DistinctCOUNT(REGEXP_EXTRACT_ALL(description, r'[A-Z]{3,3}-[0-9]{4,4}-[0-9]{0,10}')) = 1 ) c
ON
  LOWER(c.description) LIKE CONCAT('%', LOWER(a.issue), '%')
WHERE
  b.issue IS NULL;