CREATE DATABASE BookstoreDB;

\c bookstoredb;

CREATE TABLE IF NOT EXISTS Books (
    BookID BIGSERIAL NOT NULL PRIMARY KEY, 
    Title VARCHAR(50) NOT NULL, 
    Author VARCHAR(50) NOT NULL, 
    Genre VARCHAR(50),
    Price DECIMAL(10, 2) CHECK(Price > 0), 
    QuantityInStock INT CHECK(QuantityInStock >= 0)
);

INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock)
    VALUES ('Mary Poppins', 'P.L. Travers', 'Fantasy', 4.0, 3),
           ('Alanna: The First Adventure', 'Tamora Pierce','Fantasy', 3.0, 5),
           ('Outlander', 'Diana Gabaldon', 'Romance', 3.10, 10),
           ('Violeta', 'Isabel Allende', 'Romance', 3.1, 8),
           ('The Big Sleep', 'Raymond Chandler', 'Detective', 2.0, 11),
           ('Murder on the Orient Express', 'Agatha Christie', 'Crime novel', 4.20, 13),
           ('Cinderella', 'Charles Perrault', 'Fantasy ,Fairy Tales', 5.0, 15),
           ('The Hitchhikers Guide to the Galaxy', 'Douglas Adams', 'Comedy', 3.0, 9),
           ('Cruel Shoes', 'Steve Martin', 'Comedy', 4.75, 8),
           ('Fear and Loathing in Las Vegas', 'Hunter S. Thompson', 'Comedy', 7.0, 4);

CREATE TABLE IF NOT EXISTS Customers (
    CustomerID BIGSERIAL NOT NULL PRIMARY KEY, 
    Name VARCHAR(50) NOT NULL, 
    Email VARCHAR(50) UNIQUE, 
    Phone VARCHAR(50) NOT NULL
);

INSERT INTO Customers(Name, Email, Phone)
    VALUES ('Garnet Locock', 'glocock0@cbslocal.com', '419-385-3973'),
           ('Nissa Dearlove', 'ndearlove1@issuu.com', '263-807-5912'),
           ('Giustina Sturdgess', 'gsturdgess2@apache.org', '330-543-1917'),
           ('Gabbie Splaven', 'gsplaven3@google.pl', '675-297-8855'),
           ('Corinna Beirne', 'cbeirne4@phoca.cz', '567-405-4091');

CREATE TABLE IF NOT EXISTS Sales (
    SaleID BIGSERIAL NOT NULL PRIMARY KEY, 
    BookID INT, 
    CustomerID INT, 
    DateOfSale DATE, 
    QuantitySold INT CHECK(QuantitySold >= 0), 
    TotalPrice DECIMAL(10, 2) CHECK(TotalPrice > 0),
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Sales(BookID, CustomerID, DateOfSale, QuantitySold, TotalPrice)
    VALUES (3, 1, '2024-01-01', 1, 2.0),
           (4, 1, '2024-01-19', 3, 1.99),
           (5, 2, '2023-12-27', 2, 1.99),
           (8, 1, '2023-12-19', 4, 1.99),
           (9, 4, '2023-12-01', 2, 1.99);

SELECT B.Title AS BookTitle, C.Name AS CustomerName, S.DateOfSale
FROM Sales S
JOIN Books B ON S.BookID = B.BookID
JOIN Customers C ON S.CustomerID = C.CustomerID;


SELECT Genre, SUM(TotalPrice) AS TotalRevenue
FROM Books B
JOIN Sales S ON B.BookID = S.BookID
GROUP BY Genre;



CREATE OR REPLACE FUNCTION UpdateQuantityInStock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Books
    SET QuantityInStock = QuantityInStock - NEW.QuantitySold
    WHERE BookID = NEW.BookID;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER update_quantity_trigger
AFTER INSERT ON Sales
FOR EACH ROW
EXECUTE FUNCTION UpdateQuantityInStock();

