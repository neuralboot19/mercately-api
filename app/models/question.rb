class Question < ApplicationRecord
  include WebIdGenerateableConcern

  default_scope -> { where('questions.product_id IS NOT NULL') }
  belongs_to :product
  belongs_to :customer

  after_update :ml_answer_question, if: :answered?
  before_save :set_answered, if: :will_save_change_to_answer?
  after_create :generate_web_id

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }

  enum status: %i[ANSWERED UNANSWERED CLOSED_UNANSWERED UNDER_REVIEW BANNED DELETED]
  enum answer_status: %i[ACTIVE DISABLED BANNED DELETED], _prefix: true
  enum meli_question_type: %w[from_order from_product]

  delegate :retailer, to: :product

  def self.check_unique_question_meli_id(question_meli_id)
    Question.exists?(meli_id: question_meli_id.to_s)
  end

  def to_param
    web_id
  end

  def product
    @product ||= super
    @product ||= Product.unscoped.find_by(id: product_id)
  end

  private

    def ml_answer_question
      MercadoLibre::Questions.new(product.retailer).answer_question(self)
    end

    def set_answered
      self.answered = true if answer.present?
    end
end
