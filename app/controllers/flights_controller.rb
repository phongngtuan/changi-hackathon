class FlightsController < ApplicationController
  before_action :set_flight, only: [:show, :edit, :update, :destroy]
  include HTTParty

  # GET /flights
  # GET /flights.json
  def index
    Rails.logger.info params
    if params.has_key?('flight_number')
        flight = params['flight_number']
        @flights = Flight.find_by_sql("SELECT * FROM flights
                        WHERE (flights.airlineCode)||(flights.number) = '#{flight}'")
        if @flights.length > 0
            f = @flights[0]
            cookies[:flight_number] =f.airlineCode + f.number
            create_chatbox(f)
        end
        Rails.logger.info "In index"
        Rails.logger.info cookies[:flight_number]

    else
        @flights = Flight.all
    end
  end

  # GET /flights/1 GET /flights/1.json
  def show
    @chat_box = create_chatbox(@flight)
    Rails.logger.info cookies[:flight_id]
    render json: @flight.to_json(:include => {:chat_box => {:include => :comments}})
  end

  # GET /flights/new
  def new
    @flight = Flight.new
  end

  # GET /flights/1/edit
  def edit
  end

  # POST /flights
  # POST /flights.json
  def create
    @flight = Flight.new(flight_params)

    respond_to do |format|
      if @flight.save
        format.html { redirect_to @flight, notice: 'Flight was successfully created.' }
        format.json { render :show, status: :created, location: @flight }
      else
        format.html { render :new }
        format.json { render json: @flight.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flights/1
  # PATCH/PUT /flights/1.json
  def update
    respond_to do |format|
      if @flight.update(flight_params)
        format.html { redirect_to @flight, notice: 'Flight was successfully updated.' }
        format.json { render :show, status: :ok, location: @flight }
      else
        format.html { render :edit }
        format.json { render json: @flight.errors, status: :unprocessable_entity }
      end
    end
  end

  def delay
    Rails.logger.info "Flight ID= " + params["flight_id"]
    Rails.logger.info "Delay time= " + params["delay"]
    @flight=Flight.find(params['flight_id'])
    @flight.delay=params['delay']
    respond_to do |format|
      if @flight.save
        format.json { render :show, status: :created, location: @flight}
      end
    end
  end
  # DELETE /flights/1
  # DELETE /flights/1.json
  def destroy
    @flight.destroy
    respond_to do |format|
      format.html { redirect_to flights_url, notice: 'Flight was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flight
      @flight = Flight.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flight_params
      params.require(:flight).permit(:number, :scheduled, :airlineCode)
    end

    def create_chatbox(flight)
        if flight.chat_box.nil?
            chat_box = flight.create_chat_box({
                :open_time => flight.scheduled - 1.hour,
                :close_time => flight.scheduled
            })
        end
        return chat_box
    end
end
