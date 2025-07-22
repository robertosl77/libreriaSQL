select 
    (select nro_documento from gelec.ed_documentos where id_documento=dc.id_documento) nro_documento,
    c.cuenta, 
    c.ct,
    c.razon_social,
    (select custatt18 from nexus_gis.sprclients where fsclientid=c.cuenta) tarifa,
    case (select custatt16 from nexus_gis.sprclients where fsclientid=c.cuenta) 
        when '1A' then 'ELECTRODEPENDIENTES' 
        when '2A' then 'HOSPITAL' 
        when '2B' then 'GERIATICOS' 
        when '2C' then 'VIP' 
        when '2D' then 'AGUA POTABLE Y/O SERVIDAS' 
        when '2E' then 'MEDIDOR COMUNITARIO' 
        when '2F' then 'BOMBEROS' 
        when '2G' then 'POLICIA' 
        when '2H' then 'GAS NATURAL' 
        when '2I' then 'AEROPUERTOS' 
        when '2J' then 'FERROCARRILES' 
        when '2K' then 'CANALES DE AIRE Y RADIO' 
        when '3A' then 'CLIENTES CON POT. SUP. A 3MW' 
        when '3B' then 'CLIENTES T3 ELECTROINTENSIVOS' 
        when '3C' then 'MUNICIPIOS Y JUZGADOS' 
        when '3D' then 'EMBAJADAS' 
        else null end as sensibilidad,   
    case nvl(c.log_hasta,0) when 0 then 'SI' else 'NO' end activo,
    dc.fecha_inicio_corte, 
    dc.fecha_fin_corte, 
    dc.fecha_fin_editable,
    n.fechahora contacto,
    (select telefono from gelec.ed_contactos_clientes where id_tel=n.iddestino) telefono,
    case n.efectivo when 1 then 'SI' when 0 then 'NO' else 'NC' end efectivo,
    n.usuario,
    n.observaciones
from 
    gelec.ed_clientes c, 
    gelec.ed_det_documentos_clientes dc,
    gelec.ed_cliente_nota cn,
    gelec.ed_notas n
where
    c.cuenta=dc.cuenta
    and dc.cuenta= cn.cuenta
    and dc.id_documento=cn.id_documento
    and cn.id_nota=n.id_nota
    and n.id_tipo_nota=4
    and to_char(dc.fecha_inicio_corte,'yyyy')=2023
order by
    dc.id_documento desc,
    c.cuenta
;


select * from gelec.ed_det_documentos_clientes;
select * from gelec.ed_cliente_nota;
select * from gelec.ed_notas;
SELECT * from GELEC.ed_contactos_clientes;
