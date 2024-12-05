from flask import Flask, render_template, request, redirect, url_for, jsonify
import cx_Oracle
import os

app = Flask(__name__)
connection = cx_Oracle.connect("system/32432707@localhost:1521/xe")

overall_user = ""

@app.route('/')
def index():
    return render_template('login.html')

@app.route('/', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        username = request.form['username']
        overall_user = username
        password = request.form['password']
    
        try:

            with oracledb.connect(user=username, password=password, dsn="localhost/xe"):

                session['username'] = username
                return index()
        except oracledb.DatabaseError as e:
            error_message = str(e)
            print("Login failed:", error_message)
            error = "Invalid username or password. Please try again."

    return render_template('login.html', error=error)


@app.route('/logout') 
def logout():
    session.clear()
    return redirect(url_for('login'))





#----------------------CATEGORIES & BOLTS----------------------------
@app.route('/categories.html')
def categories():
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM categories")
    data = cursor.fetchall()
    cursor.close()
    return render_template('categories.html', categories=data)

@app.route('/add_category', methods=['POST'])
def add_category():
    cate_code = request.form['cate_code']
    cate_name = request.form['cate_name']
    color = request.form['color']
    current_price = request.form['current_price']
    price_date = request.form['price_date']
    quantity = request.form['quantity']

    cursor = connection.cursor()
    try:
        cursor.execute("""
            INSERT INTO categories (CATE_CODE, CATE_NAME, COLOR, CURRENT_PRICE, PRICE_DATE, QUANTITY)
            VALUES (:1, :2, :3, :4, :5, :6)
        """, (cate_code, cate_name, color, current_price, price_date, quantity))
        connection.commit()
        return redirect(url_for('categories'))
    except cx_Oracle.DatabaseError as e:
        error = str(e)
        return render_template('error.html', error=error)
    finally:
        cursor.close()

@app.route('/sort_categories', methods = ['POST'])
def sort_categories():
    cursor = connection.cursor()

    try:
        # Fetching sorted categories by CATE_CODE in ascending order
        cursor.execute("SELECT * FROM categories ORDER BY CATE_CODE, PRICE_DATE ASC")
        sorted_categories = cursor.fetchall()

        # Render the categories page with both unsorted and sorted tables
        return render_template('categories.html', categories=sorted_categories)
    except cx_Oracle.DatabaseError as e:
        error = str(e)
        print(error)
        return render_template('error.html', error="Failed to sort categories.")
    finally:
        cursor.close()


@app.route('/search_materials', methods = ['POST'])
def search_materials():
    cursor = connection.cursor()
    cate_code = request.form['category_code']
    cursor.execute("SELECT * from categories")
    categories = cursor.fetchall()
    try:
        cursor.execute("""
            SELECT 
                    s.SUPP_NAME,
                    sp.PHONE_NUM,
                    c.CATE_NAME,
                    c.COLOR,
                    p.QUANTITY,
                    p.PURCHASE_PRICE,
                    p.IMPORT_DATE
            FROM
                    suppliers s
            LEFT JOIN
                    suppliers_phone sp ON sp.SUPPLIER_CODE = s.SUPP_CODE
            LEFT JOIN
                    provides p ON p.SUPP_CODE = s.SUPP_CODE
            LEFT JOIN
                    categories c ON c.CATE_CODE = p.CATE_CODE
            WHERE
                    c.CATE_CODE = :1
            ORDER BY
                    s.SUPP_NAME, c.CATE_NAME
        """, (cate_code,))
        materials = cursor.fetchall()
        return render_template('categories.html', materials = materials, categories = categories)
    except cx_Oracle.DatabaseError as e:
        error = str(e)
        print(error)
        return render_template('error.html', error = "Failed to perform. Please check your input")
        
    finally:
        cursor.close()






#----------------------SUPPLIERS-------------------------------
@app.route('/suppliers.html')
def suppliers():
    if (overall_user in ["C##MANAGER", "C##PARTNER_STAFF"]):
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM suppliers")
        data = cursor.fetchall()
        cursor.execute('SELECT * from suppliers_phone')
        suppliers_phone = cursor.fetchall()
        cursor.close()
        return render_template("suppliers.html", suppliers = data, suppliers_phone = suppliers_phone)
    else:
        return render_template("error.html", error = "You don't have any access!")

@app.route('/add_suppliers', methods = ['POST'])
def add_suppliers():
    supp_code = request.form['supp_code']
    supp_name = request.form['supp_name']
    prt_code = request.form['prt_code']
    supp_address = request.form['supp_address']
    supp_bank = request.form['supp_bank']
    supp_tax = request.form['supp_tax']
    cursor = connection.cursor()

    try:
        cursor.execute("""
        INSERT INTO suppliers(SUPP_CODE, SUPP_NAME, PRT_CODE, ADDRESS, BANK_ACCOUNT, TAX_CODE)
        VALUES (:1, :2, :3, :4, :5, :6)
        """,
        (supp_code, supp_name, prt_code, supp_address, supp_bank, supp_tax))
        connection.commit()
        return redirect(url_for('suppliers'))
    except cx_Oracle.DatabaseError as e:
        # Log the error for debugging
        error = str(e)
        print("Database Error:", error)
        
        # Render error page with user-friendly message
        return render_template('error.html', error="Failed to add the supplier. Please check your input.")

    finally:
        # Close the cursor
        cursor.close()

@app.route('/search_all_categories', methods = ['POST'])
def search_all_categories():
    supplier_code = request.form['supplier_code']
    cursor = connection.cursor()
    cursor.execute("SELECT * from suppliers")
    suppliers = cursor.fetchall()
    cursor.execute('SELECT * from suppliers_phone')
    suppliers_phone = cursor.fetchall()
    try:
        cursor.execute("""
            SELECT c.CATE_CODE, c.CATE_NAME, c.COLOR, c.CURRENT_PRICE, c.PRICE_DATE, c.QUANTITY
            FROM categories c
            INNER JOIN provides p ON c.CATE_CODE = p.CATE_CODE AND c.IMPORT_DATE = p.IMPORT_DATE
            WHERE p.SUPP_CODE = :1 
        """, (supplier_code,))
        categories_data = cursor.fetchall()
        return render_template('suppliers.html',suppliers = suppliers, categories = categories_data, suppliers_phone = suppliers_phone)
    except cx_Oracle.DatabaseError as e:
        error = str(e)
        print(error)
        return render_template('error.html', error="Failed to add the supplier. Please check your input.")
    finally:
        cursor.close()





#-----------------------ORDERS------------------------------
@app.route('/orders.html')
def orders():
    cursor = connection.cursor()
    cursor.execute("SELECT * from orders")
    data = cursor.fetchall()
    cursor.close()
    return render_template('orders.html', orders = data)




#-----------------------CUSTOMERS-----------------------------
@app.route('/customers.html')
def customers():
    cursor = connection.cursor()
    cursor.execute("SELECT * from customers")
    data = cursor.fetchall()
    cursor.execute("SELECT * from customers_phone")
    customers_phone = cursor.fetchall()
    cursor.close()
    return render_template('customers.html', customers = data, customers_phone = customers_phone)

@app.route('/search_orders', methods = ['POST'])
def search_orders():
    cursor = connection.cursor()
    cursor.execute("SELECT * from customers")
    customers = cursor.fetchall()
    cursor.execute("SELECT * from customers_phone")
    customers_phone = cursor.fetchall()
    customer_code = request.form['customer_code']
    try:

        cursor.execute("""
            SELECT 
                o.ORDER_CODE,
                o.OPE_CODE,
                os.FIRST_NAME || ' ' || os.LAST_NAME,
                cat.CATE_CODE,
                cat.CATE_NAME,
                cat.COLOR,
                b.BOLT_CODE,
                       
                o.TOTAL_PRICE,
                o.ORDER_STATUS,
                o.CANCELLED_REASON
            FROM
                orders o
            JOIN 
                operational_staffs os ON o.OPE_CODE = os.OPE_CODE
            JOIN 
                contains cont ON o.ORDER_CODE = cont.ORDER_CODE
            JOIN 
                bolts b ON cont.BOLT_CODE = b.BOLT_CODE
            JOIN 
                categories cat ON b.CATE_CODE = cat.CATE_CODE
            WHERE 
                o.CUS_CODE = :1 AND cat.PRICE_DATE = cont.PRICE_DATE
            ORDER BY 
                o.ORDER_CODE, cat.CATE_NAME
        """, (customer_code,))

        orders = cursor.fetchall()

        return render_template('customers.html', orders = orders, customers = customers, customers_phone = customers_phone)
    except cx_Oracle.DatabaseError as e:
        error = str(e)
        print(error)
        return render_template('/error.html', error = "Something went wrong")
    finally:
        cursor.close()




#-----------------------EMPLOYEES-----------------------------
@app.route('/employees.html')
def employees():
    cursor = connection.cursor()
    # OFFICE STAFFS
    cursor.execute("SELECT * from office_staffs")
    office_staffs = cursor.fetchall()
    # OPERATIONAL STAFFS
    cursor.execute("SELECT * from operational_staffs")
    operational_staffs = cursor.fetchall()
    # PARTNER STAFFS
    cursor.execute("SELECT * from partner_staffs")
    partner_staffs = cursor.fetchall()
    # MANAGERS
    cursor.execute("SELECT * from managers")
    managers = cursor.fetchall()
    cursor.close()
    return render_template('employees.html', office_staffs = office_staffs, operational_staffs = operational_staffs, partner_staffs = partner_staffs, managers = managers)


#------------------------OTHERS--------------------------------
@app.route('/others.html')
def others():
    if overall_user in ['C##MANAGER', 'C##PARTNER_STAFF']:
        cursor = connection.cursor()
        # ORDERS
        cursor.execute('SELECT * from orders')
        orders = cursor.fetchall()
        # CONTAINS
        cursor.execute('SELECT * from contains')
        contains = cursor.fetchall()
        # BOLTS
        cursor.execute('SELECT * from bolts')
        bolts = cursor.fetchall()
        # PROVIDES
        cursor.execute('SELECT * from provides')
        provides = cursor.fetchall()
        # PAYMENTS
        cursor.execute("""SELECT * from payments""")
        payments = cursor.fetchall()
        # CONTAINS
        #cursor.execute('SELECT * from contains')
        # contains = cursor.fetchall()
        cursor.close()
        return render_template('others.html', orders = orders, contains = contains, bolts = bolts, provides = provides, payments = payments)
    else:
        return render_template('error.html', error = "You dont have any access!")


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)