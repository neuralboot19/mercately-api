module Api::V1
  class TemplateSerializer
    include FastJsonapi::ObjectSerializer

    set_type :template
    set_id :id

    attributes :id, :title, :answer
  end
end
