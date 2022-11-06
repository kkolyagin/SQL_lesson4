--a.   Попробуйте вывести не просто самую высокую зарплату во всей команде, а вывести именно фамилию сотрудника с самой высокой зарплатой.
select fio from customers c where salary in (select max(salary) from customers);

--b.     Попробуйте вывести фамилии сотрудников в алфавитном порядке
select fio from customers order by fio;

--c.     Рассчитайте средний стаж для каждого уровня сотрудников
select  titlelevel, sum((date_part('year', current_date)- date_part('year',firstday)))/count(titlelevel) as middle_stage from customers group by titlelevel;
  
--d.     Выведите фамилию сотрудника и название отдела, в котором он работает
select c.fio, d.title as department from customers c left join departments d on c.departmentid = d.id order by d.id;

--e.     Выведите название отдела и фамилию сотрудника с самой высокой зарплатой в данном отделе и саму зарплату также.