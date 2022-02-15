class ApplicationController < ActionController::API
  before_action :set_default_format_json

  protected

  def set_default_format_json
    request.format = :json if request.format == '*/*'
  end

  def render_error(message, status = 400)
    render json: { error: true, message: message }, status: status
  end

  def render_success(message, status = 200)
    render json: { success: true, message: message }, status: status
  end

  def render_model_errors(objects)
    json = { error: true, message: 'validation error', errors: [] }
    objects.each_pair do |key, obj|
      json[:errors] += (obj.errors.details || {}).flat_map do |field, errors|
        errors.flat_map do |error|
          { object: key, field: field.to_s, details: error }
        end
      end
    end
    render json: json, status: 422
  end
end
