module Api
  module V1
    class AiSummariesController < ApplicationController
      before_action :set_ai_summary, only: [:show]
      
      def index
        summaries = current_user.ai_summaries.recent
        summaries = summaries.by_type(params[:summary_type]) if params[:summary_type].present?
        summaries = summaries.completed if params[:completed] == 'true'
        
        render json: {
          ai_summaries: summaries.map { |summary| summary_response(summary) }
        }
      end
      
      def show
        render json: {
          ai_summary: summary_response(@ai_summary)
        }
      end
      
      def create
        summary = current_user.ai_summaries.new(ai_summary_params)
        
        if summary.save
          render json: {
            message: 'AI summary created successfully',
            ai_summary: summary_response(summary)
          }, status: :created
        else
          render json: { errors: summary.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def generate
        summary = current_user.ai_summaries.new(
          summary_type: params[:summary_type] || 'daily',
          summary_date: params[:summary_date] || Date.current,
          status: 'pending',
          ai_model: params[:ai_model] || 'gpt-3.5-turbo'
        )
        
        if summary.save
          summary.generate_async!
          render json: {
            message: 'AI summary generation queued',
            ai_summary: summary_response(summary)
          }, status: :accepted
        else
          render json: { errors: summary.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_ai_summary
        @ai_summary = current_user.ai_summaries.find(params[:id])
      end
      
      def ai_summary_params
        params.permit(:summary_type, :summary_date, :content, :ai_model, source_data: {})
      end
      
      def summary_response(summary)
        {
          id: summary.id,
          summary_type: summary.summary_type,
          summary_date: summary.summary_date,
          content: summary.content,
          ai_model: summary.ai_model,
          token_count: summary.token_count,
          status: summary.status,
          created_at: summary.created_at,
          updated_at: summary.updated_at
        }
      end
    end
  end
end
