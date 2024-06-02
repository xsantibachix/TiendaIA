class SessionsController < ApplicationController
    skip_before_action :authorize, only: [:new, :create]
    before_action :redirect_if_logged_in, only: [:new, :create]
  
    def new
    end
  
    def create
      usuario = Usuario.find_by(email: params[:email])
      if usuario
        if usuario.authenticate(params[:password])
          session[:usuario_id] = usuario.id
          redirect_to usuario_path(usuario), notice: "Inicio de sesión exitoso."
        else
          flash.now[:alert] = "Contraseña inválida."
          render :new, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = "Email inválido."
        render :new, status: :unprocessable_entity
      end
    end
  
    def destroy
      session[:usuario_id] = nil
      redirect_to root_path, notice: "Cierre de sesión exitoso."
    end
  
    private
  
    def redirect_if_logged_in
      if session[:usuario_id]
        redirect_to root_path, alert: "Ya has iniciado sesión."
      end
    end
  end
  