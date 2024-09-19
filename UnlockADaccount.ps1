Import-Module ActiveDirectory

function Get-ValidCredentials {
    do {
        $creds = Get-Credential -Message 'Input Admin Credentials'
        try {
            # Attempt to use the credentials to get a user to verify they are correct
            $null = Get-ADUser -Filter {SAMAccountName -eq "testuser"} -Credential $creds -ErrorAction Stop
            $valid = $true
        }
        catch {
            Write-Host "Invalid admin credentials. Please try again." -ForegroundColor Red
            $valid = $false
        }
    } while (-not $valid)
    return $creds
}

function Get-ValidUser {
    do {
        $user = Read-Host -Prompt 'Input User Login Name'
        Write-Host "Checking User: $user" -ForegroundColor Yellow
        try {
            $userinfo = Get-ADUser -Filter {SAMAccountName -eq $user} -Credential $creds -ErrorAction Stop
            if ($userinfo) {
                $validUser = $true
                Write-Host "$user Account Found" -ForegroundColor Green
            } else {
                $validUser = $false
                Write-Host "$user Not Found" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "User Not Found" -ForegroundColor Red
            $validUser = $false
        }
    } while (-not $validUser) 
        return $user        
}

function UnlockAccount {
    param (
        [string]$user,
        [pscredential]$creds    
    )
        try {
            $userinfo = Get-ADUser -Filter {SAMAccountName -eq $user} -Credential $creds -Properties LockedOut -ErrorAction Stop
            #$lockedstatus = $userinfo.lockedout
    
            $lockedstatus = $userinfo.lockedout
            # Debugging output
            Write-Host "Locked status of $user : $lockedstatus" -ForegroundColor Yellow

            #$lockedstatus = $userinfo.lockedout

            if ($lockedstatus -eq $true) {
                Unlock-ADAccount -Identity $user -Credential $creds
                Write-Host "$user's Account is locked... Unlocking" -ForegroundColor Green
                Write-Host "$user's Account has been unlocked" -BackgroundColor Green
            } else{
                Write-Host "Error Unlocking $user's Account: Account Already Unlocked!" -BackgroundColor Red -
            }
        }
        catch {
            Write-Host "Error Unlocking $user's Account: $($_.Exception.Message)" -BackgroundColor Red
        }
}

$creds = Get-ValidCredentials
$adminUsername = $creds.UserName
Write-Host "Logged in as: $adminUsername" -ForegroundColor Yellow

do {
    $user = Get-ValidUser
    UnlockAccount -user $user -Creds $creds
    $response = Read-Host -Prompt 'Press "[Enter]" to Exit Or "[A]" To Unlock Another Account...'
} while ($response -eq 'A')
