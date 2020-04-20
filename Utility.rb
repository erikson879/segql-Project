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
    _valor_retorno = nil

    partes = _condicion.upcase.strip.split('AND')
    p_temp = []
    p_or = []
    mensaje = nil
    puts 'Longitud de partes ' + partes.length.to_s
    # SEGUNDA VERSION DE PROCESAMIENTO
    _valor_retorno = valida_cantidad_orden_parentesis(_condicion)
    return _valor_retorno unless _valor_retorno.nil?

    _nodos_hash = {}
    _nodos_hash = parentesis(_condicion, _nodos_hash)
    puts '_nodos_hash'
    puts _nodos_hash
    _valor_retorno
  end

  def get_cantidad_nodos(_condicion)
    _condicion = _condicion.strip
    contador_nodos = 0
    contador_nodos += 1 unless _condicion.match(/^\(.*\)$/)
    _condicion = _condicion.split('')
    _condicion.each do |_i|
      contador_nodos += 1 if _i == '('
    end
    contador_nodos
  end

  def parentesis(_condicion, _nodos_hash)
    _nodos_hash = {} if _nodos_hash.nil?
    _condicion = _condicion.strip
    contador_nodos = get_cantidad_nodos(_condicion)
    puts 'contador_nodos ' + contador_nodos.to_s
    contador = 0
    contador += 1 unless _condicion.match(/^\(.*\)$/)
    puts '-contador ' + contador.to_s
    _condicion = _condicion.split('')
    puts 'contador_nodos ' + contador_nodos.to_s
    nodo = ''
    fin = 0
    _condicion.each do |_i|
      contador += 1 if _i == '('
      if contador_nodos == contador
        if _i == ')' && fin == 0
          nodo += _i
          fin = 1
        elsif  fin == 0
          nodo += _i
        end
      end
    end
    cadena_final = ''
    _condicion.each do |_i|
      cadena_final += _i
    end

    cadena_final = cadena_final.sub(nodo, (contador_nodos - 1).to_s)
    puts 'con delete ' + cadena_final
    puts 'contador_nodos ' + contador_nodos.to_s
    if contador > 1
      _nodos_hash[contador_nodos - 1] = nodo
      parentesis(cadena_final, _nodos_hash)
    else
      if !contador_nodos.nil? && !nodo.nil?
        _nodos_hash[contador_nodos - 1] = nodo
      end
    end
    puts _nodos_hash
    _nodos_hash
  end

  def valida_cantidad_orden_parentesis(_condicion)
    cont_parent_open = _condicion.count('(')
    cont_parent_close = _condicion.count(')')
    if cont_parent_open != cont_parent_close
      return 'Error en condición, cantidad de parentesis.'
    end

    contador = 0
    _condicion = _condicion.split('')
    _condicion.each do |_i|
      if _i == '('
        contador += 1
      elsif _i == ')'
        contador -= 1
      end
      return 'Error en condición, orden de parentesis.' if contador < 0
    end
    if contador != 0
      return 'Error en condición, parentesis no termina correctamente.'
    end

    nil
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
      # valido estructura de apertura y cierre de parentesis
      _cadena.split('').each do |_i|
        puts _i
        if _i == '('
          estru += 1
        elsif _i == ')' && estru > 0
          estru -= 1
        elsif _i == ')' && estru == 0
          return 'Error en condición, estrutura de sentencia.'
        end
      end
      # granularizar los segmentos entre parentesis
      arbol_condicion = {}
      cantidad_aperturas = 0
      pos_apertura = 0
      pos_primer_cierre = 0
      _cadena.split('').each do |_i|
        if _i == ')'
          break
        else
          posicion_cierre += 1
        end

        pos_apertura += 1 if _i == '('
        cantidad_aperturas += 1 if _i == '('
      end
      puts 'Valor variable estru ' + estru.to_s
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
