#johnson: 14
#clinton: 16
#trump: 10
  ga_johnson = Candidate.find(86)
  ga_johnson.results.each do |result|
    result.candidate_id = 14
    result.save
  end

clintons = Candidate.where(normalized_name: 'clinton')
clintons.each do |clinton|
  if clinton.id !== 16
    clinton.results.each do |cr|
      cr.candidate_id = 16
      cr.save
    end
  end
