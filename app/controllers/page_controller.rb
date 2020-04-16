class PageController < ApplicationController
  def index
    @entry=query("SELECT * FROM Blog WHERE id=#{getindex()};")[0]
  end

  def project
  end

  def about
  end

  def contact
    @includerecaptcha=true
  end

  def submitcontact
    responsetoken=params["g-recaptcha-response"]
    if (HTTParty.post('https://www.google.com/recaptcha/api/siteverify',:query => {
      :secret=>ENV["reCAPTCHA_secret"],
      :response=>responsetoken
      })["success"])
    
      message = params[:message]
      if message.strip==""
        redirect "/botfailure" 
      end
      message=params[:browser]+"\n"+message
      msg="From: MB-Main <"+ENV["master_email"]+">\nTo: Marcy Brook <"+ENV["master_email"]+">\nSubject: A Message from a Site Visitor ("+request.ip+").\n\n" + message + "\n\n"
      smtp = Net::SMTP.new 'smtp.gmail.com', 587
      smtp.enable_starttls
      smtp.start('smtp.gmail.com', ENV["master_email"],ENV["master_password"], :login) do
        smtp.send_message(msg, '', ENV["master_email"])
      end
      redirect_to("/")
    else
      redirect_to("/",status: 401)
    end
  end
end
