CREATE INDEX idx_orders_cus_code ON orders(CUS_CODE);  
create user C##PARTNER_STAFF identified by P123;
GRANT SELECT, INSERT, UPDATE on suppliers TO C##PARTNER_STAFF;
CREATE TABLE categories_code (
    CATE_CODE VARCHAR2(10) PRIMARY KEY
);

CREATE TABLE categories (
    CATE_CODE   VARCHAR2(10), -- Unique code for the category
    CATE_NAME   VARCHAR2(100) NOT NULL,  -- Name of the fabric category
    COLOR           VARCHAR2(50),            -- Color of the fabric
    CURRENT_PRICE   NUMBER NOT NULL,  -- Current price of the fabric
    PRICE_DATE      DATE NOT NULL,           -- Date when the price was last updated
    IMPORT_DATE     DATE NOT NULL,
    PRIMARY KEY (CATE_CODE, PRICE_DATE),
    CONSTRAINT FK_CATE_CODE FOREIGN KEY (CATE_CODE) REFERENCES categories_code(CATE_CODE),
    QUANTITY        INTEGER NOT NULL   -- Quantity available
);

CREATE TABLE bolts (
    BOLT_CODE VARCHAR(20) PRIMARY KEY,
    CATE_CODE VARCHAR(20),
    CONSTRAINT FK_BOLT_CATE FOREIGN KEY (CATE_CODE) REFERENCES categories_code(CATE_CODE),
    LENGTH NUMBER(10,2)
);

CREATE TABLE suppliers (
    SUPP_CODE VARCHAR(10) PRIMARY KEY,
    SUPP_NAME VARCHAR(20) NOT NULL,
    PRT_CODE VARCHAR(20) NOT NULL,
    ADDRESS VARCHAR (200),
    BANK_ACCOUNT VARCHAR (200) UNIQUE, 
    TAX_CODE VARCHAR(20) UNIQUE
);

CREATE TABLE suppliers_phone (
    SUPPLIER_CODE VARCHAR(10),
    PHONE_NUM VARCHAR(15),
    PRIMARY KEY (SUPPLIER_CODE, PHONE_NUM),
    CONSTRAINT FK_SUPPLIER FOREIGN KEY (SUPPLIER_CODE) REFERENCES suppliers (SUPP_CODE)
);

CREATE TABLE managers (
    MNG_CODE VARCHAR(10) PRIMARY KEY,
    FIRST_NAME VARCHAR(20) NOT NULL,
    LAST_NAME VARCHAR(20) NOT NULL,
    ADDRESS VARCHAR(200) NOT NULL,
    GENDER  VARCHAR (10) NOT NULL,
    PHONE_NUM VARCHAR (20)
);

CREATE TABLE office_staffs (
    OFFI_CODE VARCHAR(10) PRIMARY KEY,
    FIRST_NAME VARCHAR(20) NOT NULL,
    LAST_NAME VARCHAR(20) NOT NULL,
    ADDRESS VARCHAR(200) NOT NULL,
    GENDER  VARCHAR (10) NOT NULL,
    PHONE_NUM VARCHAR (20)
);

CREATE TABLE operational_staffs (
    OPE_CODE VARCHAR(10) PRIMARY KEY,
    FIRST_NAME VARCHAR(20) NOT NULL,
    LAST_NAME VARCHAR(20) NOT NULL,
    ADDRESS VARCHAR(200) NOT NULL,
    GENDER  VARCHAR (10) NOT NULL,
    PHONE_NUM VARCHAR (20)
);

CREATE TABLE partner_staffs (
    PRT_CODE VARCHAR(10) PRIMARY KEY,
    FIRST_NAME VARCHAR(20) NOT NULL,
    LAST_NAME VARCHAR(20) NOT NULL,
    ADDRESS VARCHAR(200) NOT NULL,
    GENDER  VARCHAR (10) NOT NULL,
    PHONE_NUM VARCHAR (20)
);

CREATE TABLE customers (
    CUS_CODE VARCHAR(20) PRIMARY KEY,
    OFFI_CODE VARCHAR(20) NOT NULL,
    CONSTRAINT FK_OFFI FOREIGN KEY(OFFI_CODE) REFERENCES office_staffs(OFFI_CODE),
    FIRST_NAME VARCHAR(20) NOT NULL,
    LAST_NAME VARCHAR(20) NOT NULL,
    ARREARAGE_STATUS VARCHAR(10)
);

CREATE TABLE customers_phone (
    CUSTOMER_CODE VARCHAR(20),
    PHONE_NUM VARCHAR(20),
    PRIMARY KEY (CUSTOMER_CODE, PHONE_NUM),
    CONSTRAINT fk_cust FOREIGN KEY (CUSTOMER_CODE) REFERENCES customers (CUS_CODE)
);

CREATE TABLE orders (
    ORDER_CODE VARCHAR(20) PRIMARY KEY,
    CUS_CODE VARCHAR(20) NOT NULL,
    CONSTRAINT FK_CUS FOREIGN KEY (CUS_CODE) REFERENCES customers(CUS_CODE),
    OPE_CODE VARCHAR(20) NOT NULL,
    CONSTRAINT FK_OPE FOREIGN KEY (OPE_CODE) REFERENCES operational_staffs(OPE_CODE),
    TOTAL_PRICE NUMBER(10, 2) NOT NULL,
    ORDER_STATUS VARCHAR(10) NOT NULL,
    CANCELLED_REASON VARCHAR(30)
);

