# frozen_string_literal: true

class DestroyFileJob < ApplicationJob
  queue_as :default

  def perform(imported_file)
    ImportedFile.transaction do
      imported_file.file.purge_later
      imported_file.destroy
    end
  end
end
