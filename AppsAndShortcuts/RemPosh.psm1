Write-Host "loading RemPosh Module..." -ForegroundColor Yellow

function Add-GitCommit {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]$commit_message
    )
    git status
    git branch
    git add .
    git status
    git commit -m "$commit_message"
}

function Add-RemPoshToProfile {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]$profilePath,
        [parameter(Mandatory)]$profileContent
    )
    Add-Content -LiteralPath $profilePath -Value $profileContent -Encoding UTF8
}

function Show-Calendar {
    param(
        [DateTime] $start = [DateTime]::Today,
        [DateTime] $end = $start,
        $firstDayOfWeek,
        [int[]] $highlightDay,
        [string[]] $highlightDate = [DateTime]::Today.ToString()
        )
    
    ## Determine the first day of the start and end months.
    $start = New-Object DateTime $start.Year,$start.Month,1
    $end = New-Object DateTime $end.Year,$end.Month,1
    
    ## Convert the highlighted dates into real dates.
    [DateTime[]] $highlightDate = [DateTime[]] $highlightDate
    
    ## Retrieve the DateTimeFormat information so that the
    ## calendar can be manipulated.
    $dateTimeFormat  = (Get-Culture).DateTimeFormat
    if($firstDayOfWeek)
    {
        $dateTimeFormat.FirstDayOfWeek = $firstDayOfWeek
    }
    
    $currentDay = $start
    
    ## Process the requested months.
    while($start -le $end)
    {
        ## Return to an earlier point in the function if the first day of the month
        ## is in the middle of the week.
        while($currentDay.DayOfWeek -ne $dateTimeFormat.FirstDayOfWeek)
        {
            $currentDay = $currentDay.AddDays(-1)
        }
    
        ## Prepare to store information about this date range.
        $currentWeek = New-Object PsObject
        $dayNames = @()
        $weeks = @()
    
        ## Continue processing dates until the function reaches the end of the month.
        ## The function continues until the week is completed with
        ## days from the next month.
        while(($currentDay -lt $start.AddMonths(1)) -or
            ($currentDay.DayOfWeek -ne $dateTimeFormat.FirstDayOfWeek))
        {
            ## Determine the day names to use to label the columns.
            $dayName = "{0:ddd}" -f $currentDay
            if($dayNames -notcontains $dayName)
            {
                $dayNames += $dayName
            }
    
            ## Pad the day number for display, highlighting if necessary.
            $displayDay = " {0,2} " -f $currentDay.Day
    
            ## Determine whether to highlight a specific date.
            if($highlightDate)
            {
                $compareDate = New-Object DateTime $currentDay.Year,
                    $currentDay.Month,$currentDay.Day
                if($highlightDate -contains $compareDate)
                {
                    $displayDay = "*" + ("{0,2}" -f $currentDay.Day) + "*"
                }
            }
    
            ## Otherwise, highlight as part of a date range.
            if($highlightDay -and ($highlightDay[0] -eq $currentDay.Day))
            {
                $displayDay = "[" + ("{0,2}" -f $currentDay.Day) + "]"
                $null,$highlightDay = $highlightDay
            }
    
            ## Add the day of the week and the day of the month as note properties.
            $currentWeek | Add-Member NoteProperty $dayName $displayDay
    
            ## Move to the next day of the month.
            $currentDay = $currentDay.AddDays(1)
    
            ## If the function reaches the next week, store the current week
            ## in the week list and continue.
            if($currentDay.DayOfWeek -eq $dateTimeFormat.FirstDayOfWeek)
            {
                $weeks += $currentWeek
                $currentWeek = New-Object PsObject
            }
        }
    
        ## Format the weeks as a table.
        $calendar = $weeks | Format-Table $dayNames -AutoSize | Out-String
    
        ## Add a centered header.
        $width = ($calendar.Split("`n") | Measure-Object -Maximum Length).Maximum
        $header = "{0:MMMM yyyy}" -f $start
        $padding = " " * (($width - $header.Length) / 2)
        $displayCalendar = " `n" + $padding + $header + "`n " + $calendar
        $displayCalendar.TrimEnd()
    
        ## Move to the next month.
        $start = $start.AddMonths(1)
    
    }
}

