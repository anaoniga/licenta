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

const CLOUDINARY_CLOUD_NAME = 'Ana Oniga';
const CLOUDINARY_API_KEY = '178427792657746';
const CLOUDINARY_API_SECRET = 'Zyn2hjkUfZ8-BwamBB-ekAOMcf8';

const EMAIL_USER = 'noreply.lensly@gmail.com';
const EMAIL_PASS = 'wcrg hmmn pfqw rkxa';


module.exports = pool;
module.exports.GEMINI_API_KEY = GEMINI_API_KEY;

module.exports.CLOUDINARY_CLOUD_NAME = CLOUDINARY_CLOUD_NAME;
module.exports.CLOUDINARY_API_KEY = CLOUDINARY_API_KEY;
module.exports.CLOUDINARY_API_SECRET = CLOUDINARY_API_SECRET;
module.exports.EMAIL_USER = EMAIL_USER;
module.exports.EMAIL_PASS = EMAIL_PASS;