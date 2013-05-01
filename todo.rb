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
2. Ability to note amount of time spent on each task if desired...pomodoro count?
3. Rating of quality of task performance?
4. Add ability to shift position of items in list
5. Add online database functionality.
* Ghettoed this out by using Dropbox. Weekend task is to get better alternative...PostgreSQL on Heroku?
6. Consolidate activate and complete code into one 'update' method?
7. Add some sort of 'random notes and ideas' section.

Additional behaviors: 

Todo tracks how many times I've created and then deleted a certain task, maybe by checking for 
keywords like 'call annoying uncle' and starts taking the initiative - adding that task on a day that
I've specified as flexible(typically weekends) and then not allowing me to delete it.

BUGS:

1. Duration is cumulative if multiple tasks are activated. This is because I'm using a single duration variable to hold the value for all tasks, whoops. 
	## Fix is to make duration a hash. 
2. Class: task?

REPEATER TASKS:

1. Can create a task and flag it as 'repeating', which means that it will appear on the same day each week. The idea of this is to have the program remind me to do things like take out the trash, etc.
2. Once a task is created and flagged as repeater, how does the app make a new task?
3. Create repeating task as a separate button?
4. Check date against all tasks in database that have repeater flag, if day of week matches AND if there's no task named the same already created, then make a new task without any prompting.
5. Would be nice if task was created before the actual day, but be careful not to do anything dumb like create infinite tasks.

=end

require 'sinatra'
require 'data_mapper'
require 'haml'
require 'active_support/all'

$curday = Date.today
duration = Hash.new

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
	property :priority, Boolean, :default => false
	property :complete, Boolean, :default => false
	property :active, Boolean, :default => false
	property :repeater, Boolean, :default => false
end

DataMapper.finalize.auto_upgrade!

get '/' do
	@notes = Note.all :order=>:id.desc
	@title = ' - CRC - '
	haml :home, :locals => {:$curday => $curday}
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
	duration["#{n}"] = 0 if duration["#{n}"].nil?
	if n.active == true
		duration["#{n}"] += (Time.now - n.updated_at)/60
		if n.duration.nil?
			n.duration = duration["#{n}"]
		else
			n.duration = duration["#{n}"] + n.duration
		end
	end
	if n.status == :new || n.status == :slack || n.active == true
		n.status = :done
		n.complete = true
		n.active = false
	elsif n.complete == true
		n.status = :new
		n.complete = false
		duration["#{n}"] = 0
	end
	n.updated_at = Time.now
	n.save
	redirect '/'
end

get '/:id/activate' do
	n = Note.get params[:id]
	duration["#{n}"] = 0 if duration["#{n}"].nil?
	if (n.active == true || n.status == :doing)
		n.status = :new
		n.active = false
		duration["#{n}"] += (Time.now - n.updated_at)/60
		if n.duration.nil?
			n.duration = duration["#{n}"]
		else
			n.duration = duration["#{n}"] + n.duration
		end
	elsif (n.status == :new || n.status == :ohshit) && $curday == Date.today
		n.status = :doing
		n.active = true
	end
	duration["#{n}"] = 0
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
end
