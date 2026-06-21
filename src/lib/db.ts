
import { Pool } from 'pg';

const pool = new Pool({
  // Use environment variable if set, otherwise fall back to local connection string
  connectionString:
    process.env.POSTGRESQL ||
    process.env.DATABASE_URL ||
    "postgresql://postgres:admin123@localhost:5432/biblioteca_db",
});

export default pool;