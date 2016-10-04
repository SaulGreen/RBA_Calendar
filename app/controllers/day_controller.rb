class DayController < ApplicationController
  	before_action :authenticate_user!
  	before_action :GetUserData
    #before_action :CheckIfUserIsActive
    before_action :GetAbogadosCasos

    # def CheckIfUserIsActive
    #     if current_user.status != 2
    #         redirect_to new_user_session_path, :notice => "Tu cuenta no esta activa, verificalo con el personal de recursos humanos."     
    #     else
    #         redirect_to GetAppointments_appointment_index_path
    #     end
    # end
	
  	def index
      if current_user.role_id != 4
          @appointments = Appointment.joins(:client).joins(:user).joins(:case_type).where("status_app = 1 AND user_id = ? AND fecha = ?", current_user.id, params[:fecha]).all.select("numcaso", "client_id, tipocaso, nombre, apaterno, color_id, fecha, hora, nombreclt, apaternoclt, numpersonas, lower(comentario) as comnt, telefonoclt as tel, emailclt, attendance").order("hora ASC")
      else
          @appointments = Appointment.joins(:client).joins(:user).joins(:case_type).where("status_app = 1 AND fecha = ?", params[:fecha]).all.select("numcaso", "client_id, tipocaso, nombre, apaterno, color_id, fecha, hora, nombreclt, apaternoclt, numpersonas, lower(comentario) as comnt, telefonoclt as tel, emailclt, attendance").order("hora ASC")
      end

      #@appointments = Appointment.where(:user_id => current_user.id,:fecha => params[:fecha])
      respond_to do |format|
          format.html
          format.pdf do 
              pdf = AppointmentPdf.new(@appointments,current_user.role_id)
              send_data pdf.render, filename: "schedule.pdf", type: 'application/pdf'
          end
      end
  	end

  	def GetUserData
  	  	@usuario = current_user.nombre + " " + current_user.apaterno
  	  	@colorUno = current_user.color.color
  	  	@colorDos = current_user.color.colorsec
      	@rolUsuario = current_user.role.id
    end

    def GetAppointments
        if current_user.role_id != 4
    			 @appointments = Appointment.joins(:client).joins(:user).joins(:case_type).where("status_app = 1 AND user_id = ? AND fecha = ?", current_user.id,params[:fecha]).all.select("id", "client_id, tipocaso, nombre, apaterno, color_id, fecha, hora, nombreclt, apaternoclt, numpersonas, comentario, telefonoclt, emailclt, attendance")
    		else
    			 @appointments = Appointment.joins(:client).joins(:user).joins(:case_type).where("status_app = 1 AND fecha = ?", params[:fecha]).all.select("id", "user_id, client_id, tipocaso, nombre, apaterno, color_id, fecha, hora, nombreclt, apaternoclt, numpersonas, comentario, telefonoclt, emailclt, attendance")
    		end

    		respond_to do |format|
    			 format.json { render :text => @appointments.to_json }
    		end
    end

    def printSchedule
         
    end

    def GetAbogadosCasos
        #Validar ROLE en el LOgin para seleccionar asesor de consulta.
        if current_user.role_id == 1 || current_user.role_id == 2 || current_user.role_id == 4
            @abogados = User.where("role_id != 4 AND role_id != 1 ")
        else current_user.role_id == 3
            @abogados = User.where("role_id = 3 AND id = ?", current_user.id)
        end

        @tipocasos = CaseType.all
    end

    def getAllUsers
        @users = User.joins(:color).where("role_id != 4 AND role_id != 1 AND status = 2").all.select("id","nombre","apaterno","color_id","color").order("nombre ASC")

        respond_to do |format|
          format.json { render :json => @users }
        end
    end

    def GetAllColors
        @color = Color.all.select("id", "color", "colorsec")

        respond_to do |format|
          format.json { render :text => @color.to_json } 
        end
    end
end
