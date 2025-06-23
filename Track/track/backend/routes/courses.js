const express = require('express');
const router = express.Router();
const Course = require('../models/Course');
const { body, validationResult } = require('express-validator');

// Get all courses
router.get('/', async (req, res) => {
    try {
        const courses = await Course.find();
        res.json(courses);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Get single course
router.get('/:id', async (req, res) => {
    try {
        const course = await Course.findById(req.params.id);
        if (!course) return res.status(404).json({ message: 'Course not found' });
        res.json(course);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Create course
router.post('/', [
    body('name').notEmpty().trim(),
    body('code').notEmpty().trim(),
    body('credits').isNumeric(),
    body('instructor').notEmpty().trim(),
    body('degree').isIn(['BCS', 'BAI', 'BSE', 'BCY', 'BFT', 'BSEE', 'BSBA']),
    body('semester').isIn(['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8']),
    body('section').isIn(['Section A', 'Section B', 'Section C', 'Section D', 'Section E', 'Section F', 'Section G']),
    body('schedule').isArray()
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const course = new Course(req.body);
    try {
        const newCourse = await course.save();
        res.status(201).json(newCourse);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Update course
router.put('/:id', async (req, res) => {
    try {
        const course = await Course.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true }
        );
        if (!course) return res.status(404).json({ message: 'Course not found' });
        res.json(course);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Delete course
router.delete('/:id', async (req, res) => {
    try {
        const course = await Course.findByIdAndDelete(req.params.id);
        if (!course) return res.status(404).json({ message: 'Course not found' });
        res.json({ message: 'Course deleted' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router; 