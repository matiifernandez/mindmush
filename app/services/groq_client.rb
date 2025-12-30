class GroqClient
  BASE_URL = "https://api.groq.com/openai/v1/chat/completions"

  def initialize
    @api_key = Rails.application.credentials.groq[:api_key]
  end

  def generate(system_prompt, user_prompt, model: "llama-3.1-8b-instant")
    response = HTTP
      .headers(
        "Authorization" => "Bearer #{@api_key}",
        "Content-Type" => "application/json"
      )
      .post(BASE_URL, json: {
        model: model,
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt }
        ],
        temperature: 0.7,
        max_tokens: 4000
      })

    if response.status.success?
      JSON.parse(response.body)["choices"][0]["message"]["content"]
    else
      raise "Groq API Error: #{response.status} - #{response.body}"
    end
  end
end
