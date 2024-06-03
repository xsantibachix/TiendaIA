require 'net/http'
require 'json'
require 'uri'

class AnunciosController < ApplicationController
  skip_before_action :authorize, only: [:index]

  def index
    @anuncios = Anuncio.all.order(created_at: :desc)
  end

  def create
    @usuario = Usuario.find(params[:usuario_id])

    if params[:anuncio].present? && params[:anuncio][:image].present?
      @anuncio = @usuario.anuncios.build(anuncio_params)
      image = params[:anuncio][:image]
      response = send_image_to_flask_api(image)

      if handle_image_response(response)
        if @anuncio.save
          flash[:notice] = "Anuncio creado exitosamente"
        else
          flash[:alert] = "Error creando el anuncio"
        end
      end
      redirect_to @usuario
    else
      flash[:alert] = "Debe subir una imagen"
      redirect_to @usuario
    end
  end

  def destroy
    @usuario = Usuario.find(params[:usuario_id])
    @anuncio = @usuario.anuncios.find(params[:id])
    @anuncio.destroy
    redirect_to usuario_path(current_usuario), notice: "Anuncio eliminado exitosamente."
  end

  private

  def anuncio_params
    params.require(:anuncio).permit(:image)
  end

  def send_image_to_flask_api(image)
    uri = URI.parse('http://localhost:5000/analyze_image')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    form_data = [['image', image.tempfile]]
    request.set_form form_data, 'multipart/form-data'
    response = http.request(request)
    JSON.parse(response.body)
  end

  def handle_image_response(response)
    if response["error"]
      if response["error"].include?("invalid_image_format")
        flash[:alert]="Solo se permiten los siguientes formatos [png, jpeg, gif, webp]"
      else
        flash[:alert] = "Error procesando la imagen: #{response['error']}"
      end
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