function New-RemoteScheduledTask {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]$ScheduledTaskScript,
        [parameter(Mandatory)]$RemoteComputer
    )
    try {
        Invoke-Command -ComputerName $RemoteComputer -ScriptBlock {
            $loggedonuser = $(Get-WMIObject -class Win32_ComputerSystem | Select-Object username).username
            # Trim domain\username to just Username
            $username = $loggedonuser.Substring(3)
            # Create Script on local computer that will be run by the scheduled task. Path is on the desktop
            new-item "C:\users\$username\desktop\ScheduledTask.ps1" -Itemtype File -Value $ScheduledTaskScript
            # Define Parameters for the scheduled task
            $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-executionpolicy bypass -file C:\users\$username\desktop\ScheduledTask.ps1"
            $trigger = New-ScheduledTaskTrigger -AtLogOn
            $principal = New-ScheduledTaskPrincipal $loggedonuser
            $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
            # Create the scheduled task and name it
            Register-ScheduledTask ScheduledTask -InputObject $task
            # Start task with a 5 second delay*
            Start-ScheduledTask -TaskName ScheduledTask
            Start-Sleep -Seconds 5
            # Delete both the scheduled task and script created on the desktop
            Unregister-ScheduledTask -TaskName ScheduledTask -Confirm:$false
            remove-item "C:\users\$username\desktop\ScheduledTask.ps1" 
        }
        return $true 
    }
    catch {
        return $false
    }
}

Function Ping-Computer {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]$RemoteComputer
    )
    $rtn4 = ping -4 -n 1 $RemoteComputer
    foreach ($line in $rtn4)
    {
        if ($line.StartsWith("Reply from") -eq $true)
        {
        $line -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | Out-Null
        $ipv4 = $matches.Values
        }
    }
    $ipv6 = (Test-Connection $RemoteComputer -Count 1 -ErrorAction SilentlyContinue).IPV6Address
    if($ipv4 -ne $null) {
        return $ipv4
    }
    elseif ($ipv6 -ne $null)  {
        return $ipv6
    }
    else {
        return $null
    }
}

function Start-RemoteOfficeOnlineRepair {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]$RemoteComputer
    )
    try {
        Invoke-Command -ComputerName $RemoteComputer -ScriptBlock{
            Set-Location 'C:\Program Files\Microsoft Office 15\ClientX64\'
            .\OfficeClickToRun.exe scenario=Repair DisplayLevel=false RepairType=FullRepair forceappshutdown=true
        }
        return $true
    }
    catch {
        return $false
    }
}

function Start-RemoteOfficeQuickRepair {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]$RemoteComputer
    )
    try {
        Invoke-Command -ComputerName $RemoteComputer -ScriptBlock{
            Set-Location 'C:\Program Files\Microsoft Office 15\ClientX64\'
            .\OfficeClickToRun.exe scenario=Repair DisplayLevel=false RepairType=quickRepair forceappshutdown=true
        }
        return $true
    }
    catch {
        return $false
    }
}

function Get-RemoteNetworkInfo {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]$RemoteComputer
    )
    try {
        Invoke-Command -ComputerName $RemoteComputer -ScriptBlock{
            $networkInfo = ipconfig /all
            return $networkInfo
        }
    }
    catch {
        return $null
    }
}

function Get-SurfaceDockMcuUpdateStatus {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]$RemoteComputer
    )
    try {
        Invoke-Command -ComputerName $RemoteComputer -ScriptBlock{
            $key = "HKLM:\software\Microsoft\Windows NT\CurrentVersion\WUDF\services\SurfaceDockFwUpdate\Parameters"
            $McuVersion = (Get-ItemProperty -Path $key -Name Component10CurrentFwVersion).Component10CurrentFwVersion
            $McuOfferVersion = (Get-ItemProperty -Path $key -Name Component10OfferFwVersion).Component10OfferFwVersion
            if($McuOfferVersion -eq $McuVersion){
                return $true
            }
            If($McuOfferVersion -gt $McuVersion){
                return $false
            }
        }
    }
    catch  {
        return $null
    }
}

