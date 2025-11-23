class SchedulerJobWorker
  include Sidekiq::Job
  
  def perform(scheduler_job_id)
    job = SchedulerJob.find(scheduler_job_id)
    job.mark_as_running!
    
    begin
      case job.job_type
      when 'daily_summary'
        execute_daily_summary(job)
      when 'crypto_check'
        execute_crypto_check(job)
      when 'calendar_sync'
        execute_calendar_sync(job)
      when 'email_digest'
        execute_email_digest(job)
      when 'alert_check'
        execute_alert_check(job)
      else
        raise "Unknown job type: #{job.job_type}"
      end
      
      job.mark_as_success!
    rescue => e
      job.mark_as_failed!(e.message)
      raise e
    end
  end
  
  private
  
  def execute_daily_summary(job)
    AiSummaryGeneratorService.generate_daily_summary(
      user: job.user,
      parameters: job.job_parameters
    )
  end
  
  def execute_crypto_check(job)
    CryptoAlertService.check_prices(
      user: job.user,
      parameters: job.job_parameters
    )
  end
  
  def execute_calendar_sync(job)
    GoogleCalendarService.sync_events(
      user: job.user,
      parameters: job.job_parameters
    )
  end
  
  def execute_email_digest(job)
    EmailDigestService.generate_digest(
      user: job.user,
      parameters: job.job_parameters
    )
  end
  
  def execute_alert_check(job)
    AlertCheckService.check_and_notify(
      user: job.user,
      parameters: job.job_parameters
    )
  end
end
