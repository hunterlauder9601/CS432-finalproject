
--Objective/usage: To update class_size and insert log whenever a enrollment is added
create or replace NONEDITIONABLE TRIGGER ADD_ENROLLMENT_TRIGGER
BEFORE insert ON G_ENROLLMENTS --occurs before insert
FOR EACH ROW
WHEN (OLD.g_B# is null) --only runs when there is no old pseudorecord / when a tuple is being inserted
declare log_no number;
userno varchar(10);
BEGIN
log_no := log#_gen.nextval;
--use sequence to get log number 
select USER into userno from dual;
--use special table dual to set user_name to USER

--insert row into logs table, uses appropriate pseudorecords - :NEW._____
  insert into LOGS (LOG#, USER_NAME, OP_TIME, TABLE_NAME, OPERATION, TUPLE_KEYVALUE)
  values (log_no+1, userno, sysdate, 'g_enrollments', 'insert', :NEW.g_B# || ', ' || :NEW.classid);

  update classes set class_size = ((select class_size from classes c2 where c2.classid=:NEW.classid) +1) where classid=:NEW.classid;
--update class_size by adding 1 to the current class_size
END;
/


--Objective/usage: To update class_size and insert log whenever a enrollment is deleted
create or replace NONEDITIONABLE TRIGGER "REMOVE_ENROLLEMENT_TRIGGER"
before delete on g_enrollments --occurs before delete
FOR EACH ROW
WHEN(NEW.g_B# is null) --only runs when there is no new pseudorecord / when a tuple is being deleted
declare log_no number;
userno varchar(10);
begin
log_no := log#_gen.nextval;
--use sequence to get log number 
select USER into userno from dual;
--use special table dual to set user_name to USER

--insert row into logs table, uses appropriate pseudorecords - :OLD._____
  insert into LOGS (LOG#, USER_NAME, OP_TIME, TABLE_NAME, OPERATION, TUPLE_KEYVALUE)
  values (log_no+1, userno, sysdate, 'g_enrollments', 'delete', :OLD.G_B# || ', ' || :OLD.classid);

  update classes set class_size = ((select class_size from classes c2 where c2.classid=:OLD.classid) -1) where classid=:OLD.classid;
  --update class_size by subtracting 1 to the current class_size

end;
/

--Objective/usage: To insert log and remove corresponding student enrollments whenever a student is deleted
create or replace NONEDITIONABLE TRIGGER "REMOVE_STUDENT_TRIGGER"
before delete on students --occurs before delete
FOR EACH ROW
WHEN(NEW.B# is null) --only runs when there is no new pseudorecord / when a tuple is being deleted
declare log_no number;
userno varchar(10);
begin
log_no := log#_gen.nextval;
--use sequence to get log number 
select USER into userno from dual;
--use special table dual to set user_name to USER

--insert row into logs table, uses appropriate pseudorecords - :OLD._____
  insert into LOGS (LOG#, USER_NAME, OP_TIME, TABLE_NAME, OPERATION, TUPLE_KEYVALUE)
  values (log_no+1, userno, sysdate, 'students', 'delete', :OLD.B#);

delete from G_ENROLLMENTS where g_b# = :OLD.B#;
--need to remove all enrollments corresponding to the student before being able to remove the student due to constraints
end;
/
