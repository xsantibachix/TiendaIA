# app/controllers/usuarios_controller.rb
class UsuariosController < ApplicationController

  def index
    @usuarios = Usuario.all
  end

  def show
    @usuario = Usuario.find(params[:id])
  end

  def new
    @usuario = Usuario.new
  end


  def create
    @usuario = Usuario.new(usuario_params)
    if @usuario.save
      redirect_to @usuario
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @usuario= Usuario.find(params[:id])
  end

  def update
    @usuario = Usuario.find(params[:id])

    if @usuario.update(usuario_params)
      redirect_to @usuario
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def usuario_params
    params.require(:usuario).permit(:nombre, :ciudad, :tlf)
  end
end
