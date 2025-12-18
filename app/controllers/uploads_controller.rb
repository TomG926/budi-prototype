require "csv"
require_relative "../services/openai_recommendations_service"

class UploadsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @uploads = current_user.uploads.order(created_at: :desc)
  end

  def new
    @upload = current_user.uploads.build
  end

  def create
    @upload = current_user.uploads.build(upload_params)

    if params[:upload][:file].present?
      @upload.file.attach(params[:upload][:file])
      @upload.status = :processing

      if @upload.save
        # Process in background for better UX
        CsvImportJob.perform_later(@upload.id)
        redirect_to @upload, notice: "Upload queued for processing. This may take a moment."
      else
        render :new, status: :unprocessable_entity
      end
    else
      @upload.errors.add(:file, "must be attached")
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @upload = current_user.uploads.find(params[:id])
    @row_count = @upload.data_rows.count
    @sample_rows = @upload.data_rows.limit(10)
  end

  def analyze_with_openai
    @upload = current_user.uploads.find(params[:id])
    
    if @upload.status != 'done'
      redirect_to @upload, alert: "Please wait for the upload to complete processing."
      return
    end

    @upload.update!(open_ai_analysis_status: :analyzing)
    
    begin
      openai_service = OpenAiRecommendationsService.new
      
      unless openai_service.configured?
        @upload.update!(open_ai_analysis_status: :analysis_failed)
        redirect_to @upload, alert: "OpenAI API key not configured. Please set OPENAI_API_KEY environment variable (and restart the server) or add to Rails credentials."
        return
      end
      
      sample_rows = @upload.data_rows.limit(100) # Use more rows for better analysis
      
      result = openai_service.generate_with_industry_prompts(
        sample_rows,
        industry_type: @upload.industry_type || 'other',
        schema_columns: @upload.schema_columns,
        row_count: @upload.data_rows.count
      )
      
      @upload.update!(
        open_ai_recommendations: result[:recommendations],
        open_ai_analysis_status: :completed
      )
      redirect_to analysis_path(@upload.id), notice: "AI analysis completed successfully!"
    rescue => e
      @upload.update!(open_ai_analysis_status: :analysis_failed)
      Rails.logger.error("OpenAI analysis failed: #{e.class.name}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      error_message = e.message.length > 150 ? "#{e.message[0..150]}..." : e.message
      redirect_to @upload, alert: "AI analysis failed: #{error_message}"
    end
  end

  private

  def upload_params
    params.require(:upload).permit(:name, :file, :industry_type)
  end
end