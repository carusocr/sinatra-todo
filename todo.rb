#!/usr/bin/env ruby
#Ruby to-do list.
# Author : Chris Caruso

=begin

This todo list tracks my tasks for a given day, changing colors to display their current state. I'm
looking to make a todo list that compensates for my laziness by nagging appropriately and preventing
me from simply deleting undone tasks at the end of the day.

White: uncompleted task
Red: uncompleted task, automatically carried over from previous day
Green: Task is currently in progress. Todo will keep track of time spent performing task.
Aqua: completed task. A red task that is completed will vanish from the current day's display 
			and show up in aqua on the day it was created.
			* add footnote listing completion date.
Yellow: You didn't have the guts to finish this task and marked it 'slacked'. A slacked task
				cannot be deleted, as testament to procrastination.

There are a set of icons under each task, although task state determines which icons are 
displayed:

↯				Activate task. Todo will begin to track time spent performing task.
▣				Complete task. This icon is displayed for uncomplete, slacked, or completed tasks.
↭				Slack on task. This icon is displayed only for uncomplete tasks.
☢				Delete task. This icon is available for all tasks except slack(testament!).
...			Postmortem comments. These can be entered for completed or slacked tasks in order to
				provide additional information about the task's execution.

Click on a task's text to edit it.

Future features:
1. Fix red task behavior...don't punt it back to day of creation!
6. Ability to note amount of time spent on each task if desired...pomodoro count?
8. Add ability to shift position of items in list
10. Add online database functionality.
* Ghettoed this out by using Dropbox. Weekend task is to get better alternative...PostgreSQL on Heroku?
11. Priority.

20120126 - Getting started on this but duration really should be a database value that gets updated...when? ONLY WHEN AN ACTIVE TASK CHANGES STATUS TO COMPLETED. Easy enough, but what about re-zeroing the duration variable every time? Only need to do that when the status goes to 'new', right?

Need to add deactivation ability! This doesn't set duration back to zero.

Additional behaviors: 

PRIORITY LEVELS!

Todo tracks how many times I've created and then deleted a certain task, maybe by checking for 
keywords like 'call annoying uncle' and starts taking the initiative - adding that task on a day that
I've specified as flexible(typically weekends) and then not allowing me to delete it.

=end

require 'sinatra'
require 'data_mapper'
require 'haml'
require 'active_support/all'

$curday = Date.today
$duration = 0

#database setup
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required=>true
	property :comment, Text
	property :status, Enum[ :new, :doing, :done, :slack, :ohshit], :default=> :new
	property :created_at, Date
	property :updated_at, DateTime
	property :pomodoros, Integer, :default => 0
	property :duration, Float, :default => 0
	property :priority, Boolean, :default => 0
end

DataMapper.finalize.auto_upgrade!

get '/' do
	@notes = Note.all :order=>:id.desc
	@title = 'All Notes'
	haml :home, :locals => {:$curday => $curday, :$duration => $duration}
end

get '/present' do
	$curday = Date.today
	redirect '/'
end

get '/nextday' do
	$curday = $curday + 1.day
	redirect '/'
end

get '/prevday' do
	$curday = $curday - 1.day
	redirect '/'
end

post '/' do
	n = Note.new
	n.content = params[:content]
	n.priority = params[:priority]
	n.created_at = $curday
	n.updated_at = Time.now
	n.save
	redirect '/'
end

def edit(id,field)
	@note = Note.get params[id]
	@title = "Edit note ##{params[id]}"
	haml :edit, :locals => {:field => field}
end

def save(id, field)
	n = Note.get params[id]
	if field == 'comment'
		n.comment = params[:comment]
	else
		n.content = params[:content]
	end
	n.updated_at = Time.now
	n.save
	redirect '/'
end

get '/:id' do
	edit(:id, 'content')
end

get '/:id/comment' do
	edit(:id, 'comment')
end 

put '/:id/content' do
	save(:id, 'content')
end

put '/:id/comment' do
	save(:id, 'comment')
end

get '/:id/delete' do
	n = Note.get params[:id]
	n.destroy
	redirect '/'
end

get '/:id/complete' do
	n = Note.get params[:id]
	if n.status == :doing
		$duration += (Time.now - n.updated_at)/60
		if n.duration.nil?
			n.duration = $duration
		else
			n.duration = $duration + n.duration
		end
	end
	if n.status == :new || n.status == :slack || n.status == :doing
		n.status = :done
	elsif n.status == :done
		n.status = :new
		$duration = 0
	end
	n.updated_at = Time.now
	n.save
	redirect '/'
end

get '/:id/activate' do
	n = Note.get params[:id]
	if n.status == :doing
		n.status = :new
		if n.duration.nil?
			n.duration = $duration
		else
			n.duration = $duration + n.duration
		end
		$duration = 0
	elsif (n.status == :new || n.status == :ohshit) && $curday == Date.today
		n.status = :doing
	end
	n.updated_at = Time.now
	n.save
	redirect '/'
end

get '/:id/slack' do
	n = Note.get params[:id]
	n.status = :slack
	n.updated_at = Time.now
	n.save
	edit(:id, 'comment')
	#redirect '/'
end
