-- Create the database
CREATE DATABASE IF NOT EXISTS db_LibraryManagement;

-- Use the created database
USE db_LibraryManagement;

-- Create the table for publishers
CREATE TABLE IF NOT EXISTS table_publisher (
    PublisherName VARCHAR(50) PRIMARY KEY NOT NULL,
    PublisherAddress VARCHAR(100) NOT NULL,
    PublisherPhone VARCHAR(20) NOT NULL
);

-- Create the table for books
CREATE TABLE IF NOT EXISTS table_book (
    BookID INT PRIMARY KEY AUTO_INCREMENT,
    Book_Title VARCHAR(100) NOT NULL,
    PublisherName VARCHAR(100) NOT NULL,
    FOREIGN KEY (PublisherName) REFERENCES table_publisher(PublisherName)
);

-- Create the table for library branches
CREATE TABLE IF NOT EXISTS table_library_branch (
    BranchID INT PRIMARY KEY AUTO_INCREMENT,
    BranchName VARCHAR(100) NOT NULL,
    BranchAddress VARCHAR(200) NOT NULL
);

-- Create the table for borrowers
CREATE TABLE IF NOT EXISTS table_borrower (
    CardNo INT PRIMARY KEY AUTO_INCREMENT,
    BorrowerName VARCHAR(100) NOT NULL,
    BorrowerAddress VARCHAR(200) NOT NULL,
    BorrowerPhone VARCHAR(50) NOT NULL
);

-- Create the table for book copies
CREATE TABLE IF NOT EXISTS table_book_copies (
    CopiesID INT PRIMARY KEY AUTO_INCREMENT,
    BookID INT NOT NULL,
    BranchID INT NOT NULL,
    NoOfCopies INT NOT NULL,
    FOREIGN KEY (BookID) REFERENCES table_book(BookID),
    FOREIGN KEY (BranchID) REFERENCES table_library_branch(BranchID)
);

-- Create the table for book authors
CREATE TABLE IF NOT EXISTS table_book_authors (
    AuthorID INT PRIMARY KEY AUTO_INCREMENT,
    BookID INT NOT NULL,
    AuthorName VARCHAR(50) NOT NULL,
    FOREIGN KEY (BookID) REFERENCES table_book(BookID)
);

-- Insert data into the table book
INSERT INTO table_book (Book_Title, PublisherName) VALUES
('X-Men: God Loves, Man Kills', 'Marvel Comics'),
('Mike Tyson: Undisputed Truth', 'Random House'),
('V for Vendetta', 'Vertigo Comics'),
('When Breath Becomes Air', 'Random House'),
('The Great Gatsby', 'Scribner');

-- Create the table for book issues
CREATE TABLE IF NOT EXISTS table_book_issue (
    IssueID INT PRIMARY KEY AUTO_INCREMENT,
    Member VARCHAR(20) NOT NULL,
    BookISBN VARCHAR(13) NOT NULL,
    DueDate DATE NOT NULL,
    LastReminded DATE,
    FOREIGN KEY (Member) REFERENCES table_borrower(BorrowerName),
    FOREIGN KEY (BookISBN) REFERENCES table_book(BookID)
);

-- Create the table for librarians
CREATE TABLE IF NOT EXISTS table_librarian (
    LibrarianID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(20) NOT NULL,
    Password CHAR(40) NOT NULL
);

-- Insert data into the table librarian
INSERT INTO table_librarian (Username, Password) VALUES
(1, 'Vani', 'xthds97@3h$yfc*jrk0%dfg');

-- Create the table for members
CREATE TABLE IF NOT EXISTS table_member (
    MemberID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(20) NOT NULL,
    Password CHAR(40) NOT NULL,
    Name VARCHAR(80) NOT NULL,
    Email VARCHAR(80) NOT NULL,
    Balance INT NOT NULL
);

-- Create the table for pending book requests
CREATE TABLE IF NOT EXISTS table_pending_book_requests (
    RequestID INT PRIMARY KEY AUTO_INCREMENT,
    Member VARCHAR(20) NOT NULL,
    BookISBN VARCHAR(13) NOT NULL,
    Time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Member) REFERENCES table_member(Username),
    FOREIGN KEY (BookISBN) REFERENCES table_book(BookID)
);

-- Create the table for pending registrations
CREATE TABLE IF NOT EXISTS table_pending_registrations (
    Username VARCHAR(30) PRIMARY KEY,
    Password CHAR(20) NOT NULL,
    Name VARCHAR(40) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Balance INT,
    Time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Insert data into the table pending registrations
INSERT INTO table_pending_registrations (Username, Password, Name, Email, Balance, Time)
VALUES
('Robin200', '7t6hg$56y^', 'Robin', 'robin@gmail.com', 200, '2021-03-21 08:59:00'),
('Aadhya100', 'Ujgf(76G5$#f@df', 'Aadhya', 'aadhya100@gmail.com', 1500, '2021-03-21 2:14:53');

-- Add primary keys to tables
ALTER TABLE table_book ADD PRIMARY KEY (BookID);
ALTER TABLE table_book_issue ADD PRIMARY KEY (IssueID);
ALTER TABLE table_librarian ADD PRIMARY KEY (LibrarianID), ADD UNIQUE KEY (Username);
ALTER TABLE table_member ADD PRIMARY KEY (MemberID), ADD UNIQUE KEY (Username), ADD UNIQUE KEY (Email);
ALTER TABLE table_pending_book_requests ADD PRIMARY KEY (RequestID);
ALTER TABLE table_pending_registrations ADD UNIQUE KEY (Username);

-- Triggers
DELIMITER $$

CREATE TRIGGER issue_book BEFORE INSERT ON table_book_issue
FOR EACH ROW
BEGIN
    SET NEW.DueDate = DATE_ADD(CURRENT_DATE(), INTERVAL 20 DAY);
    UPDATE table_member SET Balance = Balance - (SELECT price FROM table_book WHERE BookID = NEW.BookISBN) WHERE Username = NEW.Member;
    UPDATE table_book SET Copies = Copies - 1 WHERE BookID = NEW.BookISBN;
    DELETE FROM table_pending_book_requests WHERE Member = NEW.Member AND BookISBN = NEW.BookISBN;
END$$

CREATE TRIGGER return_book BEFORE DELETE ON table_book_issue
FOR EACH ROW
BEGIN
    UPDATE table_member SET Balance = Balance + (SELECT price FROM table_book WHERE BookID = OLD.BookISBN) WHERE Username = OLD.Member;
    UPDATE table_book SET Copies = Copies + 1 WHERE BookID = OLD.BookISBN;
END$$

CREATE TRIGGER add_member AFTER INSERT ON table_member
FOR EACH ROW
BEGIN
    DELETE FROM table_pending_registrations WHERE Username = NEW.Username;
END$$

CREATE TRIGGER remove_member AFTER DELETE ON table_member
FOR EACH ROW
BEGIN
    DELETE FROM table_pending_book_requests WHERE Member = OLD.Username;
END$$

DELIMITER ;
