const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/test', async (req, res) => {
  res.json({ message: 'users ok' });
});

router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT id, name, email, role, city, specializations, contact_phone, contact_instagram, bio FROM users WHERE id = $1',
      [id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User negăsit' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, city, specializations, contact_phone, contact_instagram, bio } = req.body;
    const result = await pool.query(
      'UPDATE users SET name = $1, city = $2, specializations = $3, contact_phone = $4, contact_instagram = $5, bio = $6 WHERE id = $7 RETURNING *',
      [name, city, specializations, contact_phone, contact_instagram, bio, id]
    );
    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.get('/:id/stats', async (req, res) => {
  try {
    const { id } = req.params;

    const photosResult = await pool.query(
      'SELECT COUNT(*) as count FROM photos WHERE photographer_id = $1',
      [id]
    );

    const conversationsResult = await pool.query(
      'SELECT COUNT(*) as count FROM conversations WHERE photographer_id = $1',
      [id]
    );

    const savedResult = await pool.query(
      'SELECT COUNT(*) as count FROM saved_photographers WHERE photographer_id = $1',
      [id]
    );

    res.json({
      photos: parseInt(photosResult.rows[0].count),
      conversations: parseInt(conversationsResult.rows[0].count),
      saved: parseInt(savedResult.rows[0].count),
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

module.exports = router;