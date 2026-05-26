class AccountSharesController < ApplicationController
  def show
  end

  def create
    current_user.regenerate_share!(password: params[:password])
    flash[:share_url]      = share_url(current_user.share_token)
    flash[:share_password] = params[:password]
    redirect_to account_share_path
  rescue ActiveRecord::RecordInvalid
    redirect_to account_share_path,
                alert: "Le mot de passe doit faire au moins 12 caractères."
  end

  def destroy
    current_user.revoke_share!
    redirect_to account_share_path, notice: "Lien de partage révoqué."
  end
end
