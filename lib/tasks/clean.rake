namespace :clean do
  desc "TODO"
  task fix_duplicates: :environment do
    candidates = Candidate.where.not(normalized_name: ['party', 'ticket', nil, 'for', 'unopposed', 'in', 'scattering']).select(:office_id, :district_id, :normalized_name).group(:office_id, :district_id, :normalized_name).having("count(*) > 1")
    candidates.each do |candidate|
      puts candidate.normalized_name
      matches = Candidate.where(normalized_name: candidate.normalized_name, office_id: candidate.office_id, district_id: candidate.district_id).to_a
      candidate_with_party_and_fec = matches.select { |c| !c.fec_id.nil? && !c.party.nil? }
      candidate_with_party = matches.select { |c| !c.party.nil? }
      if candidate_with_party_and_fec.length > 0
        top_candidate = filter(candidate_with_party_and_fec.pluck(:id))
        other_candidates = matches.select { |c| c.id != top_candidate }.pluck(:id)
        reassign(other_candidates, top_candidate)
      elsif candidate_with_party_and_fec.length == 0 && candidate_with_party.length >= 1
        top_candidate = filter(candidate_with_party.pluck(:id))
        other_candidates = matches.select { |c| c.id != top_candidate }.pluck(:id)
        reassign(other_candidates, top_candidate)
      else
        top_candidate = filter(matches.pluck(:id))
        other_candidates = matches.select { |c| c.id != top_candidate }.pluck(:id)
        reassign(other_candidates, top_candidate)
      end
    end
  end
end

def filter(ids)
  Result.where(candidate_id: ids).group(:candidate_id).sum(:total).sort{|a,b| a[1]<=>b[1]}.reverse[0][0]
end

def reassign(ids_to_assign, main_candidate)
  Candidate.where(id: ids_to_assign).each do |candidate|
    candidate.results.each do |result|
      result.candidate_id = main_candidate
      result.save
    end
    candidate.delete
  end
end
