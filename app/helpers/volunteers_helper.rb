module VolunteersHelper
  
  def find_matching_volunteers(object)
    matched_volunteers = Hash.new
    volunteer_ids = []
    volunteers = Volunteer.where("last_name ILIKE ?",object.last_name)
    volunteers.each do |v|
      volunteer_ids.push(v.id)
      matched_volunteer = {volunteer: v, points: 10}
      matched_volunteers[v.id] = matched_volunteer
    end
    volunteers = Volunteer.where(id: volunteer_ids).where("soundex(last_name) = soundex(#{Volunteer.sanitize(object.last_name)})")
    volunteers.each do |v|
      matched_volunteers[v.id][:points] += 5
    end
    if (!object.first_name.blank?)
      volunteers = Volunteer.where(id: volunteer_ids).where("first_name ILIKE ?",object.first_name)
      volunteers.each do |v|
        matched_volunteers[v.id][:points] += 5
      end
      volunteers = Volunteer.where(id: volunteer_ids).where("first_name ILIKE ?",object.first_name + "%")
      volunteers.each do |v|
        matched_volunteers[v.id][:points] += 3
      end
      volunteers = Volunteer.where(id: volunteer_ids).where("soundex(last_name) = soundex(#{Volunteer.sanitize(object.first_name)})")
      volunteers.each do |v|
        matched_volunteers[v.id][:points] += 2
      end
    end
    if (!object.email.blank?)
      volunteers = Volunteer.where(id: volunteer_ids).where("email ILIKE ?",object.email)
      volunteers.each do |v|
        matched_volunteers[v.id][:points] += 10
      end
    end
    if (!object.city.blank?)
      volunteers = Volunteer.where(id: volunteer_ids).where("city ILIKE ?",object.city)
      volunteers.each do |v|
        matched_volunteers[v.id][:points] += 2
      end
    end
    matched_volunteers.each {|id, mv| matched_volunteers.delete(id) if mv[:volunteer] == object }  # Get rid of the one we passed in
    matched_volunteers = Hash[matched_volunteers.sort_by { |id, mv| -mv[:points]}[0..4]]
  end
end
