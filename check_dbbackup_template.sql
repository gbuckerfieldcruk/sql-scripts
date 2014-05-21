use master
go

-- Check most recent full backup

declare @mediasetid int
declare @backupfilename varchar(250)
declare @sqltext varchar(500)
declare @backupfinished datetime
declare @database_name varchar(250)

set @database_name = '<DatabaseName,varchar(150),>'

select @mediasetid = max(media_set_id) from msdb.dbo.backupset
where database_name = @database_name and type = 'D' and is_copy_only = 0

select @backupfinished = backup_finish_date from msdb.dbo.backupset
where media_set_id = @mediasetid

select @backupfilename = physical_device_name from msdb.dbo.backupmediafamily
where media_set_id = @mediasetid

print 'Most recent full backup for ' + @database_name + ' completed at ' + convert(varchar(20), @backupfinished)

set @sqltext = 'restore verifyonly from disk = ''' + @backupfilename + ''' with checksum, stats = 10;'
print @sqltext

begin try
	exec (@sqltext)
end try

begin catch
	print 'SQL Server error message is: ' + error_message()
end catch
go


-- Check most recent differential backup

declare @mediasetid int
declare @backupfilename varchar(250)
declare @sqltext varchar(500)
declare @backupfinished datetime
declare @database_name varchar(250)

set @database_name = '<DatabaseName,varchar(150),>' 

select @mediasetid = max(media_set_id) from msdb.dbo.backupset
where database_name = @database_name and type = 'I'

select @backupfinished = backup_finish_date from msdb.dbo.backupset
where media_set_id = @mediasetid

select @backupfilename = physical_device_name from msdb.dbo.backupmediafamily
where media_set_id = @mediasetid

if @backupfinished < dateadd(hh, -12, getdate())
begin
	print 'A differential backup has not run in the last 12 hours for the ' + @database_name + ' database'
	print 'The last differential backup completed at ' + convert(varchar(20), @backupfinished)
end
else
begin

	print 'Most recent differential backup of ' + @database_name + ' completed at ' + convert(varchar(20), @backupfinished)

	set @sqltext = 'restore verifyonly from disk = ''' + @backupfilename + ''' with checksum, stats = 10;'
	print @sqltext

	begin try
		exec (@sqltext)
	end try

	begin catch
		print 'SQL Server error message is: ' + error_message()
	end catch
end
go
