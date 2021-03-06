Rails.application.routes.draw do

  get "welcome/dashboard", to: "welcome#dashboard"
  get 'users/index'
  get 'users/show'
  post 'users/ChangeUserColor'
  get 'day/GetAllColors'
  get 'day/index'
  get 'users/variety'
  post 'day/getAllUsers'

  get 'monthly/index'
  get 'appointment/index'
  get 'day/index'
  post "appointment/GetVacationPeriod"
  post 'day/GetAppointments'
  post 'appointment/nuevaCita'
  post 'appointment/nuevoCliente'
  post 'appointment/update'
  post 'appointment/cancelAppointment'
  post 'appointment/getAssistant'
  post 'appointment/searchCustomer'
  post 'appointment/Attendance'
  post "appointment/GetAssistantAppointments"
  post "appointment/CheckAnnouncement"
  post "appointment/PrintSchedulePDF"

  post "log/GetFullLog"
  get "log/GetLogActions"
  get "log/GetAdmins"
  get "log/GetUsersLog"
  post "log/SetVacationPeriod"
  get "log/GetAllCaseTypes"
  post "log/GetUserCaseTypes"
  post "log/SetUserTask"
  post "log/TaskRemove"
  post "log/GetUsersByStatus"
  post "log/GetUserInformation"
  post "log/SetAnnouncement"
  post "log/ActivateUserAccount"
  post "log/BlockUserAccount"
  post "log/GetUserAnnouncements"

  #Temp
  get "log/colorList"

  resources :appointment do
      collection do
          get 'GetAppointments'
      end
  end

  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'users#index'
  get 'welcome/log_in'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
