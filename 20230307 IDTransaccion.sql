select * from nexus_gis.sms_log where idtransaccion=64377;
select * from nexus_gis.sms_log where telefono='1151069392';

select*
from nexus_gis.sms_log
where 
    1=1
    and to_char(f_inv_moreq,'yyyy')=2023
    and to_char(f_inv_moreq,'mm')=03
order by
    --f_inv_moreq desc
    idtransaccion 
;

--FEBRERO       14429  Filas
--MARZO         15461  Filas
--ABRIL         14368  Filas    
--MAYO          15270  Filas
--JUNIO         17947  Filas
--JULIO         13915  Filas
--AGOSTO        10273  Filas
--SEPTIEMBRE     8508  Filas
--OCTUBRE        8810  Filas
--NOVIEMBRE     12405  Filas
--DICIEMBRE     17888  Filas
--ENERO         15923  Filas

--Maximo 17947


