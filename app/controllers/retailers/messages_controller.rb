class Retailers::MessagesController < RetailersController
  before_action :set_question, only: [:show, :answer_question]

  # GET /messages
  def index
    @questions = Question.includes(:product).where(products: { retailer_id: current_retailer.id })
      .order(created_at: 'DESC').page(params[:page])
  end

  # GET /messages/1
  def show
  end

  def answer_question
    @question.update!(answer: params[:answer])
    redirect_to retailers_messages_path(@retailer), notice: 'Respuesta enviada'
  end

  private

    def set_question
      @question = Question.find(params[:id])
    end
end