function Get-SurfaceDockDpUpdateStatus {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]$RemoteComputer
    )
    try {
        Invoke-Command -ComputerName $RemoteComputer -ScriptBlock{
            $key = "HKLM:\software\Microsoft\Windows NT\CurrentVersion\WUDF\services\SurfaceDockFwUpdate\Parameters"
            $DpVersion = (Get-ItemProperty -Path $key -Name Component20CurrentFwVersion).Component20CurrentFwVersion
            $DpOfferVersion = (Get-ItemProperty -Path $key -Name Component20OfferFwVersion).Component20OfferFwVersion
            if($DpOfferVersion -eq $DpVersion){
                return $true
            }
            if($DpOfferVersion -gt $DpVersion){
                return $false
            }
        }
    }
    catch  {
        return $null
    }
}

function Start-ConnectionWait {
param (
    [parameter(Mandatory)]$RemoteComputer
)
    Start-Job -Name $RemoteComputer -ScriptBlock { 
        Param($RemoteComputer)
        while (!((Test-NetConnection $RemoteComputer).PingSucceeded) -contains "true") {
            Start-Sleep 5
        } 

        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("$RemoteComputer Online",0,"Ping Succeeded",0x1)
    } -ArgumentList $RemoteComputer
}
    
function Get-LocalImportedJsonFile {
    param (
        [parameter(Mandatory)]$JsonFilePath
    )
    $ImportedJsonFile = Get-Content -Path $JsonFilePath | ConvertFrom-Json | ForEach-Object {[localData]::new($_.ScriptName, $_.LogMessage, $_.ErrorMessage, $_.RunError, $_.ExecutionTime, $_.Date)}
    return [localData]$ImportedJsonFile
}

function Exit-Process {
    param (
        [parameter(Mandatory)]$ProcessName
    )
    taskkill /PID (get-process -name $ProcessName).id /F
}

Class EscalatedTicket {
    [string]$INCNumber
    [string]$ShortDescription
    [string]$Category
    [datetime]$Date

    EscalatedTicket($INCNumber,$ShortDescription,$Category,$Date){
        $this.INCNumber = $INCNumber
        $this.ShortDescription = $ShortDescription
        $this.Category = $Category
        $this.Date = $Date
    }
}

function Add-EscalatedTicket {
param (
    [parameter(Mandatory)]$INCNumber,
    [parameter(Mandatory)]$ShortDescription,
    [parameter(Mandatory)]$Category

)
    # create an object that contains the inc number and shortdescription and optional Category, date of creation, and ID
    $TicketObject = [EscalatedTicket]::new($INCNumber, $ShortDescription, $Category, (Get-Date))
    $path = "C:\users\$env:username\Documents\EscalatedTicket\"
    If(!(test-path $path))
    {
        New-Item -ItemType Directory -Force -Path $path
    }
    # save that object locally into a json file
    $TicketObject | ConvertTo-Json | Set-Content -path "C:\users\$env:username\Documents\EscalatedTicket\$(((get-date).ToUniversalTime()).ToString("MM-dd-yy_Thhmmss"))_EscalatedTicket.json"
}

function Get-EscalatedTicket {
param (
    [parameter]$INCNumber,
    [parameter]$ShortDescription,
    [parameter]$ID
)

    $jsonfiles = get-childitem C:\Users\$env:username\Documents\EscalatedTicket\* -Filter "*EscalatedTicket.json"
    foreach ($file in $jsonfiles){
        Get-Content -Path $file | ConvertFrom-Json | ForEach-Object {[EscalatedTicket]::new($_.INCNumber, $_.ShortDescription, $_.Category, $_.Date)}
    }
    # list all tickets in the local json file in a list

    # filter results from the list using the params
}

function Open-EscalatedTicket {
param (
    [parameter(Mandatory)]$INCNumber
)
    # open the given ticket number in snow 
    start-process "https://rhiprod.service-now.com/incident.do?sysparm_query=number%3D$INCNumber"
}

