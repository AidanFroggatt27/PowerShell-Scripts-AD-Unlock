Import-Module ActiveDirectory

$creds = Get-Credential -Message 'Input Admin Credentials'
$user = Read-Host -Prompt 'Input user login name'
$userinfo = Get-ADUser -Filter * -Properties SAMAccountName
$lockedstatus = $userinfo.lockedout

try {

    if ($lockedstatus -eq "True"){
        Unlock-ADAccount -Identity $user -Credential $creds -Server DC01
        Write-Host "$user's Account is locked... Unlocking" -ForegroundColor Green
        Write-Host "$user's Account has been unlocked" -ForegroundColor Cyan
    }
    
    else {
        Write-Host "$user's Account is already unlocked..." -ForegroundColor Red
    }
}
catch {
    Write-Host "Error running unlock cmdlet $($_.exception.message)"  -ForegroundColor Red
}

