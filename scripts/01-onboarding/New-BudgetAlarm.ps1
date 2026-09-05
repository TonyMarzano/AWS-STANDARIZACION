<#
.SYNOPSIS
    Crea un AWS Budget mensual con alarmas por umbral (Etapa 1 - Onboarding).

.DESCRIPTION
    Envuelve `aws budgets create-budget` para dejar un budget mensual con
    notificaciones ACTUAL a uno o más umbrales de porcentaje, enviadas por email.

.PARAMETER Profile
    Profile de AWS CLI apuntando a la cuenta management del cliente.

.PARAMETER MonthlyLimitUSD
    Límite mensual del budget, en USD.

.PARAMETER NotificationEmails
    Uno o más emails que reciben la alerta.

.PARAMETER Thresholds
    Uno o más porcentajes (del límite) en los que se dispara la alerta. Ej: 50,80,100

.PARAMETER BudgetName
    Nombre del budget. Default: "monthly-total-budget".

.EXAMPLE
    ./New-BudgetAlarm.ps1 -Profile cliente-mgmt -MonthlyLimitUSD 1000 `
        -NotificationEmails "cloudops@bghtechpartner.com","cliente@dominio.com" `
        -Thresholds 50,80,100
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$Profile,

    [Parameter(Mandatory = $true)]
    [double]$MonthlyLimitUSD,

    [Parameter(Mandatory = $true)]
    [string[]]$NotificationEmails,

    [Parameter(Mandatory = $true)]
    [int[]]$Thresholds,

    [string]$BudgetName = "monthly-total-budget"
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

Write-Host "Resolviendo Account ID para el profile '$Profile'..."
$accountId = (Invoke-AwsCli -Arguments @("sts", "get-caller-identity", "--profile", $Profile, "--query", "Account", "--output", "text")).Trim()
Write-Host "Account ID: $accountId"

$budget = @{
    BudgetName  = $BudgetName
    BudgetLimit = @{
        Amount = "$MonthlyLimitUSD"
        Unit   = "USD"
    }
    TimeUnit   = "MONTHLY"
    BudgetType = "COST"
}

$notificationsWithSubscribers = @(foreach ($threshold in $Thresholds) {
    @{
        Notification = @{
            NotificationType   = "ACTUAL"
            ComparisonOperator = "GREATER_THAN"
            Threshold          = $threshold
            ThresholdType      = "PERCENTAGE"
        }
        # @(...) fuerza array: con un solo email, "foreach" sin envolver colapsa
        # el resultado a un objeto suelto en vez de una lista de un elemento.
        Subscribers = @(foreach ($email in $NotificationEmails) {
            @{ SubscriptionType = "EMAIL"; Address = $email }
        })
    }
})

$tempDir = Join-Path $env:TEMP ("lza-budget-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tempDir | Out-Null
$budgetFile = Join-Path $tempDir "budget.json"
$notificationsFile = Join-Path $tempDir "notifications.json"

try {
    # Set-Content -Encoding utf8 escribe BOM en Windows PowerShell 5.1, y el parser
    # JSON de aws.exe lo rechaza. Escribimos UTF-8 sin BOM con .NET directamente.
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($budgetFile, ($budget | ConvertTo-Json -Depth 5), $utf8NoBom)
    [System.IO.File]::WriteAllText($notificationsFile, ($notificationsWithSubscribers | ConvertTo-Json -Depth 5), $utf8NoBom)

    if ($PSCmdlet.ShouldProcess("$BudgetName (cuenta $accountId)", "Crear AWS Budget de $MonthlyLimitUSD USD/mes")) {
        Write-Host "Creando budget '$BudgetName' por $MonthlyLimitUSD USD/mes con umbrales $($Thresholds -join ', ')%..."
        Invoke-AwsCli -Arguments @(
            "budgets", "create-budget",
            "--account-id", $accountId,
            "--profile", $Profile,
            "--budget", "file://$budgetFile",
            "--notifications-with-subscribers", "file://$notificationsFile"
        ) | Out-Null
        Write-Host "Budget creado. Verificar en: Billing and Cost Management > Budgets."
    }
}
finally {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
