class UsersController < ApplicationController
  def index
    authorize :user
    @users = User.order(:surname, :name).includes(:adm_users).all
  end

  def show
    @user = User.find(params[:id])
    authorize @user
    @adm_users = @user.adm_users.all
  end

  def new
    authorize :user
    @user = User.new
  end

  def create
    authorize :user
    @user = User.syncronize(params[:user][:upn])
    redirect_to users_path
  end
end
