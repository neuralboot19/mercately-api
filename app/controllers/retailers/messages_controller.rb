class Retailers::MessagesController < RetailersController
  before_action :set_question, only: %i[show answer_question]

  # GET /messages/1
  def show
  end

  def questions
    @questions = Question.includes(:customer, :product).where(meli_question_type: :from_product, answered:
      params[:answered], products:
      {
        retailer_id: current_retailer.id
      }).order('questions.date_read IS NOT NULL, questions.created_at DESC').page(params[:page])
  end

  def chats
    @chats = Order.joins(:messages)
      .where('questions.id IS NOT NULL')
      .order(Message.arel_table['date_read'].desc)
      .includes(:customer)
      .where(customers: { retailer_id: current_retailer.id })

    @chats = @chats.page(params[:page])
  end

  def question
    @question = Question.find(params[:question_id])
    @question.update(date_read: Time.now) if @question.date_read.nil?
  end

  def answer_question
    @question.update!(answer: params[:answer])
    redirect_to retailers_questions_path(@retailer, answered: @question.answered), notice: 'Respuesta enviada'
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

  def facebook_chats
    @chats = current_retailer.customers.includes(:facebook_messages)
      .where.not(facebook_messages: { id: nil }).page(params[:page])
  end

  def facebook_chat
    @customer = Customer.find(params[:id])
    @messages = @customer.facebook_messages.order(:created_at)
  end

  def send_facebook_message
    customer = Customer.find(params[:id])
    FacebookMessage.create(
      customer: customer,
      uid: current_retailer_user.uid,
      id_client: customer.psid,
      facebook_retailer: current_retailer.facebook_retailer,
      text: params[:message],
      sent_from_mercately: true
    )
    redirect_back fallback_location: root_path
  end

  private

    def set_question
      @question = Question.find(params[:id])
    end
end
