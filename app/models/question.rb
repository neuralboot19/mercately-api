class Question < ApplicationRecord
  belongs_to :product
  belongs_to :customer

  after_update :ml_answer_question, if: :saved_change_to_answer?

  delegate :retailer, to: :product

  private

    def ml_answer_question
      MercadoLibre::Questions.new(product.retailer).answer_question(self)
    end
end
