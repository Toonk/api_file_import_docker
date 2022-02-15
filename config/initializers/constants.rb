ALLOWED_FILE_CONTENT_TYPES = %w[application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                                text/csv application/vnd.ms-excel].freeze
MAX_FILE_SIZE = 1024 * 1024 * 5 # 5 MB

PREVIEW_ROWS_LIMIT = 5
PREVIEW_LENGTH_LIMIT = 1000 * (PREVIEW_ROWS_LIMIT + 1)
