set serveroutput on
create or replace NONEDITIONABLE PROCEDURE DROP_G_ENROLLMENT (    
    l_g_B# in char,
    l_classid in char
) AS
--Objective/usage: to drop the given enrollment if it passes several validations
    l_B#_exists number;
    l_grad number;
    l_class number;
    l_enrolled number;
    l_current number;
    l_not_last number;
	--declare variables for case statements and if statements
BEGIN

---------------- B#
select case
when exists(select * from students where B# = l_g_B#) --checks if B# exists in students table
then 1
else 0
end into l_B#_exists --puts result in variable and then evaluates with if-statement
from dual;
IF (l_B#_exists=0) THEN
    dbms_output.put_line('The B# is invalid.');
    return; --stops procedure execution if student doesnt exist
END IF;

---------------- GRAD
select case
when exists(select * from students where B# = l_g_B# and (st_level='master' or st_level='PhD')) --checks if student with corresponding B# is a grad student
then 1
else 0
end into l_grad --puts result in variable and then evaluates with if-statement
from dual;
 IF (l_grad=0) THEN
     dbms_output.put_line('This is not a graduate student.');
     return; --stops procedure execution if student isnt grad
END IF;

--------------------- class exists
select case
when exists(select * from classes where classid = l_classid) --checks if class with corresponding classid actually exists
then 1
else 0
end into l_class --puts result in variable and then evaluates with if-statement
from dual;
IF (l_class=0) THEN
   dbms_output.put_line('The classid is invalid.');
   return; --stops procedure execution if classid isnt valid
END IF;

------------------------ not enrolled  
select case
when exists(select * from g_enrollments where g_B# = l_g_B# and classid = l_classid) --checks if student with corresponding B# is enrolled in the class with corresponding classid
then 1
else 0
end into l_enrolled --puts result in variable and then evaluates with if-statement
from dual;
IF (l_enrolled=0) THEN
    dbms_output.put_line('The student is not enrolled in the class.');
    return; --stops procedure execution if not enrolled
END IF;

---------------- spring semester
select case
when exists(select * from classes where classid = l_classid and semester = 'Spring' and year = 2021) --checks if enrollment is for current semester by checking classes table
then 1
else 0
end into l_current --puts result in variable and then evaluates with if-statement
from dual;
IF (l_current=0) THEN
    dbms_output.put_line('Only enrollment in the current semester can be dropped.');
    return; --stops procedure execution if enrollment isnt in current semester
END IF;

------------------------ last class in spring NG
select case
when exists(
select s.B#, count(g.classid)
from students s, g_enrollments g, classes c
where s.B#=g.G_B# and g.classid=c.classid and g.G_B#=l_g_B# and c.year=2021 and c.semester='Spring'
group by s.B#, 2
having count(g.classid)>=2
) --checks if enrollment is not the only enrollment for the current semester by checking and counting these valid enrollments; if the number is > 1, then it is okay to drop one
then 1
else 0
end into l_not_last --puts result in variable and then evaluates with if-statement
from dual;
if (l_not_last=0) THEN
    dbms_output.put_line('This is the only class for this student in Spring 2021 and cannot be dropped.');
    return; --stops procedure execution if this is the only one
END IF;

----- if you got here its okay to delete...
DELETE FROM g_enrollments where classid=l_classid and g_B#=l_g_B#;
dbms_output.put_line('Success.');
 
END DROP_G_ENROLLMENT;
/
