-- This query selects a subset of publications from CSET's scholarly lit corpus for
-- classification as chip fabrication and design research, or not. Publications from
-- 2010-present are in scope if they have one of 4 plausible L0 fields of study in their
-- top 3 L0 fields by score, and also have an EN title and/or abstract.

-- Get ranked L0 fields by merged_id
with ranked_fields as (
  select
    merged_id,
    field.name,
    row_number() over (partition by merged_id order by field.score desc) as rank,
  from fields_of_study_v2.field_scores, unnest(fields) as field
  inner join fields_of_study_v2.field_meta on field_meta.name = field.name
  where field_meta.level = 0
),

-- Select papers with one of 4 relevant fields in their top 3 L0 fields by score
top_fields as (
  select
    distinct merged_id
  from ranked_fields
  where
    rank between 1 and 3
    and name in ('Chemistry', 'Engineering', 'Materials science', 'Physics')
)

-- Get titles and abstracts for these papers, restricting further to papers from 2010-present
select
  merged_id,
  title_english as title,
  abstract_english as abstract,
from literature.papers
where merged_id in (select merged_id from top_fields)
  and year between 2010 and EXTRACT(YEAR FROM CURRENT_DATE)
  and (
    title_english is not null
    or abstract_english is not null
  )
