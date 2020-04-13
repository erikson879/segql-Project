# frozen_string_literal: true

#   @profesor
#   Andres Sanoja
#   @curso
#   Analisis de Documentos en Archivos Web
#   @autor
#   Erikson Agustin Rodriguez Morillo
require 'open-uri'
require 'json'
class Utility
  def validaEstructura(_param)
    mensaje = ''
    partes = limpiar_line_empty(limpiar_return_line(_param))
    funcion = partes[0].strip unless partes[0].nil?
    mensaje = validaUbicacionFuncion(partes, funcion)
    return mensaje unless mensaje.empty?

    atributos = partes[1].strip unless partes[1].nil?
    atr = valida_atributos(atributos)
    return mensaje = atr if atr.class == String

    unless partes[2].strip.upcase == 'FROM'
      return mensaje = 'Error no se encontro FROM en la ubicación esperada'
    end

    url = partes[3].strip unless partes[3].nil?
    res_url = valida_url(url)
    return mensaje = res_url if res_url.class == String

    if partes.length > 4
      if !partes[4].strip.nil? && (partes[4].strip.upcase != 'WHERE')
        return mensaje = 'Error no se encontro WHERE en la ubicación esperada'
      elsif partes.length == 5
        return mensaje = 'Error la consulta, termina de forma inesperada'
      end

      condicion = partes[5].strip unless partes[5].nil?
      if condicion.empty?
        return mensaje = 'Condicion no especificada'
      else
        return valida_condicon(condicion) unless valida_condicon(condicion).nil?
      end

      orden = partes[7].strip unless partes[7].nil?
      parametro = partes[9].strip unless partes[9].nil?
    end
    mensaje
  end

  def valida_condicon(_condicion)
    puts 'llego a valida_condicon(_condicion)'
    partes = _condicion.upcase.strip.split('AND')
    p_temp = []
    p_or = []
    mensaje = nil
    puts 'Longitud de partes ' + partes.length.to_s
    partes.each do |i|
      mensaje_tmp = valida_parentesis(i)
      return mensaje_tmp unless mensaje_tmp.nil?

      puts 'Valor de partes ' + i
      puts 'Lonngitud de partes ' + i.strip.split(/!=|<|>|=/).length.to_s
      if i.strip.split(/!=|<|>|=/).length > 2
        puts 'MAS DE DOS'
        puts i.strip.split(/!=|<|>|=/).length
        puts i.strip
        i.strip.split(/^\(/) do |_y|
          puts 'pase'
          p_or.push(_y.strip)
        end
        puts 'pase 1111' if i.strip =~ /^\(/ && i.strip =~ /\)$/
      elsif i.strip.split(/!=|<|>|=/).length < 2
        return 'Error en condición, error de formato'
      else
        puts 'SOLO UNO'
        puts i.strip.split(/!=|<|>|=/).length
      end
    end
    puts '#####################'
    puts p_or
    puts '#####################'
    puts partes
  end

  def valida_parentesis(_cadena)
    # validar orden de apertura y cierre de parentesis
    # 1.verificar desde el inicio si hay apertura de parentesis
    cont_parent_open = _cadena.count('(')
    cont_parent_close = _cadena.count(')')
    if cont_parent_open != cont_parent_close
      return 'Error en condición, cantidad de parentesis.'
    elsif cont_parent_open == 0
      return nil
    else
      puts 'PRUEBAS DE PARENTESIS'

      _cadena = _cadena.strip
      estru = 0
      _cadena.split('').each do |_i|
        puts _i
        if _i == '('
          estru += 1
        elsif _i == ')' && estru > 0
          estru -= 1
        elsif _i == ')' && estru == 0

        end
      end
      puts _cadena.length
    end

    nil
  end

  def valida_condicon_or(_condicion); end

  def valida_url(_url)
    begin
      if !_url.nil?
        rr = ['HTTP://', 'HTTPS://']
        cont = 0
        rr.each do |i|
          cont = 1 if _url.upcase.include? i
        end
        _url = 'http://' + _url if cont == 0
        respuesta = open(_url).status
      else
        raise StandardError
      end
    rescue StandardError
      respuesta = 'Error en <URL>'
    end
    respuesta
  end

  def limpiar_return_line(_param)
    partes = _param.to_s.downcase.strip.split("\r\n")
    partes.each do |_i|
      _i.to_s.strip.tr('', "\r\n")
    end
    partes
  end

  def limpiar_line_empty(_param)
    partes = []
    _param.each do |_i|
      partes.push(_i) unless _i.empty?
    end
    partes
  end

  def validaUbicacionFuncion(_partes, _funcion)
    if _funcion != 'merge' && _funcion != 'select'
      return 'Consulta mal estructurada desde el inicio'
    else
      ind = 0
      _partes.each do |_i|
        if ind != 0
          if _i == 'merge'
            return 'Se encontro MERGE en ubicación inesperada'
          elsif _i == 'select'
            return 'Se encontro SELECT en ubicación inesperada'
          end
        end
        ind += 1
      end
      ind = 0
    end

    ''
  end

  def getAtributos(_archivo)
    archivo = File.open _archivo
    archivo = JSON.load archivo
    arr = []
    archivo['page']['children'][0].each do |_i, _j|
      arr.push(_i)
    end
    arr
  end

  def valida_atributos(_atributos_raw)
    atributos_json = getAtributos('segmentacion.json')
    return atributos_json if _atributos_raw == '*'

    atributos = _atributos_raw.strip.split(',')
    atributos.each do |_a|
      return 'Lista de atributos invalida' unless atributos_json.include? _a
    end
    atributos
  end
end
