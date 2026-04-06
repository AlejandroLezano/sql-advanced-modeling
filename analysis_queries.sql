--  PROYECTO: MODELADO RELACIONAL Y AUDITORÍA DE DATOS 
-- Este script demuestra el uso de CTEs, JOINs complejos y control de calidad de datos.

-- 1. REPORTE DE VENTAS CONSOLIDADAS POR CLIENTE
-- Usamos una CTE para limpiar registros con montos nulos antes del procesamiento.
WITH cleaned_orders AS (
    SELECT 
        order_id,
        customer_id,
        product_name,
        sale_amount,
        order_date
    FROM fct_orders 
    WHERE sale_amount IS NOT NULL
)
SELECT 
    c.full_name AS cliente,
    c.country AS pais,
    o.product_name,
    o.sale_amount AS monto,
    o.order_date AS fecha
FROM dim_customers AS c
INNER JOIN cleaned_orders AS o 
    ON c.customer_id = o.customer_id
ORDER BY o.sale_amount DESC;

-- 2. AUDITORÍA DE INTEGRIDAD REFERENCIAL
-- Identificamos pedidos "huérfanos" (registros en fct_orders que no tienen un cliente en dim_customers).
-- Esto simula la detección de errores en un pipeline de datos real.
SELECT 
    o.order_id,
    o.customer_id AS id_no_encontrado,
    o.product_name,
    o.sale_amount
FROM fct_orders AS o
LEFT JOIN dim_customers AS c 
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 3. MÉTRICAS AGREGADAS POR PAÍS
-- Cálculo de ticket promedio y ventas totales utilizando la relación entre tablas.
SELECT 
    c.country,
    COUNT(o.order_id) AS cantidad_pedidos,
    ROUND(AVG(o.sale_amount), 2) AS ticket_promedio,
    SUM(o.sale_amount) AS total_facturado
FROM dim_customers AS c
JOIN fct_orders AS o ON c.customer_id = o.customer_id
GROUP BY c.country
ORDER BY total_facturado DESC;
