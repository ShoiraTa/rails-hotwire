class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]

  # GET /messages or /messages.json
  def index
    @messages = Message.order(created_at: :desc)
  end

  # GET /messages/1 or /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
    respond_to do |format|
      format.turbo_stream do 
        render turbo_stream: turbo_stream.update(@message, partial: "messages/form", locals: {message:@message})
      end
    end
  end

  # POST /messages or /messages.json
  def create
    @message = Message.new(message_params)

    respond_to do |format|
    if @message.save
      format.turbo_stream do 
        render turbo_stream: [
          turbo_stream.update('new_message', partial:'messages/form', locals: {message: Message.new}),
          turbo_stream.prepend('messages', partial:'messages/message', locals: {message: @message})
        ]
      end
      else
        format.turbo_stream do 
          render turbo_stream: [
            turbo_stream.update('new_message', partial:'messages/form', locals: {message: @message})
          ]
      end
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.turbo_stream do 
          render turbo_stream: turbo_stream.update(@message, partial: "messages/message", locals: {message:@message})
        end
      else
        format.turbo_stream do 
          render turbo_stream: turbo_stream.update(@message, partial: "messages/form", locals: {message:message})
        end
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy

    respond_to do |format|
      format.turbo_stream  {render turbo_stream: turbo_stream.remove(@message)}
      # format.turbo_stream  {render turbo_stream: turbo_stream.remove("message_#{message.id}")}
      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:body)
    end
end
