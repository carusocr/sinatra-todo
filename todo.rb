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
__END__
@@ layout
%html{:lang => "en"}
  %head
    %meta{:charset => "utf8"}
      %title= @title + ' | Recall'
      %link{:href => "/reset.css", :rel => "stylesheet"}
        %link{:href => "/style.css", :rel => "stylesheet"}
  %body
    %header
      %hgroup
        %h1
          %a{:href => "/"} Recall
        %h2 'cause you're too busy to remember
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
  %p
    = note.content
    %span
      %a{:href => "/#{note.id}"} [edit]
  %p.links
    %a{:href => "/#{note.id}/complete"} ↯
  %p.meta
    Created: #{note.created_at}
