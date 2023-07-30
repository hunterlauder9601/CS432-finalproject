set serveroutput on
--creates procedure to remove student
create or replace NONEDITIONABLE procedure del_stud
(
--declares b# parameter
  b_# in char

) as
--declares bool variable to check if student exists
  b#_exists number;


begin

--checks if student exists
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

--removes student
delete from students where b# = b_#;
dbms_output.put_line('You have successfully deleted the student.');

end;
/
