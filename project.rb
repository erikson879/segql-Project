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
  mensaje = uti.validaEstructura consulta
  if mensaje.nil? || mensaje.empty?
    mensaje = 'TODO OK'
  elsif mensaje.class == Array 
    tabla = mensaje
    mensaje = "%d fila(s) retornada(s)." % [mensaje.length]
  end
  puts 'TABLA'
  puts tabla
  erb :tabla, :layout => :respuesta, locals: { mensaje: mensaje, consulta: consulta , tabla: tabla}
end
