#
# given tab-delimited idfile of bnum, identifier, idtype (001, 020, 022)
# and files output by split_hathidata.sh, produces
# matches.txt, errors.txt, and matches_w_status.txt
#
# matches.txt is an intermediary file and contains a list of each
# bnum/id > hathirecord match. A bnum with multiple matches will have
# multiple records
#
# matches_w_status.txt collapses matches.txt into one record per bnum, and
# includes a final indication of whether there are single or multiple
# full view volumes on the hathitrust record. Cases where a single identifier
# is associated with multiple hathitrust records of differing single/multiple
# status have a status of mixed<tab>unmixed_on_collapse. Cases where a bnum
# has multiple matching identifiers that match records with different
# single/multiple statuses have a status of mixed<tab>mixed_on_collapse


#idfile = 'nohh_ids.txt'
idfile = 'nohh_ids_pre1990.txt'

def clean_isxn(isxn)
  return isxn.upcase.match(/^[- 0-9X]*/)[0].strip.gsub("-", "").gsub(" ","")
end

def clean_isxn_hash(isxn_hash)
  cleaned = {}
  isxn_hash.each do |k,v|
    cleaned_isxn = clean_isxn(k)
    cleaned[cleaned_isxn] = v
  end
  return cleaned
end

ocn = {}
isbn = {}
issn = {}
[[ocn, 'ocn'], [isbn, 'isbn'], [issn,'issn']].each do |hsh, str|
  File.foreach("hathi_#{str}_single.txt") do |id|
    hsh[id.rstrip] = :single
  end
  File.foreach("hathi_#{str}_multi.txt") do |id|
    if hsh.include?(id.rstrip)
      hsh[id.rstrip] = :mixed
    else
      hsh[id.rstrip] = :multi
    end
  end
end

issn.merge!(clean_isxn_hash(issn))
isbn.merge!(clean_isxn_hash(isbn))


idtype_map = {'001' => ocn, '020' => isbn, '022' => issn}


blah = []
ofile = File.open('matches.txt', 'w')
errfile = File.open('errors.txt', 'w')
File.foreach(idfile) do |line|
  blah << line
  begin
    bnum, id, idtype = line.split("\t")
  rescue ArgumentError
    errfile << line
    next
  end
  if idtype_map[idtype.rstrip].include?(id.to_s)
    puts "found #{line}"
    multi_status = idtype_map[idtype.rstrip][id]
    ofile << line.rstrip + "\t#{multi_status}\torig\t\n"
  elsif idtype != 'ocn' && idtype_map[idtype.rstrip].include?(clean_isxn(id).to_s)
    puts "found #{line} (cleaned)"
    multi_status = idtype_map[idtype.rstrip][clean_isxn(id)]
    ofile << line.rstrip + "\t#{multi_status}\t(cleaned)\t#{clean_isxn(id)}\n"
  end
end
ofile.close
errfile.close


collapse_matches = {}
File.foreach('matches.txt') do |line|
  bnum, id, idtype, multi_status, cleaned_status, cleaned_to = line.rstrip.split("\t")
  if collapse_matches.include?(bnum)
    collapse_matches[bnum][:multi_status] = :mixed if collapse_matches[bnum][:multi_status] != multi_status
    collapse_matches[bnum][:collapsing] = :mixed_on_collapse if collapse_matches[bnum][:multi_status] != multi_status
    collapse_matches[bnum][:matches] << [idtype, id, multi_status, [cleaned_status, cleaned_to]]
  else
    collapse_matches[bnum] = {multi_status: multi_status, collapsing: :unmixed_on_collapse, matches: [[idtype, id, multi_status, [cleaned_status, cleaned_to]]]}
  end
end

ofile = 'matches_w_status.txt'
File.open(ofile, 'w') do |ofile|
  collapse_matches.each do |k,v|
    ofile << [k, v[:multi_status], v[:collapsing]].join("\t") + "\n"
  end
end
