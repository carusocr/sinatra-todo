#!/usr/bin/env ruby

require 'sinatra'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required=>true
	property :complete, Boolean, :required=>true, :default=>false
	property :created_at, DateTime
	property :updated_at, DateTime
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
	n.complete = params[:complete] ? 1 : 0
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
	n.complete = n.complete ? 0 : 1 # flip it
	n.updated_at = Time.now
	n.save
	redirect '/'
end

delete '/:id' do
	n = Note.get params[:id]
	n.destroy
	redirect '/'
end

__END__
@@ layout
%html{:lang => "en"}
  %head
    %meta{:charset => "utf8"}
      %title= @title + ' | Recall '
      %link{:href => "/reset.css", :rel => "stylesheet"}
        %link{:href => "/style.css", :rel => "stylesheet"}
  %body
    %header
      %hgroup
        %h1
          %a{:href => "/"} To-Do
        %h2 remember this stuff!
    #main
      = yield
    %footer
      %p
@@ home
%section#add
  %form{:action => "/", :method => "post"}
    %textarea{:name => "content", :placeholder => "Your note…"}
    %input{:type => "submit", :value => "Take Note!"}
- @notes.each do |note|
  <article #{'class="complete"' if note.complete}>
  = note.content
  %a{:href => "/#{note.id}"} [edit]
  %p.links
    %a{:href => "/#{note.id}/complete"} ↯
  %p.meta
    Created: #{note.created_at}
@@ edit
- if @note
	%form#edit{:action => "/#{@note.id}", :method => "post"}
		%input{:name => "_method", :type => "hidden", :value => "put"}
			%textarea{:name => "content"}= @note.content
			<input type ="checkbox" name="complete" #{"checked" if @note.complete}>
			%input{:type => "submit"}
	%p
		%a{:href => "/#{@note.id}/delete"} Delete
- else
	%p Note not found!
@@ delete
- if @note
	%p Are you sure you want to delete note #{@note.id}?
	%form{:action => "/#{@note.id}", :method => "post"}
		%input{:name => "_method", :type => "hidden", :value => "delete"}
		%input{:type => "submit", :value => "Junk it!"}
			%a{:href => "/#{@note.id}"} Cancel
- else
	%p Note not found.
