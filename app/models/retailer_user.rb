class RetailerUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :retailer

  validates :agree_terms, presence: true
  after_create :send_welcome_email

  accepts_nested_attributes_for :retailer

  protected

    # Send email after create
    def send_welcome_email
      # TODO: change this to a proper email
      PageMailer.welcome(self).deliver_now if persisted?
    end
end