CREATE TABLE payments (
    ORDER_CODE VARCHAR2(20),
    CUS_CODE VARCHAR2(20),
    PRIMARY KEY (ORDER_CODE, CUS_CODE),
    CONSTRAINT fk_order FOREIGN KEY (ORDER_CODE) REFERENCES orders(ORDER_CODE),
    CONSTRAINT fk_customer FOREIGN KEY (CUS_CODE) REFERENCES customers(CUS_CODE),
    PAY_AMOUNT NUMBER(10,2) NOT NULL,
    PAY_DATE DATE NOT NULL,
    ARREARAGE NUMBER(10, 2) NOT NULL,
    DURATION VARCHAR2(50) NOT NULL 
);

CREATE TABLE contains (
    ORDER_CODE VARCHAR(20),
    BOLT_CODE VARCHAR(20),
    PRICE_DATE DATE,
    PRIMARY KEY (ORDER_CODE, BOLT_CODE),
    CONSTRAINT FK_BOLT FOREIGN KEY (BOLT_CODE) REFERENCES bolts(BOLT_CODE),
    CONSTRAINT ORDER_FK FOREIGN KEY (ORDER_CODE) REFERENCES orders(ORDER_CODE)
);
CREATE TABLE provides (
    CATE_CODE VARCHAR2(20),
    SUPP_CODE VARCHAR2(20),
    --CONSTRAINT CATE_FK FOREIGN KEY (CATE_CODE) REFERENCES categories(CATE_CODE),
    CONSTRAINT SUPP_FK FOREIGN KEY (SUPP_CODE) REFERENCES suppliers(SUPP_CODE),
    QUANTITY INTEGER NOT NULL,
    PURCHASE_PRICE NUMBER (10, 2) NOT NULL,
    IMPORT_DATE DATE NOT NULL,
    PRIMARY KEY (CATE_CODE, SUPP_CODE, IMPORT_DATE)
);

CREATE TABLE processes (
    OPE_CODE VARCHAR(20),
    ORDER_CODE VARCHAR (20),
    CONSTRAINT FOREGIN_OPE FOREIGN KEY (OPE_CODE) REFERENCES operational_staffs (OPE_CODE),
    CONSTRAINT FOREGIN_ORDER FOREIGN KEY (ORDER_CODE) REFERENCES orders (ORDER_CODE),
    PROC_DATE DATE,
    PROC_TIME TIMESTAMP,
    PRIMARY KEY (ORDER_CODE, PROC_DATE, PROC_TIME),
    ACTION VARCHAR(200)
);


CREATE OR REPLACE PROCEDURE increase_silk_price IS
BEGIN
    -- Update the selling price of Silk categories
    UPDATE categories c
    SET c.CURRENT_PRICE = c.CURRENT_PRICE * 1.10
    WHERE c.CATE_NAME = 'Silk' AND c.IMPORT_DATE >= TO_DATE('01-09-2020', 'DD-MM-YYYY');
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE get_order_from_silk_agency (
    result_cursor OUT SYS_REFCURSOR  -- Cursor parameter to return the result set
) IS
BEGIN
    OPEN result_cursor FOR
        SELECT o.ORDER_CODE, o.CUS_CODE, o.OPE_CODE, o.TOTAL_PRICE, o.ORDER_STATUS, o.CANCELLED_REASON
        FROM orders o
        INNER JOIN contains c ON c.ORDER_CODE = o.ORDER_CODE
        INNER JOIN bolts b ON b.BOLT_CODE = c.BOLT_CODE
        INNER JOIN provides p ON p.CATE_CODE = b.CATE_CODE
        INNER JOIN suppliers s ON s.SUPP_CODE = p.SUPP_CODE
        WHERE s.SUPP_NAME = 'Silk Agency';
END;
/

CREATE OR REPLACE FUNCTION total_purchase_price (supplier_code VARCHAR) 
RETURN SYS_REFCURSOR IS purchase_list SYS_REFCURSOR;
BEGIN
    OPEN purchase_list FOR
    SELECT 
        CATE_CODE AS Category_code,
        QUANTITY AS Quanity,
        PURCHASE_PRICE AS Price_per_unit,
        QUANTITY * PURCHASE_PRICE as Total_price,
        IMPORT_DATE AS Purchar_date,
        SUPP_CODE AS Supplier_code
    FROM
        provides
    WHERE
        SUPP_CODE = supplier_code;
    RETURN purchase_list;
END;
/

CREATE OR REPLACE PROCEDURE sort_suppliers_by_categories (start_date DATE, end_date DATE)
IS
    CURSOR sort_supplier IS
        SELECT
            SUPP_CODE AS Supplier_Code,
            COUNT(DISTINCT CATE_CODE) AS Num_Category
        FROM
            provides
        WHERE
            IMPORT_DATE BETWEEN start_date AND end_date
        GROUP BY
            SUPP_CODE
        ORDER BY
            Num_Category ASC;
    supplier_record sort_supplier%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Supplier Code | Number of Categories');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    OPEN sort_supplier;
    LOOP
        FETCH sort_supplier INTO supplier_record;
        EXIT WHEN sort_supplier%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(supplier_record.Supplier_Code || '           | ' || supplier_record.Num_Category);
    END LOOP;
    CLOSE sort_supplier;

END;
/

