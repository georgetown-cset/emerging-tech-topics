-- Create request JSON for a Vertex batch prediction task using BQ
-- See https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/batch-prediction-gemini#bigquery
CREATE OR REPLACE FUNCTION `{{ dataset }}.create_request`(
  systemInstructions STRING,
  userText STRING,
  temperature FLOAT64,
  maxOutputTokens INT64
)
RETURNS STRING
LANGUAGE js
AS """
function create_request(systemInstructions, userText, temperature = 0.5, maxOutputTokens = 1024) {
  return {
    systemInstruction: {
      role: "system",
      parts: [
        { text: systemInstructions }
      ]
    },
    contents: [
      {
        role: "user",
        parts: [
          { text: userText }
        ]
      }
    ],
    safetySettings: [
      {
        category: "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        threshold: "OFF"
      },
      {
        category: "HARM_CATEGORY_HATE_SPEECH",
        threshold: "OFF"
      },
      {
        category: "HARM_CATEGORY_HARASSMENT",
        threshold: "OFF"
      },
      {
        category: "HARM_CATEGORY_DANGEROUS_CONTENT",
        threshold: "OFF"
      }
    ],
    generationConfig: {
      temperature: temperature,
      seed: 20241216,
      maxOutputTokens: maxOutputTokens
    }
  };
}
return JSON.stringify(create_request(systemInstructions, userText, temperature, maxOutputTokens));
""";

-- Concatenate title and abstract text for input into the summarization task
CREATE OR REPLACE FUNCTION `{{ dataset }}.concat_text`(
  title STRING,
  abstract STRING
)
RETURNS STRING AS (
  replace(ltrim(trim(coalesce(title, '') || '. ' || coalesce(abstract, '')), '.'), '\n', ' ')
);

-- Extract response text from a batch prediction request
-- See https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/batch-prediction-gemini#batch_prediction_output
CREATE OR REPLACE FUNCTION `{{ dataset }}.get_response_text`(
  response JSON
)
RETURNS STRING AS (
  trim(string(json_query(response, '$.candidates[0].content.parts[0].text')))
);

-- Extract usage metadata for a batch prediction request
-- See https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/batch-prediction-gemini#batch_prediction_output
CREATE OR REPLACE FUNCTION `{{ dataset }}.get_usage`(
  response JSON
)
RETURNS STRUCT<
  prompt INT64,
  output INT64
> AS (
STRUCT (
  lax_int64(json_query(response, '$.usageMetadata.promptTokenCount')),
  lax_int64(json_query(response, '$.usageMetadata.candidatesTokenCount'))
  )
);
