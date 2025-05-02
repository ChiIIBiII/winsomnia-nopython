$PowerStateType = Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class PowerState {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);
}
"@ -PassThru

$ES_CONTINUOUS = [uint32]"0x80000000"
$ES_SYSTEM_REQUIRED = [uint32]"0x00000001"

$newState = $ES_SYSTEM_REQUIRED -bor $ES_CONTINUOUS
$previousState = [PowerState]::SetThreadExecutionState($newState)

if ($previousState -eq 0) {
    $lastError = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if ($lastError -ne 0) {
        Write-Output "SetThreadExecutionState failed with error code: $lastError"
        exit 1
    } else {
        Write-Output "SetThreadExecutionState succeeded (reset idle timer). Previous state was idle (0)."
    }
} else {
    Write-Output "SetThreadExecutionState succeeded!"
}

# Keep the script alive but idle
while ($true) {
    $previousState = [PowerState]::SetThreadExecutionState($newState)
    $lastError = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if ($previousState -eq 0 -and $lastError -ne 0) {
        Write-Error "SetThreadExecutionState failed with error code: $lastError"
        exit 1
    }
    Start-Sleep -Seconds 60
}