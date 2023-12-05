CREATE TABLE IF NOT EXISTS walmart_sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5),
    city VARCHAR(30),
    customer_type VARCHAR(30),
    gender VARCHAR(30),
    product_line VARCHAR(100),
    unit_price DECIMAL,
    quantity INT,
    tax_pct FLOAT,
    total DECIMAL,
    date DATE,
    time TIME,
    payment VARCHAR(15),
    cogs DECIMAL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL,
    rating FLOAT
);
