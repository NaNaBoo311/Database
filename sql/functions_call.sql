
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
    purchase_cursor SYS_REFCURSOR;
    category_code VARCHAR2(50);
    quantity NUMBER;
    price_per_unit NUMBER;
    total_price NUMBER;
    purchase_date DATE;
    supplier_code VARCHAR2(50);
BEGIN
    -- Call the function
    purchase_cursor := total_purchase_price('SUP001');
    
    -- Fetch the cursor data
    LOOP
        FETCH purchase_cursor INTO category_code, quantity, price_per_unit, total_price, purchase_date, supplier_code;
        EXIT WHEN purchase_cursor%NOTFOUND;

        -- Process the data (example output)
        DBMS_OUTPUT.PUT_LINE('Category Code: ' || category_code || ', Total Price: ' || total_price);
    END LOOP;
    
    CLOSE purchase_cursor;
END;
/


DECLARE
    start_date DATE := TO_DATE('01/01/2005', 'DD/MM/YYYY');
    end_date DATE := TO_DATE('01/01/2025', 'DD/MM/YYYY');
BEGIN
sort_suppliers_by_categories(start_date, end_date);
END;  --d
/



















