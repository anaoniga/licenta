const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/photographer/:photographerId', async (req, res) => {
  try {
    const { photographerId } = req.params;
    const { month, year } = req.query;

    let query = `
      SELECT 
        id,
        date,
        type,
        is_public,
        CASE WHEN is_public THEN title ELSE NULL END as title
      FROM calendar_events
      WHERE photographer_id = $1
    `;

    const params = [photographerId];

    if (month && year) {
      params.push(year, month);
      query += ` AND EXTRACT(YEAR FROM date) = $2 
                 AND EXTRACT(MONTH FROM date) = $3`;
    }

    query += ' ORDER BY date ASC';

    const result = await pool.query(query, params);
    res.json(result.rows);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { photographer_id, date, type, title, is_public } = req.body;

    const result = await pool.query(
      `INSERT INTO calendar_events 
        (photographer_id, date, type, title, is_public)
       VALUES ($1, $2::date, $3, $4, $5)
       RETURNING *`,
      [photographer_id, date, type, title || null, is_public || false]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.delete('/event/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query(
      'DELETE FROM calendar_events WHERE id = $1',
      [id]
    );
    res.json({ message: 'Eveniment șters' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.put('/event/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { type, title, is_public } = req.body;

    const result = await pool.query(
      `UPDATE calendar_events 
       SET type = $1, title = $2, is_public = $3
       WHERE id = $4
       RETURNING *`,
      [type, title || null, is_public || false, id]
    );

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

module.exports = router;