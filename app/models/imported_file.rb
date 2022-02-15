# frozen_string_literal: true

class ImportedFile < ApplicationRecord
  include AASM
  include FireEvent

  has_one_attached :file

  serialize :preview

  validates :checksum, allow_nil: true, length: { maximum: 255 }, uniqueness: true
  validates :preview, allow_blank: true, length: { maximum: PREVIEW_LENGTH_LIMIT }

  validate :correct_preview_string_limit

  after_create :process!

  aasm column: 'status' do
    state :created, initial: true
    state :failed, :processing, :ready

    event :process do
      transitions from: :created, to: :processing, after: :process_file
    end

    event :process_fail do
      transitions fron: :processing, to: :failed, after: :destroy_object
    end

    event :process_success do
      transitions fron: :processing, to: :ready
    end
  end

  private

  def correct_preview_string_limit
    return if preview.to_s.length <= PREVIEW_LENGTH_LIMIT

    errors.add(:preview, message: "Exceeded length limit of: #{PREVIEW_LENGTH_LIMIT}")
  end

  def process_file
    ProcessFileJob.set(wait: 5).perform_later(self)
  end

  def destroy_object
    DestroyFileJob.perform_later(self)
  end
end
