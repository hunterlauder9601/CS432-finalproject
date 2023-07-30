set serveroutput on
create or replace NONEDITIONABLE procedure pre_reqs2
(
  i_dept in varchar2
, i_course# in number

) as
--Objective/usage: to show all direct and indirect prerequisites of the given course
  l_exists number;
  
 -- create cursor pointing to the context area which is the join of courses and prerequisites where the course has matching attritbutes with the parameters passed in
  CURSOR c_prereqs IS
  select p.PRE_DEPT_CODE,p.PRE_COURSE# from courses c, prerequisites p where c.dept_code=p.dept_code and c.course#=p.course# and c.course#=i_course# and c.dept_code=i_dept;  
   -- create record with same type as the cursor using %ROWTYPE
   r_prereqs c_prereqs%ROWTYPE;
   
begin
--check if the course passed in through the parameter actually exists or not
select case
when exists(select * from courses where dept_code = i_dept and course# = i_course#)
then 1
else 0
end into l_exists --store result of the case statement in l_exists; if it exists, store 1; if not, store 0
from dual;
--simple if-then statement for if the course doesnt exists
IF (l_exists=0) THEN
    dbms_output.put_line( i_dept ||i_course# ||'_does_not_exist');
    return; -- execution stops if course doesnt exist
END IF;

OPEN c_prereqs;
-- open cursor and put a row into the record
LOOP
FETCH  c_prereqs  INTO r_prereqs;
EXIT WHEN c_prereqs%NOTFOUND;
--output prereq course attributes
dbms_output.put_line( r_prereqs.PRE_DEPT_CODE || r_prereqs.PRE_COURSE#);
pre_reqs2(r_prereqs.PRE_DEPT_CODE,r_prereqs.PRE_COURSE#);
 --recursively calls procedure on new prereq course in order to get indirect prereqs
END LOOP;
--stop loop when no prereqs are left and close cursor
CLOSE c_prereqs;
end;
/
