
DROP TABLE IF EXISTS StudentEnrollments;

CREATE TABLE StudentEnrollments (
    enrollment_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    enrollment_date DATE NOT NULL,
    CONSTRAINT unique_student_course UNIQUE (student_name, course_id)
);

INSERT INTO StudentEnrollments (enrollment_id, student_name, course_id, enrollment_date) VALUES
(1, 'Ashish', 'CSE101', '2024-07-01'),
(2, 'Smaran', 'CSE102', '2024-07-01'),
(3, 'Vaibhav', 'CSE101', '2024-07-01');

-- Part A: Attempt duplicate enrollment for Ashish in CSE101 (should fail)
START TRANSACTION;
INSERT INTO StudentEnrollments (enrollment_id, student_name, course_id, enrollment_date)
VALUES (4, 'Ashish', 'CSE101', '2024-07-02');
ROLLBACK;

-- Output for Part A
SELECT 'Part A: If two users try to enroll ''Ashish'' in ''CSE101'', only the first will succeed; the second will get a constraint violation.' AS info;
SELECT * FROM StudentEnrollments ORDER BY enrollment_id;


-- Part B: Demonstrate SELECT FOR UPDATE locking

-- User A locks Ashish's enrollment row
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_name = 'Ashish' AND course_id = 'CSE101'
FOR UPDATE;

-- (In real concurrency, User B trying to update this row would be blocked here)

-- User A commits, releasing the lock
COMMIT;

-- Output for Part B
SELECT 'Part B: The selected row will be locked until the transaction is committed or rolled back. Other users trying to access that row will be blocked.' AS info;
SELECT * FROM StudentEnrollments ORDER BY enrollment_id;


-- Part C: Prepare data for Part C (only Ashish's enrollment)
DELETE FROM StudentEnrollments;
INSERT INTO StudentEnrollments (enrollment_id, student_name, course_id, enrollment_date)
VALUES (1, 'Ashish', 'CSE101', '2024-07-01');

-- User 1 starts transaction and locks the row
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE enrollment_id = 1 FOR UPDATE;

-- User 1 updates enrollment_date
UPDATE StudentEnrollments SET enrollment_date = '2024-07-10' WHERE enrollment_id = 1;

-- User 1 commits, releasing lock
COMMIT;

-- User 2 starts transaction and locks the same row (would block until User 1 commits)
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE enrollment_id = 1 FOR UPDATE;

-- User 2 updates enrollment_date
UPDATE StudentEnrollments SET enrollment_date = '2024-07-15' WHERE enrollment_id = 1;

COMMIT;

-- Output for Part C
SELECT 'Part C: After both users run their updates one after the other, only the last committed update is reflected — no race condition or inconsistent data.' AS info;
SELECT * FROM StudentEnrollments ORDER BY enrollment_id;
