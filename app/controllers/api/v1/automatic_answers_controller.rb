class Api::V1::AutomaticAnswersController < Api::ApiController
  include CurrentRetailer
  before_action :set_automatic_answer, only: %i[update destroy]

  # GET /api/v1/automatic_answers
  def index
    messages = current_retailer.automatic_answers.includes(:automatic_answer_days)
      .order(created_at: :desc).page(params[:page]).per(25)

    render status: 200, json: {
      total_pages: messages.total_pages,
      automatic_answers: serialize_messages(messages)
    }
  end

  # POST /api/v1/automatic_answers
  def create
    @automatic_answer = current_retailer.automatic_answers.new(automatic_answer_params)
    @automatic_answer.days = automatic_answer_params[:automatic_answer_days_attributes]

    if @automatic_answer.save
      render status: 201, json: {
        message: 'Mensaje creado con éxito',
        automatic_answer: serialize_messages(@automatic_answer)
      }
    else
      render status: 422, json: { message: @automatic_answer.errors['base'].join(', ') }
    end
  end

  # PUT /api/v1/automatic_answers
  def update
    @automatic_answer.days = automatic_answer_params[:automatic_answer_days_attributes]

    if @automatic_answer.update(automatic_answer_params)
      render status: 200, json: {
        message: 'Mensaje actualizado con éxito',
        automatic_answer: serialize_messages(@automatic_answer)
      }
    else
      render status: 422, json: { message:  @automatic_answer.errors['base'].join(', ') }
    end
  end

  # DELETE /api/v1/automatic_answers
  def destroy
    if @automatic_answer.destroy
      render status: 200, json: {
        message: 'Mensaje eliminado con éxito.',
        automatic_answer: serialize_messages(@automatic_answer)
      }
    else
      render status: 422, json: { message:  @automatic_answer.errors.full_messages.join(', ') }
    end
  end

  private

    def set_automatic_answer
      @automatic_answer = AutomaticAnswer.find_by(id: params[:id]) || not_found
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

    def automatic_answer_params
      params.require(:automatic_answer).permit(
        :message_type,
        :interval,
        :message,
        :whatsapp,
        :messenger,
        :instagram,
        :always_active,
        automatic_answer_days_attributes: [
          :id,
          :day,
          :all_day,
          :start_time,
          :end_time,
          :_destroy
        ]
      )
    end

    def serialize_messages(messages)
      ActiveModelSerializers::SerializableResource.new(
        messages,
        each_serializer: Api::V1::AutomaticAnswerSerializer
      )
    end
end
