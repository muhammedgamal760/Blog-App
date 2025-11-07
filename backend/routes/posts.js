const express = require('express');
const { pool } = require('../config/database');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// All post routes require authentication
router.use(authMiddleware);

// Get all posts
router.get('/', async (req, res) => {
  try {
    const [posts] = await pool.query(`
      SELECT p.*, u.username as author 
      FROM posts p 
      JOIN users u ON p.author_id = u.id 
      ORDER BY p.created_at DESC
    `);
    res.json(posts);
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ message: 'Error fetching posts' });
  }
});

// Get single post
router.get('/:id', async (req, res) => {
  try {
    const [posts] = await pool.query(`
      SELECT p.*, u.username as author 
      FROM posts p 
      JOIN users u ON p.author_id = u.id 
      WHERE p.id = ?
    `, [req.params.id]);

    if (posts.length === 0) {
      return res.status(404).json({ message: 'Post not found' });
    }

    res.json(posts[0]);
  } catch (error) {
    console.error('Error fetching post:', error);
    res.status(500).json({ message: 'Error fetching post' });
  }
});

// Create new post
router.post('/', async (req, res) => {
  try {
    const { title, content } = req.body;

    if (!title || !content) {
      return res.status(400).json({ message: 'Title and content are required' });
    }

    const [result] = await pool.query(
      'INSERT INTO posts (title, content, author_id) VALUES (?, ?, ?)',
      [title, content, req.userId]
    );

    const [newPost] = await pool.query(`
      SELECT p.*, u.username as author 
      FROM posts p 
      JOIN users u ON p.author_id = u.id 
      WHERE p.id = ?
    `, [result.insertId]);

    res.status(201).json(newPost[0]);
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ message: 'Error creating post' });
  }
});

// Update post
router.put('/:id', async (req, res) => {
  try {
    const { title, content } = req.body;
    const postId = req.params.id;

    // Check if post exists and user is the author
    const [posts] = await pool.query(
      'SELECT * FROM posts WHERE id = ? AND author_id = ?',
      [postId, req.userId]
    );

    if (posts.length === 0) {
      return res.status(404).json({ message: 'Post not found or unauthorized' });
    }

    await pool.query(
      'UPDATE posts SET title = ?, content = ? WHERE id = ?',
      [title, content, postId]
    );

    const [updatedPost] = await pool.query(`
      SELECT p.*, u.username as author 
      FROM posts p 
      JOIN users u ON p.author_id = u.id 
      WHERE p.id = ?
    `, [postId]);

    res.json(updatedPost[0]);
  } catch (error) {
    console.error('Error updating post:', error);
    res.status(500).json({ message: 'Error updating post' });
  }
});

// Delete post
router.delete('/:id', async (req, res) => {
  try {
    const postId = req.params.id;

    // Check if post exists and user is the author
    const [posts] = await pool.query(
      'SELECT * FROM posts WHERE id = ? AND author_id = ?',
      [postId, req.userId]
    );

    if (posts.length === 0) {
      return res.status(404).json({ message: 'Post not found or unauthorized' });
    }

    await pool.query('DELETE FROM posts WHERE id = ?', [postId]);

    res.json({ message: 'Post deleted successfully' });
  } catch (error) {
    console.error('Error deleting post:', error);
    res.status(500).json({ message: 'Error deleting post' });
  }
});

module.exports = router;
