
# find only accessible records from hathifull, get handle, allow, oclc, isbn, issn, recnum(like a bnum, not inum)
awk -F'\t' '{if ($2 == "allow") {print $1"\t" $2"\t" $8"\t" $9"\t" $10"\t" $4}}' hathi_full_20170701.txt > hathi_allowed.txt




#hathi records with multiple full view items
awk -F'\t' '{print $6 "\t" "multi"}' hathi_allowed.txt | sort | uniq -d > hathi_multi.txt
sort -t$'\t' -k6,6 hathi_allowed.txt > hathi_allowed.srt
join -t$'\t' -a 1 -1 6 -2 1 hathi_allowed.txt hathi_multi.txt > hathi_allowed.joined.txt
#hathi_allowed.joined.txt = recnum, handle, allow, oclc, isbn, issn, [multi]

awk -F'\t' '{if (NF == 6) {print $4}}' hathi_allowed.joined.txt | tr ',' '\n' | sort | uniq > hathi_ocn_single.txt
awk -F'\t' '{if (NF == 7) {print $4}}' hathi_allowed.joined.txt | tr ',' '\n' | sort | uniq > hathi_ocn_multi.txt
awk -F'\t' '{if (NF == 6) {print $5}}' hathi_allowed.joined.txt | tr ',' '\n' | sort | uniq > hathi_isbn_single.txt
awk -F'\t' '{if (NF == 7) {print $5}}' hathi_allowed.joined.txt | tr ',' '\n' | sort | uniq > hathi_isbn_multi.txt
awk -F'\t' '{if (NF == 6) {print $6}}' hathi_allowed.joined.txt | tr ',' '\n' | sort | uniq > hathi_issn_single.txt
awk -F'\t' '{if (NF == 7) {print $6}}' hathi_allowed.joined.txt | tr ',' '\n' | sort | uniq > hathi_issn_multi.txt
