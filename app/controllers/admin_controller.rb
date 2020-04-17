class AdminController < ApplicationController
  before_action :authenticate_me
  def index
  end

  def cv
    render :layout=>nil
  end

  def database
    if !params[:input].nil?
      @result=query(params[:input])
    end
  end

  def todo
  end
  private
    def authenticate_me
      if !@isadmin
        render(file: "#{Rails.root}/public/404.html",status: 404,:layout=>false)
      end
    end
end
