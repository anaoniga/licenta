const express = require('express');
const router = express.Router();
const cloudinary = require('cloudinary').v2;
const multer = require('multer');
const pool = require('../db');
const { 
  CLOUDINARY_CLOUD_NAME, 
  CLOUDINARY_API_KEY, 
  CLOUDINARY_API_SECRET 
} = require('../db');

cloudinary.config({
  cloud_name: 'dge5swtdy',
  api_key: '178427792657746',
  api_secret: 'Zyn2hjkUfZ8-BwamBB-ekAOMcf8',
});

const storage = multer.memoryStorage();
const upload = multer({ 
  storage,
  limits: { fileSize: 20 * 1024 * 1024 }, // max 20MB
});

router.post('/photo', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Nicio imagine trimisă' });
    }

    const { photographer_id, title, category, description } = req.body;

    const uploadResult = await new Promise((resolve, reject) => {
      cloudinary.uploader.upload_stream(
        {
          folder: 'lensly',
          transformation: [
            { width: 800, crop: 'limit' },
            { quality: 'auto' },
          ],
        },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      ).end(req.file.buffer);
    });

    const result = await pool.query(
      `INSERT INTO photos (photographer_id, title, category, description, image_url)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [
        photographer_id,
        title || 'Fără titlu',
        category || 'General',
        description || '',
        uploadResult.secure_url,
      ]
    );

    res.status(201).json({
      photo: result.rows[0],
      image_url: uploadResult.secure_url,
    });

  } catch (error) {
    console.error('Eroare upload:', error);
    res.status(500).json({ error: 'Eroare la upload' });
  }
});

module.exports = router;