
EXECUTE increase_silk_price; --a

DECLARE
    result_cursor SYS_REFCURSOR;
    order_code VARCHAR2(20);
    cus_code VARCHAR2(20);
    ope_code VARCHAR2(20);
    total_price NUMBER(10, 2);
    order_status VARCHAR2(20);
    cancelled_reason VARCHAR2(50);
BEGIN
    -- Call the procedure
    get_order_from_silk_agency(result_cursor);

    -- Fetch and process the results
    LOOP
        FETCH result_cursor INTO order_code, cus_code, ope_code, total_price, order_status, cancelled_reason;
        EXIT WHEN result_cursor%NOTFOUND;
        
        -- Output the results
        DBMS_OUTPUT.PUT_LINE('Order Code: ' || order_code || 
                             ', Customer Code: ' || cus_code ||
                             ', Operation Code: ' || ope_code ||
                             ', Total Price: ' || total_price ||
                             ', Order Status: ' || order_status ||
                             ', Cancelled Reason: ' || cancelled_reason);
    END LOOP;

    -- Close the cursor
    CLOSE result_cursor;
END;  --b
/

DECLARE 
    supplier_id VARCHAR(20) := 'S001';
    purchase_data SYS_REFCURSOR;
    category_code provides.CATE_CODE%TYPE;
    quantity provides.QUANTITY%TYPE;
    price_per_unit provides.PURCHASE_PRICE%TYPE;
    total_price provides.PURCHASE_PRICE%TYPE;
    purchase_date provides.IMPORT_DATE%TYPE;
BEGIN
    --Call the function---
    purchase_data := total_purchase_price(supplier_id);
    --Fetch data----
    LOOP
        FETCH purchase_data INTO category_code, quantity, price_per_unit, total_price, purchase_date;
        EXIT WHEN purchase_data%NOTFOUND;
--        DBMS_OUTPUT.PUT_LINE('CATE_CODE: ' || category_code
--                            || ', QUANTITY: ' || quantity || 
--                            ', UNIT PRICE: ' || price_per_unit ||
--                            ', TOTAL PRICE: ' || total_price ||
--                            ', DATE: ' || purchase_date);
        
        DBMS_OUTPUT.PUT_LINE('SUPPLIER: ' || supplier_id || ', TOTAL PRICE: ' || total_price);
        
    END LOOP;
    CLOSE purchase_data;
END;  --c
/

DECLARE
    start_date DATE := TO_DATE('01/01/2005', 'DD/MM/YYYY');
    end_date DATE := TO_DATE('01/01/2025', 'DD/MM/YYYY');
BEGIN
sort_suppliers_by_categories(start_date, end_date);
END;  --d
/



















