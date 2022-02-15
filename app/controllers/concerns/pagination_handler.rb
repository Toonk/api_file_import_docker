# frozen_string_literal: true

module PaginationHandler
  extend ActiveSupport::Concern

  included do
    before_action :set_pagination, only: %i[index]
  end

  private

  def set_pagination
    @per_page = (params[:per_page] || 30).to_i
    @page = (params[:page] || 1).to_i
  end
end
