param (
  [Parameter(Mandatory = $true)]
  $filePath
)

# File name.
$fileName = $filePath -split '\\' | Select-Object -Last 1
# File path.
$path = Split-Path $filePath
# Input file.
$inputFilePath = "$path\$filename"
# Output file.
$outputFilePath = "$path\accounts_new.csv"
# Importing csv file.
$accounts = Import-Csv -Path $inputFilePath 
# Array for logins created by appending first letter of firstname and lastname.
$logins = @()
# Array for only repeated logins.
$duplicated_logins = @()
# Filling logins array.
$accounts |  ForEach-Object { $_.name } | ForEach-Object { 
  $firstname = $_ -split " " | Select-Object -First 1
  $lastname = $_ -split " " | Select-Object -Last 1
  ($firstname.Substring(0, 1) + $lastname).ToLower()
} | ForEach-Object { $logins += $_ } 
# Array with with unique logins.
$unique_logins = $logins | Select-Object -Unique
# Saving repeated logins into duplicated_logins array.
Compare-Object -ReferenceObject $unique_logins -DifferenceObject $logins |  ForEach-Object { $duplicated_logins += $_.InputObject }
# Saving unique logins of repeated logins.
$duplicated_logins = $duplicated_logins | Select-Object -Unique 
# Domain for emails.
$domain = "@abc.com"
# Filling output csv file array with modified data of columns name and email.
$accounts | ForEach-Object {
  $fullname = ($_.name).ToLower()
  $firstname = $fullname | ForEach-Object { $_ -split ' ' }  | Select-Object -First 1
  $lastname = $fullname | ForEach-Object { $_ -split ' ' } | Select-Object -Last 1
  $login = $firstname.Substring(0, 1) + $lastname
  $_.name = (Get-Culture).TextInfo.ToTitleCase($fullname)
  # Adding location id if login is duplicated.
  if ($duplicated_logins -contains $login) {
    $_.email = $login + $_.location_id + $domain
  }
  else {
    $_.email = $login + $domain
  }
}
# Exporting modified csv file.
$accounts | Export-Csv -Path $outputFilePath -NoTypeInformation