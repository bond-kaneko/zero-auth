# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = ['--display-cop-names']
  end

  namespace :rubocop do
    desc 'Run RuboCop with auto-correct'
    RuboCop::RakeTask.new(:auto_correct) do |task|
      task.options = ['--auto-correct-all']
    end
  end
end
