require_relative '../services/openai_recommendations_service'

class AnalysesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # Show all uploads that have AI recommendations
    @uploads_with_analyses = current_user.uploads
      .where(open_ai_analysis_status: :completed)
      .where.not(open_ai_recommendations: nil)
      .order(updated_at: :desc)
  end
  
  def show
    @upload = current_user.uploads.find(params[:upload_id])
    @row_count = @upload.data_rows.count
    @sample_rows = @upload.data_rows.limit(10)
    
    # Extract key metrics from the recommendations for charting
    @key_metrics = extract_metrics_from_recommendations(@upload.open_ai_recommendations)
    
    # Calculate some basic stats from data for charts
    if @upload.data_rows.any?
      @chart_data = prepare_chart_data(@upload)
    end
    
    # Load saved questions/answers for this upload
    @saved_questions = @upload.data_questions.order(created_at: :desc).limit(10)
  end
  
  def ask_question
    @upload = current_user.uploads.find(params[:upload_id])
    question = params[:question]&.strip
    
    if question.blank?
      redirect_to analysis_path(@upload.id), alert: "Please enter a question."
      return
    end
    
    begin
      openai_service = OpenAiRecommendationsService.new
      unless openai_service.configured?
        redirect_to analysis_path(@upload.id), alert: "OpenAI API key not configured."
        return
      end
      
      # Get more data rows for better context
      sample_rows = @upload.data_rows.limit(100)
      
      result = openai_service.answer_question(
        question,
        sample_rows,
        industry_type: @upload.industry_type || 'other',
        schema_columns: @upload.schema_columns,
        row_count: @upload.data_rows.count,
        existing_analysis: @upload.open_ai_recommendations
      )
      
      @answer = result[:answer]
      @question = question
      
      # Save the question and answer
      @data_question = @upload.data_questions.create!(
        user: current_user,
        question: question,
        answer: result[:answer]
      )
      
      # Render the show page with the answer
      @row_count = @upload.data_rows.count
      @sample_rows = @upload.data_rows.limit(10)
      @key_metrics = extract_metrics_from_recommendations(@upload.open_ai_recommendations)
      @saved_questions = @upload.data_questions.order(created_at: :desc).limit(10)
      if @upload.data_rows.any?
        @chart_data = prepare_chart_data(@upload)
      end
      
      render :show
    rescue => e
      Rails.logger.error("Question answering failed: #{e.message}")
      redirect_to analysis_path(@upload.id), alert: "Failed to get answer: #{e.message}"
    end
  end
  
  private
  
  def extract_metrics_from_recommendations(recommendations)
    # Extract mentioned metrics, revenue figures, etc. from the text
    metrics = {}
    
    # Look for revenue/service mentions
    if recommendations =~ /(\$\d+)/i
      metrics[:revenue_mentions] = recommendations.scan(/\$[\d,]+\.?\d*/)
    end
    
    metrics
  end
  
  def prepare_chart_data(upload)
    rows = upload.data_rows
    
    # Try to find amount/revenue column
    amount_column = upload.schema_columns.keys.find { |k| k.downcase.include?('amount') || k.downcase.include?('revenue') || k.downcase.include?('price') }
    
    # Try to find service/product column
    service_column = upload.schema_columns.keys.find { |k| k.downcase.include?('service') || k.downcase.include?('product') }
    
    # Try to find staff column
    staff_column = upload.schema_columns.keys.find { |k| k.downcase.include?('staff') || k.downcase.include?('employee') }
    
    chart_data = {}
    
    if amount_column
      # Service revenue chart
      if service_column
        service_revenues = Hash.new(0)
        rows.each do |row|
          service = row.data[service_column]&.to_s
          amount = row.data[amount_column]&.to_f || 0
          service_revenues[service] += amount if service.present?
        end
        chart_data[:service_revenue] = service_revenues.sort_by { |_, v| -v }.first(10).to_h
      end
      
      # Staff performance chart
      if staff_column
        staff_revenues = Hash.new(0)
        rows.each do |row|
          staff = row.data[staff_column]&.to_s
          amount = row.data[amount_column]&.to_f || 0
          staff_revenues[staff] += amount if staff.present?
        end
        chart_data[:staff_revenue] = staff_revenues.sort_by { |_, v| -v }.to_h
      end
    end
    
    chart_data
  end
end

