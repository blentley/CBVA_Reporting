
-- create schema bank;
-- 
-- DROP TABLE IF EXISTS bank.tran;
-- CREATE TABLE bank.tran 
-- (
-- tran_date date
-- , descr varchar(255)
-- , dr numeric(12,4)
-- , cr numeric(12,4)
-- , bal numeric(12,4)
-- , tran_id integer
-- , map_cat varchar(50)
-- , CONSTRAINT tran_id PRIMARY KEY (tran_id)
-- ); 

-- DROP TABLE IF EXISTS bank.map_admin;
-- CREATE TABLE bank.map_admin (
-- tran_id integer
-- , map_lbl varchar(150)
-- , PRIMARY KEY (tran_id)
-- , FOREIGN KEY (tran_id) REFERENCES bank.tran (tran_id) 
--);

-- DROP TABLE IF EXISTS bank.save;
-- CREATE TABLE bank.save 
-- (
-- save_date date
-- , descr varchar(255)
-- , dr numeric(12,4)
-- , cr numeric(12,4)
-- , bal numeric(12,4)
-- , save_id integer
-- , map_cat varchar(50)
-- , CONSTRAINT save_id PRIMARY KEY (save_id)
-- ); 

---------------------------------------------------------
------------------
---------------------------------------------------------

-- create schema paypal;
-- 
-- DROP TABLE IF EXISTS paypal.tran;
-- CREATE TABLE paypal.tran
-- (
-- pp_id int
-- , pp_ts timestamp with time zone
-- , name varchar(150)
-- , gross numeric(12,4)
-- , net numeric(12,4)
-- , from_email varchar(150)
-- , bank_ref_id varchar(50)
-- , map_cat varchar(50)
-- , CONSTRAINT paypal_tran PRIMARY KEY (pp_id)
-- );

SELECT *
FROM paypal.tran;

SELECT bank_ref_id
, sum(net) as nt
FROM paypal.tran
WHERE map_cat <> 'PAYPAL'
GROUP BY 1
ORDER BY 1;


---------------------------------------------------------
------------------
---------------------------------------------------------

-- create schema stripe;
-- 
-- DROP TABLE IF EXISTS stripe.tran;
-- CREATE TABLE stripe.tran
-- (
-- st_id int
-- , id varchar(150)
-- , type varchar(25)
-- , amt numeric(12,4)
-- , fee numeric(12,4)
-- , net numeric(12,4)
-- , st_ts timestamp with time zone
-- , available_date date
-- , descr varchar(255)
-- , CONSTRAINT stripe_tran PRIMARY KEY (st_id)
-- );

---------------------------------------------------------
------------------
---------------------------------------------------------

-- create schema acuity;
-- 
-- DROP TABLE IF EXISTS acuity.tran;
-- CREATE TABLE acuity.tran
-- (
-- appt_id varchar(15)
-- , session_start_dt timestamp
-- , session_end_dt timestamp
-- , first_name varchar(150)
-- , last_name varchar(150)
-- , email varchar(150)
-- , level varchar(50)
-- , coach varchar(50)
-- , appt_price numeric(12,4)
-- , paid varchar(10)
-- , cancelled varchar(15)
-- , cbva_id varchar(25)
-- , CONSTRAINT idx_appt_id PRIMARY KEY (appt_id)
-- );

CREATE TABLE acuity.tran_new AS
SELECT *
, row_number() OVER (partition by TRUE) as a_id
FROM acuity.tran;

ALTER TABLE acuity.tran_new ADD CONSTRAINT idx_a_id PRIMARY KEY (a_id);
DROP TABLE acuity.tran;
ALTER TABLE acuity.tran_new RENAME TO tran;

CREATE SCHEMA revsport;

CREATE TABLE revsport.members (

	member_name varchar(150)
	, transfer_ref varchar(50)
	, amt numeric(12,4)
	, transfer_parent_id int
	, member_status varchar(10)
	, member_expiry date
	, CONSTRAINT idx_rev_member_id PRIMARY KEY (member_name, member_expiry) 
);

CREATE TABLE revsport.payments (
	
	transfer_id int
	, transfer_ref varchar(150)
	, transfer_date date
	, amt numeric(12,4)
	, CONSTRAINT idx_rev_transfer PRIMARY KEY (transfer_id)
);

CREATE TABLE revsport.coaching (
	
	member_name varchar(150)
	, transfer_ref varchar(50)
	, info varchar(150)
	, amt numeric(12,4)
	, transfer_parent_id int
	, coach_c varchar(15)
	, CONSTRAINT idx_rev_coaching PRIMARY KEY (member_name, transfer_ref)
);

CREATE TABLE revsport.juniors (
	
	member_name varchar(150)
	, transfer_ref varchar(50)
	, info varchar(150)
	, amt numeric(12,4)
	, transfer_parent_id int
	, coach_c varchar(15)
	, CONSTRAINT idx_rev_coaching PRIMARY KEY (member_name, transfer_ref)
);

CREATE TABLE revsport.refunds (
	
	member_name varchar(150)
	, transfer_ref varchar(50)
	, amt numeric(12,4)
	, transfer_parent_id int
	, CONSTRAINT idx_rev_refunds PRIMARY KEY (member_name, transfer_ref)
);
