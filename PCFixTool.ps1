# Basic PC Fix Tool

# Saves log file to the device's Temp folder.
$logFile = "C:\Temp\PCFixTool.log"

# Writes to the log file
function Write-Log {
    param($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append 
}

function Clear-Temp{
    Write-Host "Clearning temp files..."
    Write-Log "Clearing temp files..."
    
    # Remove device temp files
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Remove user temp tiles
    Remove-Item -Path ":$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Temp files removed."
}   

# Network Fix (DNS cache and IP reset)
function Network-Fix {
    Write-Host "Running Network fixes."
    Write-Host "Clearning DNS cache and renewing IP from DHCP server."
    
    ipconfig /flushdns
    ipconfig /release
    ipconfig /renew
    netsh winsock reset

    Write-Host "Network fix finished"
}

# SFC - Scanning and repairing corrupted Windows system files.
function Run-SFC {
    Write-Host "Running SFC"
    Write-Log "Running SFC"
    sfc /scannow
    Write-Host "Scan finished"
}

# Restart common services | !!!Add more later on

function Restart-Services {
    Write-Host "Restarting common services"
    Write-Log "Restarting services"

    $services = @("Spooler", "wuauserv")

    foreach ($service in $services) {
        Restart-Service -Name $service -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Services restarted"
}

# Loops through device's disks and displays info
function Check-DiskSpace {
    $drives = Get-PSDrive -PSProvider FileSystem
    foreach($drive in $drives) {
        $free = [math]::Round($drive.Free / 1GB,2)
        $total = [math]::Round(($drive.Used + $drive.Free)/1GB,2)
        $percent = [math]::Round(($drive.Used/($drive.Used+$drive.Free))*100,2)
        Write-Host "Drive $($drive.Name): Used $($total-$free)/$total GB ($percent%)"
        Write-Log "Drive $($drive.Name): Used $($total-$free)/$total GB ($percent%)"
    }
}

# Kill High CPU Usage Processes

function Kill-Processes {
    Write-Host "Killing high CPU processes..."
    Write-Log "Killing high CPU processes"

    $processes = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5

    foreach ($p in $processes) {
        Write-Host "Stopping $($p.Name)"
        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    }
}

# Menu

function Display-Menu {
    Clear-Host
    Write-Host "============================"
    Write-Host " BASIC COMPUTER FIXES "
    Write-Host "============================"
    Write-Host "1. Clear Temp Files"
    Write-Host "2. Fix Network"
    Write-Host "3. Run System Scan (SFC)"
    Write-Host "4. Restart Common Services"
    Write-Host "5. Check Disk Space"
    Write-Host "6. Kill High CPU Processes"
    Write-Host "7. Run ALL Fixes"
    Write-Host "0. Exit"
}

# Keep the script running until the user exits

do {
    Display-Menu

    # User input prompt
    $uinput = Read-Host "Select an option."

    switch ($uinput) {

    # Run individual functions
        "1" { Clear-Temp; Pause }
        "2" { Network-Fix; Pause }
        "3" { Run-SFC; Pause }
        "4" { Restart-Services; Pause }
        "5" { Check-DiskSpace; Pause }
        "6" { Kill-Processes; Pause }

        # Run all fixes in sequence
        "7" {
            Clear-Temp
            Network-Fix
            Restart-Services
            Check-DiskSpace
            Run-SFC
            Kill-Processes
            Pause
        }

        # Exit script
        "0" { break }

        # Handle invalid input
        default {
            Write-Host "Invalid option"
            Pause
        }
    }
# Loop until user exits
} while ($true)
