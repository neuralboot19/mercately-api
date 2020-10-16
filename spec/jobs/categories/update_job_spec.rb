require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.describe Categories::UpdateJob, type: :job do
  describe '#perform_in' do
    it 'exec the task' do
      Rails.application.load_tasks

      allow(Rake::Task['update_categories']).to receive(:invoke).and_return(true)
      expect(Rake::Task['update_categories']).to receive(:invoke).with(no_args)

      Categories::UpdateJob.perform_in(2.seconds)
    end
  end
end
