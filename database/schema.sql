-- =====================================
-- USERS
-- =====================================

IF OBJECT_ID('users', 'U') IS NULL
BEGIN

CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    phone NVARCHAR(20),
    password_hash NVARCHAR(255) NOT NULL,
    role NVARCHAR(20) DEFAULT 'User'
)

END;


-- =====================================
-- AUDIT LOGS
-- =====================================

IF OBJECT_ID('audit_logs', 'U') IS NULL
BEGIN

CREATE TABLE audit_logs (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NULL,
    action NVARCHAR(100) NOT NULL,
    ip_address NVARCHAR(45),
    timestamp DATETIME DEFAULT GETDATE(),
    status NVARCHAR(50),
    details NVARCHAR(MAX)
)

END;


-- =====================================
-- DESTINATIONS
-- =====================================

IF OBJECT_ID('destinations', 'U') IS NULL
BEGIN

CREATE TABLE destinations (
    destination_id INT IDENTITY(1,1) PRIMARY KEY,
    city_name NVARCHAR(100) UNIQUE NOT NULL,
    country NVARCHAR(100) NOT NULL,
    rating FLOAT DEFAULT 4.0,
    description NVARCHAR(MAX)
)

END;


-- =====================================
-- TOURIST PLACES
-- =====================================

IF OBJECT_ID('tourist_places', 'U') IS NULL
BEGIN

CREATE TABLE tourist_places (
    place_id INT IDENTITY(1,1) PRIMARY KEY,
    destination_id INT NOT NULL,
    place_name NVARCHAR(200) NOT NULL,
    category NVARCHAR(100),
    rating FLOAT DEFAULT 4.0,
    latitude FLOAT,
    longitude FLOAT,
    address NVARCHAR(255),

    CONSTRAINT FK_destination
    FOREIGN KEY(destination_id)
    REFERENCES destinations(destination_id)
    ON DELETE CASCADE
)

END;


-- =====================================
-- FLIGHTS
-- =====================================

IF OBJECT_ID('flights', 'U') IS NULL
BEGIN

CREATE TABLE flights (
    flight_id INT IDENTITY(1,1) PRIMARY KEY,
    airline NVARCHAR(100) NOT NULL,
    source_city NVARCHAR(100) NOT NULL,
    destination_city NVARCHAR(100) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    price DECIMAL(10,2) NOT NULL
)

END;


-- =====================================
-- BOOKINGS
-- =====================================

IF OBJECT_ID('bookings', 'U') IS NULL
BEGIN

CREATE TABLE bookings (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    flight_id INT NOT NULL,
    booking_date DATETIME DEFAULT GETDATE(),
    status NVARCHAR(50) DEFAULT 'Confirmed',

    CONSTRAINT FK_booking_user
    FOREIGN KEY(user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE,

    CONSTRAINT FK_booking_flight
    FOREIGN KEY(flight_id)
    REFERENCES flights(flight_id)
    ON DELETE CASCADE
)

END;