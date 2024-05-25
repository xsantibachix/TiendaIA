require 'net/http'
require 'json'
require 'uri'

class AnunciosController < ApplicationController
  before_action :set_usuario, only: [:new, :create, :show]
  before_action :set_anuncio, only: [:show]

  def new
    @anuncio = @usuario.anuncios.build
  end

  def create
    @anuncio = @usuario.anuncios.build(anuncio_params)

    if params[:anuncio][:image].present?
      image = params[:anuncio][:image]
      response = send_image_to_flask_api(image)

      if handle_image_response(response)
        if @anuncio.save
          flash[:notice] = "Anuncio creado exitosamente"
          redirect_to usuario_anuncio_path(@usuario, @anuncio)
        else
          flash[:alert] = "Error creando el anuncio"
          render :new
        end
      else
        render :new
      end
    else
      flash[:alert] = "Debe subir una imagen"
      render :new
    end
  end

  def show
    # @anuncio se define en el callback set_anuncio
  end

  private

  def set_usuario
    @usuario = Usuario.find(params[:usuario_id])
  end

  def set_anuncio
    @anuncio = @usuario.anuncios.find(params[:id])
  end

  def anuncio_params
    params.require(:anuncio).permit(:image)
  end

  def send_image_to_flask_api(image)
    uri = URI.parse('http://localhost:5000/analyze_image') # Ajusta la URL según sea necesario
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    form_data = [['image', image.tempfile]]
    request.set_form form_data, 'multipart/form-data'
    response = http.request(request)
    JSON.parse(response.body)
  end

  def handle_image_response(response)
    if response["error"]
      flash[:alert] = "Error procesando la imagen: #{response['error']}"
      return false
    end

    if !response["enfoque"]
      flash[:alert] = "La imagen está desenfocada. Por favor, sube una imagen clara."
      return false
    elsif response["dedo"]
      flash[:alert] = "La imagen contiene un dedo que impide ver el producto. Por favor, sube una imagen sin obstrucciones."
      return false
    end

    @anuncio.assign_attributes(
      titulo: response["titulo"],
      descripcion: response["descripcion"],
      estado: response["estado"],
      marca: response["marca"],
      modelo: response["modelo"],
      daño: response["daño"]
    )
    true
  end
end
