module Api::V1
  class AdditionalFastAnswerSerializer
    include FastJsonapi::ObjectSerializer

    set_type :additional_fast_answer
    set_id :id

    attributes :id, :answer, :file_type

    attribute :file_url do |afa|
      next unless afa.file.attached?

      afa.file_url
    end

    attribute :file_name do |afa|
      next unless afa.file.attached?

      afa.file.filename.to_s
    end
  end
end
