$path = "C:\Users\r.alymbetov\Desktop\bash_powershell_task\powershell_task2"

$inputFilePath = "$path\accounts.csv"
$outputFilePath = "$path\accounts_new.csv"

$accounts = Import-Csv -Path $inputFilePath 

$logins = @()
$duplicated_logins = @()

$accounts |  ForEach-Object { $_.name } | ForEach-Object { 
  $firstname = $_ -split " " | Select-Object -First 1
  $lastname = $_ -split " " | Select-Object -Last 1
  ($firstname.Substring(0, 1) + $lastname).ToLower()
} | ForEach-Object { $logins += $_ } 

$unique_logins = $logins | Select-Object -Unique 
Compare-Object -ReferenceObject $unique_logins -DifferenceObject $logins |  ForEach-Object { $duplicated_logins += $_.InputObject }
$duplicated_logins = $duplicated_logins | Select-Object -Unique 

$domain = "@abc.com"
$accounts | ForEach-Object {
  $fullname = ($_.name).ToLower()
  $firstname = $fullname | ForEach-Object { $_ -split ' ' }  | Select-Object -First 1
  $lastname = $fullname | ForEach-Object { $_ -split ' ' } | Select-Object -Last 1
  $login = $firstname.Substring(0, 1) + $lastname

  $_.name = (Get-Culture).TextInfo.ToTitleCase($fullname)
  
  # $_.id 
  # $login
  if ($duplicated_logins -contains $login) {
    $_.email = $login + $_.location_id + $domain
  }
  else {
    $_.email = $login + $domain
  }
}


$accounts | Export-Csv -Path $outputFilePath -NoTypeInformation