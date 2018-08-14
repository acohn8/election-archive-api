
class Candidate < ApplicationRecord
  has_many :results
  has_many :states, through: :results
  has_many :counties, through: :results
  has_many :precincts, through: :results
  belongs_to :office
end

# const fetchImages = stateId => async (dispatch, getState) => {
#   console.log(stateId);
#   const wikiURLs = {
#     'US Senate': `https://en.wikipedia.org/w/api.php?action=query&prop=imageinfo&iiprop=url&generator=images&titles=United States Senate election in ${
#       getState().states.states.find(state => state.id === stateId).attributes.name
#     }, 2016&format=json`,
#     Governor: `https://en.wikipedia.org/w/api.php?action=query&prop=imageinfo&iiprop=url&generator=images&titles=${
#       getState().states.states.find(state => state.id === stateId).attributes.name
#     } gubernatorial election, 2016&format=json`,
#   };

#   const response = axios.get(wikiURLs[
#     getState().offices.offices.find(office => office.id === getState().offices.selectedOfficeId.toString()).attributes.name
#   ]);
#   console.log(response);
# };