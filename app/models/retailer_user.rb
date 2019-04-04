class RetailerUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :retailer

  before_create :agree_terms_to_bool

  validates :agree_terms, presence: true

  accepts_nested_attributes_for :retailer

  protected

    def agree_terms_to_bool
      ActiveModel::Type::Boolean.new.cast(agree_terms)
    end
end
