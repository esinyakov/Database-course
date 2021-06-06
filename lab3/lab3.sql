--1a
CREATE FUNCTION dbo.MinNumber (@x int, @y int)
RETURNS int
AS
BEGIN
	declare @minnumber int
    IF @x < @y
        set @minnumber = @x
    ELSE
        set @minnumber = @y
	return @minnumber
    
END

--1b
CREATE FUNCTION dbo.EmployeeLastName (@EmployeeID int)
RETURNS TABLE
AS
    RETURN (select e.LastName 
			  from Employees e
	         where e.EmployeeID = @EmployeeID)
			 

--1c
CREATE FUNCTION dbo.EmployeeLastNameMTF (@EmployeeID int)
RETURNS @Employee TABLE (EmployeeID int,LastName nvarchar(20))
AS
BEGIN
	insert into @Employee select e.EmployeeID, e.LastName from Employees e where e.EmployeeID = @EmployeeID
	RETURN 
END

--1d
CREATE FUNCTION dbo.Factorial (@Number int)
RETURNS int
AS
BEGIN
DECLARE @i  int

    IF @Number <= 1
        SET @i = 1
    ELSE
        SET @i = @Number * dbo.Factorial( @Number - 1 )
RETURN (@i)
END

--2a
create procedure GenerateIdTableAndData
as
	if object_id('dbo.IdTable') is null
		create table dbo.IdTable (id int)

		declare @i int = 1

		while @i <=10
		begin
			insert IdTable(id) select @i
			set @i = @i +1
		end

--2b
CREATE PROCEDURE dbo.PrintNum(@Number int)
AS
BEGIN
	print @Number
	if @Number = 1
		return
	else 
		declare @Tmp int
		set @Tmp = @Number -1
		exec dbo.PrintNum @Tmp
END

--2c
CREATE PROCEDURE dbo.SumString
AS
BEGIN
	DECLARE @LastName varchar(50)
	DECLARE @FirstName varchar(50)

	DECLARE my_cur CURSOR FOR 
     SELECT e.LastName, e.FirstName
     FROM Employees e

	open my_cur
	FETCH NEXT FROM my_cur INTO @LastName, @FirstName

	WHILE @@FETCH_STATUS = 0
    BEGIN
		print 'SUM'+@LastName+@FirstName
        FETCH NEXT FROM my_cur INTO @LastName, @FirstName
    END
	CLOSE my_cur
    DEALLOCATE my_cur
END


--2d
CREATE PROCEDURE dbo.EmployeeMeta
AS
BEGIN
	select object_id FROM sys.objects WHERE name = 'Employees'
END

--3a
CREATE TRIGGER AfterInsert
ON MyTable AFTER INSERT
AS BEGIN
	print'row inserted in my table'
END

--3b
CREATE TRIGGER InsteadOf
ON MyTable
INSTEAD OF DELETE
AS
begin
	print'row is not deleted'
end
