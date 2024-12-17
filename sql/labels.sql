-- Parse responses from the classification task yielding binary labels for each publication
with classify_outputs as (
select
  merged_id,
  status,
  {{ dataset }}.get_response_text(response) as label,
from {{ dataset }}.{{ labels }}
-- Status is an empty string if the request was successful, otherwise it holds error details
where status = ''
)

select
  merged_id,
  case
    -- The label is null if (1) the response from the summarization task was 'None' because
    -- the input text didn't seem to describe a research publication, or (2) the prediction
    -- request from either the summarization or classification task failed with an error. In
    -- either case, we apply a `false` label. In this way, we get a label for every input
    -- publication.
    when label is null then false
    -- Otherwise, in the typical case, we should have a response from the classification task
    -- that starts with YES or NO.
    when starts_with(label, 'YES') then true
    else false
  end as label
from {{ dataset }}.{{ corpus }}
left join classify_outputs using(merged_id)
