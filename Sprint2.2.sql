-- Ejercicio 2
-- Listado de países que estam gemeramdp vemtas
SELECT c.country, COUNT(t.id) AS total_ventas
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.country
ORDER BY total_ventas DESC;

-- Desde cuántos países se generan las ventas.
SELECT COUNT(DISTINCT c.country) AS total_paises_con_ventas
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;
-- Identifica a la compañía con la mayor media de ventas.
SELECT c.id, c.company_name, ROUND(AVG(t.amount),2) AS media_ventas
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.id
ORDER BY media_ventas DESC
LIMIT 1;

-- Ejercicio 3
SELECT *
FROM transaction t
WHERE EXISTS (
    SELECT 1
    FROM company c
    WHERE c.id = t.company_id
      AND c.country = 'Germany');
-- Lista las empresas que han realizado transacciones 
-- por un amount superior a la media de todas las transacciones.      
SELECT c.id, c.company_name
FROM company c
WHERE EXISTS (
    SELECT 1
    FROM transaction t
    WHERE t.company_id = c.id
      AND t.amount > (SELECT AVG(amount) FROM transaction));
 
 -- Eliminarán del sistema las empresas que carecen de transacciones registradas, 
 -- entrega el listado de estas empresas.
SELECT c.id, c.company_name, c.country
FROM company c
WHERE NOT EXISTS (
    SELECT 1
    FROM transaction t
    WHERE t.company_id = c.id);
    
    -- Ejercicio 4 Creación de tabla credit_card
CREATE TABLE credit_card (
    id VARCHAR(20) PRIMARY KEY,
    iban VARCHAR(50) NOT NULL,
    pan VARCHAR(30) NOT NULL,
    pin VARCHAR(10) NOT NULL,
    cvv VARCHAR(10) NOT NULL,
    expiring_date VARCHAR(20)
);
      -- Limpieza de filas de columna expiring_date:
-- 1. Desactivar el modo seguro
SET SQL_SAFE_UPDATES = 0;
-- 2. Ejecutar tu actualización masiva
UPDATE credit_card 
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');
-- 3. Volver a activar el modo seguro por seguridad
SET SQL_SAFE_UPDATES = 1;
-- cambiar el tipo de dato de la columna expiring_date a DATE
ALTER TABLE credit_card 
MODIFY COLUMN expiring_date DATE;

-- relacionar tablas transaction con credit_card:
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id)
ON DELETE CASCADE 
ON UPDATE CASCADE;

-- Ejercicio 5
-- El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938.
-- La información que debe mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.
-- Revisión de registro que se hizo en ID CcU-2938:
SELECT *
FROM credit_card
WHERE id = 'CcU-2938'; 

-- Actualizar el número de cuenta (iban) de la tarjeta CcU-2938
UPDATE credit_card 
SET iban = 'TR323456312213576817699999' 
WHERE id = 'CcU-2938';

-- Comprobación de cambio:
SELECT *
FROM credit_card
WHERE id = 'CcU-2938'; 

-- Ejercicio 6
-- Primer paso: Insertar la compañía para evitar valores nulos y permitir la relación
INSERT INTO company (id, company_name, phone, email, country, website) 
VALUES ('b-9999', 'Empresa Auxiliar HR', '+34000000000', 'contacto@b9999.com', 'España', 'www.b9999.com');

-- Insertar la tarjeta de crédito auxiliar para permitir la relación con la transacción
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date) 
VALUES ('CcU-9999', 'TR999950312213576817638699', '5424465566813699', '1234', '123', '2028-12-31');
-- Tercer paso inserción a tabla transaction
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, CURRENT_TIMESTAMP, 111.11, 0);

-- Ejercicio 7
ALTER TABLE credit_card 
DROP COLUMN pan;
DESCRIBE credit_card;

-- Ejercicio 8
-- Descarga los archivos CSV que encontrarás en el apartado de recursos :

