const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const { category, search } = req.query;

    let query = `
      SELECT 
        p.id,
        p.title,
        p.category,
        p.description,
        p.image_url,
        p.created_at,
        u.id as photographer_id,
        u.name as photographer_name,
        u.city as photographer_city
      FROM photos p
      JOIN users u ON p.photographer_id = u.id
      WHERE u.role = 'photographer'
    `;

    const params = [];

    if (category && category !== 'Toate') {
      params.push(category);
      query += ` AND p.category = $${params.length}`;
    }

    if (search) {
      params.push(`%${search}%`);
      query += ` AND (
        u.name ILIKE $${params.length} OR 
        p.category ILIKE $${params.length} OR 
        u.city ILIKE $${params.length}
      )`;
    }

    query += ' ORDER BY p.created_at DESC';

    const result = await pool.query(query, params);
    res.json(result.rows);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.get('/photographer/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      `SELECT * FROM photos WHERE photographer_id = $1 ORDER BY created_at DESC`,
      [id]
    );
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { photographer_id, title, category, description, image_url } = req.body;

    const result = await pool.query(
      `INSERT INTO photos (photographer_id, title, category, description, image_url)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [photographer_id, title, category, description, image_url]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});


router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM photos WHERE id = $1', [id]);
    res.json({ message: 'Fotografie ștearsă' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

module.exports = router;