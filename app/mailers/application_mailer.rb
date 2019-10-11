class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  default "Message-ID" => ->(v) {"#{Digest::SHA2.hexdigest(Time.now.to_i.to_s)}@#{host_domain}"}
  layout 'mailer'
end
