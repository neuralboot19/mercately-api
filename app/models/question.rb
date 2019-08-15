class Question < ApplicationRecord
  default_scope -> { where('questions.product_id IS NOT NULL') }
  belongs_to :product
  belongs_to :customer

  after_update :ml_answer_question, if: :saved_change_to_answer?

  enum status: %i[ANSWERED UNANSWERED CLOSED_UNANSWERED UNDER_REVIEW]
  enum answer_status: %i[ACTIVE DISABLED]
  enum meli_question_type: %w[from_order from_product]

  delegate :retailer, to: :product

  def self.check_unique_question_id(question_meli_id)
    Question.any? { |q| q.meli_id == question_meli_id.to_s }
  end

  private

    def ml_answer_question
      MercadoLibre::Questions.new(product.retailer).answer_question(self)
    end
end
