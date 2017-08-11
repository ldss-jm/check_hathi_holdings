require 'httparty'

baseurl = 'http://catalog.hathitrust.org/api/volumes/brief/<idtype>/<idvalue>.json'

idtype_map = {'001' => 'oclc', '020' => 'isbn', '022' => 'issn'}

#response = HTTParty.get('http://catalog.hathitrust.org/api/volumes/brief/oclc/41175334.json')
#JSON.parse(response.body)['items'].length
#response = HTTParty.get('http://catalog.hathitrust.org/api/volumes/brief/oclc/50731021.json')


ofile = File.open('matches_post_api_2.txt', 'w')
File.foreach('matches.txt') do |match|
  bnum, id, idtype, is_cleaned, cleaned_to = match.split("\t")
  idtype_mapped = idtype_map[idtype]
  url_safe_id = id.gsub(" ", "%20")
  response = HTTParty.get(baseurl.gsub("<idtype>", idtype_mapped).gsub("<idvalue>", url_safe_id))
  begin
    matchcount = JSON.parse(response.body)['items'].length
    #JSON.parse(response.body)['items'].select{|x| x['usRightsString'] == 'Full View'}.length
  rescue
    matchcount = 'error'
  end
  puts matchcount
  ofile << match.rstrip + "\t#{matchcount}\n"
end
ofile.close


