class AppointmentController < ApplicationController
	before_action :authenticate_user!
	before_action :GetUserData
  #before_action :CheckIfUserIsActive
	before_action :GetAbogadosCasos

	def index
	end

	def new
    @appointment = Appointment.new
	end

	def create
	end

  def show
  end

  def update
      @appointment = Appointment.where("id = ?", params[:id]).first
      client_id = @appointment.client_id
      client = Client.where(:id => client_id).update_all(:nombreclt => params[:nName],:apaternoclt => params[:nApa],:amaternoclt => params[:nAma],:numcaso => params[:n_Caso],:telefonoclt => params[:nTel],:emailclt=>params[:nMail])




      appCheck = Appointment.where(:fecha => params[:fecha], :hora => params[:hora], :user_id => params[:user_id], :status_app => 1).count

      if appCheck > 0
          respond_to do |format|
              format.json { render :text => appCheck.to_json }
          end
      else 
          Appointment.where("id = ?", params[:id]).update_all(:fecha => params[:fecha], :hora => params[:hora], :comentario => params[:nComnt], :case_type_id => params[:newCtype], :user_id => params[:user_id], :last_edited_by_id => current_user.id)
          #@appointment.update_all(:fecha => params[:fecha], :hora => params[:hora], :user_id => params[:user_id], :last_edited_by => current_user.id)

          appmnt = Appointment.where("id = ?", params[:id]).first

          customer = appmnt.client_id
          client = Client.where(:id => customer).first
          fechaStr = appmnt.fecha.strftime('%v').to_s
          horaStr = appmnt.hora.strftime('%r')
          user = appmnt.user_id
          lawyer = User.where(:id => user).first

          LogAppointment(current_user,5,client,fechaStr,horaStr,lawyer)

          respond_to do |format|
              format.json { render :text => @appointment.to_json }
          end
      end
          

      
  end

	def GetUserData
	  @usuario = current_user.nombre + " " + current_user.apaterno
	  @colorUno = current_user.color.color
	  @colorDos = current_user.color.colorsec
    @rolUsuario = current_user.role.id
  end

  def nuevoCliente
      @cliente = Client.new(client_params);

      respond_to do |format|
          if @cliente.save
              format.json { render :text => @cliente.to_json, status: :created, location: @client}
          else
              format.json { render json: @client.errors, status: :unprocesable_entity }
          end
      end
  end

  def nuevaCita
      @appointment = Appointment.new(appointment_params);
      @appointment.created_by_id = current_user.id
      @appointment.last_edited_by_id = current_user.id

      @cliente = Client.where(:id => :client_id)
      clienteDst = Client.where(:id => :client_id)

      fecha = @appointment.fecha
      hora = @appointment.hora
      user = @appointment.user_id

      @appCheck = Appointment.where("fecha = ? AND hora = ? AND user_id = ? AND status_app = 1", fecha, hora, user).count

      if @appCheck > 0
          clientId = @appointment.client_id
          Client.where(:id => clientId).delete_all
          respond_to do |format|
               format.json { render :text => @appCheck }
              #format.json { render :text => "Ya existe una cita activa para esa fecha y en ese horario", status: :created, head: :ok }
          end
      else
          respond_to do |format|
             if @appointment.save

                  lawyer = User.where(:id => user).first
                  customer = @appointment.client_id
                  client = Client.where(:id => customer).first
                  fechaStr = @appointment.fecha.strftime('%v').to_s
                  horaStr = @appointment.hora.strftime('%r')


                  LogAppointment(current_user,4,client,fechaStr,horaStr,lawyer)
                  #@action = Action.where(:id => 6).select(:id)
                  #lawyer.nombre + " " + @action + " el dia " + fecha

                  Apps.notify_lawyer(lawyer, client, fechaStr, horaStr).deliver_later!

                  if client.emailclt != nil
                      Apps.notify_client(lawyer, client, fechaStr, horaStr).deliver_later!
                  else

                  end
                #format.html { redirect_to @appointment, notice: "Cita creada exitosamente" }
                  format.json { render :text => @appointment.to_json, status: :created, head: :ok }

             else
                #format.html { render :new }
                  format.json { render json: @appointment.errors, status: :unprocesable_entity }
             end
          end
      end
  end

  def cancelAppointment
      @appointment = Appointment.find(params[:id])
      @appointment.update_attribute(:status_app, 0)
      @appointment.last_edited_by_id = current_user.id
      appmnt = Appointment.where("id = ?", params[:id]).first
      
      user = appmnt.user_id
      lawyer = User.where(:id => user).first
      customer = @appointment.client_id
      client = Client.where(:id => customer).first
      fechaStr = @appointment.fecha.strftime('%v').to_s
      horaStr = @appointment.hora.strftime('%r')

      LogAppointment(current_user,6,client,fechaStr,horaStr,lawyer)

      respond_to do |format|
          format.json { render :text => @appointment.to_json }
      end
  end
