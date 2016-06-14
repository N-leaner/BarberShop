#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do	
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	@e_holder = "e-mail"
	@mess = "Вы можете оставить нам сообщение:"
	erb :contacts
end

get '/send_done' do	
	erb :send_done
end

def w_to_f arr
	output = File.open './public/users.txt', 'a'
	output.write "user: #{arr[0]}, tel: #{arr[1]},"+
	" date: #{arr[2]}, time: #{arr[3]}, master: #{arr[4]}, color: #{arr[5]}\n"
	output.close
end

def w_to_c arr
	output = File.open './public/contacts.txt','a'
	output.write "start=========#{arr[0]}==============\n"
	output.write "#{arr[1]}\n"
	output.write "end===========#{arr[0]}==============\n"
	output.close
end	


post '/visit' do
	@user_name = params[:username].strip.capitalize
	@user_phone = params[:user_telephone].strip
	@date_visit = params[:date_].strip
	@time_visit = params[:time_].strip
	@color 		= params[:color].strip
	@master = params[:master].strip

	hh_ver = {:username => 'Не указано имя',
			:master => 'Не указан мастер',
			:date_ => 'Не указана дата',
			:time_ => 'Не указано время'}

=begin
	@error = ''
	hh_ver.each do |key, value|	
		if params[key].strip == ''
			@error = value	
			break
		end	
	end	
=end #вариант ниже - круче
	@error = hh_ver.select {|key,_| params[key] == ''}.values.join(", ")

	if @error == ''		
		arr = []
		arr << @user_name
		arr << @user_phone
		arr << @date_visit
		arr << @time_visit
		arr << @master
		arr << @color
		w_to_f arr
		if @user_phone != ''
			@reminder = "Мы перезвоним Вам по номеру: #{@user_phone}, \nчтобы напомнить о визите"
			#erb "Мы перезвоним Вам по номеру: #{@user_phone}, \nчтобы напомнить о визите"# или можно так			
		end	
		erb :visit_done
	else
		erb :visit					
	end
end	

post '/contacts' do
	@e_mail = params[:email].strip
	@e_message = params[:text].strip
	if @e_mail == ''
		@e_holder = "Не указан e-mail"		
		erb :contacts
	elsif @e_message == ''		
		@mess = "Напишите хоть что-нибудь.."	
		erb :contacts
	else
		@mess = "Сообщение отправлено успешно"			
		arr = []
		arr << @e_mail
		arr << @e_message
		w_to_c arr
		send_mess arr
		@e_mail=''
		redirect '/send_done'
	end	
	
end	

def send_mess adr
Pony.mail(
  :from => 'admin@site.com.ua',
  :body => "from #{adr[0]}:\n"+adr[1],
  :to => 'admin@site.com.ua',
  :subject => 'Barber',  
  :via => :smtp,
  :via_options => { 
    :address              => 'site.com.ua', 
    :port                 => '587', 
    :charset   			  => 'utf-8',
    :enable_starttls_auto => false, 
    :user_name            => 'admin', 
    :password             => 'mypassword', 
    :authentication       => :login, 
    :domain               => 'localhost.localdomain'
  })
end	