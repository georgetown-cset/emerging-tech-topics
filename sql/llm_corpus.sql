-- This query selects a subset of publications from CSET's scholarly lit corpus for
-- classification as LLM research, or not. Publications predicted relevant to AI/NLP/CV
-- using our arXiv-trained classifiers are in scope, which means we're restricting to
-- publications 2010-present with an EN title and/or abstract.

-- Get titles and abstracts for papers predicted AI/NLP/CV-relevant
select
  merged_id,
  title_english as title,
  abstract_english as abstract,
from article_classification.predictions
where (
  ai
  or nlp
  or cv
)