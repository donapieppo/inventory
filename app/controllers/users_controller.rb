class UsersController < ApplicationController
  def index
    @users = User.order(:surname, :name).all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.syncronize(params[:user][:upn])
    redirect_to users_path
  end
end
