# frozen_string_literal: true

Rails.application.routes.draw do
  resources :imported_files, only: %i[index create]
end
