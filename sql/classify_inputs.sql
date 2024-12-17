-- Create a table of inputs for the classification task given outputs from the summarization task
with inputs as (
select
  merged_id,
  status,
  -- Extract from the response our one-sentence summary
  {{ dataset }}.get_response_text(response) as summary,
from {{ dataset }}.{{ summaries }}
-- Status is an empty string if the request was successful, otherwise it holds error details
-- We exclude failed requests from the classification task
where status = ''
)

select
  merged_id,
  {{ dataset }}.create_request(
    @systemInstructions,
    summary,
    @temperature,
    @maxOutputTokens
  ) as request
from inputs
where
  summary != ''
  -- The prompt for the summarization task asks for a response of 'None' if the input text
  -- doesn't describe a research publication. We exclude these from classification.
  and not starts_with(summary, 'None')
