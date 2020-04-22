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

  @archivo_json

  def initialize(archivo_json)
    @archivo_json = archivo_json
  end

  def validaEstructura(param)
    partes = limpiar_line_empty(limpiar_return_line(param))
    funcion = partes[0].strip unless partes[0].nil?
    mensaje = valida_ubicacion_funcion(partes, funcion)
    return mensaje unless mensaje.nil? || mensaje.empty?

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

  def g_atri_condic(nodos_hash)
    datos_json = g_datos(@archivo_json)
    p "datos_json['page']['children']"
    p datos_json['page']['children']
    p 'nodo_hash'
    p nodos_hash 
    atributos = g_atributos @archivo_json
    p 'atributos'
    p atributos 
    #nodos_hash.sort.map do |_i, _j|
    nodos_hash.each do |_i, _j|
      puts _i.to_s + ' : ' + _j.to_s
      temp = _j.upcase
      if temp.match(/(^\(.*\)$)/)
        temp = temp.split('')
        temp.shift
        temp.pop
        temp1 = ''
        temp.each do |w|
          temp1 += w
        end
        temp = temp1
      end
      temp = temp.split(/(AND|OR)/)
      puts 'INICIO temp por AND y OR'
      if temp.length > 1 
        # si temp tiene mas de uno tiene mas de una evaluación 
        puts 'mayor a uno'
        temp.each do |o|
          puts o
          puts 'perfecto: ' + o.to_s 
          if o.include?('=') || o.include?('>') || o.include?('<')
            puts 'perfecto: ' + o.to_s 
          end
        end
      else 
        puts 'menor a uno'
        
        temp.each do |i|
          puts 'else' + i.to_s
          v_a = i.split(/(=|>|<|<>|!=)/)
          operacion(v_a, datos_json)
          p v_a
          v = nil
          a = nil
          operador = v_a[1]
          v_a.delete_at(1)
          puts v_a

          v_a.each do |q|
            if atributos.include? q.strip.upcase
              puts 'llenando variable a'
              a = q
              puts a 
            else
              puts 'llenando variable v'
              v = q
              puts v
            end
          end
          return 'Condición posee un formato incorrecto' if a.nil? || v.nil?

          datos_json['page']['children'].each do |r|
            puts r 
            if r[a] == v
              puts datos_json 
              puts r[a]
              puts v
              datos_json['page']['children'].delete_if {|g| g['bid'] == r['bid']}
              puts datos_json 
              puts '---------------------------------------------------------------------'
              puts datos_json
            end
          end
        end
      end
      puts 'FIN temp por AND y OR'
      puts 'temp'
      puts temp
      puts 'wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww'
      puts datos_json
      puts 'wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww'
    end
  end

  def operacion(arr_funcion, datos)
    v = nil
    a = nil
    final = nil
    puts 'Estoy en operacion'
    datos = datos['page']['children']
    puts datos
    'Formato invalido en operación.' if arr_funcion.length > 3

    'Blockset nulo o vacio.' if datos.nil? || datos.empty?

    atributos = g_atributos @archivo_json
    'Atributos nulo o vacio.' if atributos.nil? || atributos.empty?

    p arr_funcion    
    operador = arr_funcion[1].strip
    arr_funcion.delete_at(1)
    arr_funcion.each do |q|
      if atributos.include? q.strip.upcase
        puts 'llenando variable a'
        a = q.strip.downcase        
        puts a
      else
        puts 'llenando variable v'
        v = q.strip.upcase
        if v.match(/^\'.*\'$/)
          v = v.split('')
          v.shift
          v.pop
          v_temp = ''
          v.each do |t|
            v_temp += t
          end
          v = v_temp
        end
        puts v
      end
    end
    'Atributo invalido para el dataset.' if a.nil? || a.empty?

    'Operador invalido.' unless operador.match(/(=|>|<|<>|!=)/)

    puts 'iterando inicio'
    if operador == '='            
      datos.each do |it|
        final.push(it) if it[a] == v
      end      
    elsif operador == '!='

    #elsif operador == '<>'
    #elsif operador == '='
    end
    final
  end

  def valida_condicon(condicion)
    partes = condicion.upcase.strip.split('AND')
    valor_retorno = valida_cantidad_orden_parentesis(condicion)
    return valor_retorno unless valor_retorno.nil?

    nodos_hash = {}
    nodos_hash = parentesis(condicion, nodos_hash)
    g_atri_condic(nodos_hash)
    valor_retorno
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
    contador = 0
    contador += 1 unless _condicion.match(/^\(.*\)$/)
    _condicion = _condicion.split('')
    nodo = ''
    fin = 0
    _condicion.each do |_i|
      contador += 1 if _i == '('
      if contador_nodos == contador
        if _i == ')' && fin.zero?
          nodo += _i
          fin = 1
        elsif  fin.zero?
          nodo += _i
        end
      end
    end
    cadena_final = ''
    _condicion.each do |i|
      cadena_final += i
    end

    cadena_final = cadena_final.sub(nodo, '#' + (contador_nodos - 1).to_s + '#')
    if contador > 1
      _nodos_hash[(contador_nodos - 1).to_s] = nodo
      parentesis(cadena_final, _nodos_hash)
    else
      if !contador_nodos.nil? && !nodo.nil?
        _nodos_hash[(contador_nodos - 1).to_s] = nodo
      end
    end
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
      return 'Error en condición, orden de parentesis.' if contador.negative?
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
    elsif cont_parent_open.zero?
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

  def valida_ubicacion_funcion(partes,funcion)
    if funcion != 'merge' && funcion != 'select'
      'Consulta mal estructurada desde el inicio'
    else
      ind = 0
      partes.each do |i|
        if ind != 0
          if i == 'merge'
            return 'Se encontro MERGE en ubicación inesperada'
          elsif i == 'select'
            return 'Se encontro SELECT en ubicación inesperada'
          end
        end
        ind += 1
      end
    end
    ''
  end

  def g_atributos(archivo)
    temp = ''
    File.open archivo do |s|
      temp += s.read
    end 
    archivo = JSON.parse temp
    arr = []
    archivo['page']['children'][0].each do |_i, _j|
      arr.push(_i.upcase)
    end
    arr
  end

  def g_datos(archivo)
    temp = ''
    File.open archivo do |s|
      temp += s.read
    end
    JSON.parse temp
  end

  def valida_atributos(atributos_raw)
    atributos_json = g_atributos(@archivo_json)
    return atributos_json if atributos_raw == '*'

    atributos = atributos_raw.strip.split(',')
    puts 'atributos'
    puts atributos
    puts 'atributos_json'
    puts atributos_json
    atributos.each do |a|

      puts 'a' + a
      return 'Lista de atributos invalida' unless atributos_json.include? a
    end
    atributos
  end  
end
