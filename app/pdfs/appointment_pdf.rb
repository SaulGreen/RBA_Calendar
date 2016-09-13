class AppointmentPdf < Prawn::Document
	def initialize(appointments,usrRole)
		super(:page_layout => :landscape)
		@appointments = appointments
		@usrRole = usrRole 
		text_content
		table_content

	end

	def text_content 
		y_position = cursor - 50

		if @usrRole == 4
			bounding_box([0, y_position], :width => 270, :height => 50) do
		      text "Rudolph Baker & Associates", size: 15, style: :bold
		      text " "
		    end

		    bounding_box([300, y_position], :width => 270, :height => 50) do
		      text "Fecha: " + @appointments.first.fecha.strftime('%v').to_s, size: 15, style: :bold
		    end
		else
			bounding_box([0, y_position], :width => 270, :height => 50) do
		      text "Rudolph Baker & Associates", size: 15, style: :bold
		      text "Asesor: " + @appointments.first.nombre.to_s + " " + @appointments.first.apaterno.to_s
		      text " "
		    end

		    bounding_box([300, y_position], :width => 270, :height => 50) do
		      text "Fecha: " + @appointments.first.fecha.strftime('%v').to_s, size: 15, style: :bold
		    end
		end
	    # The bounding_box takes the x and y coordinates for positioning its content and some options to style it
	    
	end

	def table_content
		if @usrRole != 4
			table appointments_rows do
				row(0).font_style = :bold
				self.cell_style = { size: 10}
				self.header = true
				self.row_colors = ["DDDDDD","FFFFFF"]
				self.column_widths = [80,80,160,90,80,80]
			end
		else
			table appointments_rows do
				row(0).font_style = :bold
				self.cell_style = { size: 10}
				self.header = true
				self.row_colors = ["DDDDDD","FFFFFF"]
				self.column_widths = [80,60,140,90,80,80,0]
			end
		end
	end

	def appointments_rows
		#"id", "client_id, tipocaso, nombre, apaterno, color_id, fecha, hora, nombreClt, apaternoClt, numpersonas, comentario, telefonoClt, emailClt, attendance"
		
		if @usrRole == 4
			[["Hora","# Caso","Nombre del Cliente","Tipo de caso","Asesor","Comentario"]] +
			@appointments.map do |app|
				asistencia = "Sin confirmar"
				if app.attendance.to_s == "false"
					asistencia = "No atendio"
				elsif app.attendance.to_s == "true"
					asistencia = "Atendio"
				else
					asistencia = "Sin confirmar"
				end

				time = Time.new
				time = app.hora
				capLetter = app.nombre[0] + "."

				[time.strftime('%r'),app.numcaso.to_s, app.nombreclt.to_s + " " + app.apaternoclt.to_s, app.tipocaso.to_s, capLetter + " " + app.apaterno, app.comentario ]
			end
		else
			[["Hora","Num. Caso","Nombre del Cliente","Tipo de caso","Comentario"]] +
			@appointments.map do |app|
				asistencia = "Sin confirmar"
				if app.attendance.to_s == "false"
					asistencia = "No atendio"
				elsif app.attendance.to_s == "true"
					asistencia = "Atendio"
				else
					asistencia = "Sin confirmar"
				end

				time = Time.new
				time = app.hora

				[time.strftime('%r'),app.numcaso.to_s, app.nombreclt.to_s + " " + app.apaternoclt.to_s, app.tipocaso.to_s, app.comentario ]
			end
		end
	end
end