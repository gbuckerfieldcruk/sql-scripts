declare @name	varchar(1000)
declare @path	varchar(1000)
declare @time	varchar(6)
declare @sql	varchar(2000)
declare @year	varchar(4)
declare @month	varchar(2)
declare @day	varchar(2)
declare @backupfile varchar(150)

select @year = datepart(year, getdate())

select @month = right('0' + convert(varchar(2), (datepart(month, getdate()))), 2)

select @day = right('0' + convert(varchar(2), (datepart(day, getdate()))), 2)

select @time = replace(convert(varchar(20), getdate(), 108), ':', '')

-- Exclude snapshots and any database that is not online
select @name = min(name) from master.sys.databases 
where (database_id > 4 and state = 0 and source_database_id is null)
or (name in ('master', 'model', 'msdb'))


while @name is not null
begin
	-- Begin looping through databases
	-- Set the UNC path for the backup
	set @path = ''
	select @path = 'Enter backup path here'
	select @path = @path + '\' + @name
	
	-- If the path does not exist then create it
	exec xp_create_subdir @path

	-- Set the name of the backup file
	select @backupfile = @name + '_backup_' + @year + '_' + @month + '_' + @day + '_' + @time + '.bak'

	-- Build and execute the backup statement
	select @sql = 'backup database ' + quotename(@name) + ' to disk = ' + char(39) + @path + '\' + @backupfile + char(39) + ' with checksum, name = ''' + @name + ' - Full Backup'';'
	print @sql	
	exec (@sql)

	-- Build and execute the restore statement
	select @sql = 'restore verifyonly from disk = ' + char(39) + @path + '\' + @backupfile + char(39) + ' with checksum;'
	print @sql
	exec (@sql)

	-- Get the next database
	select @name = min(name) from master.sys.databases 
	where ((database_id > 4 and state = 0 and source_database_id is null)
	or (name in ('master', 'model', 'msdb'))) and name > @name
end
