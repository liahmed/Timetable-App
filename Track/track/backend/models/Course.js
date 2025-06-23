const mongoose = require('mongoose');

const courseSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    code: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },
    credits: {
        type: Number,
        required: true
    },
    instructor: {
        type: String,
        required: true
    },
    degree: {
        type: String,
        required: true,
        enum: ['BCS', 'BAI', 'BSE', 'BCY', 'BFT', 'BSEE', 'BSBA']
    },
    semester: {
        type: String,
        required: true,
        enum: ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8']
    },
    section: {
        type: String,
        required: true,
        enum: ['Section A', 'Section B', 'Section C', 'Section D', 'Section E', 'Section F', 'Section G']
    },
    schedule: [{
        day: {
            type: String,
            enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
            required: true
        },
        startTime: {
            type: String,
            required: true
        },
        endTime: {
            type: String,
            required: true
        },
        room: {
            type: String,
            required: true
        }
    }],
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Course', courseSchema); 