class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    ActiveRecord::Base.transaction do
      begin
        @user.save!
        Stripe.api_key = ENV["STRIPE_API_KEY"]
        token = params[:stripeToken]
        charge = Stripe::Charge.create(
          amount: 999,
          currency: "usd",
          card: token,
          description: "sign up payment for #{@user.email}"
        )
        UserMailer.delay.welcome_email(@user.id)
        handle_invitation if params[:invitation_token]
        flash[:success] = "Welcome to myFlix, you have successfully registered."
        redirect_to sign_in_url
      rescue ActiveRecord::RecordInvalid
        render :new
      rescue Stripe::CardError => e
        flash[:danger] = e.message
        redirect_to register_url
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

private

  def user_params
    params.require(:user).permit(:email, :password, :fullname)
  end

  def handle_invitation
    invitation = Invitation.find_by(token: params[:invitation_token])
    if invitation
      @user.follow(invitation.sender)
      invitation.sender.follow(@user)
      invitation.update_column(:token, nil)
    end
  end
end