module Api
  module V1
    module Webhooks
      class N8nController < ApplicationController
        skip_before_action :authenticate_request, only: [:workflow_callback]
        before_action :verify_n8n_signature, only: [:workflow_callback]
        
        def workflow_callback
          log = N8nWebhookLog.create!(
            user_id: params[:user_id],
            workflow_id: params[:workflow_id],
            execution_id: params[:execution_id],
            status: 'pending',
            request_payload: request_payload
          )
          
          # Process webhook in background
          N8nWebhookProcessorWorker.perform_async(log.id)
          
          render json: {
            message: 'Webhook received',
            log_id: log.id
          }, status: :accepted
        end
        
        def execute
          workflow_id = params[:workflow_id]
          workflow_params = params[:workflow_params] || {}
          
          # Execute n8n workflow
          result = N8nIntegrationService.execute_workflow(
            workflow_id: workflow_id,
            user: current_user,
            parameters: workflow_params
          )
          
          log = N8nWebhookLog.create!(
            user: current_user,
            workflow_id: workflow_id,
            execution_id: result[:execution_id],
            status: 'running',
            request_payload: workflow_params,
            executed_at: Time.current
          )
          
          render json: {
            message: 'Workflow execution started',
            execution_id: result[:execution_id],
            log_id: log.id,
            status_url: api_v1_webhooks_n8n_status_url(result[:execution_id])
          }, status: :accepted
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        def status
          execution_id = params[:job_id]
          log = N8nWebhookLog.find_by!(execution_id: execution_id)
          
          # Check status from n8n
          status = N8nIntegrationService.check_execution_status(execution_id)
          
          log.update!(
            status: status[:status],
            response_payload: status[:data],
            error_message: status[:error]
          )
          
          render json: {
            execution_id: execution_id,
            status: log.status,
            response: log.response_payload,
            error: log.error_message,
            executed_at: log.executed_at,
            updated_at: log.updated_at
          }
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Execution not found' }, status: :not_found
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        private
        
        def verify_n8n_signature
          # Implement signature verification for n8n webhooks
          signature = request.headers['X-N8N-Signature']
          expected_signature = ENV['N8N_WEBHOOK_SECRET']
          
          unless signature == expected_signature
            render json: { error: 'Invalid signature' }, status: :unauthorized
          end
        end
        
        def request_payload
          params.except(:controller, :action, :format).to_unsafe_h
        end
      end
    end
  end
end
