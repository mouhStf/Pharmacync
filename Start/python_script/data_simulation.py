import datetime
import random
import sqlite3
from datetime import date, datetime, timedelta

def is_date_valid(date_str):
    """Validate if the date string is in DD/MM/YYYY format."""
    try:
        datetime.strptime(date_str, "%d/%m/%Y")
        return True
    except ValueError:
        return False


def get_last_stock_price(cip13, db_path="DataPrimeYo.db"):
    """
    Retrieves the last stock price (prix_d_achat) for a given CIP13 from the entres_stock table.
    If no entry exists for the CIP13, it will generate a new random price.

    Args:
        cip13 (str): The CIP13 code of the product.
        db_path (str): Path to the SQLite database.

    Returns:
        int: The last stock price or a new random price if no entry exists.
    """
    conn = None
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        cursor.execute("""
            SELECT prix_d_achat, prix_de_vente
            FROM entres_stock
            WHERE code_CIP13 = ?
            ORDER BY date_acquisition DESC
            LIMIT 1
        """, (cip13,))
        result = cursor.fetchone()

        if result:
            achat = result[0]
            vente = result[1]
            dta = 0
            dtv = 0
            if (random.uniform(0, 1) > 0.8):
                dta = random.randint(0, 100) * 5
                achat += dta
                increase_percentage = random.uniform(0.01, 0.10)
                vente_raw = achat * (1 + increase_percentage)
                vente = int(round(vente_raw / 5) * 5)

            return (achat, vente)
        else:
            # Generate a new random price if no entry exists

            achat = random.randint(20, 200) * 5
            # Vente is calculated as achat + a random percentage between 1% and 10%, rounded to the nearest 5.
            increase_percentage = random.uniform(0.01, 0.10)
            vente_raw = achat * (1 + increase_percentage)
            vente = int(round(vente_raw / 5) * 5)
            return (achat, vente)

    except sqlite3.Error as e:
        print(f"Database error: {e}")
        achat = random.randint(20, 200) * 5
        # Vente is calculated as achat + a random percentage between 1% and 10%, rounded to the nearest 5.
        increase_percentage = random.uniform(0.01, 0.10)
        vente_raw = achat * (1 + increase_percentage)
        vente = int(round(vente_raw / 5) * 5)
        return (achat, vente)
    finally:
        if conn:
            conn.close()

