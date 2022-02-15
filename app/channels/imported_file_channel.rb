# frozen_string_literal: true

class ImportedFileChannel < ApplicationCable::Channel
  def subscribed
    @object = ImportedFile.find_by(id: params[:id])
    stream_for @object
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
