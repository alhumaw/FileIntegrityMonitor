

Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new Baseline?"
Write-Host "B) Begin monitoring files with saved Baseline?"

$response = Read-Host -Prompt "Please enter 'A' or 'B'"

Function Calculate-File-Hash($filepath){
#take the file path, calculate the hash for it
    
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Already-Exists(){
    $baselineExists = Test-Path -Path .\baseline.txt

    if($baselineExists){
        Remove-Item -Path .\baseline.txt
    }
}


if ($response -eq "A".ToUpper()){
    #Delete baseline if it already exists
    Erase-Baseline-If-Already-Exists

    #Calculate Hash and store baseline.txt

    #Collect all the files in the target folder
    $files = Get-ChildItem -Path .\'important files'
    
    #For file, calcluate the hash, and write to baseline.txt
    foreach($f in $files){
       $hash = Calculate-File-Hash $f.FullName
       "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }
}
elseif ($response -eq "B".ToUpper()){
    $fileHashDictionary = @{}
    #Load file|hash from baseline.txt and store in dictionary
    $filePathsandHashes = Get-Content -Path .\baseline.txt
    
    foreach($f in $filePathsandHashes){
        $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
        
    }
    while($true){
        Start-Sleep -Seconds 1
        
        
        $files = Get-ChildItem -Path .\'important files'
        #For file, calculate the hash, and write to baseline.txt
        foreach($f in $files){ 
            $hash = Calculate-File-Hash $f.FullName

            #notify if a new file has been created 
            if($fileHashDictionary[$hash.Path] -eq $null){
                #A new file has been created
                Write-Host "$($hash.Path) has been created"
            }
            # Notify if a new file has been changed
            if($fileHashDictionary[$hash.Path] -eq $hash.Hash){

            }
            else{
                Write-Host "$($hash.Path) has changed!"
            }

        }
    

        foreach($key in $fileHashDictionary.Keys){
            $baselineFileStillExists = Test-Path -Path $key
            if(-Not $baselineFileStillExists){
               Write-Host "$($key) has been deleted!" 

            }

        }

    }

    $fileHashDictionary.add("path","hash")
    $fileHashDictionary
    $fileHashDictionary["path"]
}