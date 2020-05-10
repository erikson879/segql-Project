#!/usr/bin/ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'sinatra'
require 'json'
require 'erb'
require 'logger'
require './Utility'

#   @profesor
#   Andres Sanoja
#   @curso
#   Analisis de Documentos en Archivos Webs
#   @autor
#   Erikson Agustin Rodriguez Morillo

uti = Utility.new('segmentacion.json')
Dir.mkdir('logs') unless File.exist?('logs')

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
