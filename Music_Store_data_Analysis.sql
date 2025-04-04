/* 1. Who is the senior most employee based on job title */
select title,last_name,first_name from employee order by levels desc limit 1;

/* 2. Which countries have the most Invoices. */
	SELECT billing_country,count(*) as Count FROM invoice group by billing_country order by count desc;

/* 3. What are top 3 values of total invoice. */
	SELECT total FROM invoice order by total desc limit 3;
    
/* 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals. */
	SELECT billing_city,sum(total) as invoice_total FROM invoice group by billing_city order by invoice_total desc limit 1;
    
/* 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money. */
	SELECT c.first_name,c.last_name,i.total FROM customer c join invoice i on c.customer_id=i.customer_id order by i.total desc limit 1;

/* 6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A. */ 
SELECT DISTINCT email,first_name, last_name FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id 
WHERE exists (SELECT track_id FROM track JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock') ORDER BY email;

/* 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands. */
SELECT ar.artist_id, ar.name, COUNT(t.track_id) AS no_of_songs FROM track t
JOIN album al ON al.album_id = t.album_id
JOIN artist ar ON ar.artist_id = al.artist_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock' GROUP BY ar.artist_id, ar.name ORDER BY no_of_songs DESC LIMIT 10;

/* 8. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
	select name,milliseconds from track where milliseconds > (select avg(milliseconds) as avg_track from track) order by milliseconds desc;

/* 9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent. */ 
	SELECT c.customer_id, c.first_name, c.last_name, ar.artist_id, ar.name AS artist_name, SUM(il.unit_price * il.quantity) AS total_spent FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, ar.artist_id, ar.name
ORDER BY total_spent DESC;

/* 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres. */
	WITH popular_genre AS (
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name,genre.genre_id,ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* 11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH RECURSIVE customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending 
FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4 ORDER BY 2,3 DESC),country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;




