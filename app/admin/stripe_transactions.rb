ActiveAdmin.register StripeTransaction do
  actions :all, except: %i[edit update destroy]
  menu parent: 'Transacciones'

  controller do
    defaults finder: :find_by_web_id
  end
end
