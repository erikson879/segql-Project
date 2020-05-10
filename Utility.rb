#!/usr/bin/ruby
# frozen_string_literal: true

#   @profesor
#   Andres Sanoja
#   @curso
#   Analisis de Documentos en Archivos Web
#   @autor
#   Erikson Agustin Rodriguez Morillo
require 'open-uri'
require 'json'
require 'logger'

class Utility

  @archivo_json
  @attr
  def initialize(archivo_json)
    @archivo_json = archivo_json
    @attr = g_atributos(@archivo_json)
  end

  def get_array_condicion_atom(vector)
    return 'Vector nil o vacio.' if vector.nil? || vector.empty?

    temp = String.new
    vector.each do |i|
      temp += i
    end
    temp = temp.strip.upcase
    temp = temp.split(/(AND|OR)/)
    temp = delete_element_empty_firts_end(temp)
    puts temp.inspect
    # comentario puede venir and or indice_val = 0
    # comentario puede venir and or temp.each do |i|
    # comentario puede venir and or   if (indice_val%2) == 0 && !(i.strip =~ /(AND|OR)/).nil?
    # comentario puede venir and or     return 'Nodo mal estructurado.'
    # comentario puede venir and or   end
    # comentario puede venir and or   indice_val += 1
    # comentario puede venir and or end
    temp
  end

  def get_block_result(block_set, condicion_atom)
    block_set_raw = g_datos(@archivo_json)['page']['children']
    if condicion_atom.nil?
      puts 'CONDICION ATOMICA NIL'
      return 'CONDICION ATOMICA NIL'
    elsif condicion_atom.empty?
      puts 'CONDICION ATOMICA VACIA'
      return 'CONDICION ATOMICA VACIA'
    elsif block_set.nil?
      puts 'BLOCK SET VACIO'
      return 'BLOCK SET VACIO'
    end
    ind_and = 0
    ind_or = 0
    respuesta_temp = nil
    long = condicion_atom.length
    ind_condicion = 0
    ar = []
    comienza_op = false
    termina_op = false
    comienza_op = true unless (condicion_atom.first =~ /(AND|OR)/).nil?

    termina_op = true unless (condicion_atom.last =~ /(AND|OR)/).nil?

    condicion_atom.each do |q|
      ind_condicion += 1
      if !(q =~ /(AND)/).nil?
        ind_and = 1
        ar.push q.strip if ind_condicion == long || ind_condicion == 1

      elsif !(q =~ /(OR)/).nil?
        ind_or = 1
        ar.push q.strip if ind_condicion == long || ind_condicion == 1

      else
        cond_atom = q.strip.split(/(<>|!=|<=|>=)/)
        if cond_atom.class == Array
          arr = []
          cond_atom.each do |a|
            arr.push a.strip
          end
          cond_atom = arr
        end
        v_a = if cond_atom.length == 1
                q.split(/(=|>|<)/)
              else
                cond_atom
              end
        if ind_and == 1
          respuesta_temp = if respuesta_temp.nil?
                             operacion(v_a, block_set_raw)
                           else
                             operacion(v_a, respuesta_temp)
                           end
        elsif ind_or == 1
          puts 'PASO OR'
          respuesta_temp += operacion(v_a, block_set_raw)
          respuesta_temp = respuesta_temp.uniq
        else
          respuesta_temp = operacion(v_a, block_set_raw)
        end
        if comienza_op
          puts 'COMIENZO'
          ar[1] = respuesta_temp
        elsif termina_op
          puts 'TERMINA'
          ar[0] = respuesta_temp
        end
        if ar.empty?
          ar.push respuesta_temp
        else
          ind_hash = 0
          contiene = 0
          ar.each do |k|
            unless k.class == Array
              ind_hash += 1
              next
            end
            # k += respuesta_temp
            # k.uniq
            contiene = 1
            break
          end
          if !contiene.zero?
            if ar[ind_hash].class == Array
              ar[ind_hash] = respuesta_temp
              ar[ind_hash] = fecth_arr_sin_duplicaco(ar[ind_hash],respuesta_temp) 
            end
          else
            ar.push respuesta_temp
          end

        end
        ind_and = 0
        ind_or = 0
      end
    end
    puts 'Array resultado'
    puts ar.inspect
    ar
  end

  def validaEstructura(param)
    partes = limpiar_line_empty(limpiar_return_line(param))
    funcion = partes[0].strip unless partes[0].nil?
    mensaje = valida_ubicacion_funcion(partes, funcion)
    return mensaje unless mensaje.nil? || mensaje.empty?

    atributos = partes[1].strip unless partes[1].nil?

    atr = valida_atributos(atributos)
    puts 'ATR 1'
    puts atr.inspect
    puts 'ATR 2'
    return atr if atr.class == String

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
        return mensaje = 'Condición no especificada'
      else
        mensaje = valida_condicion(condicion) unless valida_condicion(condicion).nil?
      end

      #orden = partes[7].strip unless partes[7].nil?

      #parametro = partes[9].strip unless partes[9].nil?

    end
    if mensaje.class == Array && atr.class == Array
      vector = []
      mensaje.each do |f|
        hasher = {}
        atr.each do |a|
          f.each do |k,v|
            hasher[k] = v if a.upcase.strip == k.upcase.strip

            next
          end
        end
        vector.push(hasher)
      end
      return vector
    end
    mensaje
  end

  def g_atri_condic(nodos_hash)
    datos_json = g_datos(@archivo_json)
    p "datos_json['page']['children']"
    p datos_json['page']['children']
    p 'nodo_hash'
    p nodos_hash
    atributos = @attr
    p 'atributos'
    p atributos
    respuesta = nil
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
          #puts v_a.class
          #puts v_a
          j = i.split(/(<>|!=|<=|>=)/)
          puts j.length
          puts j
          if j.length == 1
            v_a = i.split(/(=|>|<)/)
          else
            v_a = j
          end
        end
      end
    end
    puts 'RESPUESTA.CLASS'
    puts respuesta.class
    puts 'RESPUESTA'
    puts respuesta
    respuesta
  end

  def operacion(arr_funcion, datos)
    puts 'DENTRO DE OPERACION'
    puts '-----------PARAMETROS DE OPERACION 1----------------'
    puts arr_funcion.inspect
    puts '-----------PARAMETROS DE OPERACION 2----------------'
    puts datos
    puts '-----------PARAMETROS DE OPERACION FIN----------------'
    v = nil
    a = nil
    final = []
    if datos.class == Hash
      datos = datos['page']['children']
    end
    'Formato invalido en operación.' if arr_funcion.length > 3

    'Blockset nulo o vacio.' if datos.nil? || datos.empty?

    atributos = @attr
    'Atributos nulo o vacio.' if atributos.nil? || atributos.empty?

    operador = arr_funcion[1].strip
    arr_funcion.delete_at(1)
    arr_funcion.each do |q|
      if atributos.include? q.strip.upcase
        a = q.strip.downcase
      else
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
      end
    end
    'Atributo invalido para el dataset.' if a.nil? || a.empty?

    'Operador invalido.' unless operador.match(/(=|<>|>|<|!=)/)

    puts 'iterando inicio'
    puts 'operador' + operador
    if operador == '='
      puts 'entre por ='
      datos.each do |it|
        final.push(it) if it[a].to_s == v.to_s

      end
    elsif operador == '!=' || operador == '<>'
      puts 'entre por <>'
      datos.each do |it|
        final.push(it) unless it[a].to_s == v.to_s

      end
    elsif operador == '<'
      puts 'entre por <'
      v = v.to_f 
      datos.each do |it|
        final.push(it) if it[a].to_f < v.to_f

      end
    elsif operador == '>'
      puts 'entre por >'
      v = v.to_f 
      datos.each do |it|
        final.push(it) if it[a].to_f < v.to_f

      end
    elsif operador == '>='
      puts 'entre por >='
      v = v.to_f 
      datos.each do |it|
        final.push(it) if it[a].to_f >= v.to_f

      end
    elsif operador == '<='
      puts 'entre por <='
      v = v.to_f 
      datos.each do |it|
        final.push(it) if it[a].to_f <= v.to_f

      end
    end
    final
  end

  def valida_condicion(condicion)
    valor_retorno = valida_cantidad_orden_parentesis(condicion)
    return valor_retorno unless valor_retorno.nil?

    nodos_hash = {}
    puts 'llamado a parentesis'
    nodos_hash = parentesis(condicion, nodos_hash)
    return nodos_hash if nodos_hash.class == String

    valor = g_atri_condic(nodos_hash)
    return valor if valor.class == String

  end

  def get_cantidad_nodos(_condicion)
    _condicion = _condicion.strip
    contador_nodos = 0
    contador_nodos += 1 unless _condicion.match(/^\(.*/)
    contador_nodos += 1 unless _condicion.match(/.*\)$/)
    _condicion = _condicion.split('')
    _condicion.each do |_i|
      contador_nodos += 1 if _i == '('
    end
    contador_nodos
  end

  def fetch_nodo_hash(nodos_hash)
    nodos_hash = {} if nodos_hash.nil?
    nodos_hash
  end

  def fetch_strip(condicion)
    condicion = condicion.strip
    condicion
  end

  def parentesis(condicion, nodos_hash)
    nodos_hash = fetch_nodo_hash(nodos_hash)
    datos_json = g_datos(@archivo_json)
    condicion = fetch_strip condicion
    contador_nodos = get_cantidad_nodos(condicion)
    puts 'contador nodos'
    puts contador_nodos
    contador = 0
    contador += 1 unless condicion.match(/^\(.*/)

    contador += 1 unless condicion.match(/.*\)$/)

    condicion = condicion.split('')
    nodo = String.new
    fin = 0
    cadena_final = ''
    #--
    vec_cont = []
    caracter = 0
    cad_temp = nil
    #--
    puts 'CONDICION.INSPECT'
    puts condicion.inspect
    arr_block_set = []
    condicion.each do |i|
      cadena_final += i
      caracter += 1
      if i == '('
        puts 'PASO 11'
        contador += 1
        puts vec_cont.inspect
        cadena = ''
        vec_cont.each do |c|
          cadena += c
        end
        cadena = cadena.strip unless cadena.empty?
        if !cadena.empty? && !cadena.match(/(=|<>|>|<|!=)/).nil?
          vec_cont = cadena.split('')
          arreglo_nodo_atomico = get_array_condicion_atom(vec_cont)
          return arreglo_nodo_atomico if arreglo_nodo_atomico.class == String

          test_valor = get_block_result(datos_json['page']['children'], arreglo_nodo_atomico)
          puts 'test_valor 11'
          puts test_valor
          arr_block_set += test_valor
        elsif !cadena.empty?
          arr_block_set[arr_block_set.length] = cadena.upcase
        end
        vec_cont.clear
      elsif (i != '(' && i != ')')
        if caracter == condicion.length
          vec_cont.push i

          puts 'PASO 12'
          contador += 1
          unless vec_cont.empty?
            vec_cont = delete_space_firts_end(vec_cont)
            puts vec_cont.inspect

            arreglo_nodo_atomico = get_array_condicion_atom(vec_cont)
            return arreglo_nodo_atomico if arreglo_nodo_atomico.class == String

            test_valor = get_block_result(datos_json['page']['children'], arreglo_nodo_atomico)
            puts 'test_valor 12'
            puts test_valor
            arr_block_set += test_valor
          end
        else
          puts 'AGREGO AL VECTOR '
          vec_cont.push i
        end
      elsif i == ')'
        # Se evalua el resultado y se filtra las filas del blockset y
        # se guarda blockset
        vec_cont.each do |j|
          cad_temp = '' if cad_temp.nil?
          cad_temp += j
        end
        puts 'PASO 13'
        contador += 1
        unless vec_cont.empty?
          arreglo_nodo_atomico = get_array_condicion_atom(vec_cont)
          return arreglo_nodo_atomico if arreglo_nodo_atomico.class == String

          puts 'arreglo_nodo_atomico'
          puts arreglo_nodo_atomico
          test_valor = get_block_result(datos_json['page']['children'], arreglo_nodo_atomico)
          puts 'test_valor 131'
          puts test_valor
          arr_block_set += test_valor
        end
        vec_cont.clear
      elsif caracter == condicion.length && i != ')'
        # Se evalua el resultado y se filtra las filas del blockset y se guarda
        # blockset
        unless vec_cont.empty?
          arreglo_nodo_atomico = get_array_condicion_atom(vec_cont)
          return arreglo_nodo_atomico if arreglo_nodo_atomico.class == String

          test_valor =  get_block_result(datos_json, arreglo_nodo_atomico[0])
          puts 'test_valor 132'
          puts test_valor
        end
      end

      if contador_nodos == contador
        if i == ')' && fin.zero?
          nodo += i
          fin = 1
        elsif  fin.zero?
          nodo += i
        end
      end
    end
    puts 'fin bucle condicion'
    puts arr_block_set.class
    puts arr_block_set
    result_final = fecth_result_final arr_block_set
    return result_final if result_final.class == String
    
    cadena_final = cadena_final.sub(nodo, '#' + (contador_nodos - 1).to_s + '#')
    if contador > 1
      nodos_hash[(contador_nodos - 1).to_s] = nodo
    else
      if !contador_nodos.nil? && !nodo.nil?
        nodos_hash[(contador_nodos - 1).to_s] = nodo
      end
    end
    nodos_hash
  end

  def valida_cantidad_orden_parentesis(condicion)
    cont_open = condicion.count('(')
    cont_close = condicion.count(')')
    'Error en condición, cantidad de parentesis.' unless cont_open == cont_close

    contador = 0
    condicion = condicion.split('')
    condicion.each do |i|
      if i == '('
        contador += 1
      elsif i == ')'
        contador -= 1
      end
      return 'Error en condición, orden de parentesis.' if contador.negative?
    end
    return 'Error en condición, parentesis no termina correctamente.' unless contador.zero?

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
      nil
    end
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
    atributos_json = @attr
    return atributos_json if atributos_raw == '*'

    atributos = atributos_raw.strip.split(',')
    temp = []
    atributos.each do |i|
      temp.push(i.strip.upcase)
    end
    atributos = temp
    atributos.each do |a|
      return 'Lista de atributos invalida' unless atributos_json.include? a
    end
    atributos
  end
end

def delete_space_firts_end(arreglo)
  arreglo.shift while arreglo.first == ' '

  arreglo.pop while arreglo.last == ' '

  arreglo
end

def delete_element_empty_firts_end(arreglo)
  arreglo.shift while arreglo.first == ''

  arreglo.pop while arreglo.last == ''

  arreglo
end

def fecth_arr_sin_duplicaco(arr1,arr2)
  arr2.each do |h|
    unless arr1.include?(h)
      arr1 << h
    end
  end
  arr1
end

def fecth_result_final (arr_block_set)
  if (arr_block_set.length%2) == 0
    return 'Problemas en el procesamiento del blockset en condiciones'
  end
  
end
