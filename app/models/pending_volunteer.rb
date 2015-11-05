class PendingVolunteer < ActiveRecord::Base

  validate :validate_xml

  before_save {
    if (!self.xml.blank?)
      doc = Nokogiri::XML(self.xml)
      ["first_name", "middle_name", "last_name", "email", "city"].each do |item|
        node = doc.xpath("data-set/#{item}")
        if (!(node[0].nil?))
          self[item.to_sym] = node[0].text
        end
      end
    end
  }


  def name
    [first_name, last_name].join(' ')
  end

  private

  def validate_xml
    xsd = Nokogiri::XML::Schema(File.read(PENDING_VOLUNTEERS_XSD))
    doc = Nokogiri::XML(self.xml)

    xsd.validate(doc).each do |error|
      errors.add(:xml, "XML validation: " + error.message)
    end
  end
end
