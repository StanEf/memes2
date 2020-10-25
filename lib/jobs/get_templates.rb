module Jobs
  class GetTemplates
    include Delayed::RecurringJob

    run_every 1.day
    run_at '01:00am'

    def perform
      Meme::Api::GetTemplates.new.call(Imgflip.get_memes)
    end
  end
end