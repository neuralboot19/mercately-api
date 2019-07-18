class Retailers::MessagesController < RetailersController
  before_action :set_question, only: %i[show answer_question]

  # GET /messages
  def index
    @questions = Question.all
  end

  # GET /messages/1
  def show
  end

  def questions
    @questions = Question.includes(:product).where(meli_question_type: params[:meli_question_type],
      products: { retailer_id: current_retailer.id })
      .order(created_at: 'DESC').page(params[:page])
  end

  def chats
    @chats = Message.includes(order: :customer).where(meli_question_type: params[:meli_question_type],
      customers: { retailer_id: current_retailer.id })
      .order(created_at: 'DESC').page(params[:page])
  end

  def answer_question
    @question.update!(answer: params[:answer])
    redirect_to retailers_messages_path(@retailer), notice: 'Respuesta enviada'
  end

  def send_message
    order = Order.find(params[:order_id])
    @message = Message.new(
      order_id: order.id,
      customer_id: order.customer_id,
      answer: params[:answer],
      sender_id: current_retailer_user.id
    )
    MercadoLibre::Messages.new(@retailer).answer_message(@message)
    if @message.save
      redirect_to retailers_order_messages_path(@retailer, order), notice: 'Mensage enviado'
    else
      redirect_to retailers_order_messages_path(@retailer, order), notice: 'No pudo enviarse'
    end
  end

  def chat
    @order = Order.find(params[:order_id])
  end

  private

    def set_question
      @question = Question.find(params[:id])
    end
end
