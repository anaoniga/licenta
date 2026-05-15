const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const JWT_SECRET = 'lensly_secret_key_2025';
const pool = require('../db');

router.post('/register', async (req, res) => {
    try {
        const { name, email, password, role } = req.body;

        const existingUser = await pool.query(
            'SELECT * FROM users WHERE email = $1',
            [email]
        );

        if (existingUser.rows.length > 0) {
            return res.status(400).json({ error: 'Email-ul există deja' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const result = await pool.query(
            'INSERT INTO users (name, email, password, role) VALUES ($1, $2, $3, $4) RETURNING id, name, email, role',
            [name, email, hashedPassword, role || 'client']
        );

        const user = result.rows[0];

        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            JWT_SECRET,
            {expiresIn: '7d' }
        );

        res.status(201).json({ token, user });
    }   catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Eroare server' });
    }
});

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

    }   catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Eroare server' });
    }
});

module.exports = router;