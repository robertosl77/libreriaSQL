SELECT 
  CUENTA, 
  CT, 
  REGEXP_SUBSTR(CADENA, '[^#]+', 1, 1) ALIM, 
  REGEXP_SUBSTR(CADENA, '[^#]+', 1, 4) SSEE,
  CASE WHEN SUBSTR(CADENA,1,3)='ERR' THEN 'update GELEC.ed_clientes set ct=''' || CT || ''' where cuenta=''' || CUENTA  || ''';' ELSE 'update GELEC.ed_clientes set ct=''' || CT || ''', alimentador=''' || REGEXP_SUBSTR(CADENA, '[^#]+', 1, 1) || ''', ssee=''' || REGEXP_SUBSTR(CADENA, '[^#]+', 1, 4) || ''' where cuenta=''' || CUENTA  || ''';' END GELEC,
  case when substr(cadena,1,3)='ERR' then 'UPDATE NEXUS_CCYB.CLIENTES_CCYB SET CT=''' || ct || ''' WHERE CUENTA=''' || cuenta  || ''';' else 'UPDATE NEXUS_CCYB.CLIENTES_CCYB SET SSEE=''' || REGEXP_SUBSTR(cadena, '[^#]+', 1, 4) || ''', ALIMENTADOR=''' || REGEXP_SUBSTR(cadena, '[^#]+', 1, 1) || ''', CT=''' || ct || ''' WHERE CUENTA=''' || cuenta  || ''';' end ccyb
FROM 
  (select cuenta, substr(new_ct,1,instr(new_ct,'#')-1) ct, get_cadena_nbm(substr(new_ct,instr(new_ct,'#',1,2)+1, instr(new_ct,'#',instr(new_ct,'#',1,2)+1)-instr(new_ct,'#',1,2)-1)) cadena from (select fsclientid cuenta, b.ct, get_ct(fsclientid) new_ct from nexus_gis.sprclients@nexus_gis a, clientes_ccyb b where custatt16 = '1A' and custatt21 = '12521' and fsclientid=b.cuenta and logidto=0)
--where nvl(ct,'A')<>REGEXP_SUBSTR(new_ct, '[^#]+', 1, 1)
);
