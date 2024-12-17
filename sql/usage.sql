-- Extract usage metadata for a batch prediction request
-- See https://cloud.google.com/vertex-ai/generative-ai/pricing#gemini-models
with counts as (
-- Usage from summarization task
select
  {{ dataset }}.get_usage(response) as usage
from {{ dataset }}.{{ summaries }}
union all
-- Usage from classification task
select
  {{ dataset }}.get_usage(response)
from {{ dataset }}.{{ labels }}
),

totals as (
select
  sum(usage.prompt) as prompt,
  sum(usage.output) as output,
  -- Costs are in USD per 1K tokens after a 50% batch discount, as of 2024-12-16
  -- https://cloud.google.com/vertex-ai/generative-ai/pricing#gemini-models
  sum(usage.prompt) * 0.00001875 / 1000 / 2 as prompt_cost,
  sum(usage.output) * 0.000075 / 1000 / 2 as output_cost,
from counts
)

select
  *,
  prompt_cost + output_cost as total_cost
from totals