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



end