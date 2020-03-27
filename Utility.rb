# frozen_string_literal: true

class Utility
  def validaEstructura(_param)
    partes = _param.to_s.downcase.strip.split("\n")
    funcion = partes[0].strip
    partes.delete_at(0)
    if funcion != 'merge' && funcion != 'select'
      puts 'Consulta mal estructurada desde el inicio'
      'Consulta mal estructurada desde el inicio'
    else
      unless validaUbicacionFuncion(partes).empty?
        validaUbicacionFuncion(partes)
      end

    end
  end

  def validaUbicacionFuncion(_partes)
    _partes.each do |_i|
      if _i == 'merge'
        return 'Se encontro MERGE en ubicación inesperada'
      elsif _i == 'select'
        return 'Se encontro SELECT en ubicación inesperada'
      end
    end
    ''
  end
end
