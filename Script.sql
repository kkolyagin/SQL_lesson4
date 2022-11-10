--a.   Попробуйте вывести не просто самую высокую зарплату во всей команде, а вывести именно фамилию сотрудника с самой высокой зарплатой.
select fio from employees c where salary in (select max(salary) from employees);

--b.     Попробуйте вывести фамилии сотрудников в алфавитном порядке
select fio from employees order by fio;

--c.     Рассчитайте средний стаж для каждого уровня сотрудников
select  titlelevel, sum((date_part('year', current_date)- date_part('year',firstday)))/count(titlelevel) as middle_stage from employees group by titlelevel;
  
--d.     Выведите фамилию сотрудника и название отдела, в котором он работает
select c.fio, d.title as department from employees c left join departments d on c.departmentid = d.id order by d.id;

--e.     Выведите название отдела и фамилию сотрудника с самой высокой зарплатой в данном отделе и саму зарплату также.
--select  c.departmentid, max(c.salary)  from employees c group by c.departmentid

select y.department, c1.fio, c1.salary as maxsalary from employees c1 
right join 
(select d.title as department, x.maxsalary from departments d 
right join (select  c.departmentid, max(c.salary) as maxsalary  from employees c group by c.departmentid) x
on d.id = x.departmentid) y
on c1.salary = y.maxsalary; 

--f.      *Выведите название отдела, сотрудники которого получат наибольшую премию по итогам года. Как рассчитать премию можно узнать в последнем задании предыдущей домашней работы

select y.title as department from (select d.title, sum(c.ratio) as rbonus from customers c 
left join departments d on c.departmentid=d.id 
group by d.id order by rbonus desc fetch first 1 rows only) y

--g.    *Проиндексируйте зарплаты сотрудников с учетом коэффициента премии. Для сотрудников с коэффициентом премии больше 1.2 – размер индексации составит 20%, для сотрудников с коэффициентом премии от 1 до 1.2 размер индексации составит 10%. Для всех остальных сотрудников индексация не предусмотрена.
