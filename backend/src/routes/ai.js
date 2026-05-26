const express = require('express');
const router = express.Router();
const { GoogleGenerativeAI } = require('@google/generative-ai');
const pool = require('../db');

const GEMINI_API_KEY = 'AIzaSyBALBOT0kW4J_4oGrOoujiswQ3c5v0V0F8';
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

function removeDiacritics(str) {
  return str.normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase();
}

router.post('/chat', async (req, res) => {
  try {
    const { message } = req.body;

    const photosResult = await pool.query(`
      SELECT DISTINCT ON (u.id)
        u.id as photographer_id,
        u.name as photographer_name,
        u.city,
        p.category
      FROM photos p
      JOIN users u ON p.photographer_id = u.id
      WHERE u.role = 'photographer'
      ORDER BY u.id
    `);

    const allPhotographers = photosResult.rows;

    const categoriesResult = await pool.query(`
      SELECT DISTINCT LOWER(category) as category 
      FROM photos
    `);
    const availableCategories = categoriesResult.rows.map(r => r.category);

    const photographerList = allPhotographers.map(p =>
      `- ${p.photographer_name} din ${p.city}, specializat în ${p.category}`
    ).join('\n');

    const prompt = `Ești asistentul aplicației Lensly pentru fotografie din România.
    
REGULI STRICTE:
1. Răspunde DOAR cu informații din lista de mai jos
2. Răspunde SCURT — maxim 3 propoziții
3. Nu menționa alte platforme, site-uri sau fotografi din afara listei
4. Dacă nu găsești ce caută utilizatorul în listă, spune că nu avem momentan acel stil
5. Răspunde în română

Categorii disponibile în Lensly: ${availableCategories.join(', ')}

Fotografii disponibili în Lensly:
${photographerList}

Mesaj utilizator: ${message}`;

    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
    const result = await model.generateContent(prompt);
    const response = result.response.text();

    const normalizedMessage = removeDiacritics(message);

    const seen = new Set();
    const uniquePhotographers = allPhotographers.filter(p => {
      if (seen.has(p.photographer_id)) return false;
      seen.add(p.photographer_id);
      return true;
    });

    const relevantPhotographers = uniquePhotographers.filter(p => {
      const normalizedCategory = removeDiacritics(p.category);
      const normalizedCity = removeDiacritics(p.city || '');
      const normalizedName = removeDiacritics(p.photographer_name);

      return normalizedMessage.includes(normalizedCategory) ||
        normalizedMessage.includes(normalizedCity) ||
        normalizedMessage.includes(normalizedName.split(' ')[0]) ||
        (normalizedMessage.includes('nunta') && normalizedCategory === 'wedding') ||
        normalizedMessage.includes('fotograf');
    });

    const photographers = relevantPhotographers.length > 0
      ? relevantPhotographers.slice(0, 3)
      : uniquePhotographers.slice(0, 3);

    res.json({
      message: response,
      photographers: photographers,
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Eroare server' });
  }
});

module.exports = router;