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

with mid_stage as ( --iv.     Средний стаж
	select departmentid,sum((date_part('year', current_date)- date_part('year',firstday)))/count(departmentid) as middle_stage 
		from employees 
		group by departmentid 
		order by departmentid),
mid_salary as ( --v.     Средний уровень зарплаты
	select departmentid, sum(salary)/count(departmentid) as mid_salary
		from employees
		group by departmentid
		order by departmentid),
junior_count_table as (--vi.     Количество сотрудников уровня junior
	select  departmentid , titlelevel as grade, count(titlelevel) as junior_count
		from employees where titlelevel='junior'
		group  by departmentid, titlelevel 
		order by departmentid, titlelevel),
middle_count_table as (--vii.     Количество сотрудников уровня middle
	select  departmentid , titlelevel as grade, count(titlelevel) as middle_count
		from employees where titlelevel='middle'
		group  by departmentid, titlelevel 
		order by departmentid, titlelevel),
senior_count_table as (--viii.     Количество сотрудников уровня senior	
	select  departmentid , titlelevel as grade, count(titlelevel) as senior_count
		from employees where titlelevel='senior'
		group  by departmentid, titlelevel 
		order by departmentid, titlelevel),
lead_count_table as (--ix.     Количество сотрудников уровня lead
	select  departmentid , titlelevel as grade, count(titlelevel) as lead_count
		from employees where titlelevel='lead'
		group  by departmentid, titlelevel 
		order by departmentid, titlelevel),
sum_salary_table as (--x.     Общий размер оплаты труда всех сотрудников до индексации
	select departmentid, sum(salary) as sum_salary
		from employees
		group by departmentid  
		order by departmentid),
sum_salary_indexed_table as (--xi.     Общий размер оплаты труда всех сотрудников после индексации
	with salary_indexed as (
		select departmentid, 
			case when ratio > 1.2 then 1.2
				when (ratio >= 1) and (ratio <= 1.2) then 1.1
				else 1 end as salary_indexed				
			from employees)
	select si.departmentid, sum(si.salary_indexed) as sum_salary_indexed
		from salary_indexed si 
		group by si.departmentid
		order by si.departmentid),
count_grade_a_table as (--xii.     Общее количество оценок A
	with grade_a as (
		select b.employeesid, b.value, count(b.value) as grade_a_count
			from bonuses b where value ='A'
			group by  b.employeesid, b.value)
	select e.departmentid, sum(gb.grade_a_count) as grade_a_count  from employees e 
		right join grade_a gb 
		on gb.employeesid = e.id
		group by e.departmentid),
count_grade_b_table as (--xiii.     Общее количество оценок B
	with grade_b as (
		select b.employeesid, b.value, count(b.value) as grade_b_count
			from bonuses b where value ='B'
			group by  b.employeesid, b.value)
	select e.departmentid, sum(gb.grade_b_count) as grade_b_count  from employees e 
		right join grade_b gb 
		on gb.employeesid = e.id
		group by e.departmentid),
count_grade_c_table as (--xiv.     Общее количество оценок C
	with grade_c as (
		select b.employeesid, b.value, count(b.value) as grade_c_count
			from bonuses b where value ='C'
			group by  b.employeesid, b.value)
	select e.departmentid, sum(gb.grade_c_count) as grade_c_count  from employees e 
		right join grade_c gb 
		on gb.employeesid = e.id
		group by e.departmentid),
count_grade_d_table as (--xv.     Общее количество оценок D
	with grade_d as (
		select b.employeesid, b.value, count(b.value) as grade_d_count
			from bonuses b where value ='D'
			group by  b.employeesid, b.value)
	select e.departmentid, sum(gb.grade_d_count) as grade_d_count  from employees e 
		right join grade_d gb 
		on gb.employeesid = e.id
		group by e.departmentid),
count_grade_e_table as (--xvi.     Общее количество оценок E
	with grade_e as (
		select b.employeesid, b.value, count(b.value) as grade_e_count
			from bonuses b where value ='E'
			group by  b.employeesid, b.value)
	select e.departmentid, sum(gb.grade_e_count) as grade_e_count  from employees e 
		right join grade_e gb 
		on gb.employeesid = e.id
		group by e.departmentid),
middle_ratio_table as (--xvii.     Средний показатель коэффициента премии
	select em.departmentid, sum(em.ratio)/count(departmentid) as middle_ratio
		from employees em 
		group by departmentid
		order by departmentid),
sum_bonus_table as (--xviii.     Общий размер премии.
	select e.departmentid, sum(salary*(e.ratio-1)) as sum_bonus 
		from employees e 
		group by e.departmentid
		order by e.departmentid),
sum_total_table as (--xix.     Общую сумму зарплат(+ премии) до индексации
	select e.departmentid, sum(salary*e.ratio) as sum_total
		from employees e 
		group by e.departmentid
		order by e.departmentid),
sum_total_indexed_table as (--xx.     Общую сумму зарплат(+ премии) после индексации(премии не индексируются)
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
delta_salary as (--xxi.     Разницу в % между предыдущими двумя суммами(первая/вторая)
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
		where stit.departmentid=stt.departmentid)
select d.title, d.fiochief, d.employeescount,  ms.middle_stage,
	jct.junior_count, mct.middle_count, sct.senior_count, lct.lead_count,
	sum_salary, ssit.sum_salary_indexed,
	cgat.grade_a_count, cgbt.grade_b_count, cgct.grade_c_count, cgdt.grade_d_count, cget.grade_e_count,
	mrt.middle_ratio, sbt.sum_bonus, stt.sum_total, stit.sum_total_indexed, ds.delta_percent
	from departments d 
	left join mid_stage ms on d.id = ms.departmentid
	left join mid_salary mst on d.id = mst.departmentid 
	left join junior_count_table jct on d.id = jct.departmentid
	left join middle_count_table mct on d.id = mct.departmentid
	left join senior_count_table sct on d.id = sct.departmentid
	left join lead_count_table lct on d.id = lct.departmentid
	left join sum_salary_table sst on d.id = sst.departmentid
	left join sum_salary_indexed_table ssit on d.id = ssit.departmentid
	left join count_grade_a_table cgat on d.id = cgat.departmentid
	left join count_grade_b_table cgbt on d.id = cgbt.departmentid
	left join count_grade_c_table cgct on d.id = cgct.departmentid
	left join count_grade_d_table cgdt on d.id = cgdt.departmentid
	left join count_grade_e_table cget on d.id = cget.departmentid
	left join middle_ratio_table mrt on d.id = mrt.departmentid
	left join sum_bonus_table sbt on d.id = sbt.departmentid
	left join sum_total_table stt on d.id = stt.departmentid
	left join sum_total_indexed_table stit on d.id = stit.departmentid
	left join delta_salary ds on d.id = ds.departmentid
order by d.id;
