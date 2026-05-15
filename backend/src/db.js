const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'lensly',
  user: 'postgres',
  password: 'lensly2026',
});

pool.connect((err, client, release) => {
  if (err) {
    console.error('Eroare conectare DB:', err.message);
  } else {
    console.log('Conectat la PostgreSQL!');
    release();
  }
});

const GEMINI_API_KEY = 'AIzaSyBALBOT0kW4J_4oGrOoujiswQ3c5v0V0F8';

module.exports = pool;
module.exports.GEMINI_API_KEY = GEMINI_API_KEY;