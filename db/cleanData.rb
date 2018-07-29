#johnson: 14
#clinton: 16
#trump: 10

def normalize_stein
  steins = Candidate.where(normalized_name: 'stein')
  steins.each do |stein|
    if stein.id != 18
      stein.results.each do |cr|
        cr.candidate_id = 18
        cr.save
      end
    end
  end
end

def normalize_clinton
  clintons = Candidate.where(normalized_name: 'clinton')
  clintons.each do |clinton|
    if clinton.id != 16
      clinton.results.each do |cr|
        cr.candidate_id = 16
        cr.save
      end
    end
  end
end

def normalize_trump
  trumps = Candidate.where(normalized_name: 'trump')
  trumps.each do |trump|
    if trump.id != 10
      trump.results.each do |cr|
        cr.candidate_id = 10
        cr.save
      end
    end
  end
end

def normalize_johnson
  johnsons = Candidate.where(normalized_name: 'johnson')
  johnsons.each do |johnson|
    if johnson.id != 14
      johnson.results.each do |cr|
        cr.candidate_id = 14
        cr.save
      end
    end
  end
end

def normalize_mcmullin
  mcmullins = Candidate.where(normalized_name: 'mcmullin')
  mcmullins.each do |mcmullin|
    if mcmullin.id != 12
      mcmullin.results.each do |cr|
        cr.candidate_id = 12
        cr.save
      end
    end
  end
end

def delete_stray_candidates
  candidates = Candidate.includes(:results).where(results: { candidate_id: nil })
  candidates.each do |candidate|
    candidate.delete
    candidate.save
  end
end