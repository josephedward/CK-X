const examService = require('../src/services/examService');
const redisClient = require('../src/utils/redisClient');
const jumphostService = require('../src/services/jumphostService');
const MetricService = require('../src/services/metricService');
const fs = require('fs');
const path = require('path');

// Mock dependencies
jest.mock('../src/utils/redisClient');
jest.mock('../src/services/jumphostService');
jest.mock('../src/services/metricService');
jest.mock('fs'); // Mock the fs module for readFileSync

describe('Exam Service', () => {
  beforeEach(() => {
    jest.clearAllMocks(); // Clear all mocks before each test
    // Mock fs.readFileSync for config.json and answers.md
    fs.readFileSync.mockImplementation((filePath, encoding) => {
        if (filePath.includes('config.json')) {
            return JSON.stringify({
                lab: 'ckad-003',
                workerNodes: 1,
                answers: 'answers.md', // Corrected path
                questions: 'assessment.json',
                totalMarks: 100,
                lowScore: 40,
                mediumScore: 60,
                highScore: 90
            });
        }
        if (filePath.includes('answers.md')) {
            return 'Mock answers content';
        }
        return jest.requireActual('fs').readFileSync(filePath, encoding); // Use actual fs for other files
    });
    fs.existsSync.mockReturnValue(true); // Assume files exist by default
  });

  describe('createExam', () => {
    // Test for successful exam creation
    it('should successfully create an exam when no other exam is active', async () => {
      redisClient.getCurrentExamId.mockResolvedValue(null); // No active exam
      redisClient.persistExamInfo.mockResolvedValue(true);
      redisClient.persistExamStatus.mockResolvedValue(true);
      redisClient.setCurrentExamId.mockResolvedValue(true);
      jumphostService.setupExamEnvironment.mockResolvedValue({ success: true });
      MetricService.sendMetrics.mockResolvedValue(true);

      const examData = {
        assetPath: 'assets/exams/ckad/003',
        name: 'CKAD Comprehensive Lab - 3',
        category: 'CKAD',
        userAgent: 'test-agent'
      };

      const result = await examService.createExam(examData);

      expect(result.success).toBe(true);
      expect(result.data).toHaveProperty('id');
      expect(result.data.status).toBe('CREATED');
      expect(redisClient.persistExamInfo).toHaveBeenCalledWith(expect.any(String), expect.objectContaining({ ...examData, createdAt: expect.any(String), config: expect.any(Object) }));
      expect(redisClient.persistExamStatus).toHaveBeenCalledWith(expect.any(String), 'CREATED');
      expect(redisClient.setCurrentExamId).toHaveBeenCalledWith(expect.any(String));
      expect(jumphostService.setupExamEnvironment).toHaveBeenCalledWith(expect.any(String), 1);
      expect(MetricService.sendMetrics).toHaveBeenCalledWith(expect.any(String), expect.objectContaining({ event: { userAgent: 'test-agent' } }));
    });

    // Test for exam already exists
    it('should not create an exam if one is already active', async () => {
      redisClient.getCurrentExamId.mockResolvedValue('existing-exam-id'); // Active exam exists

      const examData = {
        assetPath: 'assets/exams/ckad/003',
        name: 'CKAD Comprehensive Lab - 3',
        category: 'CKAD',
        userAgent: 'test-agent'
      };

      const result = await examService.createExam(examData);

      expect(result.success).toBe(false);
      expect(result.error).toBe('Exam already exists');
      expect(redisClient.persistExamInfo).not.toHaveBeenCalled();
      expect(redisClient.persistExamStatus).not.toHaveBeenCalled();
      expect(redisClient.setCurrentExamId).not.toHaveBeenCalled();
      expect(jumphostService.setupExamEnvironment).not.toHaveBeenCalled();
      expect(MetricService.sendMetrics).not.toHaveBeenCalled();
    });

    // Test for config.json missing
    it('should return error if config.json is not found', async () => {
        fs.readFileSync.mockImplementation((filePath) => {
            if (filePath.includes('config.json')) {
                throw new Error('File not found');
            }
        });
        fs.existsSync.mockReturnValueOnce(false); // Simulate config.json not found

        const examData = {
            assetPath: 'assets/exams/ckad/003',
            name: 'CKAD Comprehensive Lab - 3',
            category: 'CKAD',
            userAgent: 'test-agent'
        };

        const result = await examService.createExam(examData);
        expect(result.success).toBe(false);
        expect(result.error).toContain('Failed to create exam');
        expect(result.message).toContain('File not found');
    });

    // Test for answers.md missing
    it('should return error if answers.md is not found', async () => {
        fs.existsSync.mockImplementation((filePath) => {
            if (filePath.includes('answers.md')) {
                return false; // Simulate answers.md not found
            }
            return true; // Other files exist
        });

        const examData = {
            assetPath: 'assets/exams/ckad/003',
            name: 'CKAD Comprehensive Lab - 3',
            category: 'CKAD',
            userAgent: 'test-agent'
        };

        const result = await examService.createExam(examData);
        expect(result.success).toBe(false);
        expect(result.error).toBe('Configuration Error');
        expect(result.message).toBe('Answers path not defined in exam configuration');
    });
  });

  describe('getCurrentExam', () => {
    // Test for successfully getting current exam
    it('should successfully return the current active exam', async () => {
      redisClient.getCurrentExamId.mockResolvedValue('active-exam-id');
      redisClient.getExamInfo.mockResolvedValue({ id: 'active-exam-id', name: 'Active Exam' });
      redisClient.getExamStatus.mockResolvedValue('READY');

      const result = await examService.getCurrentExam();

      expect(result.success).toBe(true);
      expect(result.data.id).toBe('active-exam-id');
      expect(result.data.status).toBe('READY');
      expect(result.data.info).toEqual({ id: 'active-exam-id', name: 'Active Exam' });
    });

    // Test for no active exam
    it('should return an error if no current exam is active', async () => {
      redisClient.getCurrentExamId.mockResolvedValue(null); // No active exam

      const result = await examService.getCurrentExam();

      expect(result.success).toBe(false);
      expect(result.error).toBe('Not Found');
      expect(result.message).toBe('No current exam is active');
    });
  });
});
