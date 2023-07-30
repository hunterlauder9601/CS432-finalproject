set serveroutput on
--creates procedure that shows all students in a specified class
create or replace NONEDITIONABLE procedure show_class_students
(
--declares classid parameter
  class_id in char

) as

--declares boolean for checking whether a classid exists
  c_exists number;

--declares cursor for row by row output
  CURSOR cl_students IS
  SELECT  *  FROM students s, g_enrollments g
  WHERE s.b# = g.g_b# and g.classid = class_id
  ORDER BY B# ASC;
   -- record
   r_student cl_students%ROWTYPE;

begin
--checks whether classid exists
select case
when not exists(select * from classes where classid = class_id)
then 0
else 1
end into c_exists
from dual;

IF (c_exists=0) THEN
    dbms_output.put_line('The classid is invalid.');
    return;
END IF;

--outputs students in class
dbms_output.put_line('B#            FIRST_NAME            LAST_NAME');

  OPEN cl_students;

  LOOP
    FETCH  cl_students  INTO r_student;
    EXIT WHEN cl_students%NOTFOUND;

dbms_output.put_line(r_student.B# || '     ' ||  r_student.FIRST_NAME || '                  ' || r_student.LAST_NAME);

    END LOOP;

  CLOSE cl_students;
end;
/
