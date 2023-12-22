TOPIC - Music Store Data


-- Who is the senior most employee based on job title?

SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Which countries have the most Invoices?

SELECT billing_country, count(invoice_id) as no_of_invoice
FROM invoice
GROUP BY billing_country
ORDER BY no_of_invoice DESC;

-- What are top 3 values of total invoices?
 
SELECT *
FROM invoice
ORDER BY total DESC
LIMIT 3;
 
-- Which cities has the best customers? We would like to throw a promotional music festival in 
    the city we made the most money.Write a query that returns one city that has the highest sum
	of invoices total.Return both the city name and sum of all invoices totals?

SELECT billing_city,sum(total) as invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC;

-- Who is the best customer? The customer who has spent the most money will be declared the best
   customer.Write the query that returns the person who has spent the most money?

SELECT c.customer_id,c.first_name,c.last_name,sum(i.total) as total_sum
FROM customer as c
JOIN invoice as i on c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_sum DESC
LIMIT 1;

--Write a query to return the email,first name,last name & Genre af all Rock Music listeners.Return
  your list ordered alphabetically by email starting with A?

SELECT DISTINCT email,first_name,last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (SELECT track_id FROM track
				  JOIN genre ON track.genre_id = genre.genre_id
				  WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--Let's invite the artists who have written the most rock music in our dataset.Write a query that
   returns the artist name and total track count of the top 10 rock band?
   
SELECT artist.artist_id,artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album on track.album_id = album.album_id
JOIN artist on album.artist_id = artist.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

--Return all the track names that have a song length longer than the average song length. Return the
  average song length.Return the Name and Milliseconds for each track.Order by the song length with the 
  longest songs listed first ?

SELECT name,Milliseconds
FROM track
where Milliseconds >  (SELECT avg(Milliseconds) as avg_track_songs FROM track)
ORDER BY Milliseconds DESC;

-- Find how much amount spent by each customer on artists? Write a query to return customer name,artist
   name and total spent?
   
WITH best_selling_artist AS (
	SELECT artist.artist_id as artist_id,artist.name as artist_name,SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY 1
    ORDER BY 3 DESC
    LIMIT 1
)
SELECT c.customer_id,c.first_name,c.last_name,bsa.artist_name,SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--Want to find out the most popular music Genre for each country.We determine the most popular genre as the
  genre with the highest amount of purchases. Write a query that returns each country along with the top Genre.
  For countries where the maximum number of purchases is shared return all Genre?
  
WITH popular_genre AS ( 
	SELECT COUNT(invoice_line.quantity) AS purchases,customer.country,genre.name,genre.genre_id,ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC) AS RowNo
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer  ON customer.customer_id = invoice.customer_id
    JOIN track  ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY 2,3,4
    ORDER BY 2 ASC,1 DESC )

SELECT * FROM popular_genre WHERE RowNo <= 1

-- Write a query that detemines the customer that has spent the most on music for each country.Write a query that 
   returns the country along with the top customer and how much they spent. For countries where the top amount spent
   is shared,provide all customers who spent this amount?
   
WITH RECURSIVE 
   customter_with_country AS (
	 SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
	 FROM invoice
	 JOIN customer ON customer.customer_id = invoice.customer_id
	 GROUP BY 1,2,3,4
	 ORDER BY 2,3 DESC),
	 
   country_max_spending AS(
	 SELECT billing_country,MAX(total_spending) AS max_spending
     FROM customter_with_country
     GROUP BY billing_country)

SELECT cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;