function Remove-EscalatedTicket {
param (
    [parameter(Mandatory)]$INCNumber
)
    $jsonfiles = get-childitem C:\Users\$env:username\Documents\EscalatedTicket\* -Filter "*EscalatedTicket.json"
    foreach ($file in $jsonfiles){
        $jsonData = Get-Content -Path $file | ConvertFrom-Json
        if($jsonData.INCNumber -eq $INCNumber){remove-item -path $file}
    }
}

Class UnhandeledException {
    [string]$FrameWorkVersion
    [string]$Description
    [string]$ExceptionInfo
    [string]$Location
    [string]$Control
    [string]$FullException
    [datetime]$Date

    UnhandeledException($FrameWorkVersion,$Description,$ExceptionInfo,$Location,$Control,$FullException,$Date){
        $this.FrameWorkVersion = $FrameWorkVersion
        $this.Description = $Description
        $this.ExceptionInfo = $ExceptionInfo
        $this.Location = $Location
        $this.Control = $Control
        $this.FullException = $FullException
        $this.Date = $Date
    }
}

function Find-FolderPath {
    param (
    [Parameter(ValueFromPipeline=$true)]
    [string]$FolderPath
    )
    If(test-path $FolderPath)
    {
        return $true
    }
    else {
        return $false
    }
}

function New-FolderPath {
    param (
    [Parameter(ValueFromPipeline=$true)]
    [string]$FolderPath
    )
    If(!(test-path $FolderPath))
    {
        New-Item -ItemType Directory -Force -Path $FolderPath
    }
}

function Get-UnhandeledArcExceptions {
    param (
    [Parameter(ValueFromPipeline=$true)]
    [ValidateRange(-365,-1)]
    [int32]$DaysBack = -90,
    [string]$FolderPath
    )

    # Finds all 1026 events that contain the a.l.i.c.e.exe string and places them into a event log object
    $AliceErrorEvents = (Get-EventLog -LogName Application -after (Get-Date).AddDays($DaysBack) | Where-Object {$_.InstanceId -eq 1026} | 
    Select-Object -Property Category,Index,TimeGenerated,EntryType,Source,InstanceID,Message) -match 'a.l.i.c.e.exe'

    # lazy way to make sure the file names are all unique 
    $i = 1

    foreach ($item in $AliceErrorEvents){

        # split the useful info out of the long string into an array
        $messageArray = $item.message -split '\n'

        # Add data points into the custom class object and save that object locally into a json file
        [UnhandeledException]::new($messageArray[1], $messageArray[2], $messageArray[3], $messageArray[4], $messageArray[5], $item.message, $item.TimeGenerated) | 
        ConvertTo-Json | 
        Set-Content -path "$FolderPath$(((get-date).ToUniversalTime()).ToString("MM-dd-yy_Thhmmss"))-$i-ArcUnhandeledExceptions.json"

        $i++
    }
}

function Find-EventLog {
    param (
    [parameter(Mandatory)]
    [int32]$DaysBack,
    [parameter(Mandatory)]
    [string]$KeyWord,
    [parameter(Mandatory)]
    [string]$LogName
    )
    try {

        $AliceErrorEvents = (Get-EventLog -LogName $LogName -after (Get-Date).AddDays($DaysBack) | Where-Object {$_.InstanceId -eq 41} | 
        Select-Object -Property Category,Index,TimeGenerated,EntryType,Source,InstanceID,Message) -match $KeyWord
        return $AliceErrorEvents
    }
    catch {
        return "No logs found."
    }
}


Export-ModuleMember -Function Find-EventLog, Find-FolderPath, New-FolderPath, Get-UnhandeledArcExceptions,Remove-EscalatedTicket, Add-EscalatedTicket, Get-EscalatedTicket, Open-EscalatedTicket, Show-Calendar, Add-RemPoshToProfile, Add-GitCommit, New-RemoteScheduledTask, Ping-Computer, Start-RemoteOfficeOnlineRepair, Start-RemoteOfficeQuickRepair, Get-RemoteNetworkInfo, Get-SurfaceDockMcuUpdateStatus, Get-SurfaceDockDpUpdateStatus, Start-ConnectionWait, Get-LocalImportedJsonFile, Exit-Process
