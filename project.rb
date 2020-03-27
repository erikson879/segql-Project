# frozen_string_literal: true

require 'sinatra'
require 'json'
require './Utility.rb'

uti = Utility.new
funcion = { 0 => 'SELECT', 1 => 'MERGE' }

get '/segql' do
  send_file 'pages/homePage.html'
end
post '/segqlejecucion' do
  puts uti.validaEstructura params[:query]
  params[:query]
end
