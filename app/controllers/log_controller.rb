class LogController < ApplicationController
	#before_action :CheckIfUserIsActive

	# def CheckIfUserIsActive
	# 	if current_user.status != 2
	# 		redirect_to root_path
	# 	else
	# 		redirect_to new_user_session_path, :notice => "Tu cuenta no esta activa, verificalo con el personal de recursos humanos."
	# 	end
	# end
	
	def GetUserInformation
		if current_user.role_id == 3 || current_user.role_id == 4
			msg = "No tienes permisos para esta operacion"
			respond_to do |format|
				format.json { render :text => msg.to_json }
			end
		else
			@user = User.joins(:color).where(:id => params[:user]).select("nombre,apaterno,email,telefono,last_sign_in_at as fechaSsn,last_sign_in_ip as ip,color as color1,colorsec as color2,status")
			respond_to do |format|
				format.json { render :text => @user.to_json }
			end
		end
	end

	def GetFullLog
		user = params[:user_id]
		action = params[:action_id]
		date1 = params[:date1]
		date2 = params[:date2]

		# @action = History.joins(:user).select("nombre, apaterno, fechalog, detalles, ubicacion").all
		@action = Appointment.joins("INNER JOIN clients c on c.id = appointments.client_id").where("fecha > ? AND fecha < ? AND case_type_id = 4 OR case_type_id = 28","2016-12-18","2016-12-24").select("nombreclt, apaternoclt, amaternoclt, fecha, hora, created_by_id").all

		if user == "" && action == "" && date1 == "" && date2 == ""
			respond_to do |format|
				format.json { render :text => @action.to_json  }
			end
		else
			if user != nil && action == "" && date1 == "" && date2 == "" 
				@actions = History.joins(:user).select("nombre, apaterno, fechalog, detalles, ubicacion").where(:user_id => user).all
			elsif user == "" && action != nil && date1 == "" && date2 == ""
				@actions = History.joins(:user).select("nombre, apaterno, fechalog, detalles, ubicacion").where(:action_id => action).all
			elsif user == "" && action == "" && date1 != nil && date2 != nil
				@actions = History.joins(:user).select("nombre, apaterno, fechalog, detalles, ubicacion").where("fechaLog > ? AND fechaLog < ?",date1,date2).all
			elsif user != nil && action != nil && date1 != nil && date2 != nil
			 	@actions = History.joins(:user).select("nombre, apaterno, fechalog, detalles, ubicacion").where("user_id = ? AND action_id = ? AND fechalog > ? AND fechalog < ?",user,action,date1,date2).all
			end

			respond_to do |format|
				format.json { render :text => @actions.to_json  }
			end
		end
	end

	def GetLogActions
		@actions = Action.all
		respond_to do |format|
			format.json { render :text => @actions.to_json }
		end
	end

	def GetUserCaseTypes
		usr = params[:usr]

		if usr == "" || usr == nil
			@userCases = Assignment.joins(:case_type).joins(:user).where(:user_id => current_user.id).select("case_type_id as id, tipocaso").all
		else
			@userCases = Assignment.joins(:case_type).joins(:user).where(:user_id => usr).select("case_type_id as id, tipocaso").all
		end

		respond_to do |format|
			format.json { render :text => @userCases.to_json } 
		end
	end

	def GetAllCaseTypes
		@caseTypes = CaseType.select("id, tipocaso").all
		respond_to do |format|
			format.json { render :text => @caseTypes.to_json }
		end
	end

	def SetUserTask
		user = params[:user]

		if user == "" || user == nil
			@assingCheck = Assignment.where(:user_id => current_user.id, :case_type_id => params[:task]).count
			CountAnsSave(@assingCheck,nil)
		else
			@assingCheck = Assignment.where(:user_id => user, :case_type_id => params[:task]).count
			CountAnsSave(@assingCheck,user)
		end
	end

	def CountAnsSave(count,user)
		if count > 0
			respond_to do |format|
				format.json { render :text => count }
			end
		else
			if user == nil
				@newUserTask = Assignment.create(:user_id => current_user.id, :case_type_id => params[:task])
			else
				@newUserTask = Assignment.create(:user_id => user, :case_type_id => params[:task])
			end

			if @newUserTask.save
				if user == nil
					@cases = Assignment.joins(:case_type).joins(:user).where(:user_id => current_user.id).select("case_type_id as id, tipocaso").all
				else
					@cases = Assignment.joins(:case_type).joins(:user).where(:user_id => user).select("case_type_id as id, tipocaso").all
				end

				respond_to do |format|
					format.json { render :text => @cases.to_json }
				end
			else
				respond_to do |format|
					format.json { render :json => "Something went wrong" }
				end
			end
		end
	end

	def TaskRemove
		user = params[:user]

		if user == nil || user == ""
			@userTask = Assignment.where(:user_id => current_user.id, :case_type_id => params[:ctype]).delete_all
			@cases = Assignment.joins(:case_type).joins(:user).where(:user_id => current_user.id).select("case_type_id as id, tipocaso").all
		else
			@userTask = Assignment.where(:user_id => user, :case_type_id => params[:ctype]).delete_all
			@cases = Assignment.joins(:case_type).joins(:user).where(:user_id => user).select("case_type_id as id, tipocaso").all
		end

		respond_to do |format|
			format.json { render :text => @cases.to_json }
		end
	end

	def GetUsersLog
		@users = User.all
		respond_to do |format|
			format.json { render :text => @users.to_json }
		end
	end

	def SetAnnouncement
		horaOut = params[:horainicio]
		horaIn = params[:horafinal]
		allDayLong = params[:allDay]
		# horaOut = horaOut.strftime('%r')
		# horaIn = horaIn.strftime('%r')

		@announce = Announcement.create(:titulo => params[:titulo], :fecha => params[:fecha], :comentario => params[:comentario], :horainicio => horaOut, :horafinal => horaIn, :completo => allDayLong, :id_user => params[:user], :authorized_by => params[:auth], :created_by => current_user.id, :last_edited_by => current_user.id, :type_announce => params[:type])

		if @announce.save
			respond_to do |format|
				format.json { render :text => @announce.to_json }
			end
		else
			respond_to do |format|
				format.json { render json: @announce.errors, status: :unprocesable_entity }
			end
		end
	end

	def GetUserAnnouncements
		avisos = Announcement.joins("INNER JOIN users x ON x.id = announcements.id_user").joins("INNER JOIN users y ON y.id = announcements.authorized_by").joins("INNER JOIN users z ON z.id = announcements.last_edited_by").select("announcements.id, announcements.status_announce, x.nombre as naus, x.apaterno as napa, y.nombre as naut, y.apaterno as nata, z.nombre as nedt, z.apaterno as neta, announcements.fecha, announcements.titulo, announcements.type_announce, announcements.horainicio,announcements.horafinal, announcements.comentario")

		if avisos.size > 0
			respond_to do |format|
				format.json { render :text => avisos.to_json }
			end
		else
			avisos = nil
			respond_to do |format|
				format.json { render :text => avisos.to_json }
			end
		end
	end

	def GetAdmins
		admins = User.where(:role_id => 2, :status => 2)

		if admins.size > 0
			respond_to do |format|
				format.json { render :text => admins.to_json}
			end
		else
			admins = nil
			respond_to do |format|
				format.json { render :text => admins.to_json }
			end
		end
	end

	def SetVacationPeriod
		startDate = params[:start]
		endDate = params[:end]
		comment = params[:comment]

		@vacation = Vacation.create(:startdate => startDate, :enddate => endDate, :comment => comment, :user_id => current_user.id)

		if @vacation.save
			respond_to do |format|
				format.json { render :text => @vacation.to_json }
			end
		else
			respond_to do |format|
				format.json { render json: @vacation.errors, status: :unprocesable_entity }
			end
		end

	end

	def ActivateUserAccount
		activo = 0
		if current_user.role_id == 1 || current_user.role_id == 2
			if params[:user] != nil || params[:user] != ""
				user = User.where(:id => params[:user]).update_all(:status => 2)
				activo = 1

				respond_to do |format|
					format.json { render :text => activo.to_json }
				end
			else
				respond_to do |format|
					format.json { render :text => activo.to_json }
				end
			end
		else
			respond_to do |format|
				format.json { render :text => activo.to_json }
			end
		end
	end

	def BlockUserAccount
		activo = 0
		if current_user.role_id == 1 || current_user.role_id == 2
			if params[:user] != nil || params[:user] != ""
				user = User.where(:id => params[:user]).update_all(:status => 1)
				activo = 1

				respond_to do |format|
					format.json { render :text => activo.to_json }
				end
			else
				respond_to do |format|
					format.json { render :text => activo.to_json }
				end
			end
		else
			respond_to do |format|
				format.json { render :text => activo.to_json }
			end
		end
	end

	def GetUsersByStatus
		status = params[:status]
		role = params[:role]

		@users = User.select("id, nombre, apaterno, email, telefono, role_id as rol, created_at as fechaIng, status, current_sign_in_ip as ip").all

		if status != "" && role == ""
			@users = User.where(:status => status).select("id, nombre, apaterno, email, telefono, role_id as rol, created_at as fechaIng, status, current_sign_in_ip as ip").all
		elsif status == "" && role != ""
			@users = User.where(:role_id => role).select("id, nombre, apaterno, email, telefono, role_id as rol, created_at as fechaIng, status, current_sign_in_ip as ip").all
		elsif status != "" && role != ""
			@users = User.where(:role_id => role, :status => status).select("id, nombre, apaterno, email, telefono, role_id as rol, created_at as fechaIng, status, current_sign_in_ip as ip").all
		end 

		respond_to do |format|
			format.json { render :text => @users.to_json }
		end
			
	end

	#TEMP
	def colorList
		#@color = User.joins(:color).select("color as color1, colorsec, nombre, apaterno, used").all
		@color = Color.where("used != ?",true).select("id, color as color1, colorsec as color2").all
		respond_to do |f|
			f.json { render :text => @color.to_json }
		end
	end
end