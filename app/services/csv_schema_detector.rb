require "csv"

class CsvSchemaDetector
  # Analyze CSV file and return schema information
  # Returns hash: { "column_name" => "detected_type" }
  def self.detect_schema(csv_content, sample_size: 100)
    csv = CSV.parse(csv_content, headers: true)
    
    return {} if csv.headers.nil? || csv.headers.empty?

    schema = {}
    sample_rows = csv.first(sample_size)

    csv.headers.each do |column_name|
      # Try to detect type from sample data
      column_values = sample_rows.map { |row| row[column_name] }.compact.reject(&:empty?)
      
      if column_values.empty?
        schema[column_name] = "String"
      else
        schema[column_name] = detect_column_type(column_values)
      end
    end

    schema
  end

  private

  def self.detect_column_type(values)
    # Try to detect type based on values
    int_count = 0
    float_count = 0
    date_count = 0
    bool_count = 0

    values.each do |value|
      value = value.to_s.strip

      # Try integer
      if value.match?(/^-?\d+$/)
        int_count += 1
      # Try float
      elsif value.match?(/^-?\d+\.\d+$/)
        float_count += 1
      # Try date/datetime (common formats)
      elsif value.match?(/\d{4}-\d{2}-\d{2}/) || value.match?(/\d{2}\/\d{2}\/\d{4}/)
        date_count += 1
      # Try boolean
      elsif ["true", "false", "yes", "no", "1", "0"].include?(value.downcase)
        bool_count += 1
      end
    end

    total = values.length

    # Return the most common detected type
    if date_count > total * 0.5
      "DateTime"
    elsif bool_count > total * 0.8
      "Boolean"
    elsif float_count > total * 0.5
      "Double"
    elsif int_count > total * 0.8
      "Int64"
    else
      "String"
    end
  end
end

