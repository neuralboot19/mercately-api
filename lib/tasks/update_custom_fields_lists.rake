namespace :update_custom_fields do
  task lists: :environment do
    CustomerRelatedField.all.where(field_type: :list).each do |crf|
      list = crf.list_options
      next unless list.present?
      next unless list.first.key.blank?

      array_list = []
      crf.read_attribute(:list_options).each do |l|
        array_list << {
          key: l,
          value: l
        }
      end

      crf.update_column(:list_options, array_list)
    end
  end
end
