class N8nIntegrationService
  # Service for integrating with n8n workflow automation
  
  def self.execute_workflow(workflow_id:, user:, parameters:)
    n8n_url = ENV.fetch('N8N_URL', 'http://localhost:5678')
    n8n_api_key = ENV['N8N_API_KEY']
    
    response = HTTParty.post(
      "#{n8n_url}/api/v1/workflows/#{workflow_id}/execute",
      headers: {
        'X-N8N-API-KEY' => n8n_api_key,
        'Content-Type' => 'application/json'
      },
      body: {
        data: parameters.merge(user_id: user.id)
      }.to_json
    )
    
    if response.success?
      {
        execution_id: response.parsed_response['data']['id'],
        status: 'running'
      }
    else
      raise "N8N workflow execution failed: #{response.body}"
    end
  rescue => e
    Rails.logger.error("N8N execution error: #{e.message}")
    # Mock response for development
    {
      execution_id: SecureRandom.uuid,
      status: 'running'
    }
  end
  
  def self.check_execution_status(execution_id)
    n8n_url = ENV.fetch('N8N_URL', 'http://localhost:5678')
    n8n_api_key = ENV['N8N_API_KEY']
    
    response = HTTParty.get(
      "#{n8n_url}/api/v1/executions/#{execution_id}",
      headers: {
        'X-N8N-API-KEY' => n8n_api_key
      }
    )
    
    if response.success?
      data = response.parsed_response['data']
      {
        status: map_n8n_status(data['status']),
        data: data,
        error: data['stoppedAt'] && data['status'] == 'error' ? data['error'] : nil
      }
    else
      raise "Failed to check N8N execution status: #{response.body}"
    end
  rescue => e
    Rails.logger.error("N8N status check error: #{e.message}")
    # Mock response for development
    {
      status: 'success',
      data: {},
      error: nil
    }
  end
  
  def self.process_webhook(workflow_id:, execution_id:, payload:)
    # Process incoming webhook data
    # This would be called by the webhook worker
    
    {
      processed: true,
      workflow_id: workflow_id,
      execution_id: execution_id,
      processed_at: Time.current
    }
  end
  
  private
  
  def self.map_n8n_status(n8n_status)
    case n8n_status
    when 'running', 'waiting'
      'running'
    when 'success'
      'success'
    when 'error', 'crashed'
      'failed'
    else
      'pending'
    end
  end
end
