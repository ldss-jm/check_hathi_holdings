
# check_hathi_holdings
Bash and ruby scripts to take a list of bib records / identifiers and find full view Hathitrust matches based on a hathifile, as well as indicate whether the hathitrust match has single or multiple full view volumes on the record.

# input
## hathitrust
Download the latest full hathifile from:
https://www.hathitrust.org/hathifiles

## Sierra / bib records

nohh_ids.sql can be used or adapted to generate a tab-delimited list of bnum, identifier, idtype for the appropriate set of records.

# process
Use split_hathidata.sh to pare down and split the hathifile into the separate components.

Use check_hathi.rb to match the bib records against the hathi data.

hathi_api_junk.rb is, appropriately enough, unused junk relating to the hathi api