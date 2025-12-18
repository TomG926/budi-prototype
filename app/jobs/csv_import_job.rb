require "csv"

class CsvImportJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    upload = Upload.find(upload_id)
    
    begin
      upload.update!(status: :processing)
      
      # Download and parse CSV
      file_content = upload.file.download
      csv = CSV.parse(file_content, headers: true)
      
      if csv.headers.nil? || csv.headers.empty?
        raise "CSV file has no headers"
      end

      # Detect schema from CSV
      schema_columns = CsvSchemaDetector.detect_schema(file_content)
      upload.update!(schema_columns: schema_columns)

      # Store data in PostgreSQL (JSONB for flexibility)
      rows_data = []
      csv.each do |row|
        # Skip blank rows (where all values are nil or empty)
        next if row.fields.all? { |field| field.nil? || field.strip.empty? }
        
        row_hash = {}
        csv.headers.each do |header|
          row_hash[header] = row[header]
        end
        
        data_row = upload.data_rows.create!(data: row_hash)
        rows_data << row_hash
      end

      # Create Power BI dataset and push data
      if upload_to_power_bi?(upload)
        push_to_power_bi(upload, schema_columns, rows_data)
      end

      upload.update!(status: :done)
      Rails.logger.info("CSV import completed for upload #{upload_id}: #{rows_data.count} rows")
      
    rescue => e
      upload.update!(status: :failed)
      Rails.logger.error("CSV import failed for upload #{upload_id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise
    end
  end

  private

  def upload_to_power_bi?(upload)
    # Check if Power BI credentials are configured (via credentials or ENV)
    (ENV['POWER_BI_CLIENT_ID'].present? && ENV['POWER_BI_CLIENT_SECRET'].present?) ||
      (Rails.application.credentials.dig(:power_bi, :client_id).present? &&
       Rails.application.credentials.dig(:power_bi, :client_secret).present?)
  end

  def push_to_power_bi(upload, schema_columns, rows_data)
    power_bi = PowerBiService.new
    
      # Create dataset name from upload name or use timestamp
      # Include user email for better organization in Power BI
      user_identifier = upload.user.email.split('@').first.gsub(/[^a-zA-Z0-9]/, '_')
      base_name = upload.name.present? ? upload.name : "Upload_#{upload.id}"
      dataset_name = "#{user_identifier}_#{base_name}_#{upload.id}"
      dataset_name = sanitize_dataset_name(dataset_name)
    table_name = "Data"

    # Create push dataset in Power BI
    dataset_id = power_bi.create_push_dataset(dataset_name, schema_columns)
    
    # Store Power BI info
    upload.update!(
      power_bi_dataset_id: dataset_id,
      power_bi_table_name: table_name
    )

    # Push data in batches (Power BI has limits)
    batch_size = 1000
    rows_data.each_slice(batch_size) do |batch|
      power_bi.push_rows(dataset_id, table_name, batch)
    end

    Rails.logger.info("Pushed #{rows_data.count} rows to Power BI dataset #{dataset_id}")
    
  rescue => e
    Rails.logger.error("Power BI push failed: #{e.message}")
    # Don't fail the whole import if Power BI fails
    # The data is still in PostgreSQL
  end

  def sanitize_dataset_name(name)
    # Power BI dataset names have restrictions
    # Remove invalid characters
    name.gsub(/[^a-zA-Z0-9_\s-]/, "").strip.gsub(/\s+/, "_")
  end
end

