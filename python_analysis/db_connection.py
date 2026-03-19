from sqlalchemy import create_engine
import pandas as pd

# Update these if your setup is different
DB_NAME = "ipl_analytics"
DB_USER = "postgres"
DB_PASS = "postgres"
DB_HOST = "localhost"
DB_PORT = "5432"

engine = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

def load_table(table_name):
    """Load a full table into a pandas DataFrame."""
    return pd.read_sql(f"SELECT * FROM {table_name}", engine)

def run_query(query):
    """Run any SQL query and return a DataFrame."""
    return pd.read_sql(query, engine)