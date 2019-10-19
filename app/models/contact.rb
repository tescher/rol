class Contact < ActiveRecord::Base
  belongs_to :volunteer
  belongs_to :contact_method
  belongs_to :user
  belongs_to :last_edit_user, class_name: "User", foreign_key: :last_edit_user_id
  acts_as_paranoid

  validates_date :date_time, on_or_before: lambda { Date.today }, allow_blank: false
  validates :contact_method_id, presence: true
  validates :volunteer_id, presence: true
  validates :user_id, presence: true, on: :create  #Allow old ones to remain without user id
  validates :last_edit_user_id, presence: true, on: :update

end
