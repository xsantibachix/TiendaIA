require 'net/http'
require 'json'
require 'uri'

class AnunciosController < ApplicationController
  
  def create
    @usuario = Usuario.find(params[:usuario_id])

    unless params[:anuncio][:image].nil?
   
      @anuncio = @usuario.anuncios.create(anuncio_params)
    
   
 
      image = params[:anuncio][:image]
      response = send_image_to_flask_api(image)

     if handle_image_response(response)
        if @anuncio.save
          flash[:notice] = "Anuncio creado exitosamente"
          redirect_to @usuario
        else
          flash[:alert] = "Error creando el anuncio"
          redirect_to @usuario
        end
      else
        redirect_to @usuario
      end
    else
      flash[:alert] = "Debe subir una imagen"
      render :new
    end
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
