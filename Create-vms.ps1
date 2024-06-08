param(
    [Parameter(Mandatory=$true)]
    [int]$NumberOfVMs,
    [Parameter(Mandatory=$true)]
    [int]$MemoryInGB,
    [Parameter(Mandatory=$true)]
    [int]$DiskSizeInGB,
    [Parameter(Mandatory=$true)]
    [string]$VMSwitchName,
    [Parameter(Mandatory=$true)]
    [string]$ISOPath
)

for ($i = 1; $i -le $NumberOfVMs; $i++) {
    $vmName = "VM$i"

    New-VM -Name $vmName -MemoryStartupBytes ($MemoryInGB * 1GB) -NewVHDPath "F:/machine$i/base.vhdx" -NewVHDSizeBytes ($DiskSizeInGB * 1GB) -SwitchName $VMSwitchName

    $dvdDrive = Get-VMDvdDrive -VMName $vmName
    Set-VMDvdDrive -VMName $vmName -ControllerNumber $dvdDrive.ControllerNumber -ControllerLocation $dvdDrive.ControllerLocation -Path $ISOPath

    Set-VMFirmware -VMName $vmName -EnableSecureBoot Off -FirstBootDevice (Get-VMDvdDrive -VMName $vmName)

    # Start-VM -Name $vmName

    # Enter-PSSession -VMName $vmName -Credential root  # Commented out for now

    # Attendez que la machine virtuelle démarre et obtenez son adresse IP
    # do {
    #     Start-Sleep -Seconds 5
    #     $ipAddress = (Get-VMNetworkAdapter -VMName $vmName).IPAddresses | Where-Object { $_ -match '^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$' }
    # } while (-not $ipAddress)

    # Write-Host "VM $vmName created with IP: $ipAddress"
}