-- american_users.csv
-- european_users.csv
-- companies.csv
-- credit_cards.csv
-- transactions.csv
-- Estudia y diseña una base de datos con un esquema de estrella que contenga, al menos 4 tablas de las que puedas realizar las siguientes consultas:
-- La tabla de products.csv la utilizaremos más adelante.

DROP DATABASE IF EXISTS transacciones_db;
CREATE DATABASE transacciones_db;
USE transacciones_db;

-- Habilitar carga local de archivos CSV
SET GLOBAL local_infile = 1;

-- Creación de tabla american_users
CREATE TABLE american_users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(150),
    signup_date VARCHAR(20),
    user_segment VARCHAR(50),
    income_band VARCHAR(50)
);

-- Creación de tabla european_users
CREATE TABLE european_users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(150),
    signup_date VARCHAR(20),
    user_segment VARCHAR(50),
    income_band VARCHAR(50)
);

-- Creación de tabla companies
CREATE TABLE companies (
    company_id VARCHAR(50) PRIMARY KEY,
    company_name VARCHAR(150),
    phone VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(150),
    merchant_category VARCHAR(100),
    merchant_price_position VARCHAR(50)
);

-- Creación de tabla credit_cards
CREATE TABLE credit_cards (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin VARCHAR(10),
    cvv VARCHAR(10),
    track1 TEXT,
    track2 TEXT,
    exping_date VARCHAR(20),
    card_type VARCHAR(50),
    card_renewal_flag VARCHAR(10)
);

-- Creación de tabla transactions
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
    id VARCHAR(50) PRIMARY KEY,
    card_id VARCHAR(50),
    business_id VARCHAR(50),
    timestamp DATETIME,
    amount DECIMAL(12,4),
    declined BOOLEAN,
    product_ids TEXT,
    user_id INT,
    lat DOUBLE,
    longitude DOUBLE,
    discount_amount DECIMAL(12,4),
    tax_amount DECIMAL(12,4),
    shipping_amount DECIMAL(12,4),
    channel VARCHAR(50),
    campaign_id VARCHAR(50),
    device_type VARCHAR(50),
    is_international BOOLEAN,
    decline_reason VARCHAR(100),
    distance_km DECIMAL(12,4)
);

-- 2. CARGA DE DATOS DESDE ARCHIVOS CSV

LOAD DATA LOCAL INFILE 'C:/Users/freak/OneDrive/Documentos/ITAcademy/sprint1/ARchivosEjercicio8/N1-Ex.8__american_users.csv'
IGNORE
INTO TABLE american_users
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/freak/OneDrive/Documentos/ITAcademy/sprint1/ARchivosEjercicio8/N1-Ex.8__european_users.csv'
IGNORE
INTO TABLE european_users
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/freak/OneDrive/Documentos/ITAcademy/sprint1/ARchivosEjercicio8/N1-Ex.8__companies.csv'
IGNORE
INTO TABLE companies
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/freak/OneDrive/Documentos/ITAcademy/sprint1/ARchivosEjercicio8/N1-Ex.8__credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE transactions;
LOAD DATA LOCAL INFILE 'C:/Users/freak/OneDrive/Documentos/ITAcademy/sprint1/ARchivosEjercicio8/N1-Ex.8__transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. CREACIÓN DEL MODELO EN ESTRELLA (Dimensiones)
-- Dimensión 1: Usuarios (Unificación con prefijo para evitar colisiones)
DROP TABLE IF EXISTS dim_user;
CREATE TABLE dim_user AS
SELECT 
    CAST(id AS CHAR(50)) AS user_id,                    
    'Americas' AS macro_region,      
    name, surname, phone, email, birth_date, country, city, postal_code, address
FROM american_users

UNION ALL

SELECT 
    CAST(id AS CHAR(50)) AS user_id,                    
    'Europe' AS macro_region,
    name, surname, phone, email, birth_date, country, city, postal_code, address
FROM european_users;

ALTER TABLE dim_user ADD PRIMARY KEY (user_id);

ALTER TABLE transactions MODIFY COLUMN user_id VARCHAR(50);

-- 6. CONSULTAS DE LOS EJERCICIOS

