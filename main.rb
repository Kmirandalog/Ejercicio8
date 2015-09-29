require_relative 'event'

class Main < Shoes
  url '/', :new_event
  url '/new_event', :new_event
  url '/event', :event
  url '/new_activity', :new_activity

  def current_event
    @@current_event
  end

  def display_error(message)
    @error_content.clear do
      background '#ff9999'
      border('#b20000', strokewidth: 2)
      para message, margin: 10
    end
  end

  def new_event
    background '#EFC'
    border('#BE8', strokewidth: 6)

    flow width: '100%', height: '100%' do
      stack margin: 10 do
        flow do
          title = para 'Bienvenido al organizador de eventos!'
          title.style(size: 20)
        end
      end

      @error_content = stack({ margin_left: 20, margin_bottom: 10, width: '780px' }) do
      end

      stack({ margin_left: 20, margin_bottom: 10 }) do
        para "Nombre del evento"
        @name = edit_line(width: 300)
      end

      stack({ margin_left: 20, margin_bottom: 10 }) do
        para "Fecha de inicio (dd-mm-aaaa)"
        @start_date = edit_line(width: 100)
      end

      stack({ margin_left: 20, margin_bottom: 40 }) do
        para "Fecha de fin (dd-mm-aaaa)"
        @end_date = edit_line(width: 100)
      end

      stack({ margin_left: 20 , size: 20 }) do
        button('Crear evento', width: '760px', height: '40px') do
          validate_and_create_event
        end
      end
    end
  end

  def validate_and_create_event
    if @start_date.text.empty? || @end_date.text.empty? || @name.text.empty?
      display_error('Todos los campos son obligatorios')
      return
    end

    start_date = valid_date(@start_date.text)
    end_date = valid_date(@end_date.text)
    if start_date && end_date
      result = Event.create_event(@name.text, start_date, end_date)
      if result.instance_of?(Event)
        @@current_event = result
        visit '/event'
      else
        display_error(result)
      end
    else
      display_error('Las fechas ingresadas no tienen formato valido')
    end
  end

  def event
    background '#EFC'
    border('#BE8', strokewidth: 6)

    event = current_event

    flow width: '100%', height: '100%', scroll: true do
      stack margin: 10 do
        title = para event.details
        title.style(size: 20)
      end

      stack margin:  10 do
        button("Nueva actividad", width: '780px', height: '40px') do
          visit '/new_activity'
        end
      end

      stack margin: 10 do
        event.dates.each do |date|
          stack({margin_bottom: 4}) do
            background '#BE8'
            para date, align: 'center', size: 16
            activities_details = event.activities_details_for_date(date)
            if activities_details.any?
              activities_details.each do |activity_details|
                flow do
                  para strong(activity_details[:time])
                  para activity_details[:description]
                end
              end
            else
              para('No hay actividades definidas', align: 'center')
            end
          end
        end
      end
    end
  end

  def new_activity
    background '#EFC'
    border('#BE8', strokewidth: 6)

    @content = flow width: '100%', height: '100%' do
      stack margin: 10 do
        title = para "Nueva Actividad - Datos generales (1/2)"
        title.style(size: 20)
      end

      @error_content = stack({ margin_left: 20, margin_bottom: 10, width: '780px' }) do
      end

      stack({ margin_left: 20, margin_bottom: 10 }) do
        para "Nombre"
        @name = edit_line(width: 300)
      end
      stack({ margin_left: 20, margin_bottom: 10 }) do
        para 'Fecha'
        @date = list_box items: current_event.dates.map { |date| date.strftime('%d-%m-%Y') }
      end
      stack({ margin_left: 20, margin_bottom: 10 }) do
        para "Hora de inicio (hh)"
        @start_time = list_box items: (0..23).to_a.map { |h| "%02d" % h }
      end
      stack({ margin_left: 20, margin_bottom: 10 }) do
        para "Hora de fin (hh)"
        @end_time = list_box items: (1..24).to_a.map { |h| "%02d" % h }
      end
      stack({ margin_left: 20, margin_bottom: 20 }) do
        para 'Tipo de actividad'
        @type = list_box items: ['Charla', 'Debate', 'Taller']
      end

      stack({ margin_left: 20, margin_bottom: 10, margin_top: 20 }) do
        flow do
          button("Continuar", width: '380px', height: '40px') do
            validate_and_continue_activity
          end
          button("Cancelar", width: '380px', height: '40px', margin_left: '40px') do
            visit '/event'
          end
        end
      end

    end
  end

  def validate_and_continue_activity
    @data = {
      name: @name.text,
      date: @date.text,
      start_time: @start_time.text,
      end_time: @end_time.text,
      type: @type.text
    }

    if @data.any?{ |field, value| value.nil? || value.empty? }
      display_error('Todos los campos son obligatorios')
      return
    end

    @data[:date] = valid_date(@data[:date])
    @data[:start_time] = @data[:start_time].to_i
    @data[:end_time] = @data[:end_time].to_i

    if @data[:start_time] < @data[:end_time]
      if current_event.respond_to?(:is_available_time_range?) &&
        !current_event.is_available_time_range?(@data[:date], @data[:start_time], @data[:end_time])
        display_error('El horario ingresado ya esta ocupado')
      else
        new_activity_details(@type.text)
      end
    else
      display_error('La hora de fin debe ser mayor a la inicio')
    end
  end

  def new_activity_details(type)
    @content.clear do
      stack margin: 10 do
        title = para "Nueva Actividad - Detalles (2/2)"
        title.style(size: 20)
      end

      @error_content = stack({ margin_left: 20, margin_bottom: 10, width: '780px' }) do
      end

      case type
      when 'Charla'
        new_talk_details
      when 'Debate'
        new_debate_details
      else
        new_workshop_details
      end
    end
  end

  def new_talk_details
    stack({ margin_left: 20, margin_bottom: 10 }) do
      para "Habla:"
      @speaker = edit_line(width: 300)
    end

    stack({ margin_left: 20, margin_bottom: 10 })do
      button("Crear Charla", width: '760px', height: '40px') do
        if @speaker.text.empty?
          display_error('Todos los campos son obligatorios')
        else
          current_event.add_talk(@data[:name], @data[:date], @data[:start_time], @data[:end_time], @speaker.text)
          visit '/event'
        end
      end
    end
  end

  def new_workshop_details
    stack({ margin_left: 20, margin_bottom: 10 })do
      para "Requerimientos:"
      @reqs = edit_line(width: 400)
    end

    stack({ margin_left: 20, margin_bottom: 10 }) do
      button("Crear Taller", width: '760px', height: '40px') do
        if @reqs.text.empty?
          display_error('Todos los campos son obligatorios')
        else
          current_event.add_workshop(@data[:name], @data[:date], @data[:start_time], @data[:end_time], @reqs.text)
          visit '/event'
        end
      end
    end
   end


  def new_debate_details
    stack({ margin_left: 20, margin_bottom: 10 }) do
      para "Discuten:"
      @speaker_1 = edit_line(width: 300)
      @speaker_2 = edit_line(width: 300)
    end

    stack({ margin_left: 20, margin_bottom: 10 }) do
      para "Modera:"
      @moderator = edit_line(width: 300)
    end

    stack({ margin_left: 20, margin_bottom: 10 })do
      button("Crear Debate", width: '760px', height: '40px') do
        if @speaker_1.text.empty? || @speaker_2.text.empty? || @moderator.text.empty?
          display_error('Todos los campos son obligatorios')
        else
          current_event.add_debate(@data[:name], @data[:date], @data[:start_time], @data[:end_time], [@speaker_1.text, @speaker_2.text], @moderator.text)
          visit '/event'
        end
      end
    end
  end

  def valid_date(date_string)
    Date.parse(date_string)
  rescue
    nil
  end

end

Shoes.app(title: 'Organizador de eventos', width: 800, height: 600)
