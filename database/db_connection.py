import pyodbc
import os
import logging
import config

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("db_connection")

def get_connection():
    try:
        conn = pyodbc.connect(
            f"DRIVER={{ODBC Driver 18 for SQL Server}};"
            f"SERVER={config.SQL_SERVER};"
            f"DATABASE={config.SQL_DATABASE};"
            f"UID={config.SQL_USER};"
            f"PWD={config.SQL_PASSWORD};"
            "Encrypt=yes;"
            "TrustServerCertificate=no;"
            "Connection Timeout=30;"
        )
        return conn
    except Exception as e:
        logger.error(f"Azure SQL connection failed: {e}")
        raise e
    
    
def execute_query(query, params=None):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)

        conn.commit()

        try:
            cursor.execute("SELECT @@IDENTITY")
            last_row_id = cursor.fetchone()[0]
        except:
            last_row_id = None

        cursor.close()
        conn.close()

        return last_row_id

    except Exception as e:
        conn.rollback()
        cursor.close()
        conn.close()
        logger.error(f"Error executing query: {e}")
        raise e
    

def execute_read(query, params=None):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)

        columns = [column[0] for column in cursor.description]
        rows = cursor.fetchall()

        result = []

        for row in rows:
            result.append(dict(zip(columns, row)))

        cursor.close()
        conn.close()

        return result

    except Exception as e:
        cursor.close()
        conn.close()
        logger.error(f"Error executing read query: {e}")
        raise e
    
    
def init_db():
    """
    Initializes the database using the schema.sql file.
    Creates tables if they do not exist.
    """
    schema_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "schema.sql")
    if not os.path.exists(schema_path):
        logger.error(f"Schema file not found at {schema_path}")
        return
        
    with open(schema_path, "r") as f:
        schema_sql = f.read()
        
    conn = get_connection()
    cursor = conn.cursor()
    
   
            
  
    statements = schema_sql.split(";")
    
    for statement in statements:
        statement = statement.strip()
        if not statement:
            continue
        
                
        try:
            cursor.execute(statement)
        except Exception as e:
            # For SQLite, ignore errors on things it doesn't fully support or if they exist
            logger.error(f"Failed to execute schema statement: {statement}. Error: {e}")
            
    conn.commit()
    cursor.close()
    conn.close()
    logger.info("Database initialized successfully.")
