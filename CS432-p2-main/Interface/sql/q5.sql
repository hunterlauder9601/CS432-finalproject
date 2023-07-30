--creates procedure to enroll a specified grad student into a specified class
set serveroutput on
create or replace NONEDITIONABLE procedure enroll_grad
(
--declares parameters
  class_id in char,
  b_# in char

) as

--declares boolean variables to check for certain requirements before enrolling
  b#_exists number;
  gb#_exists number;
  c_exists number;
  curr_sem number;
  c_full number;
  enrolled number;
  c_max number;
  preqs_met number;
--declares variable to store number of prereqs
  prqs_count number;

begin

--stores number of prereqs in variable
select count(*) into prqs_count from prerequisites p where
    p.dept_code in (select c.dept_code from classes c where c.classid = class_id) AND p.course# in (select c.course# from classes c where c.classid = class_id);

--multiple requirements are checked and if they are not met, the procedure is ended with a report of which requirement was not met
--checks if student is valid
select case
when not exists(select * from students where b# = b_#)
then 0
else 1
end into b#_exists
from dual;
if (b#_exists=0) then
    dbms_output.put_line('The B# is invalid.');
    return;
end if;

--checks if student is a graduate
select case
when not exists(select * from g_enrollments where g_b# = b_#)
then 0
else 1
end into gb#_exists
from dual;
if (gb#_exists=0) then
    dbms_output.put_line('This is not a graduate student.');
    return;
end if;

--checks if class is valid
select case
when not exists(select * from classes where classid = class_id)
then 0
else 1
end into c_exists
from dual;
if (c_exists=0) then
    dbms_output.put_line('The classid is invalid.');
    return;
end if;

--checks if class is in the current semester
select case
when not exists(select * from classes where semester = 'Spring' and year = 2021 and classid = class_id)
then 0
else 1
end into curr_sem
from dual;
if (curr_sem=0) then
    dbms_output.put_line('Cannot enroll into a class from a previous semester.');
    return;
end if;

--checks if class is full
select case
when not exists(select * from classes where classid = class_id AND class_size >= limit)
then 0
else 1
end into c_full
from dual;
if (c_full=1) then
    dbms_output.put_line('The class is already full.');
    return;
end if;

--checks if student already enrolled
select case
when not exists(select * from g_enrollments where g_b# = b_# and classid = class_id)
then 0
else 1
end into enrolled
from dual;
if (enrolled=1) then
    dbms_output.put_line('The student is already in the class.');
    return;
end if;

--checks if students has enrolled in max classes
select case
when not exists(select count(*) from g_enrollments g, classes c where g.g_b# = b_# and g.classid = c.classid and c.semester = 'Spring' and c.year = 2021 having count(*) = 5)
then 0
else 1
end into c_max
from dual;
if (c_max=1) then
    dbms_output.put_line('Students cannot be enrolled in more than five classes in the same semester.');
    return;
end if;

--checks if all prereqs are met
select case
when not exists(select count(g.classid) from g_enrollments g, score_grade s where g.g_b# = b_# and g.score = s.score and s.lgrade <= 'C' and
    g.classid in (select c.classid from classes c, prerequisites p where c.dept_code = p.pre_dept_code and c.course# = pre_course# and (c.semester != 'Spring' or c.year != 2021) and p.dept_code in (select cl.dept_code from classes cl where cl.classid = class_id) and p.course# in (select cl.course# from classes cl where cl.classid = class_id)) having count(g.classid) = prqs_count)
then 0
else 1
end into preqs_met
from dual;
if (preqs_met=0) then
    dbms_output.put_line('Prerequisite not satisfied.');
    return;
end if;

--student is enrolled
insert into g_enrollments values (b_#, class_id, null);
dbms_output.put_line('You have successfully enrolled.');

end;
/
