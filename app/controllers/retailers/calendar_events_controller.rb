class Retailers::CalendarEventsController < RetailersController
  before_action :find_calendar_event, except: %i[index create]
  skip_before_action :verify_authenticity_token, only: :destroy

  # GET /calendar_events
  # GET /calendar_events.json
  def index
    @calendar_events = current_retailer_user.calendar_events
    if params[:start].present? && params[:end].present?
      starts = params[:start].to_date
      ends = params[:end].to_date
      @calendar_events = @calendar_events.where(starts_at: starts.beginning_of_day..ends.end_of_day)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @calendar_events }
    end
  end

  # POST /calendar_events
  # POST /calendar_events.json
  def create
    @calendar_event = current_retailer.calendar_events.new(calendar_event_params)
    @calendar_event.retailer_user_id = current_retailer_user.id

    if @calendar_event.save
      render json: @calendar_event, status: :ok
    else
      render json: @calendar_event.errors, status: :unprocessable_entity
    end
  end

  # PUT /calendar_events/1
  # PUT /calendar_events/1.json
  def update
    if @calendar_event.update(calendar_event_params)
      render status: :ok, json: @calendar_event
    else
      render json: @calendar_event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /calendar_events/1
  # DELETE /calendar_events/1.json
  def destroy
    @calendar_event.destroy

    render json: @calendar_event, status: :ok
  end

  private
    def find_calendar_event
      @calendar_event = CalendarEvent.find_by(web_id: params[:id])
    end

    def calendar_event_params
      params.require(:calendar_event).permit(
        :title,
        :starts_at,
        :ends_at,
        :retailer_user_id,
        :remember,
        :timezone
      )
    end
end
