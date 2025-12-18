require "net/http"
require "json"
require "uri"

class PowerBiService
  POWER_BI_AUTH_URL = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
  POWER_BI_API_BASE = "https://api.powerbi.com/v1.0"

  def initialize(tenant_id: nil, client_id: nil, client_secret: nil, workspace_id: nil)
    @tenant_id = tenant_id || ENV['POWER_BI_TENANT_ID'] || Rails.application.credentials.dig(:power_bi, :tenant_id)
    @client_id = client_id || ENV['POWER_BI_CLIENT_ID'] || Rails.application.credentials.dig(:power_bi, :client_id)
    @client_secret = client_secret || ENV['POWER_BI_CLIENT_SECRET'] || Rails.application.credentials.dig(:power_bi, :client_secret)
    @workspace_id = workspace_id || ENV['POWER_BI_WORKSPACE_ID'] || Rails.application.credentials.dig(:power_bi, :workspace_id) || "myorg"
    @access_token = nil
  end

  # Get OAuth2 access token
  def authenticate!
    tenant_endpoint = @tenant_id ? "https://login.microsoftonline.com/#{@tenant_id}/oauth2/v2.0/token" : POWER_BI_AUTH_URL
    uri = URI(tenant_endpoint)
    
    params = {
      grant_type: "client_credentials",
      client_id: @client_id,
      client_secret: @client_secret,
      scope: "https://analysis.windows.net/powerbi/api/.default"
    }

    response = Net::HTTP.post_form(uri, params)
    
    if response.code == "200"
      data = JSON.parse(response.body)
      @access_token = data["access_token"]
      @access_token
    else
      raise "Power BI authentication failed: #{response.body}"
    end
  end

  # Get access token (cached)
  def access_token
    @access_token ||= authenticate!
  end

  # Create a push dataset with dynamic schema
  # schema_columns: Hash of column_name => data_type
  # Example: { "date" => "DateTime", "amount" => "Double", "product" => "String" }
  def create_push_dataset(dataset_name, schema_columns)
    authenticate! unless @access_token

    # Convert schema_columns to Power BI table schema
    tables = [
      {
        name: "Data",
        columns: schema_columns.map do |column_name, data_type|
          {
            name: column_name,
            dataType: map_data_type_to_power_bi(data_type)
          }
        end
      }
    ]

    dataset_request = {
      name: dataset_name,
      tables: tables,
      defaultMode: "Push"
    }

    api_url = @workspace_id && @workspace_id != "myorg" ? 
      "#{POWER_BI_API_BASE}/groups/#{@workspace_id}" : 
      "#{POWER_BI_API_BASE}/myorg"
    uri = URI("#{api_url}/datasets")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request["Authorization"] = "Bearer #{access_token}"
    request["Content-Type"] = "application/json"
    request.body = dataset_request.to_json

    response = http.request(request)

    if response.code == "201"
      dataset = JSON.parse(response.body)
      dataset["id"]
    else
      raise "Failed to create Power BI dataset: #{response.body}"
    end
  end

  # Push rows to a dataset table
  def push_rows(dataset_id, table_name, rows)
    authenticate! unless @access_token

    # Ensure rows is an array of hashes
    rows_array = rows.is_a?(Array) ? rows : [rows]

    request_body = {
      rows: rows_array
    }

    api_url = @workspace_id && @workspace_id != "myorg" ? 
      "#{POWER_BI_API_BASE}/groups/#{@workspace_id}" : 
      "#{POWER_BI_API_BASE}/myorg"
    uri = URI("#{api_url}/datasets/#{dataset_id}/tables/#{table_name}/rows")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request["Authorization"] = "Bearer #{access_token}"
    request["Content-Type"] = "application/json"
    request.body = request_body.to_json

    response = http.request(request)

    if response.code == "200"
      true
    else
      raise "Failed to push rows to Power BI: #{response.body}"
    end
  end

  # Delete all rows from a table (useful for refreshing data)
  def clear_table(dataset_id, table_name)
    authenticate! unless @access_token

    api_url = @workspace_id && @workspace_id != "myorg" ? 
      "#{POWER_BI_API_BASE}/groups/#{@workspace_id}" : 
      "#{POWER_BI_API_BASE}/myorg"
    uri = URI("#{api_url}/datasets/#{dataset_id}/tables/#{table_name}/rows")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Delete.new(uri.path)
    request["Authorization"] = "Bearer #{access_token}"

    response = http.request(request)
    response.code == "200"
  end

  private

  # Map Ruby/CSV data types to Power BI data types
  def map_data_type_to_power_bi(ruby_type)
    case ruby_type.to_s.downcase
    when "datetime", "date", "time"
      "DateTime"
    when "integer", "int", "number"
      "Int64"
    when "float", "decimal", "double", "numeric"
      "Double"
    when "boolean", "bool"
      "Boolean"
    else
      "String"
    end
  end
end

