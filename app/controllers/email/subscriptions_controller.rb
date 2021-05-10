module Email
  class SubscriptionsController < BaseController
    before_action :set_subscription, only: [:show, :edit, :update, :destroy]
    before_action :prepare_form, only: [:new]

    def index
      @subscriptions = Subscription.includes(:reason).page(params[:page])
    end

    def new
      login_by_token(params[:auth_token])

      @subscription = Subscription.new
      @subscription.address = params[:address]
    end

    def create
      account = Account.find current_account.id
      @subscription = account.subscription || account.build_subscription
      @subscription.assign_attributes subscription_params
      @subscription.unsubscribe_at = Time.current

      unless @subscription.save
        render :new, locals: { model: @subscription }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @subscription.assign_attributes(subscription_params)

      unless @subscription.save
        render :edit, locals: { model: @subscription }, status: :unprocessable_entity
      end
    end

    def destroy
      @subscription.destroy
    end

    private
    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    def prepare_form
      @reasons = Reason.all
    end

    def subscription_params
      params.fetch(:subscription, {}).permit(
        :address,
        :state,
        :unsubscribe_at,
        :reason_id
      )
    end

  end
end
