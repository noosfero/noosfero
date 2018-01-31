class PushSubscriptionsController < PublicController

  before_action :accept_only_post, :only => :create

  def create
    return head :unauthorized unless current_person.present?

    endpoint = subscription_params[:endpoint]
    subscription = current_person.push_subscriptions
                                 .find_or_initialize_by(endpoint: endpoint)
    subscription.keys = subscription_params[:keys]

    if subscription.save
      head :ok
    else
      head :bad_request
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:endpoint, keys: [:auth, :p256dh])
  end

end