-- Ejercicio 9 (Nivel 1): Usuarios con más de 80 transacciones 
SELECT u.* 
FROM dim_user u  
WHERE EXISTS (     
    SELECT 1     
    FROM transactions t     
    WHERE t.user_id = u.user_id     
    GROUP BY t.user_id     
    HAVING COUNT(t.id) > 80 
);
-- Ejercicio 10 (Nivel 1): Cantidad media por IBAN para Donec Ltd
SELECT  
    cc.iban,  
    c.company_name,
    ROUND(AVG(t.amount), 2) AS cantidad_media
FROM transactions t
INNER JOIN credit_cards cc ON t.card_id = cc.id
INNER JOIN companies c ON t.business_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban
ORDER BY cantidad_media;

-- Ejercicio 1 (Nivel 2): 5 días con mayores ingresos por ventas
SELECT  
    DATE(t.timestamp) AS fecha_venta,  
    SUM(t.amount) AS total_ingresos
FROM transactions t
WHERE t.declined = 0
GROUP BY fecha_venta
ORDER BY total_ingresos DESC
LIMIT 5;

-- Ejercicio 2 (Nivel 2): Transacciones entre 350 y 400€ en fechas específicas
SELECT  
    c.company_name,  
    c.phone,  
    c.country,  
    DATE(t.timestamp) AS fecha,  
    t.amount
FROM transactions t
INNER JOIN companies c ON t.business_id = c.company_id
WHERE t.declined = 0
  AND t.amount BETWEEN 350 AND 400
  AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY t.amount DESC;

-- Ejercicio 3 (Nivel 2): Categoría operativa por transacciones (>=400 o menos)
SELECT  
    c.company_name,
    COUNT(t.id) AS total_transacciones,
    CASE  
        WHEN COUNT(t.id) >= 400 THEN 'Igual o más de 400 transacciones'
        ELSE 'Menos de 400 transacciones'
    END AS categoria_operativa
FROM companies c
LEFT JOIN transactions t ON c.company_id = t.business_id
GROUP BY c.company_id
ORDER BY total_transacciones DESC;

-- Ejercicio 4 (Nivel 2): Eliminar registro específico de la tabla de hechos
-- Verificación de registro antes de borrar:
SELECT * FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- ELiminación de registro
DELETE FROM transactions 
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Ejercicio 5 (Nivel 2): Vista VistaMarketing
CREATE OR REPLACE VIEW VistaMarketing AS
SELECT  
    c.company_name AS nombre_compañía,
    c.phone AS teléfono_contacto,
    c.country AS país_residencia,
    ROUND(AVG(t.amount), 2) AS media_compra
FROM companies c
LEFT JOIN transactions t ON c.company_id = t.business_id
GROUP BY c.company_id;

-- Consulta para ver el resultado de la vista
SELECT * FROM VistaMarketing;

-- Ejercicio 1 (Nivel 3): Tarjetas activas (si al menos 1 de las últimas 3 no fue declinada), creación de tabla card_status
DROP TABLE IF EXISTS card_status; 

CREATE TABLE card_status AS
WITH ranked_transactions AS (
    SELECT 
        card_id,
        declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS rn
    FROM transactions
),
last_three AS (
    SELECT card_id, declined
    FROM ranked_transactions
    WHERE rn <= 3
)
SELECT 
    card_id,
    CASE 
        WHEN SUM(declined) = 3 THEN 'inactivo'
        ELSE 'activo'
    END AS status
FROM last_three
GROUP BY card_id;

-- Cuántas tarjetas están activas?
SELECT COUNT(*) AS tarjetas_activas
FROM card_status
WHERE status = 'activo';

