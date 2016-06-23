#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def get_db
	db=SQLite3::Database.new 'barber.db'
	db.results_as_hash = true
	return db
end

def is_barber_exists? db, name
	db.execute('select name from Barbers where name=?',[name]).size > 0
end

def get_barbers
	db = get_db
	return db.execute 'select name from Barbers order by name'
end	

def create_users db
	db.execute 'CREATE TABLE IF NOT EXISTS
	"Users" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 
	"username" VARCHAR, 
	"phone" VARCHAR, 
	"datestamp" VARCHAR, 
	"barber" VARCHAR, 
	"color" VARCHAR
	);'
end	

def create_masters db
	db.execute 'CREATE TABLE IF NOT EXISTS
	"Barbers" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 
	"name" VARCHAR
	);'

	arr = ['Walter White','Jessie Pinkman','Gus Fring', 'Barbara Brylska']  
   	arr.each do |name_|
   		if !is_barber_exists? db, name_
			db.execute 'insert into Barbers (name) values (?)', [name_]
		end
	end
end

configure do
	db = get_db	
	create_users db
	create_masters db
end	

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do	
	erb :about
end

get '/visit' do
	@result = get_barbers
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

get '/showusers' do
	db = get_db	
	@result = db.execute 'select * from Users order by Id desc'
	erb :showusers
end	

def w_to_f arr
	output = File.open './public/users.txt', 'a'
	output.write "user: #{arr[0]}, tel: #{arr[1]},"+
	" date-time: #{arr[2]}, master: #{arr[3]}, color: #{arr[4]}\n"
	output.close
end

def w_to_b arr
	db = get_db
	db.execute 'insert into Users 
	(
		username,
		phone,
		datestamp,
		barber,
		color
	)
	values
	(?, ?, ?, ?, ?)', [arr[0], arr[1], arr[2], arr[3], arr[4]]
end	

def w_to_c arr
	output = File.open './public/contacts.txt','a'
	output.write "start=========#{arr[0]}==============\n"
	output.write "#{arr[1]}\n"
	output.write "end===========#{arr[0]}==============\n"
	output.close
end	


post '/visit' do	
	@result = get_barbers
	@user_name = params[:username].strip.capitalize
	@user_phone = params[:user_telephone].strip
	@date_visit = params[:date_].strip	
	@color 		= params[:color].strip
	@master = params[:master].strip

	hh_ver = {:username => 'Не указано имя',
			:master => 'Не указан мастер',
			:date_ => 'Не указана дата'}

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
		arr << @master
		arr << @color
		w_to_f arr
		w_to_b arr
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