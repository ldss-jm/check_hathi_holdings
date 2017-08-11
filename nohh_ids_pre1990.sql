with locbibs as (select b.id --select distinct 'b' || rm.record_num || 'a'
from sierra_view.item_record i
inner join sierra_view.bib_record_item_record_link bil on bil.item_record_id = i.id
inner join sierra_view.bib_record b on b.id = bil.bib_record_id
  and b.bcode1 = 'm'
inner join sierra_view.record_metadata rm on rm.id = b."id"
where i.location_code = 'nohh'

UNION

select b.id
from sierra_view.holding_record_location h
inner join sierra_view.bib_record_holding_record_link bhl on bhl.holding_record_id = h.holding_record_id
inner join sierra_view.bib_record b on b.id = bhl.bib_record_id
  and b.bcode1 = 'm'
inner join sierra_view.record_metadata rm on rm.id = b.id
where h.location_code = 'nohh'
),
pubdate AS (
SELECT c.p07 || c.p08 || c.p09 || c.p10 AS pubdate,
       c.record_id
FROM sierra_view.control_field c
INNER JOIN locbibs
ON c.record_id = locbibs.id
WHERE c.control_num = 8
and (c.p07 || c.p08 || c.p09 || c.p10) !~ '^2|^199'
)

select 'b' || rm01.record_num || 'a', v001.field_content as identifier, v001.marc_tag
from locbibs 
inner join sierra_view.varfield v001 on locbibs.id = v001.record_id
  and v001.marc_tag = '001'
inner join pubdate on pubdate.record_id = locbibs.id
inner join sierra_view.record_metadata rm01 on rm01.id = v001.record_id
where v001.marc_tag = '001'

UNION

select 'b' || rmsf.record_num || 'a', sf020.content as identifier, marc_tag
from locbibs
inner join sierra_view.subfield sf020 on locbibs.id = sf020.record_id
   and (sf020.marc_tag = '020' or sf020.marc_tag = '022') and tag = 'a'
inner join sierra_view.record_metadata rmsf on rmsf.id = sf020.record_id
inner join pubdate on pubdate.record_id = locbibs.id