#!/usr/bin/ruby
# frozen_string_literal: true

#   @profesor
#   Andres Sanoja
#   @curso
#   Analisis de Documentos en Archivos Webs
#   @autor
#   Erikson Agustin Rodriguez Morillo
require 'sinatra'
require 'json'
require 'erb'
require './Utility'

uti = Utility.new('segmentacion.json')
funcion = { 0 => 'SELECT', 1 => 'MERGE' }

get '/segql' do
  send_file 'pages/homePage.html'
end
post '/segqlejecucion' do
  consulta = params[:query]
  mensaje = uti.validaEstructura params[:query]
  mensaje = 'TODO OK' if mensaje.empty?
  puts mensaje
  puts consulta
  erb :respuesta, locals: { mensaje: mensaje, consulta: consulta }
end
