SELECT
    sli.linkvalue ct,
    sli2.linkvalue idlocalidad,
    ama.areaname localidad,
    ama2.areaname partido,
    AMA3.AREANAME ZONA
FROM
    nexus_gis.sprlinks sli
inner join nexus_gis.sprobjects ob on ob.objectid = sli.objectid
inner join nexus_gis.sprentities en on ob.sprid = en.sprid and en.categid = 132    
inner join nexus_gis.sprlinks sli2 on sli.objectid = sli2.objectid and sli2.logidto = 0 and sli2.linkid = 1197
inner join nexus_gis.amareas ama on sli2.linkvalue = ama.areaid
inner join nexus_gis.amareas ama2 on ama.superarea = ama2.areaid
inner join nexus_gis.amareas ama3 on ama2.superarea = ama3.areaid
WHERE SLI.LINKID = 1187
    and sli.logidto = 0