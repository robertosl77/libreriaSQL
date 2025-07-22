Select o.CUENTA, 'ORD-'||to_char(o.inicio,'YYYY-MM')||'-'||lpad(O.ID,5,0) nro_orden, ef.serie, eo.descripcion as estado, o.inicio, o.fin, ti.descripcion as tipo, fc.retiro, fc.id idFaeCliente, o.abonada,o.ID idOrden
From gelec.ed_ordenes o 
inner join gelec.ed_fae_cliente fc on fc.id = o.id_fae_cliente
left join gelec.ed_equipo_fae ef on ef.id = fc.id_fae
inner join GELEC.ED_ESTADO_ORDENES eo on eo.id = o.ID_ESTADO
inner join GELEC.ED_TIPO_ORDEN ti on ti.id = o.id_tipo 
where o.ID_ESTADO != 4
--and o.cuenta='8210081952'
order by o.cuenta, o.inicio asc
;



select 
  fo.cuenta, fe.serie, eo.descripcion estado, fo.inicio, fo.fin, ft.descripcion tipo, fc.retiro, fc.id idFaeCliente, fo.abonada, fo.id idOrden, 'ORD-'||to_char(fo.inicio,'YYYY-MM')||'-'||lpad(fo.ID,5,0) nro_orden
from 
  gelec.ed_ordenes fo, 
  gelec.ed_fae_cliente fc, 
  gelec.ed_equipo_fae fe,
  gelec.ed_estado_ordenes eo, 
  gelec.ed_tipo_orden ft
where
  fo.cuenta= fc.cuenta
  and fc.id_fae=fe.id(+)
  and eo.id=fo.id_tipo
  and fo.id_tipo=ft.id
  --and fo.cuenta='8210081952'
order by
  fo.cuenta, fo.inicio asc
;