create table tblA ( iFid1 i )
insert into tblA values (1)
insert into tblA values (2)
create table tblB ( iFid1 i )
insert into tblB values (1)
insert into tblB values (2)

?
select tblA
scan  && A
  ? "#1 A", alias()
  f()
  ? "#2 A", alias()
endscan && A
? "#3 A", alias()
brow
function f
select tblB
scan && B
  select tblA
  ? "#4 A", alias()
  return
endscan && B