module Api
  module V1
    class SchedulerJobsController < ApplicationController
      before_action :set_scheduler_job, only: [:show, :update, :destroy, :run_now, :enable, :disable]
      
      def index
        jobs = current_user.scheduler_jobs
        jobs = jobs.enabled if params[:enabled] == 'true'
        jobs = jobs.by_type(params[:job_type]) if params[:job_type].present?
        
        render json: {
          scheduler_jobs: jobs.map { |job| job_response(job) }
        }
      end
      
      def show
        render json: {
          scheduler_job: job_response(@scheduler_job)
        }
      end
      
      def create
        job = current_user.scheduler_jobs.new(scheduler_job_params)
        
        if job.save
          render json: {
            message: 'Scheduler job created successfully',
            scheduler_job: job_response(job)
          }, status: :created
        else
          render json: { errors: job.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def update
        if @scheduler_job.update(scheduler_job_params)
          render json: {
            message: 'Scheduler job updated successfully',
            scheduler_job: job_response(@scheduler_job)
          }
        else
          render json: { errors: @scheduler_job.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        @scheduler_job.destroy
        render json: { message: 'Scheduler job deleted successfully' }
      end
      
      def run_now
        @scheduler_job.run_now!
        render json: {
          message: 'Job queued for execution',
          scheduler_job: job_response(@scheduler_job)
        }
      end
      
      def enable
        @scheduler_job.enable!
        render json: {
          message: 'Job enabled successfully',
          scheduler_job: job_response(@scheduler_job)
        }
      end
      
      def disable
        @scheduler_job.disable!
        render json: {
          message: 'Job disabled successfully',
          scheduler_job: job_response(@scheduler_job)
        }
      end
      
      private
      
      def set_scheduler_job
        @scheduler_job = current_user.scheduler_jobs.find(params[:id])
      end
      
      def scheduler_job_params
        params.permit(:name, :job_type, :schedule, :enabled, job_parameters: {})
      end
      
      def job_response(job)
        {
          id: job.id,
          name: job.name,
          job_type: job.job_type,
          schedule: job.schedule,
          job_parameters: job.job_parameters,
          enabled: job.enabled,
          last_run_at: job.last_run_at,
          next_run_at: job.next_run_at,
          last_status: job.last_status,
          last_error: job.last_error,
          created_at: job.created_at,
          updated_at: job.updated_at
        }
      end
    end
  end
end
