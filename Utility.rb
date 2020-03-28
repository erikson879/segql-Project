# frozen_string_literal: true

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

    url = partes[3].strip unless partes[3].nil?
    condicion = partes[5].strip unless partes[5].nil?
    orden = partes[7].strip unless partes[7].nil?
    parametro = partes[9].strip unless partes[9].nil?
    # mensaje = validaUbicacionFuncion(partes, funcion)
    mensaje
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
