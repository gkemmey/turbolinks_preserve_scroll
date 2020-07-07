class EmailsController < ApplicationController
  before_action :set_email, only: [:show, :edit, :update, :destroy]

  def index
    preserve_scroll
    @pagy, @emails = paginates(Email.all)
  end

  def show
  end

  def new
    @email = Email.new
  end

  def edit
  end

  def create
    @email = Email.new(email_params)

    respond_to do |format|
      if @email.save
        format.html { redirect_to @email, notice: 'Email was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @email.update(email_params)
        format.html { redirect_to @email, notice: 'Email was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @email.destroy

    respond_to do |format|
      format.html { redirect_to emails_url, notice: 'Email was successfully destroyed.' }
    end
  end

  private

    def set_email
      @email = Email.find(params[:id])
    end

    def email_params
      params.require(:email).permit(:subject, :message)
    end
end
