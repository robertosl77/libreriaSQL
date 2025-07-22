select 
  z.cuenta, 
  z.razon_social, 
  z.telefono, 
  z.tipo_de_tarifa, 
  z.nivel_de_sensibilidad, 
  z.calle, 
  z.nro, 
  z.piso_dpto, 
  z.entre_calle_1, 
  z.entre_calle_2, 
  z.localidad, 
  z.partido, 
  z.region, 
  z.x, 
  z.y, 
  z.medidor, 
  z.ct, 
  z.alimentador, 
  z.ssee 
from 
  (
    select 
      p.*
    from 
      (
        SELECT 
          c.fsclientid AS CUENTA, 
          c.fullname AS RAZON_SOCIAL, 
          c.telephonenumber AS TELEFONO, 
          c.CUSTATT18 AS TIPO_DE_TARIFA, 
          case c.custatt16 when '1A' then 'ELECTRODEPENDIENTES' when '2A' then 'HOSPITAL' when '2B' then 'GERIATICOS' when '2C' then 'VIP' when '2D' then 'AGUA POTABLE Y/O SERVIDAS' when '2E' then 'MEDIDOR COMUNITARIO' when '2F' then 'BOMBEROS' when '2G' then 'POLICIA' when '2H' then 'GAS NATURAL' when '2I' then 'AEROPUERTOS' when '2J' then 'FERROCARRILES' when '2K' then 'CANALES DE AIRE Y RADIO' when '3A' then 'CLIENTES CON POT. SUP. A 3MW' when '3B' then 'CLIENTES T3 ELECTROINTENSIVOS' when '3C' then 'MUNICIPIOS Y JUZGADOS' when '3D' then 'EMBAJADAS' else null end as nivel_de_sensibilidad, 
          (
            SELECT 
              s.STREETNAME 
            FROM 
              NEXUS_GIS.SMSTREETS s 
            WHERE 
              s.STREETANTIQ = 0 
              AND s.STREETDELETED = 0 
              AND s.STREETID = c.STREETID
          ) AS CALLE, 
          c.STREETNUMBER AS NRO, 
          trim(c.STREETOTHER) AS PISO_DPTO, 
          (
            SELECT 
              s.STREETNAME 
            FROM 
              NEXUS_GIS.SMSTREETS s 
            WHERE 
              s.STREETANTIQ = 0 
              AND s.STREETDELETED = 0 
              AND s.STREETID = c.STREETID1
          ) AS ENTRE_CALLE_1, 
          (
            SELECT 
              s.STREETNAME 
            FROM 
              NEXUS_GIS.SMSTREETS s 
            WHERE 
              s.STREETANTIQ = 0 
              AND s.STREETDELETED = 0 
              AND s.STREETID = c.STREETID2
          ) AS ENTRE_CALLE_2, 
          (
            SELECT 
              trim(a.AREANAME) 
            FROM 
              NEXUS_GIS.AMAREAS a 
            WHERE 
              a.AREAID = c.LEVELONEAREAID
          ) LOCALIDAD, 
          (
            SELECT 
              trim(a.AREANAME) 
            FROM 
              NEXUS_GIS.AMAREAS a 
            WHERE 
              a.AREAID = c.LEVELTWOAREAID
          ) PARTIDO, 
          l.REGION || ' - ' || l.SECTOR AS REGION, 
          (
            SELECT 
              o.X 
            FROM 
              NEXUS_GIS.SPROBJECTS o 
            WHERE 
              o.LOGIDTO = 0 
              AND o.SPRID = 190 
              AND o.OBJECTID = (
                SELECT 
                  MAX (sl.OBJECTID) 
                FROM 
                  NEXUS_GIS.SPRLINKS sl 
                WHERE 
                  sl.LINKID = 407 
                  AND sl.LOGIDTO = 0 
                  AND sl.LINKVALUE = RPAD (c.FSCLIENTID, 30)
              )
          ) AS X, 
          (
            SELECT 
              o.Y 
            FROM 
              NEXUS_GIS.SPROBJECTS o 
            WHERE 
              o.LOGIDTO = 0 
              AND o.SPRID = 190 
              AND o.OBJECTID = (
                SELECT 
                  MAX (sl.OBJECTID) 
                FROM 
                  NEXUS_GIS.SPRLINKS sl 
                WHERE 
                  sl.LINKID = 407 
                  AND sl.LOGIDTO = 0 
                  AND sl.LINKVALUE = RPAD (c.FSCLIENTID, 30)
              )
          ) AS Y, 
          c.CUSTATT25 || ' - ' || c.METERID AS MEDIDOR, 
          cc.ct CT, 
          cc.Alimentador alimentador, 
          cc.ssee ssee 
        FROM 
          nexus_gis.sprclients c 
          LEFT JOIN NEXUS_CCYB.CLIENTES_CCYB cc ON cc.cuenta = c.FSCLIENTID 
          INNER JOIN NEXUS_GIS.LLAM_SECTORES l on l.LOCA_ID = c.leveloneareaid 
        WHERE 
          c.logidto = 0 
          and l.REGION = 'R1' 
          and trim(l.PARTIDO) = 'CAPITAL FEDERAL'
      ) p
  ) z
  where z.nivel_de_sensibilidad is not null