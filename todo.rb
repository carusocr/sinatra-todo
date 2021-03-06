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
☢				Delete task. This icon is available for all tasks except slacked.
...			Postmortem comments. These can be entered for completed or slacked tasks in order to
				provide additional information about the task's execution.

Click on a task's text to edit it.

Future features:
* Move repeater option to edit window, then add daily/weekly/otherday options
* Add ability to shift position of items in list
* Consolidate activate and complete code into one 'update' method?
* Add some sort of 'random notes and ideas' section.
* Add ability to move task to different day.

Encountered bug where active items follow when I switch days...was going to fix this but I kind of like the constant reminder of what I'm supposed to be working on while I plan ahead.

=end

require 'sinatra'
require 'data_mapper'
require 'haml'
require 'active_support/all'

duration = Hash.new

#database setup
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")
$curday = Date.today

class Note
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required=>true
	property :comment, Text
	property :status, Enum[ :new, :doing, :done, :slack, :overdue ], :default=> :new
	property :created_at, Date
	property :task_date, Date
	property :updated_at, DateTime
	property :completed_at, DateTime
	property :duration, Integer, :default => 0
	property :priority, Boolean, :default => false
	property :complete, Boolean, :default => false
	property :active, Boolean, :default => false
	property :repeater, Boolean, :default => false
end

DataMapper.finalize.auto_upgrade!

def check_repeaters()
	#pay rent first of month
	if Date.today.day == 25
		#Note.first_or_create(:content=>"MORTGAGE",:created_at=>Date.today)
	end
	Note.all(:repeater => true).each do |rep|
		if rep.created_at.cwday == Date.today.cwday && rep.complete == true && rep.created_at != Date.today
			#switch off repeater for old one
			rep.repeater = false
			rep.save
			#now to make a new one...
			Note.create(rep.attributes.merge(:id=>nil,:repeater=>true,:complete=>false,:status=>:new,:created_at=>Date.today,:duration=>0))
		end
	end
end

# notes are slow since db is getting bigger...why reload entire table on get '/'?
# change this so that it only loads current day

get '/' do
	check_repeaters()
 	notes = Note.all(:created_at => $curday) | Note.all(:created_at.lt => Date.today, :status => :new) | Note.all(:completed_at => $curday) | Note.all(:status => :doing)
	@notes = notes.all(:order => [:complete]).reverse
	@title = ' - CRC - '
	haml :home, :locals => {:curday => $curday}
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

post '/datejump' do
	if params[:newdate] == ''
	else
		$curday = Date.strptime("#{params[:newdate]}", '%m/%d/%Y') #fix date format
		redirect '/'
	end
end

get '/table' do
  haml :table
end

post '/' do
  task_create(:content, :repeater)
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

#call this when script launches if there's a repeater task that falls on that DOW
def task_create(content, repeater)
	n = Note.new(:content => params[content],
                :repeater => params[repeater],
                :created_at => $curday,
                :task_date => Date.today,
                :updated_at => Time.now
              )
	n.save
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
	n.completed_at = $curday
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
	elsif (n.status == :new || n.status == :overdue) && $curday == Date.today
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
