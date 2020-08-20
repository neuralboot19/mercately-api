module WebIdGenerateableConcern
  extend ActiveSupport::Concern

  private

    def generate_web_id
      update web_id: retailer.id.to_s + ('a'..'z').to_a.sample(5).join + id.to_s
    end
end
