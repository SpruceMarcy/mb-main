class AdminController < ApplicationController
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
end