''
  def LogAppointment(user,action,client,fecha,hora,lawyer)

      request.remote_ip
      @remote_ip = request.remote_ip#request.env["HTTP_X_FORWARDED_FOR"]
      
      descripcion = Action.find(action)
      @log = History.new(:user_id => user.id,:action_id => 6,:fechalog => Time.now,:client_id => client.id,:detalles => descripcion.accion + " para " + lawyer.nombre + " " + lawyer.apaterno + " con " + client.nombreclt + " " + client.apaternoclt + " para el dia " + fecha + " a las " + hora + ".",:ubicacion => @remote_ip)
      @log.save
  end

	def GetAbogadosCasos
      #Validar ROLE en el LOgin para seleccionar asesor de consulta.
      if current_user.role_id == 1 || current_user.role_id == 2 || current_user.role_id == 4
          @abogados = User.where("role_id != 4 AND role_id != 1 ")
          @tipocasos = CaseType.all
      else current_user.role_id == 3
		      @abogados = User.where("role_id = ? AND id = ?", 3, current_user.id)
          @tipocasos = current_user.case_type.all.select("id", "tipocaso");
      end

		  
	end

  def GetAppointments
      if current_user.role_id != 3
          @weekAppointments = Appointment.joins(:client).joins(:user).joins(:case_type).where("status_app = 1 AND fecha >= ? AND fecha <= ? ", params[:fecha1],params[:fecha2]).all.select("id","nombre, apaterno, color_id", "user_id, client_id, tipocaso, fecha, hora, nombreclt, apaternoclt, amaternoclt, numcaso, numpersonas, comentario, telefonoclt, emailclt, attendance, created_by_id, last_edited_by_id")
          #@weekAppointments = Appointment.joins(:client).joins(:lawyer).joins(:creator).joins(:case_type).where("status_app = 1 AND fecha >= ? AND fecha <= ? ", params[:fecha1],params[:fecha2]).all.select("id","nombre, apaterno, color_id", "user_id, client_id, tipocaso, fecha, hora, nombreclt, apaternoclt, numpersonas, comentario, telefonoclt, emailclt, attendance")
          #@weekAppointments = Appointment.joins(:client).joins(:user).includes(:created_by).joins(:case_type).where("status_app = 1 AND fecha >= ? AND fecha <= ? ", params[:fecha1],params[:fecha2]).all.select("id, client_id, nombre, apaterno, color_id","created_by_id")
          #.select("user_id, client_id, tipocaso, fecha, hora, nombreclt, apaternoclt, numpersonas, comentario, telefonoclt, emailclt, attendance").select("nombre, apaterno, color_id") 
      else
          @weekAppointments = Appointment.joins(:client).joins(:case_type).where("user_id = ? AND status_app = 1 AND fecha >= ? AND fecha <= ?", current_user.id, params[:fecha1],params[:fecha2]).select("id", "client_id, fecha, hora, nombreclt, apaternoclt, amaternoclt, numcaso, numpersonas, comentario, telefonoclt, emailclt, attendance, created_by_id, last_edited_by_id, tipocaso")
      end

      respond_to do |format|
          format.json { render :text => @weekAppointments.to_json }
      end
  end

  def GetAssistantAppointments
      if current_user.role_id == 2
          @weekAppointments = Appointment.joins(:client).joins(:case_type).joins(:user).where("user_id = ? AND status_app = 1 AND fecha >= ? AND fecha <= ?", params[:lawyerId], params[:fecha1],params[:fecha2]).select("id", "client_id, fecha, hora, nombreclt, apaternoclt, numpersonas, comentario, telefonoclt, emailclt, attendance, nombre, apaterno, tipocaso")
      else
          @weekAppointments = 0
      end

      respond_to do |format|
          format.json { render :text => @weekAppointments.to_json }
          format.json { render json: @weekAppointments.errors }
      end
  end

  def getAssistant
      @caseTpe = CaseType.find(params[:idCstype])
      @lawyers = @caseTpe.users.all.select("id","nombre","apaterno")

      respond_to do |format|
          format.json { render :text => @lawyers.to_json }
      end
  end

  def searchCustomer
      client = params[:client]
      option = params[:opt]
      
      # opt = params[:opt]

      # if opt == 1
      #     @client = Client.where("lower(nombreclt) = ? AND lower(apaternoclt) = ? OR lower(emailclt) = ? OR telefonoclt = ? OR numcaso = ?", params[:name].downcase,params[:apaterno].downcase,params[:email].downcase,params[:telefono],params[:numcase]).first
      # elsif == 2

      # elsif  == 3

      # elsif == 4
        
      if option == 1
        @client = Client.where("lower(apaternoclt) = ? AND status_app = 1",client.downcase).joins(:appointment).select("nombreclt, apaternoclt, telefonoclt, fecha, hora").order("fecha ASC").all
      elsif option == 2
        @client = Client.where("telefonoclt = ? AND status_app = 1",client).joins(:appointment).select("nombreclt, apaternoclt, telefonoclt, fecha, hora").order("fecha ASC").all
      else
        @client = nil
      end
        
      respond_to do |format|
          format.json { render :text => @client.to_json }
      end
  end

  def Attendance
      @appointment = Appointment.find(params[:id])

      if @appointment != nil
          option = params[:opt]
          if option == true
              @appointment.update_attribute(:attendance, true)

              respond_to do |format|
                  format.json { render :json => @appointment.to_json }
              end

          elsif option == false
              @appointment.update_attribute(:attendance, false)

              respond_to do |format|
                  format.json { render :json => @appointment.to_json }
              end
          end
      else
          respond_to do |format|
              format.json { render :json => @appointment.to_json }
          end
      end
  end

  def CheckAnnouncement
      hora = params[:hora]
      @avisos = Announcement.where("id_user = ? AND fecha = ? AND completo = ?",params[:user],params[:fecha],true).all 

      if @avisos.size < 1     
          @avisos = Announcement.where("id_user = ? AND fecha = ? AND horainicio <= ? AND horafinal > ?",params[:user],params[:fecha],params[:hora].to_time,params[:hora].to_time).all
      else
      end

      @vacation = Vacation.where("user_id = ? AND startdate <= ? AND enddate >= ?",params[:user],params[:fecha],params[:fecha]).all
      ausencias = { avisos: @avisos, vacaciones: @vacation };

      if @avisos.size > 0 || @vacation.size > 0
          respond_to do |format|
              format.json { render :text => ausencias.to_json }
          end
      else
        aviso = nil
          respond_to do |format|
              format.json { render :text => @aviso.to_json }
          end
      end
      
  end

  def GetVacationPeriod
      if current_user.role_id != 4
          @vacations = Vacation.where("user_id = ? AND startdate >= ?",current_user.id,params[:fd]).all
          #@vacations = Vacation.where(:user_id => current_user.id, :startdate >= params[:fd], :enddate <= params[:ld]).all
      else
          @vacations = Vacation.where("startdate >= ?",params[:fd]).all
          #@vacations = Vacation.where(:startdate >= params[:fd], :enddate <= params[:ld]).select("startdate,enddate,comment").all
      end

      respond_to do |format|
          format.json { render :text => @vacations.to_json }
      end
  end

  private 

  def cancel_params
      params.require(:appointment).permit(:id, :fecha, :hora)
  end

  def client_params
    params.require(:client).permit(:nombreclt,:apaternoclt,:amaternoclt,:emailclt,:direccion,:telefonoclt, :numcaso)
  end

  def check_params
      params.require(:appointment).permit(:fecha, :hora, :user_id)
  end

	def appointment_params
		params.require(:appointment).permit(:numpersonas, :fecha, :hora, :comentario, :client_id, :user_id, :case_type_id, :tipocita)
	end

  def log_params
    params.require(:history).permit(:user_id,:action_id,:fecha,:client_id,:detalles,:ubicacion)
  end

end