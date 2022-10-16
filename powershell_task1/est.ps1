
$ip1_addr = "192.168.80.63"
$ip1_bits = ""

$ip2_addr = "192.168.5.145"
$ip2_bits = ""

$ip_mask = "18"
$mask_bits = ""

function ConvertToBits {
  param (
    $ip_addr,
    [ref]$ip_bits
  )
  if ($ip_addr.Length -lt 3) {
    for ($i = 1; $i -le 32; $i++) {
      if (([int]$ip_addr) -ge $i) {
        $ip_bits.Value = $ip_bits.Value + "1"
        continue
      }
      $ip_bits.Value = $ip_bits.Value + "0"
    }
    return
  }

  
  $ip_array = @()
  $ip_addr -split '\.' | ForEach-Object { [System.Convert]::ToString($_, 2) } | ForEach-Object { $ip_array += $_ } 

  $octazero = "00000000"
  foreach ($octet in $ip_array) {
    if ($octet.Length -lt 8) {
      $ip_bits.Value = $ip_bits.Value + $octazero.Substring(0, 8 - $octet.Length) + $octet
      # Write-Host $i $ip_bits.Value 
      continue
    }
    $ip_bits.Value = $ip_bits.Value + $octet 
  }
}

# Write-Host $mask_bits

function IsSameSubnet {
  param (
    $ip1,
    $ip2,
    $mask
  )
  $ip1_nw_addr = ""
  $ip1_bc_addr = ""

  $ip2_nw_addr = ""
  $ip2_bc_addr = ""
  
  $mask_bit_length = ($mask -split '[0]+' | Select-Object -First 1 | % { $_.Length }) 
  # Write-Host "LINE54:" $mask
  # Write-Host "LINE55:" $mask_bit_length

  for ($i = 1; $i -le 32; $i++) {
    if ( $mask_bit_length -lt $i ) {
      $ip1_nw_addr = $ip1_nw_addr + "0"
      $ip1_bc_addr = $ip1_bc_addr + "1"
      $ip2_nw_addr = $ip2_nw_addr + "0"
      $ip2_bc_addr = $ip2_bc_addr + "1"
    }
  }

  $ip1_nw_addr = ($ip1.Substring(0, $mask_bit_length) + $ip1_nw_addr)
  $ip1_bc_addr = ($ip1.Substring(0, $mask_bit_length) + $ip1_bc_addr)
  $ip2_nw_addr = ($ip2.Substring(0, $mask_bit_length) + $ip2_nw_addr)
  $ip2_bc_addr = ($ip2.Substring(0, $mask_bit_length) + $ip2_bc_addr)

  
  # Write-Host "IP1 NW:" $ip1_nw_addr
  # Write-Host "IP2 NW:" $ip2_nw_addr
  # Write-Host
  # Write-Host "IP1 BC:" $ip1_bc_addr
  # Write-Host "IP2 BC:" $ip2_bc_addr

  if (($ip1_nw_addr -eq $ip2_nw_addr) -and ($ip1_bc_addr -eq $ip2_bc_addr) ) {
    Write-Host
    Write-Host "+-----+"
    Write-Host "| YES |"
    Write-Host "+-----+"
    return
  }
  Write-Host
  Write-Host "+----+"
  Write-Host "| NO |"
  Write-Host "+----+"

  # Write-Host "68: Net1  BC " $ip1_bc_addr
  # Write-Host "69: Net2  BC " $ip2_bc_addr
  # Write-Host "68: IP1" $ip1
  
}
# Write-Host $mask_bits
ConvertToBits $ip1_addr ([ref]$ip1_bits)
ConvertToBits $ip2_addr ([ref]$ip2_bits)
ConvertToBits $ip_mask ([ref]$mask_bits)

IsSameSubnet -ip1 $ip1_bits -ip2 $ip2_bits -mask $mask_bits



# Write-Host "line 38: IP1 " $ip1_bits
# Write-Host "line 39: IP2 " $ip2_bits
# Write-Host "line 41: Mask" $mask_bits