def add_stock(cip13, id_fournisseur, quantite, achat, vente, peremption_string, db_path="pharmacy.db"):
    """
    Add a stock entry to entres_stock and update or insert into stock.
    
    Args:
        cip13 (str): CIP13 code of the product.
        id_fournisseur (int): Supplier ID.
        quantite (int): Quantity to add.
        achat (int): Purchase price.
        vente (int): Sale price.
        peremption_string (str): Expiration date in DD/MM/YYYY format.
        db_path (str): Path to the SQLite database.
    
    Returns:
        str: Empty string on success, error message on failure.
    """
    # Input validations
    if achat <= 0:
        return "Purchase price must be positive."
    if vente <= 0:
        return "Sale price must be positive."
    if id_fournisseur == 0:
        return "Supplier must be specified."
    if not is_date_valid(peremption_string):
        return "Invalid expiration date format. Use DD/MM/YYYY."
    
    try:
        peremption = datetime.strptime(peremption_string, "%d/%m/%Y")
        if datetime.now().date() > peremption.date():
            return "Expiration date has passed."
        
        # Connect to database
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Validate CIP13 existence
        cursor.execute("SELECT code_CIP13 FROM presentation WHERE code_CIP13 = ?", (cip13,))
        if not cursor.fetchone():
            conn.close()
            return f"Product with CIP13 {cip13} does not exist."
        
        # Start transaction
        conn.execute("BEGIN TRANSACTION")
        
        # Insert into entres_stock
        current_time = int(datetime.now().timestamp())
        peremption_secs = int(peremption.timestamp())
        cursor.execute("""
            INSERT INTO entres_stock (code_CIP13, restant, quantite, prix_d_achat, prix_de_vente,
                                      date_acquisition, id_fournisseur, date_peremption)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (cip13, quantite, quantite, achat, vente, current_time, id_fournisseur, peremption_secs))
        
        # Get the last inserted ID
        entres_stock_id = cursor.lastrowid
        
        # Check if stock entry exists
        cursor.execute("SELECT code_CIP13 FROM stock WHERE code_CIP13 = ?", (cip13,))
        stock_exists = cursor.fetchone() is not None
        
        if not stock_exists:
            # Get category from produits via presentation_produit
            cursor.execute("""
                SELECT produits.category
                FROM produits
                JOIN presentation_produit ON produits.code_produit = presentation_produit.code_produit
                WHERE presentation_produit.ean_13 = ?
            """, (cip13,))
            category = cursor.fetchone()
            category = category[0] if category else 1
            
            # Insert into stock
            cursor.execute("""
                INSERT INTO stock (code_CIP13, restant, id_current, category)
                VALUES (?, ?, ?, ?)
            """, (cip13, quantite, entres_stock_id, category))
        else:
            # Update stock
            cursor.execute("""
                SELECT SUM(restant), MIN(id)
                FROM entres_stock
                WHERE code_CIP13 = ? AND restant > 0 AND deleted = 0
            """, (cip13,))
            result = cursor.fetchone()
            if not result or result[0] is None:
                conn.rollback()
                conn.close()
                return f"No valid stock entries found for CIP13 {cip13}."
            
            restant, min_id = result
            restant = restant or 0
            cursor.execute("""
                UPDATE stock
                SET restant = ?, id_current = ?
                WHERE code_CIP13 = ?
            """, (restant + quantite, min_id if min_id else entres_stock_id, cip13))
        
        # Commit transaction
        conn.commit()
        conn.close()
        return ""
    
    except sqlite3.Error as e:
        if conn:
            conn.rollback()
            conn.close()
        return f"Database error: {str(e)}"
    except Exception as e:
        if conn:
            conn.rollback()
            conn.close()
        return f"Error: {str(e)}"

def get_random_cip13_and_fournisseur_id():
    """
    Picks a random code_CIP13 from the presentation table and a random id from the fournisseur table using SQL's RANDOM() function.

    Returns:
        tuple: A tuple containing a random code_CIP13 and a random fournisseur id.
    """

    try:
        # Connect to the SQLite database
        conn = sqlite3.connect("DataPrimeYo.db")
        cursor = conn.cursor()

        # Fetch a random code_CIP13 from the presentation table
        cursor.execute("SELECT code_CIP13 FROM presentation ORDER BY RANDOM() LIMIT 1")
        cip13_result = cursor.fetchone()
        random_cip13 = cip13_result[0] if cip13_result else None

        # Fetch a random id from the fournisseur table
        cursor.execute("SELECT id FROM fournisseur ORDER BY RANDOM() LIMIT 1")
        fournisseur_id_result = cursor.fetchone()
        random_fournisseur_id = fournisseur_id_result[0] if fournisseur_id_result else None

        # Close the database connection
        conn.close()

        # Handle the case where either query returns None
        if random_cip13 is None or random_fournisseur_id is None:
            raise ValueError("Could not retrieve random CIP13 or fournisseur ID from the database.")

    except sqlite3.Error as e:
        print(f"Database error: {e}")
        # Use placeholder data in case of an error
        random_cip13 = random.choice(["3400930159459", "3400930000000", "3400930245678"])
        random_fournisseur_id = random.choice([1, 2, 3, 4, 5])
    except ValueError as e:
        print(f"Value error: {e}")
        # Use placeholder data in case of an error
        random_cip13 = random.choice(["3400930159459", "3400930000000", "3400930245678"])
        random_fournisseur_id = random.choice([1, 2, 3, 4, 5])

    return random_cip13, random_fournisseur_id

def generate_random_stock_data():
    (cip13, fournisseur) = get_random_cip13_and_fournisseur_id()
    quantite = random.randint(5, 20) * 10

    (achat, vente) = get_last_stock_price(cip13, db_path="DataPrimeYo.db") 

    # Generate a random expiration date at least 2 years in the future
    current_year = date.today().year
    random_year = random.randint(current_year + 2, current_year + 10)
    random_month = random.randint(1, 12)
    random_day = random.randint(1, 28)  # Safest to avoid month length issues
    peremption_date = date(random_year, random_month, random_day)
    peremption_string = peremption_date.strftime("%d/%m/%Y")

    return [cip13, fournisseur, quantite, achat, vente, peremption_string]

def generate_random_sale(db_path="DataPrimeYo.db"):
    """
    Picks random products from stock to generate a sale list and calculates the total value.
    
    Args:
        db_path (str): Path to the SQLite database.
        
    Returns:
        tuple: A tuple containing the sale dictionary {cip13: quantity} and the total value.
    """
    conn = None
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        num_products_to_sell = random.randint(1, 7)
        
        query = """
            SELECT s.code_CIP13, s.restant, es.prix_de_vente
            FROM stock s
            JOIN entres_stock es ON s.id_current = es.id
            WHERE s.restant > 0
            ORDER BY RANDOM()
            LIMIT ?
        """
        cursor.execute(query, (num_products_to_sell,))
        available_products = cursor.fetchall()

        if not available_products:
            print("No products in stock to generate a sale.")
            return {}, 0

        sale_dict = {}
        total_value = 0
        for cip13, stock_quantity, price in available_products:
            if stock_quantity > 0:
                sell_quantity = 1
                if random.uniform(0, 1) > 0.8: 
                    sell_quantity = random.randint(1, min(5, stock_quantity))
                sale_dict[cip13] = sell_quantity
                total_value += sell_quantity * price
            
        return sale_dict, total_value

    except sqlite3.Error as e:
        print(f"Database error in generate_random_sale: {e}")
        return {}, 0
    finally:
        if conn:
            conn.close()

def generate_random_sale_data():
    sale_products, sale_valeur = generate_random_sale()

    if sale_products:
        # --- Simulate Realistic Payment ---
        prob = random.random()
        donne = 0

        if prob < 0.95:  # 80% chance of paying with a larger, round bill
            round_bills = [500, 1000, 2000, 5000]
            # Find the smallest bill that is larger than the sale value
            for bill in round_bills:
                if bill > sale_valeur:
                    donne = bill
                    break
            if donne == 0: # If the value is very high, just add a bit
                while donne < sale_valeur:
                    donne += 5000
        else:  # 5% chance of paying less
            donne = sale_valeur - (random.randint(0, 500) * 5)
            if donne < 0:
                donne = 0
        
        # Ensure donne is a multiple of 5
        donne = int(round(donne / 5) * 5)

        rendu = max(0, donne - sale_valeur)
        
        return [sale_products, sale_valeur, donne, rendu]
        print(f"Amount given: {donne}, Change: {rendu}")
    else:
        return []

def remove_from_stock(cursor, cip13, qt):
    """
    Removes a given quantity from the stock for a specific CIP13.
    Corresponds to the C++ removeFromStock function.
    """
    cursor.execute("SELECT restant FROM stock WHERE code_CIP13 = ?", (cip13,))
    result = cursor.fetchone()
    if result is None:
        raise Exception(f"Stock entry not found for CIP13 {cip13}")
    
    restant = result[0]
    
    new_restant = restant - qt
    if new_restant < 0:
        print(f"Warning: Stock for {cip13} is going negative.")

    cursor.execute("UPDATE stock SET restant = ? WHERE code_CIP13 = ?", (new_restant, cip13))
    return True

def insert_flux(cursor, id_facture, cip13, quantite):
    """
    Handles the sale of a single product, creating a flux entry.
    Corresponds to the C++ insertFlux function.
    """
    cursor.execute("SELECT id_current FROM stock WHERE code_CIP13 = ?", (cip13,))
    id_current_result = cursor.fetchone()
    if not id_current_result or id_current_result[0] is None or id_current_result[0] == -1:
        raise Exception(f"No available stock batch (id_current) for CIP13 {cip13}.")
    id_current = id_current_result[0]

    cursor.execute("SELECT restant FROM entres_stock WHERE id = ?", (id_current,))
    restant_result = cursor.fetchone()
    if not restant_result:
        raise Exception(f"entres_stock entry not found for id {id_current}.")
    restant = restant_result[0]

    delta = restant - quantite
    a = min(restant, quantite)
    b = max(delta, 0)
    dtime = int(datetime.now().timestamp())

    cursor.execute("""
        INSERT INTO flux (code_CIP13, quantite, restant, id_facture, id_entres_stock, date) 
        VALUES (?, ?, ?, ?, ?, ?)
    """, (cip13, a, a, id_facture, id_current, dtime))

    cursor.execute("UPDATE entres_stock SET restant = ? WHERE id = ?", (b, id_current))
    
    remove_from_stock(cursor, cip13, a)

    if delta <= 0:
        cursor.execute("""
            SELECT id FROM entres_stock 
            WHERE code_CIP13 = ? AND restant > 0 AND deleted = 0 
            ORDER BY id ASC LIMIT 1
        """, (cip13,))
        new_id_result = cursor.fetchone()
        new_id = new_id_result[0] if new_id_result else -1
        
        cursor.execute("UPDATE stock SET id_current = ? WHERE code_CIP13 = ?", (new_id, cip13))
        
        if delta < 0:
            insert_flux(cursor, id_facture, cip13, -delta)
            
    return True

def vendre(produits, valeur, donne, rendu, date_facture, user_id=1, db_path="DataPrimeYo.db"):
    """
    Simulates selling products, creating an invoice and flux entries.
    Corresponds to the C++ vendre function.
    """
    if not produits:
        return "No products to sell."

    conn = None
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        conn.execute("BEGIN TRANSACTION")

        #date_facture = int(datetime.now().timestamp())
        paye = donne - rendu
        cursor.execute("""
            INSERT INTO facture (date, valeur, paye, donne, rendu, id_user)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (date_facture, valeur, paye, donne, rendu, user_id))

        print("Date ", date_facture)
        
        id_facture = cursor.lastrowid

        for cip13, quantite in produits.items():
            if quantite <= 0:
                continue
            insert_flux(cursor, id_facture, cip13, quantite)

        conn.commit()
        return ""
    except sqlite3.Error as e:
        if conn:
            conn.rollback()
        return f"Database error during sale: {e}"
    except Exception as e:
        if conn:
            conn.rollback()
        return f"An error occurred during sale: {e}"
    finally:
        if conn:
            conn.close()

