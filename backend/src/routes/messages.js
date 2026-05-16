const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/conversations/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const result = await pool.query(`
      SELECT 
        c.id,
        c.created_at,
        u1.id as client_id,
        u1.name as client_name,
        u2.id as photographer_id,
        u2.name as photographer_name,
        (
          SELECT text FROM messages 
          WHERE conversation_id = c.id 
          ORDER BY created_at DESC LIMIT 1
        ) as last_message,
        (
          SELECT created_at FROM messages 
          WHERE conversation_id = c.id 
          ORDER BY created_at DESC LIMIT 1
        ) as last_message_time,
        (
          SELECT COUNT(*) FROM messages 
          WHERE conversation_id = c.id 
          AND is_read = false 
          AND sender_id != $1
        ) as unread_count
      FROM conversations c
      JOIN users u1 ON c.client_id = u1.id
      JOIN users u2 ON c.photographer_id = u2.id
      WHERE c.client_id = $1 OR c.photographer_id = $1
      ORDER BY last_message_time DESC NULLS LAST
    `, [userId]);

    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.get('/conversation/:conversationId', async (req, res) => {
  try {
    const { conversationId } = req.params;

    const result = await pool.query(`
      SELECT 
        m.id,
        m.text,
        m.is_read,
        m.created_at,
        m.sender_id,
        u.name as sender_name
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = $1
      ORDER BY m.created_at ASC
    `, [conversationId]);

    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.post('/conversation', async (req, res) => {
  try {
    const { client_id, photographer_id } = req.body;

    const existing = await pool.query(
      `SELECT * FROM conversations 
       WHERE client_id = $1 AND photographer_id = $2`,
      [client_id, photographer_id]
    );

    if (existing.rows.length > 0) {
      return res.json(existing.rows[0]);
    }

    const result = await pool.query(
      `INSERT INTO conversations (client_id, photographer_id)
       VALUES ($1, $2) RETURNING *`,
      [client_id, photographer_id]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

router.put('/read/:conversationId/:userId', async (req, res) => {
  try {
    const { conversationId, userId } = req.params;

    await pool.query(
      `UPDATE messages SET is_read = true 
       WHERE conversation_id = $1 AND sender_id != $2`,
      [conversationId, userId]
    );

    res.json({ message: 'Mesaje marcate ca citite' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

module.exports = router;