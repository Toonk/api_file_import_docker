# frozen_string_literal: true

class ImportedFilesController < ApplicationController
  include PaginationHandler

  before_action :check_file, only: %i[create]

  def index
    @objects = ImportedFile.paginate(page: @page, per_page: @per_page)
  end

  def create
    @object = ImportedFile.new(create_params)
    @object.save ? render_success(id: @object.id) : render_object_model_errors
  end

  private

  def check_file
    return render_error('no_file') if file.blank?
    return render_error('file_too_large') if file.size > MAX_FILE_SIZE
    return render_error('invalid_file_format') unless file.content_type.in?(ALLOWED_FILE_CONTENT_TYPES)
  end

  def create_params
    params.require(:imported_file).permit(:file)
  end

  def render_object_model_errors
    render_model_errors(imported_file: @object)
  end

  def file
    create_params[:file]
  end
end
