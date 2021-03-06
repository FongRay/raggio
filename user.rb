#new
get '/authenticated/users/new' do
	@title = "NEW USER ACCOUNT"
	@user ||= User.new
	erb :user_form
end

#index
get '/authenticated/users' do
	@title = "USER ACCOUNTS"
	@users = User.all(:mac_address => false, :order => [:username.asc])
	erb :users
end

#show
get '/authenticated/users/:id' do
	@user = User.get(params[:id])
	@user = User.first(:username => params[:id].gsub(/:/, "-")) unless @user #find the record by the username, since there is no association with History/User/MacAddress models
	if @user && @user.mac_address #if a record is found, and it is a mac address, then redirect to its show page
		redirect "/authenticated/mac_addresses/#{@user.id}"
	end
	if !@user
		flash[:error] = "User not found"
		redirect '/authenticated/users'
	else
		@history = History.all(:username => @user.username, :order => [:authdate.desc], :limit => 10) #find the recent authentication attempts
		@download_total = Accounting.new(:acctoutputoctets => Accounting.sum(:acctoutputoctets, :username => @user.username)).download
		@accounting = Accounting.all(:username => @user.username, :order => [:acctstarttime.desc], :limit => 30) #get all the recent accounting logs
		erb :user_show
	end
end

#create
post '/authenticated/users' do
	@user = User.new(params)
	@user.created_by = session[:username]
	if @user.save
		flash[:notice] = "User successfully created"
		redirect "/authenticated/users/#{@user.id}"
	else
		@title = "NEW USER ACCOUNT"
		erb :user_form
	end
end

#edit
get '/authenticated/users/:id/edit' do
	@title = "EDIT USER"
	@user = User.get(params[:id])
	if !@user
		flash[:error] = "User not found"
		redirect '/authenticated/users'
	end
	erb :user_form
end

#update
post '/authenticated/users/edit' do
	@user = User.get(params[:id])
	if @user.update(params)
		flash[:notice] = "User successfully updated"
		redirect "/authenticated/users/#{@user.id}"
	else
		@title = "EDIT USER"
		erb :user_form
	end
end

#destroy
delete '/authenticated/users/:id' do
	@user = User.get(params[:id])
	if @user && @user.destroy
		flash[:notice] = "Successfully deleted user #{@user.username}"
	else
		flash[:error] = "Deletetion of user unsuccessful."
	end
	status 200 #since we're hitting this with a JS ajax DELETE, return that all is well so that it will redirect on success
end
