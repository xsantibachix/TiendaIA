# app/controllers/usuarios_controller.rb
class UsuariosController < ApplicationController
  def new
    @usuario = Usuario.new
  end

  def create
    @usuario = Usuario.new(usuario_params)
    if @usuario.save
      redirect_to new_usuario_anuncio_path(@usuario)
    else
      render :new
    end
  end

  private

  def usuario_params
    params.require(:usuario).permit(:nombre, :ciudad, :tlf)
  end
end
