ActiveAdmin.register StripeTransaction do
  actions :all, except: %i[edit update destroy]
  menu parent: 'Transacciones'
end
