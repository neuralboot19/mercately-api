class Retailers::MessagesController < RetailersController
  before_action :check_ownership, only: %i[show answer_question]
  before_action :set_question, only: %i[show answer_question]

  # GET /messages/1
  def show
  end

  def questions
  end

  def chats
  end

  def question
    @question = Question.joins('INNER JOIN products ON products.id = questions.product_id')
      .where('questions.id = ? AND products.retailer_id = ?', params[:question_id], current_retailer.id)
      .first

    product = @question.product
    url = "http://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/"
    key = product.main_picture_id ? product.images&.find(product.main_picture_id)&.key : product.images&.first&.key
    url += key

    render json: { question: @question, product: product, questions_total: product.questions.count, orders_total:
      product.order_items.count, success_orders_total: product.order_items.includes(:order).where(orders:
      { status: 'success' }).count, earned: product.earned, image: url }

    return unless @question.date_read.nil?

    @question.update(date_read: Time.now)
    ml_helper = MercadoLibreNotificationHelper
    ml_helper.broadcast_data(@retailer, @retailer.retailer_users, 'questions')
  end

  def answer_question
    @question.update!(answer: params[:answer])
    redirect_back fallback_location: root_path, notice: 'Respuesta enviada'
  end

  def facebook_chats
    @chats = if current_retailer_user.only_assigned
               current_retailer_user.a_customers.includes(:facebook_messages)
                 .where.not(facebook_messages: { id: nil }).page(params[:page])
             else
               current_retailer.customers.includes(:facebook_messages)
                 .where.not(facebook_messages: { id: nil }).page(params[:page])
             end
  end

  def facebook_chat
    @customer = Customer.find(params[:id])
    @messages = @customer.facebook_messages.order(:created_at)
  end

  def send_facebook_message
    customer = Customer.find(params[:id])
    FacebookMessage.create(
      customer: customer,
      sender_uid: current_retailer_user.uid,
      id_client: customer.psid,
      facebook_retailer: current_retailer.facebook_retailer,
      text: params[:message],
      sent_from_mercately: true
    )
    redirect_back fallback_location: root_path
  end

  def questions_list
    @questions = Question.joins('INNER JOIN customers ON customers.id = questions.customer_id INNER JOIN products ON products.id = questions.product_id')
      .where('questions.meli_question_type = 1 AND products.retailer_id = ?', current_retailer.id)
      .select('questions.*, customers.first_name, customers.last_name, customers.meli_nickname')
      .order('questions.date_read IS NOT NULL, questions.created_at DESC').page(params[:page])

    render json: { questions: @questions, total: @questions.total_pages }
  end

  private

    def check_ownership
      question = Question.find_by(web_id: params[:id])
      redirect_to retailers_dashboard_path(@retailer) unless question && question.retailer.id == @retailer.id
    end

    def set_question
      @question = Question.find_by(web_id: params[:id])
    end
end
