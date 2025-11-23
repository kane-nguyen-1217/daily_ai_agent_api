class AiSummaryWorker
  include Sidekiq::Job
  
  def perform(ai_summary_id)
    summary = AiSummary.find(ai_summary_id)
    summary.mark_as_generating!
    
    begin
      result = AiSummaryGeneratorService.generate(summary)
      summary.mark_as_completed!(result[:content], result[:token_count])
    rescue => e
      summary.mark_as_failed!
      Rails.logger.error("AI Summary generation failed: #{e.message}")
      raise e
    end
  end
end
