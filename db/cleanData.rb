#johnson: 14
#clinton: 16
#trump: 10
  ga_johnson = Candidate.find(86)
  ga_johnson.results.each do |result|
    result.candidate_id = 14
    result.save
  end

steins = Candidate.where(normalized_name: 'stein')
steins.each do |stein|
  if stein.id != 18
    stein.results.each do |cr|
      cr.candidate_id = 18
      cr.save
    end
  end
end