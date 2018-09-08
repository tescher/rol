class Waiver < ActiveRecord::Base
  belongs_to :volunteer
  belongs_to :guardian, class_name: "Volunteer", foreign_key: :guardian_id
  acts_as_paranoid

  validates_date :date_signed, on_or_before: lambda { Date.today }, allow_blank: false
  validates_date :birthdate, allow_blank: true
  validate :check_age_or_guardian_recorded

  def initialize(params = {})
    @file = params.delete(:file)
    super
    if @file
      self.filename = sanitize_filename(@file.original_filename)
      self.data = @file.read
    end
  end

  def effective_date_signed
    self.date_signed || self.created_at.to_date
  end


  private

  def sanitize_filename(filename)
    # Get only the filename, not the whole path (for IE)
    # Thanks to this article I just found for the tip: http://mattberther.com/2007/10/19/uploading-files-to-a-database-using-rails
    return File.basename(filename)
  end

  def pdf_only
    if (@file) && (@bypass_file != true) && (@file.content_type != 'application/pdf')
      errors.add(:file, 'File type must be PDF')
    end
  end

  def check_age_or_guardian_recorded
    if (self.adult != true) && !self.birthdate.present? && !self.guardian_id.present?
      errors.add(:adult, "Volunteer must be marked as an adult, have a recorded birthdate, or waiver signed by a guardian")
    end
  end


end
