--all code here has been commented in the other sql files, this is just all the code in package form

create sequence log#_gen
increment by 1
start with 1000
nomaxvalue
order;

set serveroutput on
create or replace NONEDITIONABLE TRIGGER ADD_ENROLLMENT_TRIGGER
BEFORE insert ON G_ENROLLMENTS
FOR EACH ROW
WHEN (OLD.g_B# is null)
declare log_no number;
userno varchar(10);
BEGIN
log_no := log#_gen.nextval;
select USER into userno from dual;

  insert into LOGS (LOG#, USER_NAME, OP_TIME, TABLE_NAME, OPERATION, TUPLE_KEYVALUE)
  values (log_no+1, userno, sysdate, 'g_enrollments', 'insert', :NEW.g_B# || ', ' || :NEW.classid);

  update classes set class_size = ((select class_size from classes c2 where c2.classid=:NEW.classid) +1) where classid=:NEW.classid;

END;
/



create or replace NONEDITIONABLE TRIGGER "REMOVE_ENROLLEMENT_TRIGGER"
before delete on g_enrollments
FOR EACH ROW
WHEN(NEW.g_B# is null)
declare log_no number;
userno varchar(10);
begin
log_no := log#_gen.nextval;
select USER into userno from dual;

  insert into LOGS (LOG#, USER_NAME, OP_TIME, TABLE_NAME, OPERATION, TUPLE_KEYVALUE)
  values (log_no+1, userno, sysdate, 'g_enrollments', 'delete', :OLD.G_B# || ', ' || :OLD.classid);

  update classes set class_size = ((select class_size from classes c2 where c2.classid=:OLD.classid) -1) where classid=:OLD.classid;
end;
/


create or replace NONEDITIONABLE TRIGGER "REMOVE_STUDENT_TRIGGER"
before delete on students
FOR EACH ROW
WHEN(NEW.B# is null)
declare log_no number;
userno varchar(10);
begin
log_no := log#_gen.nextval;
select USER into userno from dual;

  insert into LOGS (LOG#, USER_NAME, OP_TIME, TABLE_NAME, OPERATION, TUPLE_KEYVALUE)
  values (log_no+1, userno, sysdate, 'students', 'delete', :OLD.B#);

delete from G_ENROLLMENTS where g_b# = :OLD.B#;
end;
/

create or replace package proj2 as
  procedure show_students;
  procedure show_logs;
  procedure show_g_enrollments;
  procedure show_courses;
  procedure show_prerequisites;
  procedure show_course_credit;
  procedure show_classes;
  procedure show_score_grade;
  procedure show_class_students(class_id char);
  procedure pre_reqs2(i_dept varchar2, i_course# number);
  procedure enroll_grad(class_id char, b_# char);
  procedure DROP_G_ENROLLMENT(l_g_B# char, l_classid char);
  procedure del_stud(b_# char);

END proj2;
/

set serveroutput on
create or replace package body proj2 as

    procedure show_students
    is
    CURSOR c_students IS
    SELECT  *  FROM students
    ORDER BY B# DESC;
     -- record
     r_student c_students%ROWTYPE;

    begin
    dbms_output.put_line(
      'B#      FIRST_NAME      LAST_NAME      ST_LEVEL   GPA   EMAIL BDATE' );

      OPEN c_students;

      LOOP
        FETCH  c_students  INTO r_student;
        EXIT WHEN c_students%NOTFOUND;

    dbms_output.put_line(
      r_student.B# || ' ' ||  r_student.FIRST_NAME || ' ' || r_student.LAST_NAME  || ' ' ||  r_student.ST_LEVEL  || ' (' || r_student.GPA || ') ' || r_student.EMAIL || ' ' || r_student.BDATE );

        END LOOP;

      CLOSE c_students;
    end;



  procedure show_logs is

    CURSOR c_logs IS
    SELECT  *  FROM logs
    ORDER BY log# DESC;
     -- record
     r_log c_logs%ROWTYPE;

  begin
  dbms_output.put_line(
    'LOG#   USER    TIME     TABLE    OPERATION     VALUE' );

    OPEN c_logs;

    LOOP
      FETCH  c_logs  INTO r_log;
      EXIT WHEN c_logs%NOTFOUND;

  dbms_output.put_line(
    r_log.log# || ' ' ||  r_log.user_name || ' ' || r_log.op_time  || ' ' ||  r_log.table_name  || ' ' || r_log.operation || ' ' || r_log.tuple_keyvalue );

      END LOOP;

    CLOSE c_logs;
  end;

  procedure show_g_enrollments is

    CURSOR c_g_enrollments IS
    SELECT  *  FROM g_enrollments
    ORDER BY g_B# DESC;
     -- record
     r_g_enrollment c_g_enrollments%ROWTYPE;

  begin
  dbms_output.put_line(
    'G_B#     CLASSID      SCORE' );


    OPEN c_g_enrollments;

    LOOP
      FETCH  c_g_enrollments  INTO r_g_enrollment;
      EXIT WHEN c_g_enrollments%NOTFOUND;

  dbms_output.put_line(
    r_g_enrollment.g_B# || ' ' ||  r_g_enrollment.classid || ' ' || r_g_enrollment.score );

      END LOOP;

    CLOSE c_g_enrollments;
  end;


  procedure show_courses is

    CURSOR c_courses IS
    SELECT  *  FROM courses
    ORDER BY course# DESC;
     -- record
     r_course c_courses%ROWTYPE;

  begin
  dbms_output.put_line(
    'DEPT_CODE   COURSE#     TITLE' );

    OPEN c_courses;

    LOOP
      FETCH  c_courses  INTO r_course;
      EXIT WHEN c_courses%NOTFOUND;

  dbms_output.put_line(
    r_course.dept_code || ' ' ||  r_course.course# || ' ' || r_course.title);

      END LOOP;

    CLOSE c_courses;
  end;


  procedure show_prerequisites is

    CURSOR c_prerequisites IS
    SELECT  *  FROM prerequisites
    ORDER BY course# DESC;
     -- record
     r_prerequisite c_prerequisites%ROWTYPE;

  begin
  dbms_output.put_line(
    'DEPT_CODE     COURSE#     PRE_DEPT_CODE     PRE_COURSE#' );


    OPEN c_prerequisites;

    LOOP
      FETCH  c_prerequisites  INTO r_prerequisite;
      EXIT WHEN c_prerequisites%NOTFOUND;

  dbms_output.put_line(
    r_prerequisite.dept_code || ' ' ||  r_prerequisite.course# || ' ' || r_prerequisite.pre_dept_code || ' ' || r_prerequisite.pre_course#);

      END LOOP;

    CLOSE c_prerequisites;
  end;


  procedure show_course_credit is

    CURSOR c_course_credit IS
    SELECT  *  FROM course_credit
    ORDER BY course# DESC;
     -- record
     r_course_credit c_course_credit%ROWTYPE;

  begin
  dbms_output.put_line(
    'COURSE#      CREDITS' );

    OPEN c_course_credit;

    LOOP
      FETCH  c_course_credit  INTO r_course_credit;
      EXIT WHEN c_course_credit%NOTFOUND;

  dbms_output.put_line(
    r_course_credit.course# || ' ' ||  r_course_credit.credits);

      END LOOP;

    CLOSE c_course_credit;
  end;


  procedure show_classes is

    CURSOR c_classes IS
    SELECT  *  FROM classes
    ORDER BY classid DESC;
     -- record
     r_class c_classes%ROWTYPE;

  begin
  dbms_output.put_line(
    'CLASSID   DEPT_CODE    COURSE#    SECT#    YEAR   SEMESTER   LIMIT   CLASS_SIZE     ROOM' );
    OPEN c_classes;

    LOOP
      FETCH  c_classes INTO r_class;
      EXIT WHEN c_classes%NOTFOUND;

  dbms_output.put_line(
    r_class.classid || ' ' ||  r_class.dept_code || ' ' ||  r_class.course# || ' ' ||  r_class.sect# || ' ' ||  r_class.year || ' ' ||  r_class.semester || ' ' ||  r_class.limit
    || ' ' ||  r_class.class_size || ' ' ||  r_class.room);

      END LOOP;

    CLOSE c_classes;
  end;


  procedure show_score_grade is

    CURSOR c_score_grade IS
    SELECT  *  FROM score_grade
    ORDER BY score DESC;
     -- record
     r_score_grade c_score_grade%ROWTYPE;

  begin
  dbms_output.put_line(
    'SCORE    LGRADE' );

    OPEN c_score_grade;

    LOOP
      FETCH  c_score_grade INTO r_score_grade;
      EXIT WHEN c_score_grade%NOTFOUND;

  dbms_output.put_line(
    r_score_grade.score || ' ' ||  r_score_grade.lgrade);

      END LOOP;

    CLOSE c_score_grade;
  end;


  procedure show_class_students(class_id char) as

    c_exists number;

    CURSOR cl_students IS
    SELECT  *  FROM students s, g_enrollments g
    WHERE s.b# = g.g_b# and g.classid = class_id
    ORDER BY B# ASC;
     -- record
     r_student cl_students%ROWTYPE;

  begin

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

  dbms_output.put_line('B#            FIRST_NAME            LAST_NAME');

    OPEN cl_students;

    LOOP
      FETCH  cl_students  INTO r_student;
      EXIT WHEN cl_students%NOTFOUND;

  dbms_output.put_line(r_student.B# || '     ' ||  r_student.FIRST_NAME || '                  ' || r_student.LAST_NAME);

      END LOOP;

    CLOSE cl_students;
  end;

  procedure pre_reqs2(i_dept varchar2 , i_course# number) as

  l_exists number;

  CURSOR c_prereqs IS
  select p.PRE_DEPT_CODE,p.PRE_COURSE# from courses c, prerequisites p where c.dept_code=p.dept_code and c.course#=p.course# and c.course#=i_course# and c.dept_code=i_dept;
   -- record
   r_prereqs c_prereqs%ROWTYPE;

  begin

  select case
  when exists(select * from courses where dept_code = i_dept and course# = i_course#)
  then 1
  else 0
  end into l_exists
  from dual;

  IF (l_exists=0) THEN
    dbms_output.put_line( i_dept ||i_course# ||' does not exist');
    return;
  END IF;

  OPEN c_prereqs;

  LOOP
  FETCH  c_prereqs  INTO r_prereqs;
  EXIT WHEN c_prereqs%NOTFOUND;

  dbms_output.put_line( r_prereqs.PRE_DEPT_CODE || r_prereqs.PRE_COURSE#);
  pre_reqs2(r_prereqs.PRE_DEPT_CODE,r_prereqs.PRE_COURSE#);

  END LOOP;

  CLOSE c_prereqs;
  end;


  procedure enroll_grad(class_id char, b_# char) as

    b#_exists number;
    gb#_exists number;
    c_exists number;
    curr_sem number;
    c_full number;
    enrolled number;
    c_max number;
    preqs_met number;
    prqs_count number;

  begin

  select count(*) into prqs_count from prerequisites p where
      p.dept_code in (select c.dept_code from classes c where c.classid = class_id) AND p.course# in (select c.course# from classes c where c.classid = class_id);

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

  insert into g_enrollments values (b_#, class_id, null);
  dbms_output.put_line('You have successfully enrolled.');

  end;


  PROCEDURE DROP_G_ENROLLMENT (l_g_B# char, l_classid char) as
      l_B#_exists number;
      l_grad number;
      l_class number;
      l_enrolled number;
      l_current number;
      l_not_last number;
  BEGIN

  ---------------- B#
  select case
  when exists(select * from students where B# = l_g_B#)
  then 1
  else 0
  end into l_B#_exists
  from dual;
  IF (l_B#_exists=0) THEN
      dbms_output.put_line('The B# is invalid.');
      return;
  END IF;

  ---------------- GRAD
  select case
  when exists(select * from students where B# = l_g_B# and (st_level='master' or st_level='PhD'))
  then 1
  else 0
  end into l_grad
  from dual;
   IF (l_grad=0) THEN
       dbms_output.put_line('This is not a graduate student.');
       return;
  END IF;

  --------------------- class exists
  select case
  when exists(select * from classes where classid = l_classid)
  then 1
  else 0
  end into l_class
  from dual;
  IF (l_class=0) THEN
     dbms_output.put_line('The classid is invalid.');
     return;
  END IF;

  ------------------------ not enrolled
  select case
  when exists(select * from g_enrollments where g_B# = l_g_B# and classid = l_classid)
  then 1
  else 0
  end into l_enrolled
  from dual;
  IF (l_enrolled=0) THEN
      dbms_output.put_line('The student is not enrolled in the class.');
      return;
  END IF;

  ---------------- spring semester
  select case
  when exists(select * from classes where classid = l_classid and semester = 'Spring' and year = 2021)
  then 1
  else 0
  end into l_current
  from dual;
  IF (l_current=0) THEN
      dbms_output.put_line('Only enrollment in the current semester can be dropped.');
      return;
  END IF;

  ------------------------ last class in spring NG
  select case
  when exists(
  select s.B#, count(g.classid)
  from students s, g_enrollments g, classes c
  where s.B#=g.G_B# and g.classid=c.classid and g.G_B#=l_g_B# and c.year=2021 and c.semester='Spring'
  group by s.B#, 2
  having count(g.classid)>=2
  )
  then 1
  else 0
  end into l_not_last
  from dual;
  if (l_not_last=0) THEN
      dbms_output.put_line('This is the only class for this student in Spring 2021 and cannot be dropped.');
      return;
  END IF;

  ----- if you got here its okay to delete...
  DELETE FROM g_enrollments where classid=l_classid and g_B#=l_g_B#;
  dbms_output.put_line('Success.');

  END DROP_G_ENROLLMENT;


  procedure del_stud(b_# char) as

    b#_exists number;


  begin

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

  delete from students where b# = b_#;
  dbms_output.put_line('You have successfully deleted the student.');

  end;


end proj2;
/
