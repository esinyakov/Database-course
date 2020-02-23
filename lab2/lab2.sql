--1
--��� ���� �� UK �� ������ ������
select distinct e1.City, e1.LastName
  from Employees e1
  join Employees e2 on e1.City = e2.City
 where e1.EmployeeID <> e2.EmployeeID
   and e1.City = 'London'

--2
--��� ���� � ����� �������� ����� 50 � 60
select *
  from Employees e
 where e.BirthDate between '1950-01-01' and '1960-01-01'

--3
--��� ���� � Manager � �������� ���������
select *
  from Employees e
 where e.Title like '%Manager%'

--4
--��� �������� � ���������� Meat/Poultry
select p.ProductID, p.ProductName
  from products p where p.CategoryID
    in (select c.CategoryID from Categories c where c.CategoryName = 'Meat/Poultry')

--5
--�������� ������ ��������� ���������� ������� �� Boston
select p.ProductID,p.ProductName
  from products p
 where exists (select 1 from Suppliers s join Products p
			  		      on s.SupplierID = p.SupplierID
					   where s.City = 'Boston')

--6
--�������� ������ ���������, UnitsInStock ������� ������ UnitsInStock ������ �������� ��������� 2
select p.ProductID, p.ProductName 
  from products p
 where p.UnitsInStock > ALL (select p.UnitsInStock from products p where p.CategoryID = 2)

--7
--������� �� ����� UnitPrice ��������������� �� CategoryID
select avg(totalprice) 'Actual AVG',
	   sum(totalprice) / count(CategoryID) 'Calc AVG'
  from (select p.CategoryID CategoryID, sum(p.UnitPrice) totalprice
		   from Products p	
		  group by p.CategoryID) total
			
--8
--��� ������� productid ������� ������ � CategoryID = 2
select p.ProductID,p.ProductName,
	   (select avg(od.Discount)
	      from [Order Details] od
	     where od.ProductID = p.ProductID) avgdisc
  from Products p
 where p.CategoryID = 2

--9
--����������� ��� ���������� ������ ��� � ��� ���� ��� ���
select case year(e.HireDate)
	     when year(getdate()) then 'This Year'
		 else 'Not This Year'
	   end as 'When'
  from Employees e

--10
--���������� ���� �� ��������� ��� ���� ������
select case 
	     when year(e.BirthDate) < 1955 then 'Too old'
		 else 'Not too old'
	   end as 'Too old for this shit'
  from Employees e

--11
--�������� ��������� ��������� �������
select *
  into #TempTable
  from Products

--12
--�������� ������� � ������ �������
select p.ProductName 'Best discount'
  from Products p
  join (select top 1 od.ProductID, sum(od.Discount) sumdis
	      from [Order Details] od
	     group by od.ProductID
		 order by sumdis desc) t
       on t.ProductID = p.ProductID

--13
--�������� ������� � ������ �������
select p.ProductName 'Best discount'
  from Products p
 where p.ProductID = (select ProductID
    				    from [Order Details] od
	   				   group by od.ProductID
	   				  having sum(od.Discount) = (select max(t.sumdis)
					 							   from (select sum(od.Discount) sumdis
					 									   from [Order Details] od
					 									  group by od.ProductID) t))
		
--14
--��� ������� �������� ����� �������
select sum(od.Quantity),od.ProductID 
  from [Order Details] od
 group by od.ProductID

--15
--��� ������� �������� ����� ������� ��� ������� ������ 10
select sum(od.Quantity),od.ProductID 
  from [Order Details] od
 group by od.ProductID
having sum(od.Quantity)>10

--16
--������� � �������
insert Categories
values ('CategoryMy','lala',null)

--17
--������� � ������� �����������
insert Categories
select 'CategoryMy','lala',null

--18
--������ �������
update Categories 
   set CategoryName = 'CategoryMy2'
 where CategoryName = 'CategoryMy'

--19
--������ ������� � �����������
update Categories 
   set CategoryName = (select 'CategoryMy3')
 where CategoryName = 'CategoryMy2'

--20
--�������� �� �������
delete Categories
 where CategoryName = 'CategoryMy3'

--21
--�������� � �����������
delete Products
 where CategoryID
    in (select c.CategoryID
		  from Categories c
		 where c.CategoryName = 'Cheeses')

--22
--������� ���������� ������� �� ���� ���������
with qp (Quantity,ProductID)
  as (select sum(od.Quantity),od.ProductID 
        from [Order Details] od
       group by od.ProductID)
select avg(Quantity) from qp

--23
--����������� ������
CREATE TABLE dbo.MyTable
(
	id smallint NOT NULL,
	parent smallint  NOT NULL,
	somevalue  nvarchar(40) NOT NULL
) ;

insert MyTable
values(1,-1,'some')

insert MyTable
values(2,1,'some2')

insert MyTable
values(3,2,'some3')

insert MyTable
values(4,2,'some4')

insert MyTable
values(5,3,'some5')

insert MyTable
values(6,4,'some6')

insert MyTable
values(7,3,'some5')

insert MyTable
values(8,3,'some5')

insert MyTable
values(9,8,'some5')

insert MyTable
values(10,8,'some5')

with c (id,parent,somevalue,depth)
  as (select id,
  	         parent,
  	         somevalue,
  	         0 depth
  	    from  MyTable
  	   where id = 3
  	   union all
  	  select T.id,
  	         T.parent,
  	         T.somevalue,
  	         c.depth + 1
  	    from MyTable as T
  	    inner join c 
  	      on T.parent = c.id)
select * from c
  
--24
--pivot
select ShipCity,USA,UK,Canada
  from Orders
 pivot (sum(EmployeeID)
		for ShipCountry
		in([USA],[UK],[Canada]))
    as pivottable

--25
--merge
merge MyTable as target
using (select 11 id,10 parent,'some5' somevalue) source
   on (target.id = source.id)
when matched then update set target.parent = 3
when not matched then insert values(source.id,source.parent,source.somevalue);
