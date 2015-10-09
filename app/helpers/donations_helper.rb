module DonationsHelper

  def add_donation_fields(donator)
    new_object = Donation.new
    output = ""
    association = :donations
    form_builder = form_for(donator) do |builder|
      output = builder.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render("donations/donation_fields", :f => builder, :association => association)
      end
    end
    output
  end

  def get_donation_summary(objectName, id)

    if (objectName == "volunteer")
      object = Volunteer.find(id)
      address_hash = (object.address + object.city).gsub(/\s+/,"").downcase
      where_clause = "(LOWER(TRANSLATE(volunteers.address || volunteers.city, ' ', '')) = '" + address_hash + "') AND (donations.volunteer_id = volunteers.id) AND (donations.donation_type_id = donation_types.id) and (donation_types.non_monetary = FALSE)"
      # join = "INNER JOIN workday_#{@objectName}s ON workday_#{@objectName}s.workday_id = workdays.id"
      donation_years = Donation.select("ROUND(EXTRACT(YEAR FROM donations.date_received)) as year").joins(:volunteer, :donation_type).where(where_clause).group("year").order("year DESC")
      donations_by_year = Hash[donation_years.map { |dy|
                                 year = dy.year.to_s.split(".").first
                                 donations = Donation.select("donations.*").joins(:volunteer, :donation_type).where("ROUND(EXTRACT(YEAR FROM donations.date_received)) = '#{dy.year}' AND " + where_clause).order("donations.date_received DESC")
                                 [year, donations]
                               }]
    else
      object = Organization.find(id)
      where_clause = "(organizations.id = '#{object.id}') AND (donations.organization_id = organizations.id) AND (donations.donation_type_id = donation_types.id) and (donation_types.non_monetary = FALSE)"
      # join = "INNER JOIN workday_#{@objectName}s ON workday_#{@objectName}s.workday_id = workdays.id"
      donation_years = Donation.select("ROUND(EXTRACT(YEAR FROM donations.date_received)) as year").joins(:organization, :donation_type).where(where_clause).group("year").order("year DESC")
      donations_by_year = Hash[donation_years.map { |dy|
                                 year = dy.year.to_s.split(".").first
                                 donations = Donation.select("donations.*").joins(:organization, :donation_type).where("ROUND(EXTRACT(YEAR FROM donations.date_received)) = '#{dy.year}' AND " + where_clause).order("donations.date_received DESC")
                                 [year, donations]
                               }]

    end

    year_totals = Hash[donations_by_year.map { |y, ds|
                         year_value = 0
                         ds.each do |d|
                           year_value += d.value
                         end
                         [y, year_value]
                       }]
    puts donation_years
    puts donations_by_year
    puts year_totals
    [donation_years, donations_by_year, year_totals]
  end
end