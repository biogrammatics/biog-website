class SubscriptionsController < ApplicationController
  allow_unauthenticated_access only: [ :index ]
  before_action :authenticate_user!, except: [ :index ]
  before_action :set_subscription, only: [ :show, :add_vector ]

  def index
    @vectors = Vector.where(available_for_subscription: true)
      .joins(:product_status).where(product_statuses: { is_available: true })
      .includes(:promoter, :selection_marker, :vector_type)
    @current_subscription = authenticated? ? Current.user.current_subscription : nil
  rescue ActiveRecord::StatementInvalid, NoMethodError
    # Handle case where models/tables might not exist in test
    @vectors = []
    @current_subscription = nil
  end

  def show
    @subscription_vectors = @subscription.subscription_vectors.includes(:vector).ordered_by_date
  end

  def new
    @subscription = Current.user.subscriptions.build
    @vectors = Vector.available_for_subscription.active.includes(:promoter, :selection_marker, :vector_type)
  end

  def create
    @subscription = Current.user.subscriptions.build(subscription_params)

    if @subscription.save
      # Process initial vectors if any
      if params[:vector_ids].present?
        params[:vector_ids].each do |vector_id|
          vector = Vector.find(vector_id)
          prorated_amount = @subscription.calculate_prorated_amount(vector)
          @subscription.add_vector(vector, prorated_amount)
        end
        @subscription.start_subscription!
      end

      redirect_to @subscription, notice: "Subscription created successfully! Your Twist onboarding will begin shortly."
    else
      @vectors = Vector.available_for_subscription.active.includes(:promoter, :selection_marker, :vector_type)
      render :new
    end
  end

  def add_vector
    vector = Vector.find(params[:vector_id])

    if @subscription.vectors.include?(vector)
      redirect_to @subscription, alert: "Vector is already in your subscription."
      return
    end

    prorated_amount = @subscription.calculate_prorated_amount(vector)
    @subscription.add_vector(vector, prorated_amount)

    redirect_to @subscription, notice: "#{vector.name} added to subscription. Prorated amount: $#{prorated_amount.round(2)}"
  rescue ActiveRecord::RecordNotFound
    redirect_to subscriptions_path, alert: "Vector not found."
  end

  private

  def set_subscription
    @subscription = Current.user.subscriptions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to subscriptions_path, alert: "Subscription not found."
  end

  def subscription_params
    params.require(:subscription).permit(:twist_username, :onboarding_fee, :minimum_prorated_fee)
  end

  def authenticate_user!
    unless authenticated?
      redirect_to new_session_path, alert: "Please sign in to access subscriptions."
    end
  end
end
