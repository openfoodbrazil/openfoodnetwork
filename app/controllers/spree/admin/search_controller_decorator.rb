Spree::Admin::SearchController.class_eval do
  def known_users
    @users = if exact_match = Spree.user_class.find_by(email: params[:q])
               [exact_match]
             else
               spree_current_user.known_users.ransack(
                 m: 'or',
                 email_start: params[:q],
                 ship_address_firstname_start: params[:q],
                 ship_address_lastname_start: params[:q],
                 bill_address_firstname_start: params[:q],
                 bill_address_lastname_start: params[:q]
               ).result.limit(10)
             end

    render json: @users, each_serializer: Api::Admin::UserSerializer
  end

  def customers
    @customers = if spree_current_user.enterprises.pluck(:id).include? params[:distributor_id].to_i
                   Customer.ransack(m: 'or', email_start: params[:q], name_start: params[:q])
                     .result.where(enterprise_id: params[:distributor_id])
                 else
                   []
                 end

    render json: @customers, each_serializer: Api::Admin::CustomerSerializer
  end

  def users_with_ams
    users_without_ams
    render json: @users, each_serializer: Api::Admin::UserSerializer
  end

  alias_method_chain :users, :ams
end
