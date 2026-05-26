const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db');
const { sendVerificationEmail } = require('./email');

const JWT_SECRET = 'lensly_secret_key_2025';

// REGISTER — salveaza temporar si trimite cod
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    // verificam daca emailul exista deja in users
    const existingUser = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );
    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'Email-ul există deja' });
    }

    // stergem orice inregistrare pending anterioara
    await pool.query(
      'DELETE FROM pending_users WHERE email = $1',
      [email]
    );

    // criptam parola
    const hashedPassword = await bcrypt.hash(password, 10);

    // generam cod de verificare
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minute

    // salvam temporar in pending_users
    const result = await pool.query(
      `INSERT INTO pending_users (name, email, password, role, verification_code, verification_expires)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, email`,
      [name, email, hashedPassword, role || 'client', verificationCode, expiresAt]
    );

    // trimitem emailul
    await sendVerificationEmail(email, verificationCode);

    res.status(201).json({
      message: 'Cod trimis pe email!',
      pendingId: result.rows[0].id,
      email: result.rows[0].email,
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

// VERIFY — verifica codul si creeaza contul real
router.post('/verify', async (req, res) => {
  try {
    const { pendingId, code } = req.body;

    const result = await pool.query(
      'SELECT * FROM pending_users WHERE id = $1',
      [pendingId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Sesiune expirată. Înregistrează-te din nou.' });
    }

    const pending = result.rows[0];

    // verificam codul
    if (pending.verification_code !== code) {
      return res.status(400).json({ error: 'Cod incorect' });
    }

    // verificam expirarea
    if (new Date() > new Date(pending.verification_expires)) {
      await pool.query('DELETE FROM pending_users WHERE id = $1', [pendingId]);
      return res.status(400).json({ error: 'Codul a expirat. Înregistrează-te din nou.' });
    }

    // cream contul real in users
    const userResult = await pool.query(
      `INSERT INTO users (name, email, password, role, is_verified)
       VALUES ($1, $2, $3, $4, true)
       RETURNING id, name, email, role`,
      [pending.name, pending.email, pending.password, pending.role]
    );

    // stergem din pending
    await pool.query('DELETE FROM pending_users WHERE id = $1', [pendingId]);

    const user = userResult.rows[0];

    // generam JWT
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      }
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

// RESEND CODE
router.post('/resend', async (req, res) => {
  try {
    const { pendingId } = req.body;

    const result = await pool.query(
      'SELECT * FROM pending_users WHERE id = $1',
      [pendingId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Sesiune expirată' });
    }

    const pending = result.rows[0];

    // generam cod nou
    const newCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await pool.query(
      `UPDATE pending_users SET verification_code = $1, verification_expires = $2 WHERE id = $3`,
      [newCode, expiresAt, pendingId]
    );

    await sendVerificationEmail(pending.email, newCode);

    res.json({ message: 'Cod nou trimis!' });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

// LOGIN
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Email sau parolă incorectă' });
    }

    const user = result.rows[0];

    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Email sau parolă incorectă' });
    }

    // verificam daca emailul e verificat
    if (!user.is_verified) {
      return res.status(401).json({
        error: 'Email-ul nu este verificat.',
        needsVerification: true,
        email: user.email,
      });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      }
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

module.exports = router;