class ApplicationController < ActionController::Base
    include ActionController::Cookies
  
    before_action :authorize
    helper_method :current_usuario # Hace que el método esté disponible en las vistas
  
    private
  
    def authorize
      unless current_usuario
        redirect_to login_path, alert: "No autorizado. Por favor, inicia sesión."
      end
    end
  
    def current_usuario
      @current_usuario ||= Usuario.find_by(id: session[:usuario_id])
    end
  
    def render_unprocessable_entity_response(exception)
      render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
    end
  end
  