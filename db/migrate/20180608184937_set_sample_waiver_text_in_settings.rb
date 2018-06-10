class SetSampleWaiverTextInSettings < ActiveRecord::Migration
  def change
    system_record = Setting.find_by_id(1)
    system_record.adult_waiver_text = "Sample adult waiver text."
    system_record.minor_waiver_text = "Sample minor waiver text."
    system_record.save!
  end
end
