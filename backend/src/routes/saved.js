const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/photographers/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await pool.query(`
      SELECT 
        sp.id as saved_id,
        u.id as photographer_id,
        u.name,
        u.city,
        u.specializations
      FROM saved_photographers sp
      JOIN users u ON sp.photographer_id = u.id
      WHERE sp.user_id = $1
    `, [userId]);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.post('/photographer', async (req, res) => {
  try {
    const { user_id, photographer_id } = req.body;

    const existing = await pool.query(
      'SELECT * FROM saved_photographers WHERE user_id = $1 AND photographer_id = $2',
      [user_id, photographer_id]
    );

    if (existing.rows.length > 0) {
      return res.status(400).json({ error: 'Fotograf deja salvat' });
    }

    const result = await pool.query(
      'INSERT INTO saved_photographers (user_id, photographer_id) VALUES ($1, $2) RETURNING *',
      [user_id, photographer_id]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.delete('/photographer/:userId/:photographerId', async (req, res) => {
  try {
    const { userId, photographerId } = req.params;
    await pool.query(
      'DELETE FROM saved_photographers WHERE user_id = $1 AND photographer_id = $2',
      [userId, photographerId]
    );
    res.json({ message: 'Fotograf eliminat din salvate' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.get('/check/:userId/:photoId', async (req, res) => {
  try {
    const { userId, photoId } = req.params;
    const result = await pool.query(
      'SELECT * FROM saved_photos WHERE user_id = $1 AND photo_id = $2',
      [userId, photoId]
    );
    res.json({ isSaved: result.rows.length > 0 });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await pool.query(`
      SELECT 
        sp.id as saved_id,
        sp.folder,
        sp.created_at as saved_at,
        p.id as photo_id,
        p.title,
        p.category,
        p.image_url,
        u.name as photographer_name,
        u.city as photographer_city
      FROM saved_photos sp
      JOIN photos p ON sp.photo_id = p.id
      JOIN users u ON p.photographer_id = u.id
      WHERE sp.user_id = $1
      ORDER BY sp.created_at DESC
    `, [userId]);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { user_id, photo_id, folder } = req.body;
    const existing = await pool.query(
      'SELECT * FROM saved_photos WHERE user_id = $1 AND photo_id = $2',
      [user_id, photo_id]
    );
    if (existing.rows.length > 0) {
      return res.status(400).json({ error: 'Fotografie deja salvată' });
    }
    const result = await pool.query(
      `INSERT INTO saved_photos (user_id, photo_id, folder)
       VALUES ($1, $2, $3) RETURNING *`,
      [user_id, photo_id, folder || 'General']
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.delete('/:userId/:photoId', async (req, res) => {
  try {
    const { userId, photoId } = req.params;
    await pool.query(
      'DELETE FROM saved_photos WHERE user_id = $1 AND photo_id = $2',
      [userId, photoId]
    );
    res.json({ message: 'Fotografie eliminată din salvate' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

module.exports = router;