class CreateSchedulerJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :scheduler_jobs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :job_type, null: false  # 'daily_summary', 'crypto_check', 'calendar_sync', etc.
      t.string :schedule, null: false  # cron format: '0 8 * * *'
      t.json :job_parameters
      t.boolean :enabled, default: true
      t.datetime :last_run_at
      t.datetime :next_run_at
      t.string :last_status  # 'success', 'failed', 'running'
      t.text :last_error
      
      t.timestamps
    end
    
    add_index :scheduler_jobs, [:user_id, :enabled]
    add_index :scheduler_jobs, :next_run_at
    add_index :scheduler_jobs, :job_type
  end
end
