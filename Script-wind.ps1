$ipAddress = "0.0.0.0"
$port = 12345
$data=@()
$listener = New-Object System.Net.Sockets.TcpListener($ipAddress, $port)

try {
    $listener.Start()
}
catch {
    Write-Host "Erreur lors du démarrage du TcpListener : $_"
    return
}

Write-Host "En attente de connexions sur $($ipAddress):$($port)..."

while ($true) {
    try {
        $client = $listener.AcceptTcpClient()
        Write-Host "Nouvelle connexion établie avec $($client.Client.RemoteEndPoint)"

        $stream = $client.GetStream()
        $writer = New-Object System.IO.StreamWriter($stream)
        $reader = New-Object System.IO.StreamReader($stream)

        $writer.AutoFlush = $true  # Activer l'envoi automatique des données

        $writerThread = [PowerShell]::Create().AddScript({
            param($writer, $reader,$client)

            $writer.WriteLine("Bonjour from windows, Entrez le nombre de machine que vous voulez créer : ")

        
            $response = $reader.ReadLine()
             
            [int]$nombre_machines=$response
            $data+=$nombre_machines
            # $writer.WriteLine("nombre des machines est $nombre_machines")
            if ($response -eq "exit") {
                Write-Host "Client déconnecté."
                
                $client.Close()
                break
            }
            Write-Host "Réponse reçue : $response"
            
            
            # For($i=0 ; $i -lt $entier ; $i++) 
            # { 
            #     $writer.WriteLine("La valeur est $i")  
            # }
            $writer.WriteLine("Est ce vous voulez les nomer d'une manière automatique ? (y/n) : ") 
            $response = $reader.ReadLine()
            $writer.WriteLine("nombre des machines est $nombre_machines")
            $response = $reader.ReadLine()
            if($response -eq "y"){
                [bool]$nom_automatique=$true
            }
            else {
                [bool]$nom_automatique=$false
                $listeNomMachies = @()
                For($i=0 ; $i -lt $nombre_machines ; $i++){
                    $writer.WriteLine("Entrer le nom de la machine $($i+1) : ")
                    $response = $reader.ReadLine()
                    $listeNomMachies+=$response
                    # $data+=$response
                    
                }
                
                [string]$lesNoms = $listeNomMachies -join " , "
                $writer.WriteLine("les noms des machines : $lesNoms")
                $response = $reader.ReadLine()
            }
            $totalRAM = (Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB
            $availableRAM = (Get-WmiObject Win32_PerfFormattedData_PerfOS_Memory).AvailableBytes / 1GB
            $writer.WriteLine("Taille totale de la RAM : $totalRAM Go et la Mémoire RAM disponible pour les processus utilisateur : $availableRAM Go")
            $response = $reader.ReadLine()
            # Obtenir la taille du disque dur
            $disks = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}
            foreach ($disk in $disks) {
                $diskSize = [math]::Round($disk.Size / 1GB, 2)
                $freeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
                
                $writer.WriteLine("Disque $disk.DeviceID - Taille totale: $diskSize Go, Espace libre: $freeSpace Go")
                $response = $reader.ReadLine()
            }
            $writer.WriteLine("Entrer le numero du disk dans le quel vous allez installez vos machines : ")
            $response=$reader.ReadLine()
            [int]$numDisk=$response
            $disk=$disks[$($numDisk-1)]
            $freeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
            $writer.WriteLine("free space is $freeSpace ")
            $response=$reader.ReadLine()

            # Obtenir la mémoire RAM disponible pour les processus utilisateur
            $writer.WriteLine("Entrer la mémoire RAM pour chaque machines en Go : ")
            $response = $reader.ReadLine()
            $memoirPourChaqueMachine=[int]$response
            [int]$TotalMemoNeeded=$memoirPourChaqueMachine*$nombre_machines
            $writer.WriteLine("total RAM needed is $TotalMemoNeeded")
            $response = $reader.ReadLine()
            while ($TotalMemoNeeded -gt $availableRAM ){
                $writer.WriteLine("Mémoire insiffusante Entrer la mémoire RAM pour chaque machines en Go : ")
                $response = $reader.ReadLine()
                $memoirPourChaqueMachine=$response
                $TotalMemoNeeded=$memoirPourChaqueMachine*$nombre_machines
            }
            $data+=$memoirPourChaqueMachine

            [int]$capacitePourChaqueMachine
            $writer.WriteLine("Entrer le stockage pour chaque machine en Go : ")
            $response = $reader.ReadLine()
            [int]$capacitePourChaqueMachine=$response
            $TotalStockNeeded=$nombre_machines * $capacitePourChaqueMachine
            $writer.WriteLine("Total storage needed : $TotalStockNeeded GO ")
            $response = $reader.ReadLine()
            while ($TotalStockNeeded -gt $freeSpace ){
                $writer.WriteLine("Storage insifusant, try again (GO) : ")
                $response = $reader.ReadLine()
                $capacitePourChaqueMachine=$response
                $capacitePourChaqueMachine=$response
                $TotalStockNeeded=$nombre_machines * $capacitePourChaqueMachine
                $writer.WriteLine("Total storage needed : $TotalStockNeeded GO ")
                $response = $reader.ReadLine()
            }
            $data+=$capacitePourChaqueMachine
        # Spécifiez le chemin du répertoire
        $directoryPath = "F:\images"

        # Obtenez la liste des fichiers dans le répertoire
        $files = Get-ChildItem -Path $directoryPath
        $filesContent=""

        foreach ($file in $files) {
            
            
            $filesContent=$file -join " , "
        }
        $writer.WriteLine("Choisir l'index de l'image voulue : $filesContent")
        $response = $reader.ReadLine()
        $image=$files[$response-1]
        $writer.WriteLine("L'image choisi est $image tapez Entrez pour continuer.. et data : $($data[1])")
        $response = $reader.ReadLine()
        $data+=$image
        # Création des machines 
        # Création des machines
        # for ($i=0 ; $i -lt $nombre_machines; $i++) {
        #     New-VM -Name "$($listeNomMachies[$i])" -MemoryStartupBytes ([int]$memoirPourChaqueMachine * 1GB) -NewVHDPath "F:/machine$($i+1)/base.vhdx" -NewVHDSizeBytes ($capacitePourChaqueMachine * 1GB) -SwitchName "New Virtual Switch"
        # }

                }).AddArgument($writer).AddArgument($reader).AddArgument($client).BeginInvoke()
        


# Création des machines
# for ($i = 0; $i -lt $nombre_machines; $i++) {
#     New-VM -Name "$($listeNomMachies[$i])" -MemoryStartupBytes ([int]$memoirPourChaqueMachine * 1GB) -NewVHDPath "F:/machine$($i+1)/base.vhdx" -NewVHDSizeBytes ($capacitePourChaqueMachine * 1GB) -SwitchName "New Virtual Switch"
#     $writer.WriteLine("machine $i créé")
#     $response = $reader.ReadLine()
# }



        $writerThread.AsyncWaitHandle.WaitOne() | Out-Null
        $client.Close()
        break
        
    }
    catch {
        Write-Host "Erreur : $_"
    }
    

}

# Create a new VM

.\create-vms.ps1 -NumberOfVMs $data[0] -MemoryInGB $data[1] -DiskSizeInGB $data[2] -VMSwitchName "New Virtual Switch" -ISOPath "F:\images\ubuntu.iso"