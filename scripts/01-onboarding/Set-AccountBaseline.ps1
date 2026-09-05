<#
.SYNOPSIS
    Aplica baseline mínimo de seguridad a nivel cuenta (Etapa 1 - Onboarding).

.DESCRIPTION
    Aplica sobre la cuenta indicada por -Profile:
      - IAM account password policy (mínimos de complejidad y rotación).
      - S3 Block Public Access a nivel cuenta.
    Es defensa en profundidad previa a LZA (que reforzará esto a nivel Organization en la Etapa 2).

.PARAMETER Profile
    Profile de AWS CLI apuntando a la cuenta a asegurar.

.PARAMETER MinimumPasswordLength
    Longitud mínima de password IAM. Default: 14.

.PARAMETER MaxPasswordAgeDays
    Días máximos antes de forzar rotación. Default: 90.

.EXAMPLE
    ./Set-AccountBaseline.ps1 -Profile cliente-mgmt
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$Profile,

    [int]$MinimumPasswordLength = 14,

    [int]$MaxPasswordAgeDays = 90
)

$ErrorActionPreference = "Stop"

function Invoke-AwsCli {
    # No redirigir stderr (2>&1): en Windows PowerShell 5.1 eso envuelve cualquier
    # línea de stderr en un NativeCommandError y aborta el script aunque aws.exe
    # haya salido con código 0. Dejamos que stderr se imprima solo a la consola.
    param([string[]]$Arguments)
    $output = & aws @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "aws cli falló ($($Arguments -join ' ')) con exit code $LASTEXITCODE"
    }
    return $output
}

if ($PSCmdlet.ShouldProcess("Cuenta del profile '$Profile'", "Aplicar IAM password policy")) {
    Write-Host "Aplicando IAM account password policy..."
    Invoke-AwsCli -Arguments @(
        "iam", "update-account-password-policy",
        "--profile", $Profile,
        "--minimum-password-length", $MinimumPasswordLength,
        "--require-symbols",
        "--require-numbers",
        "--require-uppercase-characters",
        "--require-lowercase-characters",
        "--max-password-age", $MaxPasswordAgeDays,
        "--password-reuse-prevention", "24",
        "--allow-users-to-change-password"
    ) | Out-Null
    Write-Host "Password policy aplicada (min length: $MinimumPasswordLength, max age: $MaxPasswordAgeDays días)."
}

if ($PSCmdlet.ShouldProcess("Cuenta del profile '$Profile'", "Habilitar S3 Block Public Access a nivel cuenta")) {
    Write-Host "Resolviendo Account ID..."
    $accountId = (Invoke-AwsCli -Arguments @("sts", "get-caller-identity", "--profile", $Profile, "--query", "Account", "--output", "text")).Trim()

    Write-Host "Habilitando S3 Block Public Access a nivel cuenta ($accountId)..."
    Invoke-AwsCli -Arguments @(
        "s3control", "put-public-access-block",
        "--profile", $Profile,
        "--account-id", $accountId,
        "--public-access-block-configuration", "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    ) | Out-Null
    Write-Host "S3 Block Public Access habilitado a nivel cuenta."
}

Write-Host "Baseline de cuenta aplicado. Registrar en 02-baseline-checklist.md del repo del cliente."
