class N8nWebhookProcessorWorker
  include Sidekiq::Job
  
  def perform(log_id)
    log = N8nWebhookLog.find(log_id)
    log.mark_as_running!
    
    begin
      # Process the webhook payload
      result = N8nIntegrationService.process_webhook(
        workflow_id: log.workflow_id,
        execution_id: log.execution_id,
        payload: log.request_payload
      )
      
      log.mark_as_success!(result)
    rescue => e
      log.mark_as_failed!(e.message)
      Rails.logger.error("N8N webhook processing failed: #{e.message}")
    end
  end
end
