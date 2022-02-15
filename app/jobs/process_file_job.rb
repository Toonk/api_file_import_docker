# frozen_string_literal: true

class ProcessFileJob < ApplicationJob
  queue_as :default

  def perform(imported_file)
    @object = imported_file
    @file = imported_file.file
    @object.assign_attributes(checksum: @file.blob.checksum, preview: fetch_preview)
    @object.save && @object.preview != { rows: [] } ? handle_success : handle_error
  rescue
    handle_error
  end

  private

  def fetch_preview
    result = { rows: [] }
    case @file.blob.filename.extension
    when 'csv' then fetch_previev_for_csv(result)
    when 'xlsx', 'xls' then fetch_previev_for_excel(result)
    end
    result
  end

  def fetch_previev_for_csv(result)
    CSV.foreach(ActiveStorage::Blob.service.path_for(@file.key), encoding: 'iso-8859-1:utf-8').with_index do |row, idx|
      break if idx > PREVIEW_ROWS_LIMIT

      idx.zero? ? result[:headers] = row : result[:rows] << row
      broadcast_progress(fetch_progress(idx))
    end
  end

  def fetch_previev_for_excel(result)
    @file_to_process = fetch_file_to_process
    return result[:headers] = [] unless @file_to_process.first_row

    last_row = @file_to_process.last_row
    fetch_header_for_non_csv_and_broadcast(result)
    return if last_row == 1

    (2..fetch_last_row(last_row)).each { |idx| fetch_row_for_non_csv_and_broadcast(result, idx) }
  end

  def fetch_file_to_process
    Roo::Spreadsheet.open(ActiveStorage::Blob.service.path_for(@file.key), extension: @file.blob.filename.extension)
  end

  def fetch_header_for_non_csv_and_broadcast(result)
    result[:headers] = @file_to_process.row(1)
    broadcast_progress(fetch_progress(0))
  end

  def fetch_row_for_non_csv_and_broadcast(result, idx)
    result[:rows] << @file_to_process.row(idx)
    broadcast_progress(fetch_progress(idx - 1))
  end

  def fetch_last_row(file_last_row)
    (PREVIEW_ROWS_LIMIT + 1) < file_last_row ? PREVIEW_ROWS_LIMIT + 1 : file_last_row
  end

  def fetch_progress(idx)
    ((idx.to_f / (PREVIEW_ROWS_LIMIT + 1)) * 100).round(2)
  end

  def handle_success
    broadcast_progress(100, 'success')
    @object.process_success!
  end

  def handle_error
    broadcast_progress(100, 'failed')
    @object.process_fail!
  end

  def broadcast_progress(progress, status = 'processing')
    ImportedFileChannel.broadcast_to(@object, { progress: progress, status: status })
  end
end
