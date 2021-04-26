class ContactGroupCustomer < ApplicationRecord
  belongs_to :contact_group
  belongs_to :customer

  after_commit :send_for_opt_in, on: :create

  private

    def send_for_opt_in
      customer.send_for_opt_in = true
      customer.save
    end
end
