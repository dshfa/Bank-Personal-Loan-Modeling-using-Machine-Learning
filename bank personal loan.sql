SELECT * FROM public.bankloan

-- Q1. Berapa total nilai Mortgage (KPR) dan average Income berdasarkan tingkat Education?
-- (Menggunakan: Education, Mortgage, Income)
select education_group, SUM(mortgage) as total_mortgage, round(avg(income), 2) as avg_income
from bankloan
group by education_group
order by education_group;


-- Q2. Nasabah mana saja yang memiliki CCAvg (pengeluaran kartu kredit) di atas rata-rata keseluruhan, 
--     tetapi memiliki nilai Income di bawah rata-rata?
-- (Menggunakan: ID, CCAvg, Income, Subquery)
select id, ccavg, income
from bankloan
where ccavg > (select avg(ccavg) from bankloan)
	and income < (select avg(income) from bankloan)
order by ccavg desc
limit 15;


-- Q3. Tampilkan 5 ZIP Code dengan rata-rata Income nasabah tertinggi!
-- (Menggunakan: ZIP Code, Income, GROUP BY, LIMIT 5)
select zip_code, round(avg(income), 2) as avg_income
from bankloan
group by zip_code
order by avg_income desc
limit 5;


-- Q4. Bandingkan rata-rata pengeluaran kartu kredit (CCAvg) dan rata-rata Income 
--     antara nasabah yang mengambil Personal Loan (1) vs yang tidak (0).
-- (Menggunakan: Personal Loan, CCAvg, Income)
select 
	personal_loan, 
	round(avg(ccavg)::numeric, 2) as avg_ccavg, 
	round(avg(income), 2) as avg_income
from bankloan
group by personal_loan
order by personal_loan;


-- Q5. Apakah nasabah yang memiliki CD Account cenderung memiliki nilai Mortgage (KPR) yang lebih tinggi? 
--     Bandingkan rata-rata dan total Mortgage-nya.
-- (Menggunakan: CD Account, Mortgage)
select cd_account, 
	sum(mortgage) as total_mortgage,
	round(avg(mortgage), 2) as avg_mortgage
from bankloan
group by cd_account
order by cd_account;


-- Q6. Berapa persentase penerimaan Personal Loan untuk setiap tingkat Education (Undergrad, Graduate, Professional)?
-- (Menggunakan: Education, Personal Loan, Persentase)
select education_group,
	count(id) as total_customers,
	sum(personal_loan) as total_loan,
	round((sum(personal_loan) * 100 / count(id)), 2) as acceptance_rate_percentage
from bankloan
group by education_group
order by education_group;

-- Q7. Klasifikasikan nasabah ke dalam segmen pendapatan (Income): 'Low' (< 50), 'Medium' (50-100), 
--     dan 'High' (> 100), lalu hitung jumlah nasabah serta berapa yang mengambil Personal Loan di setiap segmen.
-- (Menggunakan: CASE WHEN pada Income, Personal Loan)
select 
	case
		when income < 50 then 'Low'
		when income between 50 and 100 then 'Medium'
		when income > 100 then 'High'
	end as income_segment,
	count(id) as total_customers,
	sum(personal_loan) as total_personal_loan
from bankloan
group by
	case
		when income < 50 then 'Low'
		when income between 50 and 100 then 'Medium'
		when income > 100 then 'High'
	end
order by total_customers desc;


-- Q8. Tampilkan Top 3 ZIP Code yang memiliki jumlah pemegang Personal Loan terbanyak untuk setiap tingkat Education!
-- (Menggunakan: CTE & Window Function ROW_NUMBER() OVER(PARTITION BY Education ...))
with ranked_zipcode as (
	select
		education_group, zip_code,
		sum(personal_loan) as total_personal_loan,
		row_number() over(
			partition by education_group
			order by sum(personal_loan) desc
		) as rank_number
	from bankloan
	group by education_group, zip_code
)

select education_group, zip_code,
	   total_personal_loan, rank_number
from ranked_zipcode
where rank_number<= 3
order by education_group, rank_number;


-- Q9. Apakah nasabah yang aktif menggunakan Online banking DAN memiliki CreditCard bank cenderung mengambil Personal Loan?
-- (Menggunakan: Online, CreditCard, Personal Loan)
select online, creditcard,
	   count(id) as total_cutomers,
	   sum(personal_loan) as total_loan,
	   round((sum(personal_loan)::numeric * 100.0 / count(id)), 2) as acceptance_rate
from bankloan
group by online, creditcard 
order by acceptance_rate desc;


-- Q10. Kelompokkan nasabah ke dalam Age Group (<30, 30-45, 46-60, >60) dan hitung kontribusi 
--      total Mortgage serta rata-rata CCAvg dari masing-masing kelompok umur tersebut.
-- (Menggunakan: CASE WHEN pada Age, Mortgage, CCAvg)
select
	case
		when age < 30 then '<30'
		when age between 30 and 45 then '30-45'
		when age between 46 and 60 then '46-60'
		when age > 60 then '60'
	end as age_group,
	count(id) as total_customers,
	sum(mortgage) as total_mortgage,
	round(avg(ccavg)::numeric, 2) as avg_ccavg
from bankloan
group by 	
	case
		when age < 30 then '<30'
		when age between 30 and 45 then '30-45'
		when age between 46 and 60 then '46-60'
		when age > 60 then '60'
	end 
order by age_group;