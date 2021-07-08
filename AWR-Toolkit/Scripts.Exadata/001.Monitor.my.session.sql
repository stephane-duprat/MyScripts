select * from
(select phys_reads+phys_writes+redo_size mb_requested,
offload_eligible mb_eligible_offload,
interconnect_bytes interconnect_mb,
storageindex_bytes storageindex_mb_saved, flashcache_hits flashcache_mb,
round(((case
when offload_eligible=0 then 0
when offload_eligible> 0 then
(100*(((phys_reads+phys_writes+redo_size)-interconnect_bytes) /
(phys_reads+phys_writes+redo_size)))
end)),2) smartscan_efficiency,
interconnect_bytes/dbt interconnect_mbps,
(phys_reads+phys_writes+redo_size)-(storageindex_bytes+flashcache_hits)
cell_mb_processed,
((phys_reads+phys_writes+redo_size)-(storageindex_bytes+flashcache_hits))/dbt
cell_mbps
from (
select * from (
select name,mb,dbt from (
select stats.name,tm.dbt dbt,
(case
when stats.name='physical reads' then (stats.value * dbbs.value)/1024/1024
when stats.name='physical writes' then
asm.asm_redundancy*((stats.value * dbbs.value)/1024/1024)
when stats.name='redo size' then asm.asm_redundancy*((stats.value * 512)
/1024/1024)
when stats.name like 'cell physi%' then stats.value/1024/1024
when stats.name like 'cell%flash%' then (stats.value * dbbs.value)/1024/1024
else stats.value
end) mb
from (
select b.name,
value
from
v$mystat a,
v$statname b
where a.statistic# = b.statistic#
and b.name in
( 'cell physical IO bytes eligible for predicate offload',
'cell physical IO interconnect bytes',
'cell physical IO interconnect bytes returned by smart scan',
'cell flash cache read hits','cell physical IO bytes saved by storage
index',
'physical reads',
'physical writes',
'redo size')
) stats,
(select value from v$parameter where name='db_block_size') dbbs,
(select decode(max(type),'NORMAL',2,'HIGH',3,2) asm_redundancy
from v$asm_diskgroup ) asm,
(select b.value/100 dbt
from v$mystat b, v$statname a
where a.statistic#=b.statistic#
and a.name='DB time') tm
)) pivot (sum(mb) for (name)
in ('cell physical IO bytes eligible for predicate offload' as offload_eligible,
'cell physical IO interconnect bytes'
as interconnect_bytes,
'cell physical IO interconnect bytes returned by smart scan' as smartscan_returned,
'cell flash cache read hits'
as flashcache_hits,
'cell physical IO bytes saved by storage index'
as storageindex_bytes,
'physical reads'
as phys_reads,
'physical writes'
as phys_writes,
'redo size'
as redo_size))
))
unpivot
(statval for stattype in
(mb_requested as 'MB Requested',
mb_eligible_offload as 'MB Eligible for Offload',
smartscan_efficiency as 'Smart Scan Efficiency',
interconnect_mb as 'Interconnect MB',
interconnect_mbps as 'Interconnect MBPS',
storageindex_mb_saved as 'Storage Index MB Saved',
flashcache_mb as 'Flash Cache MB read',
cell_mb_processed as 'Cell MB Processed' ,
cell_mbps as 'Cell MBPS'))
/



