#new
get '/authenticated/mac_addresses/new' do
	@title = "NEW MAC ADDRESS"
	@mac_address ||= MacAddress.new
	erb :mac_address_form
end

#index
get '/authenticated/mac_addresses' do
	@title = "MAC ADDRESSES"
	@mac_addresses = MacAddress.all(:mac_address => true, :order => [:username.asc])
	erb :mac_addresses
end

#show
get '/authenticated/mac_addresses/:id' do
	@mac_address = MacAddress.get(params[:id])
	if !@mac_address
		flash[:error] = "MAC Address not found"
		redirect '/authenticated/mac_addresses'
	else
		@download_total = Accounting.new(:acctoutputoctets => Accounting.sum(:acctoutputoctets, :username => @mac_address.username.gsub(/:/, "-").downcase)).download
		@history = History.all(:username => @mac_address.username.gsub(/:/, "-"), :order => [:authdate.desc], :limit => 10)
		@accounting = Accounting.all(:username => @mac_address.username.gsub(/:/, "-").downcase, :order => [:acctstarttime.desc], :limit => 30) #get all the recent accounting logs
		erb :mac_address_show
	end
end

#create
post '/authenticated/mac_addresses' do
	@mac_address = MacAddress.new(params)
	@mac_address.created_by = session[:username]
	if @mac_address.save
		flash[:notice] = "MAC Address successfully created"
		redirect "/authenticated/mac_addresses/#{@mac_address.id}"
	else
		@title = "NEW MAC ADDRESS"
		erb :mac_address_form
	end
end

#edit
get '/authenticated/mac_addresses/:id/edit' do
	@title = "EDIT MAC ADDRESS"
	@mac_address = MacAddress.get(params[:id])
	if !@mac_address
		flash[:error] = "MAC Address not found"
		redirect '/authenticated/mac_addresses'
	end
	erb :mac_address_form
end

#update
post '/authenticated/mac_addresses/edit' do
	@mac_address = MacAddress.get(params[:id])
	if @mac_address.update(params)
		flash[:notice] = "MAC Address successfully updated"
		redirect "/authenticated/mac_addresses/#{@mac_address.id}"
	else
		@title = "EDIT MAC ADDRESS"
		erb :mac_address_form
	end
end

#destroy
delete '/authenticated/mac_addresses/:id' do
	@mac_address = MacAddress.get(params[:id])
	if @mac_address && @mac_address.destroy
		flash[:notice] = "Successfully deleted MAC Address #{@mac_address.username}"
	else
		flash[:error] = "Deletetion of MAC Address unsuccessful."
	end
	status 200
end
