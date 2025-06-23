const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Course = require('../models/Course');

// Get user's timetable
router.get('/:userId', async (req, res) => {
    try {
        const user = await User.findById(req.params.userId)
            .populate('enrolledCourses');
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.json(user.enrolledCourses);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Add course to user's timetable
router.post('/:userId/courses/:courseId', async (req, res) => {
    try {
        const user = await User.findById(req.params.userId);
        const course = await Course.findById(req.params.courseId);

        if (!user || !course) {
            return res.status(404).json({ message: 'User or course not found' });
        }

        // Check if course is already enrolled
        if (user.enrolledCourses.includes(course._id)) {
            return res.status(400).json({ message: 'Course already enrolled' });
        }

        user.enrolledCourses.push(course._id);
        await user.save();

        res.json({ message: 'Course added to timetable' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Remove course from user's timetable
router.delete('/:userId/courses/:courseId', async (req, res) => {
    try {
        const user = await User.findById(req.params.userId);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        user.enrolledCourses = user.enrolledCourses.filter(
            courseId => courseId.toString() !== req.params.courseId
        );
        
        await user.save();
        res.json({ message: 'Course removed from timetable' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router; 