-- Ejercicio 2
-- Crea una tabla con la que podamos unir los datos del archivo de products.csv con la base de datos creada  (
-- ya que hasta ahora no podíamos hacerlo), teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:
-- 👉 Necesitamos conocer el número de veces que se ha vendido cada producto.
-- Paso 1: Creación de tabla de dimensiones dim_product:  -- Dimensión 4: Productos
DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(12,4),
    colour VARCHAR(50),
    weight DECIMAL(12,4),
    warehouse_id VARCHAR(50),
    category VARCHAR(100),
    brand VARCHAR(100),
    cost DECIMAL(12,4),
    launch_date DATE
);
-- Agregación de columna: "currency" para no perder datos existentes y de la misma forma limpar las columnas 
-- price y cost para poder hacer operaciones. 
ALTER TABLE dim_product ADD COLUMN currency VARCHAR(5) DEFAULT 'USD';

-- Inserción de datos a dim_product

LOAD DATA LOCAL INFILE 'C:/Users/freak/OneDrive/Documentos/ITAcademy/sprint1/ARchivosEjercicio8/N1-Ex.8__products.csv'
INTO TABLE dim_product
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','  
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_name, @price, colour, @weight, warehouse_id, category, brand, @cost, launch_date)
SET  
    price = CAST(REPLACE(@price, '$', '') AS DECIMAL(12,4)),
    weight = CAST(@weight AS DECIMAL),
    cost = CAST(REPLACE(@cost, '$', '') AS DECIMAL(12,4)),
    currency = 'USD';




-- 5. NORMALIZACIÓN N:M (Tabla Intermedia de Productos)

DROP TABLE IF EXISTS transaction_products;

CREATE TABLE transaction_products (
    transaction_id VARCHAR(255),
    product_id VARCHAR(50),
    PRIMARY KEY (transaction_id, product_id),
    
    CONSTRAINT fk_tp_product FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);


-- Poblar la tabla puente desglosando la lista delimitada por comas
INSERT INTO transaction_products (transaction_id, product_id)
SELECT DISTINCT 
    t.id,
    TRIM(j.product_id) AS product_id
FROM transactions t
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(t.product_ids, ',', '","'), '"]'),
    '$[*]' COLUMNS (product_id VARCHAR(50) PATH '$')
) j
WHERE t.product_ids IS NOT NULL AND t.product_ids != '';

-- Una vez normalizado, eliminamos la columna multivaluada de transactions
ALTER TABLE transactions DROP COLUMN product_ids;

-- Ejercicio 2 (Nivel 3): Número de ventas por producto (Usando la tabla intermedia)
SELECT  
    p.product_id,
    p.product_name,
    COUNT(tp.transaction_id) AS total_veces_vendido
FROM dim_product p
LEFT JOIN transaction_products tp ON p.product_id = tp.product_id
LEFT JOIN transactions t ON tp.transaction_id = t.id AND t.declined = 0
GROUP BY p.product_id
ORDER BY total_veces_vendido DESC;

-- normalización a modelo estrella
-- Convertir user_id en la tabla transactions a VARCHAR(50) para que coincida con dim_user
ALTER TABLE transactions MODIFY COLUMN user_id VARCHAR(50);

--   clave foránea vinculada a transactions(id)
ALTER TABLE transaction_products 
ADD CONSTRAINT fk_tp_transaction 
FOREIGN KEY (transaction_id) 
REFERENCES transactions(id)
ON DELETE CASCADE 
ON UPDATE CASCADE;




--  Enlazar transactions con la dimensión companies (Empresas)
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_company 
FOREIGN KEY (business_id) REFERENCES companies(company_id)
ON DELETE CASCADE 
ON UPDATE CASCADE;

-- Enlazar transactions con la dimensión dim_user (Usuarios)
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_user 
FOREIGN KEY (user_id) REFERENCES dim_user(user_id)
ON DELETE CASCADE 
ON UPDATE CASCADE;

-- Enlazar transactions con credit_cards (Tarjetas de crédito)
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_card 
FOREIGN KEY (card_id) REFERENCES credit_cards(id)
ON DELETE CASCADE 
ON UPDATE CASCADE;

--  Enlazar card_status con credit_cards 
ALTER TABLE card_status
ADD CONSTRAINT fk_card_status_card 
FOREIGN KEY (card_id) REFERENCES credit_cards(id)
ON DELETE CASCADE 
ON UPDATE CASCADE;






