class UsuariosController < ApplicationController
  skip_before_action :authorize, only: [:new, :create]
  before_action :redirect_if_logged_in, only: [:new, :create]
  before_action :set_usuario, only: [:show, :edit, :update, :destroy]
  before_action :correct_usuario, only: [:show, :edit, :update]

  def show
    @mostrar_boton_eliminar = true
    @anuncios = @usuario.anuncios.order(created_at: :desc)
  end

  def new
    @usuario = Usuario.new
  end

  def create
    @usuario = Usuario.new(usuario_params)
    if @usuario.save
      session[:usuario_id] = @usuario.id
      redirect_to @usuario, notice: "Usuario creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @usuario ya se ha establecido en set_usuario
  end

  def update
    if @usuario.update(usuario_params)
      redirect_to @usuario, notice: "Usuario actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @usuario = Usuario.find(params[:id])
    if @usuario == current_usuario
      @usuario.destroy
      session[:usuario_id] = nil # Asegúrate de cerrar sesión después de eliminar al usuario
      redirect_to root_path, notice: "Usuario eliminado exitosamente."
    else
      redirect_to root_path, alert: "No tienes permiso para realizar esta acción."
    end
  end
  

  private

  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  def correct_usuario
    redirect_to root_path, alert: "No autorizado para acceder a esta página." unless @usuario == current_usuario
  end

  def usuario_params
    params.require(:usuario).permit(:email, :password, :password_confirmation, :nombre, :ciudad, :tlf)
  end

  def redirect_if_logged_in
    if session[:usuario_id]
      redirect_to root_path, alert: "Ya has iniciado sesión."
    end
  end

  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id])
  end
end
