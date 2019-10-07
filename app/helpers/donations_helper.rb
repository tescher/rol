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

  def get_donation_summary(objectName, id, non_monetary = false)

    if (objectName == "volunteer")
      object = Volunteer.find(id)
      if (object.address.to_s.empty? && object.city.to_s.empty?)
        where_clause = "(volunteers.id = '#{object.id}') AND (donations.volunteer_id = volunteers.id) AND (donations.donation_type_id = donation_types.id) and (donation_types.non_monetary = #{non_monetary})"
      else
        address_hash = (object.address.to_s + object.city.to_s).gsub(/[^0-9a-zA-Z]/,"").downcase
        # puts "Address Hash #{address_hash}"
        where_clause = "(REGEXP_REPLACE(LOWER(volunteers.address || volunteers.city), '[^0-9a-z]', '', 'g') = '" + address_hash + "') AND (donations.volunteer_id = volunteers.id) AND (donations.donation_type_id = donation_types.id) and (donation_types.non_monetary = #{non_monetary})"
      end

      # join = "INNER JOIN workday_#{@objectName}s ON workday_#{@objectName}s.workday_id = workdays.id"
      donation_years = Donation.select("ROUND(EXTRACT(YEAR FROM donations.date_received)) as year").joins(:volunteer, :donation_type).where(where_clause).group("year").order("year DESC")
      donations_by_year = Hash[donation_years.map { |dy|
                                 year = dy.year.to_s.split(".").first
                                 donations = Donation.select("donations.*").joins(:volunteer, :donation_type).where("ROUND(EXTRACT(YEAR FROM donations.date_received)) = '#{dy.year}' AND " + where_clause).order("donations.date_received DESC")
                                 [year, donations]
                               }]
    else
      object = Organization.find(id)
      where_clause = "(organizations.id = '#{object.id}') AND (donations.organization_id = organizations.id) AND (donations.donation_type_id = donation_types.id) and (donation_types.non_monetary = #{non_monetary})"
      # join = "INNER JOIN workday_#{@objectName}s ON workday_#{@objectName}s.workday_id = workdays.id"
      donation_years = Donation.select("ROUND(EXTRACT(YEAR FROM donations.date_received)) as year").joins(:organization, :donation_type).where(where_clause).group("year").order("year DESC")
      donations_by_year = Hash[donation_years.map { |dy|
                                 year = dy.year.to_s.split(".").first
                                 donations = Donation.select("donations.*").joins(:organization, :donation_type).where("ROUND(EXTRACT(YEAR FROM donations.date_received)) = '#{dy.year}' AND " + where_clause).order("donations.date_received DESC")
                                 [year, donations]
                               }]

    end

    grand_total = 0
    year_totals = Hash[donations_by_year.map { |y, ds|
                         year_value = 0
                         ds.each do |d|
                           year_value += d.value.to_s.to_d
                         end
                         grand_total += year_value
                         [y, year_value]
                       }]

    [donation_years, donations_by_year, year_totals, grand_total]

  end

end