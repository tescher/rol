class WaiverText < ApplicationRecord
  enum waiver_type: [:adult, :minor]

  validate :pdf_only

  def initialize(params = {})
    @file = params.delete(:file)
    @bypass_file = params.delete(:bypass_file)
    super
    if @file
      self.filename = sanitize_filename(@file.original_filename)
      self.data = @file.read
    end
  end

  private

  def sanitize_filename(filename)
    # Get only the filename, not the whole path (for IE)
    # Thanks to this article I just found for the tip: http://mattberther.com/2007/10/19/uploading-files-to-a-database-using-rails
    return File.basename(filename)
  end

  def pdf_only
    if (@bypass_file != true) && (@file.content_type != 'application/pdf')
      errors.add(:file, 'File type must be PDF')
    end
  end
end
