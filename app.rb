require 'sinatra'
require 'urbanairship'
require './api_keys'

UA = Urbanairship

get '/' do
  send_file 'index.html'
end

post '/' do
  message = params[:message]
  device_id = params[:device_id]
  time_delay = params[:time_delay]

  push = build_push(message, device_id)
  if time_delay.empty?
    push.send_push
  else
    schedule_push(push, time_delay.to_i)
  end
  
  send_file 'index.html'
end

def build_push(message, device_id)
  airship = UA::Client.new(key: APP_KEY, secret: MASTER_SECRET)
  push = airship.create_push
  push.device_types = UA.all  
  push.notification = UA.notification(alert: message)  
  if device_id
    push.audience = UA.device_token(device_id)
  end

  push
end

def schedule_push(push, time_delay)
  airship = UA::Client.new(key: APP_KEY, secret: MASTER_SECRET)

  schedule = airship.create_scheduled_push
  schedule.push = push
  schedule.name = "optional name for later reference"
  schedule.schedule = UA.local_scheduled_time(Time.now + time_delay)
  response = schedule.send_push

  puts ("Created schedule. url: " + response.schedule_url)
end