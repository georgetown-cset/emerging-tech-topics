# Identifying Emerging Technology Research

This repository contains materials for identifying research publications relevant to LLM development and chip design or fabrication.

Our approach is to chain two prompts using [Gemini 1.5 Flash](https://deepmind.google/technologies/gemini/flash/). We first generate a one-sentence summary of the research described in a publication's title and abstract. Then, we generate a relevance prediction  given the summary. 

Prompt text can be found in the `prompts` directory: 
- LLM research: [summarization](prompts/llm-summarization.txt) and [classification](prompts/llm-classification.txt)
- Chip design and fabrication research: [summarization](prompts/chip-summarization.txt) and [classification](prompts/chip-classification.txt) 

In deployment on Google Cloud, we use Vertex [batch prediction](https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/batch-prediction-gemini) with BigQuery. The `sql` directory contains the queries used in our pipeline, and the [`demo`](demo.ipynb) notebook illustrates generation of summaries and classifications for a small set of publications. The sequence looks like:

- [`udfs.sql`](sql/udfs.sql): Define UDFs for wrangling batch prediction inputs and outputs.
- [`chip_corpus.sql`](sql/chip_corpus.sql) and [`llm_corpus.sql`](sql/llm_corpus.sql): Create tables holding the scholarly literature that we'll generate predictions for, given titles and abstracts.
- [`summary_inputs.sql`](sql/summary_inputs.sql): Create a table of [batch prediction requests](https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/batch-prediction-gemini#bigquery).
- Run the first batch job, yielding one-sentence summaries for each publication.
- [`classify_inputs.sql`](sql/classify_inputs.sql): Create a table of batch prediction requests for the classification task.
- Run the second batch job for predicted relevance.
- [`labels.sql`](sql/labels.sql): Parse the responses from the classification task to create a table of labels for the input publications.
- [`usage.sql`](sql/usage.sql): Estimate pipeline costs based on the input and output token counts contained in response metadata.
