--a.   Попробуйте вывести не просто самую высокую зарплату во всей команде, а вывести именно фамилию сотрудника с самой высокой зарплатой.
select fio from customers c where salary in (select max(salary) from customers);

--b.     Попробуйте вывести фамилии сотрудников в алфавитном порядке
select fio from customers order by fio;

--c.     Рассчитайте средний стаж для каждого уровня сотрудников
select  titlelevel, sum((date_part('year', current_date)- date_part('year',firstday)))/count(titlelevel) as middle_stage from customers group by titlelevel;
  
--d.     Выведите фамилию сотрудника и название отдела, в котором он работает
select c.fio, d.title as department from customers c left join departments d on c.departmentid = d.id order by d.id;

--e.     Выведите название отдела и фамилию сотрудника с самой высокой зарплатой в данном отделе и саму зарплату также.
--select  c.departmentid, max(c.salary)  from customers c group by c.departmentid

select y.department, c1.fio, c1.salary as maxsalary from customers c1 
right join 
(select d.title as department, x.maxsalary from departments d 
right join (select  c.departmentid, max(c.salary) as maxsalary  from customers c group by c.departmentid) x
on d.id = x.departmentid) y
on c1.salary = y.maxsalary; 
