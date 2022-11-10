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

select y.title as department from (select d.title, sum(c.ratio) as rbonus from employees c 
left join departments d on c.departmentid=d.id 
group by d.id order by rbonus desc fetch first 1 rows only) y;

--g.    *Проиндексируйте зарплаты сотрудников с учетом коэффициента премии. Для сотрудников с коэффициентом премии больше 1.2 – размер индексации составит 20%, для сотрудников с коэффициентом премии от 1 до 1.2 размер индексации составит 10%. Для всех остальных сотрудников индексация не предусмотрена.
select *, 
	case when ratio > 1.2 then 1.2
		when (ratio >= 1) and (ratio <= 1.2) then 1.1
		else 1 end as salary_indexed				
from employees;

--**По итогам индексации отдел финансов хочет получить следующий отчет: вам необходимо на уровень каждого отдела вывести следующую информацию:
--i.     Название отдела
--ii.     Фамилию руководителя
--iii.     Количество сотрудников
select d.id as departmentid, d.title, d.fiochief, d.employeescount  
	from departments d order by d.id;

--iv.     Средний стаж
select e.departmentid,sum((date_part('year', current_date)- date_part('year',firstday)))/count(departmentid) as middle_stage 
	from employees e 
	group by e.departmentid order by e.departmentid;

--v.     Средний уровень зарплаты
select em.departmentid, sum(em.salary)/count(departmentid) 
	from employees em 
	group by departmentid
	order by departmentid;

--vi.     Количество сотрудников уровня junior
select  departmentid , titlelevel as grade, count(titlelevel) 
	from employees e where e.titlelevel='junior'
	group  by departmentid, titlelevel 
	order by departmentid, titlelevel;
	
--vii.     Количество сотрудников уровня middle
select  departmentid , titlelevel as grade, count(titlelevel) 
	from employees e where e.titlelevel='middle'
	group  by departmentid, titlelevel 
	order by departmentid, titlelevel;
	
--viii.     Количество сотрудников уровня senior	
select  departmentid , titlelevel as grade, count(titlelevel) 
	from employees e where e.titlelevel='senior'
	group  by departmentid, titlelevel 
	order by departmentid, titlelevel;

--ix.     Количество сотрудников уровня lead
select  departmentid , titlelevel as grade, count(titlelevel) 
	from employees e where e.titlelevel='lead'
	group  by departmentid, titlelevel 
	order by departmentid, titlelevel;

--x.     Общий размер оплаты труда всех сотрудников до индексации
select e.departmentid, sum(e.salary) as sum_salary
	from employees e 
	group by e.departmentid  
	order by e.departmentid;
	
--xi.     Общий размер оплаты труда всех сотрудников после индексации
with salary_indexed as (
	select departmentid, 
		case when ratio > 1.2 then 1.2
			when (ratio >= 1) and (ratio <= 1.2) then 1.1
			else 1 end as salary_indexed				
		from employees)	
select si.departmentid, sum(si.salary_indexed) as sum_salary_indexed
	from salary_indexed si 
	group by si.departmentid
	order by si.departmentid;

--xii.     Общее количество оценок А
with grade_A as (
	select b.employeesid, b.value, count(b.value) as grade_a_count
		from bonuses b where value ='A'
		group by  b.employeesid, b.value)
select e.departmentid, sum(ga.grade_a_count) as grade_a_count  from employees e 
	right join grade_A ga 
	on ga.employeesid = e.id
	group by e.departmentid;

--xiii.     Общее количество оценок B
with grade_B as (
	select b.employeesid, b.value, count(b.value) as grade_b_count
		from bonuses b where value ='B'
		group by  b.employeesid, b.value)
select e.departmentid, sum(gb.grade_b_count) as grade_b_count  from employees e 
	right join grade_B gb 
	on gb.employeesid = e.id
	group by e.departmentid;
	
--xiv.     Общее количество оценок C
with grade_c as (
	select b.employeesid, b.value, count(b.value) as grade_c_count
		from bonuses b where value ='C'
		group by  b.employeesid, b.value)
select e.departmentid, sum(gc.grade_c_count) as grade_c_count  from employees e 
	right join grade_c gc 
	on gc.employeesid = e.id
	group by e.departmentid;

--xv.     Общее количество оценок D
with grade_d as (
	select b.employeesid, b.value, count(b.value) as grade_d_count
		from bonuses b where value ='D'
		group by  b.employeesid, b.value)
select e.departmentid, sum(gd.grade_d_count) as grade_d_count  from employees e 
	right join grade_d gd 
	on gd.employeesid = e.id
	group by e.departmentid;

--xvi.     Общее количество оценок Е
with grade_e as (
	select b.employeesid, b.value, count(b.value) as grade_e_count
		from bonuses b where value ='E'
		group by  b.employeesid, b.value)
select e.departmentid, sum(ge.grade_e_count) as grade_e_count  from employees e 
	right join grade_e ge
	on ge.employeesid = e.id
	group by e.departmentid;


--xvii.     Средний показатель коэффициента премии
select em.departmentid, sum(em.ratio)/count(departmentid) as middle_ratio
	from employees em 
	group by departmentid
	order by departmentid;

--xviii.     Общий размер премии.
select e.departmentid, sum(salary*(e.ratio-1)) as sum_bonus 
	from employees e 
	group by e.departmentid
	order by e.departmentid;

--xix.     Общую сумму зарплат(+ премии) до индексации
select e.departmentid, sum(salary*e.ratio) as sum_total
	from employees e 
	group by e.departmentid
	order by e.departmentid;

--xx.     Общую сумму зарплат(+ премии) после индексации(премии не индексируются)
with salary_indexed_table as (
	select id, 
		case when ratio > 1.2 then salary * 1.2
			when (ratio >= 1) and (ratio <= 1.2) then salary * 1.1
			else salary end as salary_indexed
	from employees)
select e.departmentid, sum(salary*(e.ratio-1)+sit.salary_indexed) as sum_total_indexed from employees e 
	left join salary_indexed_table sit on e.id=sit.id
	group by e.departmentid
	order by e.departmentid;

--xxi.     Разницу в % между предыдущими двумя суммами(первая/вторая)
with sum_total_indexed_table as (
	with salary_indexed_table as (
		select id, 
			case when ratio > 1.2 then salary * 1.2
				when (ratio >= 1) and (ratio <= 1.2) then salary * 1.1
				else salary end as salary_indexed
		from employees)
	select e.departmentid, sum(salary*(e.ratio-1)+sit.salary_indexed) as sum_total_indexed from employees e 
		left join salary_indexed_table sit on e.id=sit.id
		group by e.departmentid
		order by e.departmentid),		
	sum_total_table as (
		select e.departmentid, sum(salary*e.ratio) as sum_total
			from employees e 
			group by e.departmentid
			order by e.departmentid)
select stit.departmentid, (stt.sum_total/stit.sum_total_indexed)*100 as delta_percent from sum_total_indexed_table stit, sum_total_table stt
	where stit.departmentid=stt.departmentid

---осталось все это слепить в один запрос


