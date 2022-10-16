param (
  [Parameter(Mandatory = $true, Position = 0)]
  [ValidatePattern("\b(1?(1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])\b")]
  $ip1_addr,
  [Parameter(Mandatory = $true, Position = 1)]
  [ValidatePattern("\b(1?(1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])\b")]
  $ip2_addr,
  [Parameter(Mandatory = $true, Position = 2)]
  [ValidatePattern("(^(((255\.){3}(255|254|252|248|240|224|192|128|0+))|((255\.){2}(255|254|252|248|240|224|192|128|0+)\.0)|((255\.)(255|254|252|248|240|224|192|128|0+)(\.0+){2})|((255|254|252|248|240|224|192|128|0+)(\.0+){3}))$)|^([0-9]|1[0-9]|2[0-9]|3[0-2])$")]
  $ip_mask
)

# IP1 in 32-bits form.
$ip1_bits = ""
# IP2 in 32-bits form.
$ip2_bits = ""
# Mask in 32-bits form.
$mask_bits = ""
# Converting decimal IP and Mask into bits. 
function ConvertToBits {
  param (
    [Parameter(Position = 0)]
    $ip_addr,
    [Parameter(Position = 1)]
    [ref]$ip_bits # Reference to given argument variable.
  )

  # Convert given decimal Mask bits number into 32-bits form.
  if ($ip_addr.Length -lt 8) {
    for ($i = 1; $i -le 32; $i++) {
      if (([int]$ip_addr) -ge $i) {
        $ip_bits.Value = $ip_bits.Value + 1
        continue
      }
      $ip_bits.Value = $ip_bits.Value + 0
    }
    return
  }
  
  # Adding 4 octets of IP to array.
  $ip_array = @()
  $ip_addr -split '\.' | ForEach-Object { [System.Convert]::ToString($_, 2) } | ForEach-Object { $ip_array += $_ } 

  # Octet of zeroes for filling empty leading zero bits.
  $octazero = "00000000" 
  foreach ($octet in $ip_array) {
    if ($octet.Length -lt 8) {
      $ip_bits.Value = $ip_bits.Value + $octazero.Substring(0, 8 - $octet.Length) + $octet
      continue
    }
    $ip_bits.Value = $ip_bits.Value + $octet 
  }
}

# Comparing IP1 and IP2 networks.
function IsSameSubnet {
  param (
    $ip1,
    $ip2,
    $mask
  )
  # IP1 network address in 32-bits form.
  $ip1_nw_addr = ""
  # IP1 broadcast address in 32-bits form.
  $ip1_bc_addr = ""
  # IP2 broadcast address in 32-bits form.
  $ip2_nw_addr = ""
  # IP2 broadcast address in 32-bits form.
  $ip2_bc_addr = ""
  # Calculating mask length.
  $mask_bit_length = ($mask -split '[0]+' | Select-Object -First 1 | % { $_.Length }) 
  # Filling network and broadcast addresses with 0 and 1 bits using Mask.  
  for ($i = 1; $i -le 32; $i++) {
    if ( $mask_bit_length -lt $i ) {
      $ip1_nw_addr = $ip1_nw_addr + "0"
      $ip1_bc_addr = $ip1_bc_addr + "1"
      $ip2_nw_addr = $ip2_nw_addr + "0"
      $ip2_bc_addr = $ip2_bc_addr + "1"
    }
  }
  # Calculating and converting network and broadcast addresses to 32-bit form.
  $ip1_nw_addr = ($ip1.Substring(0, $mask_bit_length) + $ip1_nw_addr)
  $ip1_bc_addr = ($ip1.Substring(0, $mask_bit_length) + $ip1_bc_addr)
  $ip2_nw_addr = ($ip2.Substring(0, $mask_bit_length) + $ip2_nw_addr)
  $ip2_bc_addr = ($ip2.Substring(0, $mask_bit_length) + $ip2_bc_addr)
  # Comparing IP1's and IP2's network and broadcast addresses. 
  if (($ip1_nw_addr -eq $ip2_nw_addr) -and ($ip1_bc_addr -eq $ip2_bc_addr) ) {
    Write-Host "yes"
    return
  }  
  Write-Host "no"
}

# Calling function and passing IP1 and reference to IP1-bits variable.
ConvertToBits $ip1_addr ([ref]$ip1_bits)
# Calling function and passing IP2 and reference to IP2-bits variable.
ConvertToBits $ip2_addr ([ref]$ip2_bits)
# Calling function and passing Mask and reference to Mask-bits variable.
ConvertToBits $ip_mask ([ref]$mask_bits)

# Calling function and passing IP1-bits, IP2-bits and Mask-bits.
IsSameSubnet -ip1 $ip1_bits -ip2 $ip2_bits -mask $mask_bits





