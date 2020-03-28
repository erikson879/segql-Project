# frozen_string_literal: true

require 'sinatra'
require 'json'
require './Utility'

uti = Utility.new
funcion = { 0 => 'SELECT', 1 => 'MERGE' }

get '/segql' do
  send_file 'pages/homePage.html'
end
post '/segqlejecucion' do
  mensaje = uti.validaEstructura params[:query]
  mensaje = 'TODO OK' if mensaje.empty?
  puts mensaje
  params[:query]
end
