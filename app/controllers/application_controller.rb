require 'date'
class ApplicationController < ActionController::Base
  skip_forgery_protection
  before_action :before
  private

  def before
    adminuid=ENV["master_name"]
    @adminuid=ENV["master_name"]
    today=Date.today
    if today==Date.new(2020,3,31)
      @seasonal_style="tdov"
      @seasonal_text="It's Transgender Day of Visibility 2020!"
    end
  end

  def query(q)
    conndomain=ENV["mdata_dom"]
    connport=ENV["mdata_port"].to_i
    conndata=ENV["mdata_data"]
    connuser=ENV["mdata_user"]
    connpass=ENV["mdata_pass"]
    conn=PG.connect(conndomain, connport,"","",conndata, connuser, connpass)
    returnval = conn.exec(q)
    conn.finish
    return returnval
  end
  def getindex()
    highest=0
    query("SELECT id FROM Blog;").each do |entry|
      testhigh=entry["id"].to_i
      if testhigh>highest
        highest=testhigh
      end
    end
    return highest
  end
end
