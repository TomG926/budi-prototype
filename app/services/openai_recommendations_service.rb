require "net/http"
require "json"
require "uri"

# Service to generate business recommendations using OpenAI
# Can be used alongside or instead of Power BI
class OpenAiRecommendationsService
  OPENAI_API_URL = "https://api.openai.com/v1/chat/completions"

  def initialize(api_key: nil)
    @api_key = api_key || ENV['OPENAI_API_KEY'] || Rails.application.credentials.dig(:openai, :api_key)
  end

  def configured?
    @api_key.present?
  end

  # Generate recommendations based on data summary and industry type
  def generate_recommendations(data_summary, industry_type: "other", schema_columns: {})
    industry_info = IndustryPromptsService.for_industry(industry_type)
    
    prompt = build_prompt(data_summary, industry_info, schema_columns)
    
    response = call_openai_api(prompt)
    parse_recommendations(response)
  rescue => e
    Rails.logger.error("OpenAI recommendations failed: #{e.message}")
    nil
  end

  # Generate recommendations from sample data rows
  def generate_from_sample_rows(sample_rows, industry_type: "other", schema_columns: {}, row_count: 0)
    # Create a summary of the data
    data_summary = {
      row_count: row_count > 0 ? row_count : sample_rows.count,
      columns: schema_columns.keys,
      sample_data: sample_rows.first(10).map { |row| row.data }
    }
    
    generate_recommendations(data_summary, industry_type: industry_type, schema_columns: schema_columns)
  end

  # Generate recommendations using the same prompts as Power BI (industry-specific)
  def generate_with_industry_prompts(sample_rows, industry_type: "other", schema_columns: {}, row_count: 0)
    unless configured?
      raise "OpenAI API key not configured. Please set OPENAI_API_KEY environment variable or add to Rails credentials (config/credentials.yml.enc)."
    end
    
    industry_info = IndustryPromptsService.for_industry(industry_type)
    
    # Use the same prompts that we show for Power BI
    power_bi_prompts = industry_info[:power_bi_prompts]
    key_metrics = industry_info[:key_metrics]
    
    # Create data summary with actual sample data
    sample_data_preview = sample_rows.first(10).map { |row| row.data }
    
    prompt = build_industry_prompt(
      sample_data_preview,
      row_count,
      schema_columns,
      industry_info,
      power_bi_prompts,
      key_metrics
    )
    
    response = call_openai_api(prompt)
    result = parse_recommendations(response)
    
    unless result && result[:recommendations]
      raise "OpenAI API returned empty response or no recommendations"
    end
    
    result
  rescue => e
    Rails.logger.error("OpenAI recommendations failed: #{e.class.name}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise # Re-raise to let controller handle it
  end

  # Answer a user's question about their data
  def answer_question(question, sample_rows, industry_type: "other", schema_columns: {}, row_count: 0, existing_analysis: nil)
    raise "OpenAI API key not configured" unless configured?
    
    industry_info = IndustryPromptsService.for_industry(industry_type)
    
    # Prepare sample data
    sample_data = sample_rows.first(50).map { |row| row.data } # Use more rows for questions
    
    # Build prompt with context about the data and existing analysis
    prompt = build_question_prompt(question, sample_data, row_count, schema_columns, industry_info, existing_analysis)
    
    # Use a more conversational approach
    messages = [
      {
        role: "system",
        content: "You are a helpful business analyst AI assistant. You analyze business data and answer questions in a clear, concise, and data-driven way. Reference specific numbers and patterns from the data when possible."
      },
      {
        role: "user",
        content: prompt
      }
    ]
    
    response = call_openai_api_with_messages(messages)
    
    {
      answer: response.dig("choices", 0, "message", "content"),
      model: response.dig("model"),
      usage: response.dig("usage")
    }
  rescue => e
    Rails.logger.error("OpenAI question answer failed: #{e.class.name}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise
  end

  private

  def build_prompt(data_summary, industry_info, schema_columns)
    <<~PROMPT
      You are a business analyst specializing in #{industry_info[:name]}.
      
      Analyze the following data and provide actionable business recommendations:
      
      Data Summary:
      - Number of records: #{data_summary[:row_count]}
      - Columns: #{schema_columns.keys.join(', ')}
      - Sample data: #{JSON.pretty_generate(data_summary[:sample_data])}
      
      Industry Context: #{industry_info[:description]}
      
      Key Metrics to Consider: #{industry_info[:key_metrics].join(', ')}
      
      Please provide:
      1. Top 3-5 actionable business recommendations
      2. Key insights from the data
      3. Potential risks or opportunities
      4. Suggested next steps for analysis
      
      Format your response as clear, actionable recommendations suitable for business decision-makers.
    PROMPT
  end

  def call_openai_api(prompt)
    uri = URI(OPENAI_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 60 # Increase timeout for longer responses

    request = Net::HTTP::Post.new(uri.path)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    
    request.body = {
      model: "gpt-4o-mini", # Cost-effective model ($0.15/$0.60 per 1M tokens), can switch to "gpt-4" for better quality
      messages: [
        {
          role: "system",
          content: "You are an expert business analyst providing data-driven recommendations."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.7,
      max_tokens: 2000  # Increased for more comprehensive analysis
    }.to_json

    response = http.request(request)
    
    if response.code == "200"
      JSON.parse(response.body)
    else
      error_body = JSON.parse(response.body) rescue response.body
      raise "OpenAI API error (#{response.code}): #{error_body}"
    end
  end

  def build_industry_prompt(sample_data, row_count, schema_columns, industry_info, power_bi_prompts, key_metrics)
    <<~PROMPT
      You are a business analyst specializing in #{industry_info[:name]}.
      
      Analyze the following business data and provide actionable recommendations based on the same key questions and metrics that would be analyzed in Power BI.
      
      Dataset Overview:
      - Total Records: #{row_count}
      - Columns: #{schema_columns.keys.join(', ')}
      - Industry: #{industry_info[:name]}
      
      Sample Data (first 10 rows):
      #{JSON.pretty_generate(sample_data)}
      
      Industry Context: #{industry_info[:description]}
      
      Key Questions to Address (same as Power BI prompts):
      #{power_bi_prompts.map.with_index(1) { |q, i| "#{i}. #{q}" }.join("\n")}
      
      Key Metrics to Analyze:
      #{key_metrics.map.with_index(1) { |m, i| "#{i}. #{m}" }.join("\n")}
      
      Please provide a comprehensive business analysis that includes:
      1. **Top 5-7 Actionable Recommendations** - Specific, data-driven recommendations based on the key questions above
      2. **Key Insights** - Important patterns, trends, or findings from the data
      3. **Opportunities & Risks** - Potential opportunities to capitalize on and risks to address
      4. **Performance Analysis** - Analysis of key metrics and how they relate to business performance
      5. **Next Steps** - Recommended actions to take based on the analysis
      
      Format your response in clear sections with actionable, specific recommendations that a business owner can implement.
      Use the data to support your recommendations with specific examples from the dataset.
    PROMPT
  end

  def parse_recommendations(response)
    content = response.dig("choices", 0, "message", "content")
    {
      recommendations: content,
      model: response.dig("model"),
      usage: response.dig("usage")
    }
  end
  
  private
  
  def build_question_prompt(question, sample_data, row_count, schema_columns, industry_info, existing_analysis)
    <<~PROMPT
      You are analyzing business data for a #{industry_info[:name]} business.
      
      Dataset Overview:
      - Total Records: #{row_count}
      - Columns: #{schema_columns.keys.join(', ')}
      
      Sample Data (first 50 rows):
      #{JSON.pretty_generate(sample_data)}
      
      #{existing_analysis ? "Previous Analysis Summary:\n#{existing_analysis[0..500]}...\n\n" : ""}
      
      User Question: #{question}
      
      Please answer the user's question in a clear, concise, and easy-to-understand way. 
      
      Guidelines:
      - Start with a direct, simple answer (1-2 sentences)
      - Use bullet points for key findings
      - Highlight important numbers prominently
      - Keep calculations brief or summarize the result
      - Provide 2-3 actionable insights if relevant
      - Use simple language, avoid jargon
      - Keep the total response under 200 words unless detailed analysis is specifically requested
      
      Format: 
      1. Direct answer at the top
      2. Key numbers/findings as bullet points
      3. Brief insights (if applicable)
      
      If the question cannot be answered from the available data, explain what information would be needed.
    PROMPT
  end
  
  def call_openai_api_with_messages(messages)
    uri = URI(OPENAI_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 60

    request = Net::HTTP::Post.new(uri.path)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    
    request.body = {
      model: "gpt-4o-mini",
      messages: messages,
      temperature: 0.7,
      max_tokens: 1000
    }.to_json

    response = http.request(request)
    
    if response.code == "200"
      JSON.parse(response.body)
    else
      error_body = JSON.parse(response.body) rescue response.body
      raise "OpenAI API error (#{response.code}): #{error_body}"
    end
  end
end

