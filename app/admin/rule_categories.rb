ActiveAdmin.register RuleCategory do
  actions :all, except: :destroy
  permit_params :name,
                business_rules_attributes: [
                  :id,
                  :name,
                  :description,
                  :identifier,
                  :_destroy
                ]

  index do
    selectable_column
    id_column
    column :name
    column :created_at
    column :updated_at

    actions
  end

  form do |f|
    f.inputs do
      f.input :name

      f.inputs 'Reglas' do
        f.has_many :business_rules, heading: false, allow_destroy: true do |br|
          br.input :name
          br.input :description
          br.input :identifier
        end
      end
    end

    f.actions
  end

  show do
    attributes_table title: 'Detalles de la categoría' do
      row :id
      row :name
      row :created_at
      row :updated_at

      panel 'Reglas de negocio' do
        rules = rule_category.business_rules
        table_for rules do
          column :id
          column :name
          column :description
          column :identifier
          column :created_at
          column :updated_at
        end
      end
    end
  end
end
