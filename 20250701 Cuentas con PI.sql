select * from nexus_gis.llam_pedido_ints_mt;

select 
    cc.cuenta
    ,pimt.ct
    ,pimt.pedido
    ,pimt.fecha_inicio
    ,pimt.hora_inicio
    ,pimt.fecha_hasta
    ,pimt.hora_hasta
    --,ROUND(SYSDATE - TO_DATE(pimt.fecha_inicio, 'DD/MM/YY')) dias
from nexus_gis.llam_pedido_ints_mt pimt, nexus_ccyb.clientes_ccyb cc
where 
    pimt.ct= cc.ct
    --AND ROUND(SYSDATE - TO_DATE(pimt.fecha_inicio, 'DD/MM/YY')) <50
    and pimt.pedido='CA-34915'
order by
    to_date(pimt.fecha_inicio,'dd/mm/yy') desc
;

select * from nexus_gis.llam_pedido_ints_mt where pedido='CA-34915';


