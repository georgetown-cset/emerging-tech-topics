-- Create a table of inputs formatted for the summarization task
select
  merged_id,
  -- See udfs.sql
  {{ dataset }}.create_request(
    @systemInstructions,
    {{ dataset }}.concat_text(title, abstract),
    @temperature,
    @maxOutputTokens
  ) as request
-- This table contains {merged_id, title, abstract}
from {{ dataset }}.{{ corpus }}
