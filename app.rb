require 'sinatra'
require 'erb'
require 'rubygems'
require 'sinatra/activerecord'
require './models/task'
require './models/log'

def new_task(id, name)
<<TASK
<tr id=#{id}>
<td class="col-md-2">
			<select class="btn btn-lg new-added">
				<option val="1" value="#d9534f" selected>IMPORTANT</option>
				<option val="2" value="#428bca">UNIMPORTANT</option>
				<option val="3" value="#f0ad4e">WAITING</option>
				<option val="4" value="#5cb85c">DONE</option>
			</select>
		<td class="col-md-7">	

			<div class="panel panel-default">
				
				<div class="panel-heading toggle-col">
					<a data-toggle="collapse" data-parent="#accordion" href="#">
						<h4 class="panel-title" id="collapse-text">	
							<span class="name">#{name}</span>
							<span class="total-time" style="float:right">0</span>
						</h4>
					</a>
				</div>
				
				<div class="panel-collapse collapse">
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
								<input type="text" class="form-control new-name" style="margin-bottom:20px" value="#{name}" />
							</div>
						</div>

						<div class="row">
							<div class="col-md-2">
								<label for="time-format">start</label><input type="text" id="time-format" title="format: H:M:S" style="min-width:100%" class="input-name start-time">	
							</div>	
							<div class="col-md-2">
								<label for="time-format">end</label><input type="text" id="time-format" title="format: H:M:S" style="min-width:100%" class="input-name end-time">
							</div>
							<div class="col-md-2">
								<label for="date">date</label><input type="text" style="min-width:100%" class="input-name date">
								<script>$('.date').datepicker();</script>
							</div>
							<div class="col-md-1">
								<button type="submit" class="btn btn-lg btn-primary save">
									Add
								</button>						
							</div>
							<div class="col-md-2" style="margin-left:15px">
								<button type="submit" class="btn btn-lg btn-primary rename">
									Rename
								</button>						
							</div>
							<div class="col-md-1">
								<button class="btn btn-info btn-lg" data-toggle="modal" data-target="#logModal#{id}">
									<span class="glyphicon glyphicon glyphicon-list" ></span>
								</button>
								<div class="modal fade" id="logModal#{id}" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
									<div class="modal-dialog">
										<div class="modal-content">
											<div class="modal-header round">
												<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
												<h4 class="modal-title" id="myModalLabel">Time spent on task</h4>
											</div>
											<div class="modal-body">
												<table class="table" id="table-log">
							
												</table>
											</div>
										</div>
									</div>
								</div>
							</div>
							<div class="col-md-1">
								<button type="submit" data-toggle="collapse" class="btn btn-lg btn-danger delete">
									<span class="glyphicon glyphicon-remove"></span>
								</button>
							</div>
						</div>
					</div>
				</div>
			</div>
		</td>

		<td class="col-md-2"><span class="time-position">0</span></td>
		<td class="col-md-2">
			<button type="submit" class="btn btn-lg btn-default start">
				<span class="glyphicon glyphicon-play" ></span>
				<span class="glyphicon glyphicon-pause" ></span>
			</button>
		</td>
</tr>
TASK
end

def new_log(st,en,time,log_id)
<<LOG
	<tr id=#{log_id}>
		<td>#{st}</td>
		<td>#{en}</td>
		<td>#{time}</td>
		<td><button class="log-del delete-log">
		<span class="glyphicon glyphicon-remove"></span></button></td>
	</tr>
LOG
end

helpers do
    def time_total(id)
    	@logs = Log.all.where(task_id: id)
    	time = 0
    	@logs.each do |item|
    		time = time + item.task_time
    	end
    	write_right(time)
    end

    def write_right(time)
    	if time < 60
    		time
    	elsif time < 3600
    		(time/60).floor.to_s + ":" + (time%60).to_s
    	elsif time < 86400 
    		(time/3600).floor.to_s + ":" + ((time%3600)/60).floor.to_s + ":" + (time%60).to_s
    	else 
    		(time/86400).floor.to_s + "day(s) - " + ((time%86400)/3600).floor.to_s + ":" + ((time%3600)/60).floor.to_s + ":" + (time%60).to_s
    	end
    end
end


get '/tasks' do
	@tasks = Task.all.order(:status).order(:name)
	@logs = Log.all
	erb :tasks
end

post '/add' do
	name = params[:name]
	@task = Task.new(:name => name,
					 :status => 1,
					 :total_time => 0,
					 )
	@task.save
	new_task(@task.id, name)
end

post '/add-log' do
	start_time = params[:start_time]
	end_time = params[:end_time]
	date = params[:date]

		date_data = date.split('/')
		date_data.each_with_index do |item, i|
			date_data[i] = item.sub(/^[0]/,"")
		end

		time_data_start = start_time.split(':')
		time_data_start.each_with_index do |item, i|
			time_data_start[i] = item.sub(/^[0]/,"")
		end

		time_data_end = end_time.split(':')
		time_data_end.each_with_index do |item, i|
			time_data_end[i] = item.sub(/^[0]/,"")
		end

		start_total = time_data_start[0].to_i*3600 + time_data_start[1].to_i*60 + time_data_start[2].to_i
    	end_total = time_data_end[0].to_i*3600 + time_data_end[1].to_i*60 + time_data_end[2].to_i

    	if end_total > start_total
    		total = end_total - start_total
    	else 
    		total = end_total - start_total + 86400
    	end

		st = Time.new(date_data[2], date_data[0], date_data[1], time_data_start[0].to_i, time_data_start[1].to_i, time_data_start[2].to_i).to_s
		en = Time.new(date_data[2], date_data[0], date_data[1], time_data_end[0].to_i, time_data_end[1].to_i, time_data_end[2].to_i).to_s

		@log = Log.new(:start_time => st,
					   :end_time => en,
					   :task_time => total,
					   :task_id => params[:id]
					   )
		@log.save

		new_log(st,en,total,@log.id)

end

delete '/delete' do
	@task = Task.find(params[:id])
	@logs = Log.all.where(task_id: params[:id])
	@logs.each do |log| 
		log.destroy
	end
	@task.destroy
end

delete '/delete-log' do
	@log = Log.find(params[:id])
	@log.destroy
	time_total(params[:task_id]).to_s
end

post '/retime' do
	time_total(params[:id]).to_s
end

post '/log' do
	if params[:clocktoggle] == "0"
		Time.now.to_s
	elsif params[:clocktoggle] == "1"
		end_time = Time.now.to_s
		@log = Log.new(:start_time => params[:stime],
				   	   :end_time => end_time,
				   	   :task_time => params[:clocked],
				  	   :task_id => params[:id]
				  	   )
		@log.save
		new_log(params[:stime],end_time,params[:clocked],@log.id)
	end
end

put '/rename' do
	@task = Task.find(params[:id])
	@task.name = params[:name]
	@task.save
end

put '/status' do
	@task = Task.find(params[:id])
	@task.status = params[:value]
	@task.save
end
