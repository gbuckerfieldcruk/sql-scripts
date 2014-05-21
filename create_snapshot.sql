/*
SCRIPT CREATES DATABASE SNAPSHOT OF THE CURRENT DB.
CHANGE THE <DATABASE_NAME> AT THE TOP OF THE SCRIPT.
*/
use RaceStaging
go

declare @name varchar(200)
declare @datapath varchar(2000)
declare @logicalname varchar(250)
declare @sqltext varchar(3000)
declare @snapshotname varchar(200)
declare @snapdate varchar(8)
declare @datafilename varchar(200)
declare @snaptime varchar(6)

select @snapdate = convert(varchar, getdate(), 112)

select @snaptime = replace(convert(time, getdate()), ':', '')

select @name = db_name()

select @snapshotname = @name + '_snapshot_' + @snapdate + '_' + @snaptime

select @datafilename = right([physical_name],charindex('\',reverse ([physical_name]))-1) from master.sys.master_files where database_id = db_id() and file_id = 1

select @datapath = substring(physical_name, 1, charindex(@datafilename, lower(physical_name)) - 1) from sys.database_files where file_id = 1

select @datapath = @datapath + @name + '_' + @snapdate + '_' + @snaptime + '_snapshot.ss'

select @logicalname = name from sys.database_files where file_id = 1

set @sqltext = 'create database ' + @snapshotname + ' on (Name = ' + @logicalname + ', filename = ''' + @datapath + ''') as snapshot of ' + @name + ';'

print @sqltext

exec(@sqltext)