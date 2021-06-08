module WebIdGenerateableConcern
  extend ActiveSupport::Concern

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def generate_web_id(retailer, id = nil)
      set_web_id(retailer, id)
    end

    def set_web_id(retailer, id = nil)
      retailer.id.to_s + ('a'..'z').to_a.sample(5).join + id.to_s
    end
  end

  private

    def generate_web_id
      update web_id: self.class.set_web_id(self.retailer, self.id)
    end

    def generate_funnel_web_id
      update web_id: self.class.set_web_id(self.funnel.retailer, self.id)
    end
end
