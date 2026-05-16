require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const pool = require('./db');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

app.use(cors());
app.use(express.json());

const authRoutes = require('./routes/auth');
app.use('/api/auth', authRoutes);

const photosRoutes = require('./routes/photos');
app.use('/api/photos', photosRoutes);

const aiRoutes = require('./routes/ai');
app.use('/api/ai', aiRoutes);

const calendarRoutes = require('./routes/calendar');
app.use('/api/calendar', calendarRoutes);

const messagesRoutes = require('./routes/messages');
app.use('/api/messages', messagesRoutes);

io.on('connection', (socket) => {
  console.log('User conectat:', socket.id);

  socket.on('join_conversation', (conversationId) => {
    socket.join(`conversation_${conversationId}`);
    console.log(`User ${socket.id} a intrat in conversatia ${conversationId}`);
  });

  socket.on('send_message', async (data) => {
    const { conversation_id, sender_id, text } = data;

    try {
      const result = await pool.query(
        `INSERT INTO messages (conversation_id, sender_id, text)
         VALUES ($1, $2, $3)
         RETURNING *`,
        [conversation_id, sender_id, text]
      );

      const message = result.rows[0];

      io.to(`conversation_${conversation_id}`).emit('receive_message', message);

    } catch (error) {
      console.error('Eroare salvare mesaj:', error);
    }
  });

  socket.on('disconnect', () => {
    console.log('User deconectat:', socket.id);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server pornit pe portul ${PORT}`);
});