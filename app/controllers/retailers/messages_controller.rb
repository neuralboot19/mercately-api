class Retailers::MessagesController < RetailersController
  before_action :set_question, only: %i[show answer_question]

  # GET /messages/1
  def show
  end

  def questions
    @questions = Question.includes(:product).where(meli_question_type: :from_product, products:
      {
        retailer_id: current_retailer.id
      }).order(date_read: 'DESC', created_at: 'DESC')

    @questions = Question.order_questions(@questions)
    @questions = Kaminari.paginate_array(@questions).page(params[:page]).per(Question::PER_PAGE)
  end

  def chats
    @chats = Order.includes(:customer, :messages)
      .where(customers:
      {
        retailer_id: current_retailer.id
      }).order(created_at: 'DESC')

    @chats = @chats.where('questions.order_id = orders.id')
    @chats = Message.order_messages(@chats)
    @chats = Kaminari.paginate_array(@chats).page(params[:page]).per(Message::PER_PAGE)
  end

  def question
    @question = Question.find(params[:question_id])
    @question.update(date_read: Time.now) if @question.date_read.nil?
  end

  def answer_question
    @question.update!(answer: params[:answer])
    redirect_to retailers_questions_path(@retailer), notice: 'Respuesta enviada'
  end

  def send_message
    order = Order.find(params[:order_id])
    @message = Message.new(
      order_id: order.id,
      customer_id: order.customer_id,
      answer: params[:answer],
      sender_id: current_retailer_user.id,
      meli_question_type: Question.meli_question_types[:from_order]
    )
    msg = MercadoLibre::Messages.new(@retailer).answer_message(@message)
    @message.meli_id = msg[0]&.[]('message_id')
    if @message.save
      redirect_to retailers_order_messages_path(@retailer, order), notice: 'Mensage enviado'
    else
      redirect_to retailers_order_messages_path(@retailer, order), notice: 'No pudo enviarse'
    end
  end

  def chat
    @return_to = params[:return_to]
    @order = Order.find(params[:order_id])
    @order.messages.where(date_read: nil, answer: nil).update_all(date_read: Time.now)
  end

  private

    def set_question
      @question = Question.find(params[:id])
    end
end
