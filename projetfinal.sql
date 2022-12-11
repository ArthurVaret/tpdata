select * from vendor;
select * from productvendor;
select * from purchaseorderheader;
select * from purchaseorderdetail;

--alter table purchaseorderdetail drop constraint pk_purchaseorderdetail;
--alter table productvendor drop constraint pk_productvendor;

alter table purchaseorderdetail add constraint pk_purchaseorderdetail primary key (purchaseorderid, purchaseorderdetailid, productid);
alter table purchaseorderheader add constraint pk_purchaseorderheader primary key (purchaseorderid);
alter table vendor add constraint pk_vendor primary key (businessentityid);
alter table productvendor add constraint pk_productvendor primary key (productid, businessentityid);

--alter table purchaseorderdetail drop constraint fk_purchaseorderdetail;
--alter table purchaseorderdetail drop constraint fk_product;
alter table purchaseorderdetail add constraint fk_purchaseorderdetail foreign key (purchaseorderid) references purchaseorderheader(purchaseorderid);
--alter table purchaseorderdetail add constraint fk_product foreign key (productid) references productvendor(productid);
alter table productvendor add constraint fk_productvendor foreign key (businessentityid) references vendor(businessentityid);
alter table purchaseorderheader add constraint fk_purchaseorderheader foreign key (vendorid) references vendor(businessentityid);

-- Part 2 --
-- Question 1
-- A
select name, productid
from vendor inner join productvendor on vendor.businessentityid=productvendor.businessentityid
where creditrating = 5 and productid > 500;
-- B
select purchaseorderdetail.purchaseorderid, orderdate, purchaseorderdetailid, orderqty, productid
from purchaseorderdetail inner join purchaseorderheader on purchaseorderdetail.purchaseorderid = purchaseorderheader.purchaseorderid
where orderqty > 500;
-- C
select purchaseorderdetail.purchaseorderid, vendorid, purchaseorderdetailid, productid, unitprice
from purchaseorderdetail join purchaseorderheader on purchaseorderdetail.purchaseorderid = purchaseorderheader.purchaseorderid
where purchaseorderdetail.purchaseorderid >= 1440 and purchaseorderdetail.purchaseorderid <= 1600;
-- D
select vendorid, count(purchaseorderid), sum(subtotal)
from purchaseorderheader
group by vendorid
order by sum(subtotal) desc;
-- E
select avg(count(purchaseorderid)), avg(sum(subtotal))
from purchaseorderheader
group by vendorid;
-- F
select vendorid
from purchaseorderdetail join purchaseorderheader on purchaseorderdetail.purchaseorderid = purchaseorderheader.purchaseorderid
group by vendorid
order by avg(rejectedqty) desc
fetch first 10 rows only;
-- G
select vendorid
from purchaseorderdetail join purchaseorderheader on purchaseorderdetail.purchaseorderid = purchaseorderheader.purchaseorderid
group by vendorid
order by sum(orderqty) desc
fetch first 10 rows only;
-- H
select productid
from purchaseorderdetail
group by productid
order by sum(orderqty) desc
fetch first 10 rows only;
-- I

-- Question 2
-- J
create table Transaction_History (purchaseorderid integer, purchaseorderdetailid integer, duedate Date, orderqty number, productid number, unitprice float, receivedqty number, rejectedqty number, modifieddate Date);
alter table Transaction_History add constraint pk_Transaction_History primary key (purchaseorderid, purchaseorderdetailid);

drop trigger After_Update;
create trigger After_Update
after update on purchaseorderdetail
for each row
declare
nouvSubtotal number;
begin
insert into Transaction_History (purchaseorderid, purchaseorderdetailid, duedate, orderqty, productid, unitprice, receivedqty, rejectedqty, modifieddate)
values (:new.purchaseorderid, :new.purchaseorderdetailid, :new.duedate, :new.orderqty, :new.productid, :new.unitprice, :new.receivedqty, :new.rejectedqty, :new.modifieddate);
update purchaseorderdetail set modifieddate = sysdate where purchaseorderdetailid=:new.purchaseorderdetailid;
select sum(orderqty*unitprice) into nouvSubtotal from purchaseorderdetail where purchaseorderid=:new.purchaseorderid group by purchaseorderid;
update purchaseorderheader set subtotal= nouvSubtotal where purchaseorderid=:new.purchaseorderid;
end;

-- K
drop trigger Before_Update;
create trigger Before_Update
before update on purchaseorderheader
for each row
declare
detailSubtotal number;
begin
select sum(orderqty*unitprice) into detailSubtotal from purchaseorderdetail where purchaseorderid=:new.purchaseorderid group by purchaseorderid;
if (detailSubtotal != :new.subtotal) then
    raise_application_error(-20111,'Can''t change the city for this supplier!');
end if;
end;









