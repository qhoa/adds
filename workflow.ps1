Import-Module PSWorkflow
function testing
{
$newname = hostname
echo $newname > C:\scripts\$newname.txt
}

workflow Rename-And-Reboot {
  param ([string]$Name)
  Rename-Computer -NewName $Name -Force -Passthru
  Restart-Computer -Wait
  testing
}
#Continue automatic workflow
#Link : #https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/jj574130(v=ws.11)?redirectedfrom=MSDN
#Note Command Create Job: Rename-And-Reboot -Name Newname2021 -JobName Rename-Job01
# Resume Job : Get-Job -Name Rename-Job01 | Resume-Job