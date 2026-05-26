const nodemailer = require('nodemailer');
const { EMAIL_USER, EMAIL_PASS } = require('../db');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: EMAIL_USER,
    pass: EMAIL_PASS,
  },
});

async function sendVerificationEmail(toEmail, code) {
  const mailOptions = {
    from: `"Lensly" <${EMAIL_USER}>`,
    to: toEmail,
    subject: 'Verifică-ți contul Lensly',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 40px; background-color: #FAF8F5;">
        <h1 style="font-size: 28px; font-weight: 300; color: #3D3530; letter-spacing: 2px; text-align: center;">Lensly</h1>
        <p style="font-size: 12px; color: #C4B9A8; text-align: center; letter-spacing: 3px;">discover · book · inspire</p>
        <div style="margin: 40px 0; padding: 30px; background-color: #EDEA E4; border-radius: 12px; text-align: center;">
          <p style="font-size: 14px; color: #8C7B6B; margin-bottom: 20px;">Codul tău de verificare:</p>
          <h2 style="font-size: 42px; font-weight: 300; color: #3D3530; letter-spacing: 8px; margin: 0;">${code}</h2>
        </div>
        <p style="font-size: 12px; color: #C4B9A8; text-align: center;">Codul expiră în 10 minute.</p>
        <p style="font-size: 12px; color: #C4B9A8; text-align: center;">Dacă nu tu ai creat acest cont, ignoră acest email.</p>
      </div>
    `,
  };

  await transporter.sendMail(mailOptions);
}

module.exports = { sendVerificationEmail };