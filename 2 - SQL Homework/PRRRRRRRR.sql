-- Soal 1
-- SELECT BillingCity, count(1) 'Jumlah per BillingCity'
-- FROM invoices
-- GROUP BY 1
-- ORDER BY 2 DESC;

-- Soal 2
SELECT COUNT(DISTINCT nama) 'Jumlah Customer Penipu'
FROM rakamin_customer
WHERE penipu = 1;

-- Soal 3
SELECT kota, count(1) 'Jumlah Customer'
FROM rakamin_customer_address
GROUP BY 1; 

-- Soal 4
SELECT id_pelanggan, nama, email, telepon
FROM rakamin_customer
WHERE 
	umur > 22 AND
	penipu = 0 AND
	konfirmasi_telepon = 1;
	
-- Soal 5
SELECT *
FROM rakamin_order
ORDER BY tanggal_pembelian DESC
LIMIT 5;

-- Soal 6
SELECT bulan_lahir, count(1) 'Jumlah Customer'
FROM rakamin_customer
GROUP BY 1
ORDER BY 2 DESC;

-- Soal 7
SELECT rca.kota, rca.alamat, SUM(ro.kuantitas) 'jumlah produk terjual', SUM(ro.harga) 'Total Revenue'
FROM rakamin_customer_address rca
LEFT JOIN
	rakamin_order ro
	ON rca.id_pelanggan = ro.id_pelanggan
LEFT JOIN
	rakamin_merchant rm
	ON ro.id_merchant = rm.id_merchant
WHERE rca.kota IS NOT 'Depok' AND rm.nama_merchant = 'KFC'
GROUP BY 1,2
ORDER BY 3 DESC;

-- Soal 8
SELECT
	rc.id_pelanggan,
	rc.nama,
	rc.telepon,
	rc.email,
	IFNULL(SUM(ro.harga),0) jumlah_pengeluaran
FROM 
	rakamin_customer rc
LEFT JOIN
	rakamin_order ro
	ON rc.id_pelanggan = ro.id_pelanggan
WHERE rc.email LIKE '%@roketmail.com' AND rc.penipu = 0
GROUP BY 1;

-- Soal 9
SELECT
	CASE WHEN metode_bayar = 'cash' then 'cash'
	ELSE 'cashless'
	END as tipe_pembayaran,
	sum(harga) as Volume_harga,
	sum(kuantitas) as Volume_kuantitas,
	count(1) AS jumlah_transaksi
FROM
	rakamin_order ro
LEFT JOIN
	rakamin_customer rc
	on ro.id_pelanggan = rc.id_pelanggan
WHERE
	rc.penipu IS NOT 1 AND
	rc.pengguna_aktif = 1
GROUP BY 1
-- dengan melihat perbandinga  volume harga dengan volume kuantitas bisa diliat kalau kuantitas pembelian pada cashless sudah melebihi pembayaran cash
-- namun jumlah transaksinya masih lebih banyak pembayaran cash, melihat vloume harga yang masih bisa ditingkatkan bisa memberi insight
-- dalam hal ini volume harga bisa ditingkatkan melalui pemberian promo pembayaran cashless
-- volume yang dihitung adalah volume pengguna yang aktif dan bukan penipu

--tabel 2
WITH t as(
	SELECT 
		rca.kota,
		SUM(CASE WHEN ro.metode_bayar NOT LIKE 'cash' THEN 1 ELSE 0 END) total_pelanggan_cashlesss,
		SUM(CASE WHEN ro.metode_bayar = 'cash' THEN 1 ELSE 0 END) total_pelanggan_cash,
		COUNT(ro.metode_bayar) total_pelanggan
	FROM
		rakamin_customer_address rca
	LEFT JOIN
		rakamin_order ro
		ON ro.id_pelanggan = rca.id_pelanggan
	LEFT JOIN 
		rakamin_customer rc
		on ro.id_pelanggan = rc.id_pelanggan
	WHERE 
		rc.penipu IS NOT 1 AND
		rc.pengguna_aktif = 1
	GROUP BY 1
	
)

SELECT *, (t.total_pelanggan_cashlesss*100.0/t.total_pelanggan) cashless_percentage 
FROM t
ORDER BY cashless_percentage;

-- dengan melihat persentase transaksi cashless terkecil berasal dari kota mana, campaign atau promo berikutnya bisa dieksekusi dengan mempertimbangkan perbandingan jumlah pelanggan cash dan cashless

-- Soal 10
WITH t as(
	SELECT 
		rca.kota,
		SUM(CASE WHEN ro.metode_bayar = 'cash' THEN 1 ELSE 0 END) cash,
		SUM(CASE WHEN ro.metode_bayar = 'ovo' THEN 1 ELSE 0 END) ovo,
		SUM(CASE WHEN ro.metode_bayar = 'gopay' THEN 1 ELSE 0 END) gopay,
		SUM(CASE WHEN ro.metode_bayar = 'shopeepay' THEN 1 ELSE 0 END) shopeepay,
		SUM(CASE WHEN ro.metode_bayar = 'link aja' THEN 1 ELSE 0 END) linkaja,
		SUM(CASE WHEN ro.metode_bayar = 'dana' THEN 1 ELSE 0 END) dana,
		SUM(CASE WHEN ro.metode_bayar NOT LIKE 'cash' THEN 1 ELSE 0 END) total_pelanggan_cashlesss,
		COUNT(ro.metode_bayar) total_pelanggan
	FROM
		rakamin_customer_address rca
	LEFT JOIN
		rakamin_order ro
		ON ro.id_pelanggan = rca.id_pelanggan
	GROUP BY 1
)

SELECT *, (t.total_pelanggan_cashlesss*100.0/t.total_pelanggan) cashless_percentage 
FROM t
ORDER BY cashless_percentage DESC;