def generate_sales_dates(begin_date, end_date):
    """
    Generates a list of datetime objects randomly distributed between a given start and end date,
    with times between 9:00 and 22:00.

    Args:
        begin_date (datetime): The start date (YYYY-MM-DD).
        end_date (datetime): The end date (YYYY-MM-DD).

    Returns:
        list: A list of datetime objects.
    """
    num_dates = random.randint(100, 200)
    current_date = begin_date
    while current_date <= end_date:
        for _ in range(num_dates):
            random_hour = random.randint(9, 22)
            random_minute = random.randint(0, 59)
            random_second = random.randint(0, 59)
            random_date = current_date.replace(hour=random_hour, minute=random_minute, second=random_second)
            yield random_date
        current_date += timedelta(days=1)



thstock = []
def doJob(date_vente):
    sale_products, sale_valeur = generate_random_sale()

    if sale_products:
        print("--- Performing a Random Sale ---")
        print(f"Products to sell: {sale_products}")
        print(f"Total value: {sale_valeur}")

        # --- Simulate Realistic Payment ---
        prob = random.random()
        donne = 0

        if prob < 0.95:  # 80% chance of paying with a larger, round bill
            round_bills = [500, 1000, 2000, 5000]
            # Find the smallest bill that is larger than the sale value
            for bill in round_bills:
                if bill > sale_valeur:
                    donne = bill
                    break
            if donne == 0: # If the value is very high, just add a bit
                while donne < sale_valeur:
                    donne += 5000
        else:  # 5% chance of paying less
            donne = sale_valeur - (random.randint(0, 500) * 5)
            if donne < 0:
                donne = 0
        
        # Ensure donne is a multiple of 5
        donne = int(round(donne / 5) * 5)

        rendu = max(0, donne - sale_valeur)
        
        print(f"Amount given: {donne}, Change: {rendu}")

        result_vendre = vendre( sale_products, sale_valeur, donne, rendu, date_vente, user_id=1 )
        print(f"Result of selling stock: '{result_vendre if result_vendre else 'Success'}'")
    else:
        print("--- Populating Database with 20 Random Stock Entries ---")
        if len(thstock) == 0:
            for _ in range(250):
                thstock.append(generate_random_stock_data())
        for stock_data in thstock:
            r = random.randint(1, 5)
            for i in range(r):
                result_add = add_stock(
                    stock_data[0], stock_data[1], stock_data[2],
                    stock_data[3], stock_data[4], stock_data[5],
                    db_path="DataPrimeYo.db" 
                )
                if result_add:
                    print(f"Failed to add stock for {stock_data[0]}: {result_add}")
            print("--- Population Complete ---\n")

if __name__ == "__main__":
    #doJob()

    # Generate and print random sales dates
    begin_date = datetime(2015, 1, 1)
    end_date = datetime(2025, 7, 31)
    current_month = 1
    for dt in generate_sales_dates(begin_date, end_date):
        if current_month != dt.month:
            current_month = dt.month
            print(current_month)
            stock_data = generate_random_stock_data()
            thstock.append(stock_data)
            result_add = add_stock(
                stock_data[0], stock_data[1], stock_data[2],
                stock_data[3], stock_data[4], stock_data[5],
                db_path="DataPrimeYo.db" 
            )
        print(dt, int(dt.timestamp()))
        doJob(int(dt.timestamp()))
