set serveroutput on
create or replace NONEDITIONABLE procedure show_students as
-- Objective/usage: to output all rows within the table students
-- create cursor pointing to the context area which is all students rows
  CURSOR c_students IS 
  SELECT  *  FROM students 
  ORDER BY B# DESC;
   -- create record with same type as the cursor using %ROWTYPE
   r_student c_students%ROWTYPE;

begin
dbms_output.put_line(
  'B#      FIRST_NAME      LAST_NAME      ST_LEVEL   GPA   EMAIL BDATE' );

  OPEN c_students;
-- open cursor and put a row into the record
  LOOP
    FETCH  c_students  INTO r_student;
    EXIT WHEN c_students%NOTFOUND;
--ouput record attributes
dbms_output.put_line(
  r_student.B# || ' ' ||  r_student.FIRST_NAME || ' ' || r_student.LAST_NAME  || ' ' ||  r_student.ST_LEVEL  || ' (' || r_student.GPA || ') ' || r_student.EMAIL || ' ' || r_student.BDATE );
 
    END LOOP;
 --continuously loop this process until there are no more rows left and then close cursor
  CLOSE c_students;
end;
/





set serveroutput on
create or replace NONEDITIONABLE procedure show_logs as
-- Objective/usage: to output all rows within the table logs
-- create cursor pointing to the context area which is all logs rows
  CURSOR c_logs IS
  SELECT  *  FROM logs  
  ORDER BY log# DESC;
   -- create record with same type as the cursor using %ROWTYPE
   r_log c_logs%ROWTYPE;

begin
dbms_output.put_line(
  'LOG#   USER    TIME     TABLE    OPERATION     VALUE' );

  OPEN c_logs;
-- open cursor and put a row into the record
  LOOP
    FETCH  c_logs  INTO r_log;
    EXIT WHEN c_logs%NOTFOUND;

--ouput record attributes
dbms_output.put_line(
  r_log.log# || ' ' ||  r_log.user_name || ' ' || r_log.op_time  || ' ' ||  r_log.table_name  || ' ' || r_log.operation || ' ' || r_log.tuple_keyvalue );
 
    END LOOP;
 --continuously loop this process until there are no more rows left and then close cursor

  CLOSE c_logs;
end;
/




set serveroutput on
create or replace NONEDITIONABLE procedure show_g_enrollments as
-- Objective/usage: to output all rows within the table g_enrollments
-- create cursor pointing to the context area which is all g_enrollments rows
  CURSOR c_g_enrollments IS
  SELECT  *  FROM g_enrollments
  ORDER BY g_B# DESC;
   -- create record with same type as the cursor using %ROWTYPE
   r_g_enrollment c_g_enrollments%ROWTYPE;

begin
dbms_output.put_line(
  'G_B#     CLASSID      SCORE' );


  OPEN c_g_enrollments;
-- open cursor and put a row into the record
  LOOP
    FETCH  c_g_enrollments  INTO r_g_enrollment;
    EXIT WHEN c_g_enrollments%NOTFOUND;
	
--ouput record attributes
dbms_output.put_line(
  r_g_enrollment.g_B# || ' ' ||  r_g_enrollment.classid || ' ' || r_g_enrollment.score );
 
    END LOOP;
 --continuously loop this process until there are no more rows left and then close cursor

  CLOSE c_g_enrollments;
end;
/




set serveroutput on
create or replace NONEDITIONABLE procedure show_courses as
-- Objective/usage: to output all rows within the table courses
-- create cursor pointing to the context area which is all courses rows
  CURSOR c_courses IS
  SELECT  *  FROM courses
  ORDER BY course# DESC;
   -- create record with same type as the cursor using %ROWTYPE
   r_course c_courses%ROWTYPE;

begin
dbms_output.put_line(
  'DEPT_CODE   COURSE#     TITLE' );

  OPEN c_courses;
-- open cursor and put a row into the record
  LOOP
    FETCH  c_courses  INTO r_course;
    EXIT WHEN c_courses%NOTFOUND;

--ouput record attributes
dbms_output.put_line(
  r_course.dept_code || ' ' ||  r_course.course# || ' ' || r_course.title);
 
    END LOOP;
 --continuously loop this process until there are no more rows left and then close cursor

  CLOSE c_courses;
end;
/








set serveroutput on
create or replace NONEDITIONABLE procedure show_prerequisites as
-- Objective/usage: to output all rows within the table prerequisites
-- create cursor pointing to the context area which is all prerequisites rows
  CURSOR c_prerequisites IS
  SELECT  *  FROM prerequisites
  ORDER BY course# DESC;
   -- create record with same type as the cursor using %ROWTYPE
   r_prerequisite c_prerequisites%ROWTYPE;

begin
dbms_output.put_line(
  'DEPT_CODE     COURSE#     PRE_DEPT_CODE     PRE_COURSE#' );


  OPEN c_prerequisites;
-- open cursor and put a row into the record
  LOOP
    FETCH  c_prerequisites  INTO r_prerequisite;
    EXIT WHEN c_prerequisites%NOTFOUND;

--ouput record attributes
dbms_output.put_line(
  r_prerequisite.dept_code || ' ' ||  r_prerequisite.course# || ' ' || r_prerequisite.pre_dept_code || ' ' || r_prerequisite.pre_course#);
 
    END LOOP;
 --continuously loop this process until there are no more rows left and then close cursor

  CLOSE c_prerequisites;
end;
/





set serveroutput on
create or replace NONEDITIONABLE procedure show_course_credit as
-- Objective/usage: to output all rows within the table course_credit
-- create cursor pointing to the context area which is all course_credit rows
  CURSOR c_course_credit IS
  SELECT  *  FROM course_credit
  ORDER BY course# DESC;
   -- create record with same type as the cursor using %ROWTYPE
   r_course_credit c_course_credit%ROWTYPE;

begin
dbms_output.put_line(
  'COURSE#      CREDITS' );

  OPEN c_course_credit;
-- open cursor and put a row into the record
  LOOP
    FETCH  c_course_credit  INTO r_course_credit;
    EXIT WHEN c_course_credit%NOTFOUND;

--ouput record attributes
dbms_output.put_line(
  r_course_credit.course# || ' ' ||  r_course_credit.credits);
 
    END LOOP;
 --continuously loop this process until there are no more rows left and then close cursor

  CLOSE c_course_credit;
end;
/




set serveroutput on
create or replace NONEDITIONABLE procedure show_classes as
-- Objective/usage: to output all rows within the table classes
-- create cursor pointing to the context area which is all classes rows
  CURSOR c_classes IS
  SELECT  *  FROM classes
  ORDER BY classid DESC;
   -- create record with same type as the cursor using %ROWTYPE
   r_class c_classes%ROWTYPE;

begin
dbms_output.put_line(
  'CLASSID   DEPT_CODE    COURSE#    SECT#    YEAR   SEMESTER   LIMIT   CLASS_SIZE     ROOM' );
  OPEN c_classes;
-- open cursor and put a row into the record
  LOOP
    FETCH  c_classes INTO r_class;
    EXIT WHEN c_classes%NOTFOUND;

--ouput record attributes
dbms_output.put_line(
  r_class.classid || ' ' ||  r_class.dept_code || ' ' ||  r_class.course# || ' ' ||  r_class.sect# || ' ' ||  r_class.year || ' ' ||  r_class.semester || ' ' ||  r_class.limit
  || ' ' ||  r_class.class_size || ' ' ||  r_class.room);
 
    END LOOP;
 --continuously loop this process until there are no more rows left and then close cursor

  CLOSE c_classes;
end;
/



set serveroutput on
create or replace NONEDITIONABLE procedure show_score_grade as
-- Objective/usage: to output all rows within the table score_grade
-- create cursor pointing to the context area which is all score_grade rows
  CURSOR c_score_grade IS
  SELECT  *  FROM score_grade
  ORDER BY score DESC;
   -- create record with same type as the cursor using %ROWTYPE
   r_score_grade c_score_grade%ROWTYPE;

begin
dbms_output.put_line(
  'SCORE    LGRADE' );

  OPEN c_score_grade;
-- open cursor and put a row into the record
  LOOP
    FETCH  c_score_grade INTO r_score_grade;
    EXIT WHEN c_score_grade%NOTFOUND;

--ouput record attributes
dbms_output.put_line(
  r_score_grade.score || ' ' ||  r_score_grade.lgrade);
 
    END LOOP;
 --continuously loop this process until there are no more rows left and then close cursor

  CLOSE c_score_grade;
end;
/
