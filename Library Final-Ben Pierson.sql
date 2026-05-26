-- =============================================
-- Library Database Creation Script
-- =============================================

CREATE DATABASE IF NOT EXISTS Personal_Library;
USE Personal_Library;

-- ==================== TABLE CREATION ====================

CREATE TABLE Genre (
    GenreID     INT AUTO_INCREMENT PRIMARY KEY,
    GenreName   VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Reading_Status (
    StatusID    INT AUTO_INCREMENT PRIMARY KEY,
    StatusName  VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE Author (
    AuthorID    INT AUTO_INCREMENT PRIMARY KEY,
    FirstName   VARCHAR(50) NOT NULL,
    LastName    VARCHAR(50) NOT NULL
);

CREATE TABLE Book (
    BookID       INT AUTO_INCREMENT PRIMARY KEY,
    Title        VARCHAR(255) NOT NULL,
    ISBN         VARCHAR(13) UNIQUE,
    PublishDate  DATE,
    Publisher    VARCHAR(100),
    Pages        INT,
    Description  TEXT,
    GenreID      INT NOT NULL,
    StatusID     INT NOT NULL,
    
    FOREIGN KEY (GenreID)  REFERENCES Genre(GenreID),
    FOREIGN KEY (StatusID) REFERENCES Reading_Status(StatusID)
);

CREATE TABLE Book_Author (
    BookAuthorID INT AUTO_INCREMENT PRIMARY KEY,
    BookID       INT NOT NULL,
    AuthorID     INT NOT NULL,
    
    FOREIGN KEY (BookID)   REFERENCES Book(BookID) ON DELETE CASCADE,
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID) ON DELETE CASCADE,
    UNIQUE KEY (BookID, AuthorID)
);

CREATE TABLE Review (
    ReviewID    INT AUTO_INCREMENT PRIMARY KEY,
    BookID      INT NOT NULL,
    Rating      INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment     TEXT,
    ReviewDate  DATE NOT NULL,
    
    FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE
);

-- =============================================
-- 5. INSERT SAMPLE DATA
-- =============================================

-- Genres
INSERT INTO Genre (GenreID, GenreName) VALUES
(1, 'Fantasy'), (2, 'Science Fiction'), (3, 'Religious'),
(4, 'Biography'), (5, 'Classic Literature'), (6, 'Fiction'),
(7, 'Non-Fiction'), (8, 'Historical'), (9, 'Poetry');

-- Reading Statuses
INSERT INTO Reading_Status (StatusName) VALUES
('Unread'), ('In Progress'), ('Finished');

-- Authors
INSERT INTO Author (FirstName, LastName) VALUES
('Loren', 'Cunningham'),
('Barry', 'Strauss'),
('Travis', 'Baldree'),
('Emily', 'Wilson'),
('Billy', 'Collins'),
('J.R.R.', 'Tolkien'),
('George', 'Orwell'),
('Stephen', 'King');

-- Books
INSERT INTO Book (Title, ISBN, PublishDate, Publisher, Pages, GenreID, StatusID, Description) VALUES
('The Book That Transforms Nations', '9781576583814', '2007-08-06', 'YWAM Publishing', 256, 3, 3, 'A powerful book about how the Bible can transform entire nations and cultures.'),
('The Spartacus War', '9781416532064', '2009-03-17', 'Simon & Schuster', 264, 8, 3, 'A gripping historical account of Spartacus and the Third Servile War.'),
('Bookshops & Bonedust', '9781250886101', '2023-11-07', 'Tor Books', 336, 1, 2, 'A cozy fantasy novella about a retired mercenary finding new purpose in a bookshop.'),
('The Iliad', '9781324076148', '2023-09-26', 'W W Norton & Company', 761, 5, 1, 'Emily Wilson\'s fresh and highly readable translation of Homer\'s epic.'),
('Aimless Love', '9780812982671', '2013-10-22', 'Random House', 261, 9, 3, 'A delightful collection of poetry by former U.S. Poet Laureate Billy Collins.'),
('The Hobbit', '9780547928227', '1937-09-21', 'Allen & Unwin', 310, 1, 3, 'The classic tale of Bilbo Baggins and his journey to reclaim the Lonely Mountain.'),
('1984', '9780451524935', '1949-06-08', 'Secker & Warburg', 328, 2, 3, 'A dystopian masterpiece exploring surveillance, truth, and authoritarianism.'),
('The Shining', '9780307743657', '1977-01-28', 'Doubleday', 447, 6, 1, 'A terrifying story of isolation and supernatural horror at the Overlook Hotel.');

-- Book-Author Relationships
INSERT INTO Book_Author (BookID, AuthorID) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8);

-- Reviews
INSERT INTO Review (BookID, Rating, Comment, ReviewDate) VALUES
(1, 5, 'Life-changing book. Highly recommend!', '2026-05-10'),
(2, 4, 'Excellent historical research.', '2026-04-02'),
(3, 5, 'Cozy and heartwarming fantasy.', '2026-02-16'),
(4, 4, 'Beautiful translation, very readable.', '2026-05-05'),
(5, 5, 'Perfect poetry for everyday life.', '2026-03-25'),
(6, 5, 'A timeless adventure!', '2026-01-15'),
(7, 5, 'Chilling and brilliant.', '2026-05-01'),
(8, 4, 'Terrifying and masterfully written.', '2026-04-20');

-- =============================================
-- 6. COMMON QUERIES & VIEWS
-- =============================================

-- View: Complete Book Details
CREATE OR REPLACE VIEW vw_BookDetails AS
SELECT 
    b.BookID,
    b.Title,
    b.ISBN,
    b.PublishDate,
    b.Pages,
    b.Description,
    g.GenreName,
    s.StatusName,
    GROUP_CONCAT(CONCAT(a.FirstName, ' ', a.LastName) SEPARATOR ', ') AS Authors,
    AVG(r.Rating) AS AverageRating,
    COUNT(r.ReviewID) AS ReviewCount
FROM Book b
JOIN Genre g ON b.GenreID = g.GenreID
JOIN Reading_Status s ON b.StatusID = s.StatusID
LEFT JOIN Book_Author ba ON b.BookID = ba.BookID
LEFT JOIN Author a ON ba.AuthorID = a.AuthorID
LEFT JOIN Review r ON b.BookID = r.BookID
GROUP BY b.BookID;

-- View: Books by Status
CREATE OR REPLACE VIEW vw_BooksByStatus AS
SELECT s.StatusName, COUNT(*) AS BookCount
FROM Book b
JOIN Reading_Status s ON b.StatusID = s.StatusID
GROUP BY s.StatusName;

-- Example Queries:

-- 1. All books with full details
SELECT * FROM vw_BookDetails ORDER BY Title;

-- 2. Currently reading
SELECT Title, Authors, GenreName 
FROM vw_BookDetails 
WHERE StatusName = 'In Progress';

-- 3. Highly rated books
SELECT Title, Authors, AverageRating, GenreName
FROM vw_BookDetails 
WHERE AverageRating >= 4 
ORDER BY AverageRating DESC;

-- 4. Books by specific author
SELECT b.Title, g.GenreName, s.StatusName
FROM Book b
JOIN Book_Author ba ON b.BookID = ba.BookID
JOIN Author a ON ba.AuthorID = a.AuthorID
JOIN Genre g ON b.GenreID = g.GenreID
JOIN Reading_Status s ON b.StatusID = s.StatusID
WHERE a.LastName = 'Tolkien';