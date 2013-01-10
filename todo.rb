#!/usr/bin/env ruby
#Ruby to-do list.
# Author : Chris Caruso

# Future features:
# 1. Add duration and comments section to database.
# 2. Add additional coloring/status for tasks that are overdue or weren't done.
# 3. Display only current day in list, with ability to view previous days as well. Future too?
# 4. Clean up formatting.
# 5. Add some sort of show/hide comments in home display.
# 6. Ability to note amount of time spent on each task if desired...pomodoro count?
# 7. Rating of quality of task performance?
# 8. Add ability to shift position of items in list

require 'sinatra'
require 'data_mapper'
require 'haml'

#database setup
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required=>true
	property :status, Enum[ :new, :done, :slack], :default=> :new
	property :created_at, DateTime
	property :updated_at, DateTime
end

def flip_status
end
	

DataMapper.finalize.auto_upgrade!

get '/' do
	@notes = Note.all :order=>:id.desc
	@title = 'All Notes'
	haml :home
end

post '/' do
	n = Note.new
	n.content = params[:content]
	n.created_at = Time.now
	n.updated_at = Time.now
	n.save
	redirect '/'
end

get '/:id' do
	@note = Note.get params[:id]
	@title = "Edit note ##{params[:id]}"
	haml :edit
end

put '/:id' do
	n = Note.get params[:id]
	n.content = params[:content]
	n.status = params[:status] ? :done : :new
	n.updated_at = Time.now
	n.save
	redirect '/'
end

get '/:id/delete' do
	@note = Note.get params[:id]
	@title = "Delete note ##{params[:id]}"
	haml :delete
end

get '/:id/complete' do
	n = Note.get params[:id]
	if n.status == :new || n.status == :slack
		n.status = :done
	elsif n.status == :done
		n.status = :new
	end
	#n.status = n.status ? :new : :done # flip it
	n.updated_at = Time.now
	n.save
	redirect '/'
end

get '/:id/slack' do
	n = Note.get params[:id]
	#n.status = n.status ? :new : :slack # flip it
	n.status = :slack
	n.updated_at = Time.now
	n.save
	redirect '/'
end

delete '/:id' do
	n = Note.get params[:id]
	n.destroy
	redirect '/'
end
