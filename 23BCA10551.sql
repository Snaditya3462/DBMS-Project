-- Create Database & Schema
CREATE DATABASE Freelancer;
USE Freelancer;

CREATE SCHEMA IF NOT EXISTS freelancer_mgmt;
USE freelancer_mgmt;

-- TABLE CREATION

CREATE TABLE Freelancer (
    freelancer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    skills TEXT,
    hourly_rate DECIMAL(10, 2),
    portfolio_link VARCHAR(255),
    availability VARCHAR(50),
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255)
);

CREATE TABLE Client (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    company_name VARCHAR(100),
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255)
);

CREATE TABLE Project (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) UNIQUE,
    description TEXT,
    start_date DATE,
    due_date DATE,
    budget DECIMAL(10, 2),
    payment_terms VARCHAR(50),
    client_id INT,
    freelancer_id INT,
    FOREIGN KEY (client_id) REFERENCES Client(client_id),
    FOREIGN KEY (freelancer_id) REFERENCES Freelancer(freelancer_id)
);

CREATE TABLE Task (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    description TEXT,
    due_date DATE,
    status VARCHAR(50),
    project_id INT,
    freelancer_id INT,
    FOREIGN KEY (project_id) REFERENCES Project(project_id),
    FOREIGN KEY (freelancer_id) REFERENCES Freelancer(freelancer_id)
);

CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT,
    amount DECIMAL(10, 2),
    payment_date DATE,
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),
    status VARCHAR(50),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

CREATE TABLE Invoice (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT UNIQUE,
    amount_due DECIMAL(10, 2),
    invoice_date DATE,
    due_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

CREATE TABLE Feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT,
    user_type ENUM('Freelancer', 'Client'),
    user_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

-- DATA INSERTION

INSERT INTO Freelancer (full_name, email, phone_number, skills, hourly_rate, portfolio_link, availability, username, password)
VALUES 
('Aditya Yadav', 'aditya@gmail.com', '9876543210', 'Web Design', 30.00, 'http://adityaportfolio.com', 'Full-time', 'aditya', 'hashed_pw_aditya'),
('Ravi Sharma', 'ravi@gmail.com', '9123456780', 'Graphic Design', 40.00, 'http://ravisharma.com', 'Part-time', 'ravi', 'hashed_pw_ravi');

INSERT INTO Client (name, email, phone_number, company_name, username, password)
VALUES
('Acme Corp', 'acme@gmail.com', '1122334455', 'Acme', 'acmeuser', 'hashed_pw_acme'),
('Tech Solutions', 'tech@gmail.com', '9988776655', 'Tech Solutions', 'techuser', 'hashed_pw_tech');

INSERT INTO Project (title, description, start_date, due_date, budget, payment_terms, client_id, freelancer_id)
VALUES
('Website Redesign', 'Redesign homepage and layout', '2025-05-01', '2025-06-01', 5000.00, 'Fixed Price', 1, 1),
('Mobile App Design', 'Design and develop a mobile app', '2025-06-01', '2025-08-01', 8000.00, 'Milestone Based', 2, 2);

INSERT INTO Task (title, description, due_date, status, project_id, freelancer_id)
VALUES
('Homepage Layout', 'Create the homepage layout', '2025-05-10', 'In Progress', 1, 1),
('Mobile Interface', 'Design the mobile app interface', '2025-06-15', 'To-do', 2, 2);

INSERT INTO Payment (project_id, amount, payment_date, payment_method, payment_reference, status)
VALUES
(1, 2500.00, '2025-05-10', 'PayPal', 'REF12345', 'Paid'),
(2, 4000.00, '2025-06-15', 'Bank Transfer', 'REF67890', 'Pending');

INSERT INTO Invoice (project_id, amount_due, invoice_date, due_date, status)
VALUES
(1, 5000.00, '2025-05-15', '2025-05-30', 'Paid'),
(2, 8000.00, '2025-06-20', '2025-07-01', 'Pending');

INSERT INTO Feedback (project_id, user_type, user_id, rating, comments)
VALUES
(1, 'Client', 1, 5, 'Great work Aditya! Timely and clean design.'),
(2, 'Freelancer', 2, 4, 'Client was cooperative and paid on time.');

-- SQL QUERIES

-- 1. List all freelancers and their hourly rate
SELECT full_name, hourly_rate FROM Freelancer;

-- 2. Show all projects along with their client names
SELECT p.title, c.name AS client_name
FROM Project p
JOIN Client c ON p.client_id = c.client_id;

-- 3. Find all tasks assigned to a particular freelancer
SELECT t.title, t.status
FROM Task t
JOIN Freelancer f ON t.freelancer_id = f.freelancer_id
WHERE f.full_name = 'Aditya Yadav';

-- 4. Count how many projects each freelancer is handling
SELECT f.full_name, COUNT(p.project_id) AS project_count
FROM Freelancer f
LEFT JOIN Project p ON f.freelancer_id = p.freelancer_id
GROUP BY f.full_name;

-- 5. Show pending payments
SELECT * FROM Payment WHERE status = 'Pending';

-- 6. Retrieve all invoices with due dates within this week
SELECT * FROM Invoice
WHERE due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY);

-- 7. Fetch all tasks under a project titled "Mobile App Design"
SELECT t.title, t.status
FROM Task t
JOIN Project p ON t.project_id = p.project_id
WHERE p.title = 'Mobile App Design';

-- 8. Display total payment received per project
SELECT p.title, SUM(pay.amount) AS total_received
FROM Project p
JOIN Payment pay ON p.project_id = pay.project_id
WHERE pay.status = 'Paid'
GROUP BY p.title;

-- 9. List freelancers who are not assigned to any project
SELECT f.full_name
FROM Freelancer f
LEFT JOIN Project p ON f.freelancer_id = p.freelancer_id
WHERE p.project_id IS NULL;

-- 10. Get the top-rated freelancers (average rating)
SELECT f.full_name, AVG(fe.rating) AS avg_rating
FROM Freelancer f
JOIN Feedback fe ON f.freelancer_id = fe.user_id AND fe.user_type = 'Freelancer'
GROUP BY f.full_name
ORDER BY avg_rating DESC;

-- 11. Count number of tasks by status for a specific project
SELECT t.status, COUNT(*) AS total_tasks
FROM Task t
JOIN Project p ON t.project_id = p.project_id
WHERE p.title = 'Website Redesign'
GROUP BY t.status;

-- 12. Find overdue tasks (due date < today and not completed)
SELECT title, due_date
FROM Task
WHERE due_date < CURDATE() AND status != 'Completed';