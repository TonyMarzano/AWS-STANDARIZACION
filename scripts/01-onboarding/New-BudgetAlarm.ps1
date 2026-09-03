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
    param([string[]]$Arguments)
    $output = & aws @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "aws cli falló ($($Arguments -join ' ')): $output"
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

$notificationsWithSubscribers = foreach ($threshold in $Thresholds) {
    @{
        Notification = @{
            NotificationType   = "ACTUAL"
            ComparisonOperator = "GREATER_THAN"
            Threshold          = $threshold
            ThresholdType      = "PERCENTAGE"
        }
        Subscribers = foreach ($email in $NotificationEmails) {
            @{ SubscriptionType = "EMAIL"; Address = $email }
        }
    }
}

$tempDir = Join-Path $env:TEMP ("lza-budget-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tempDir | Out-Null
$budgetFile = Join-Path $tempDir "budget.json"
$notificationsFile = Join-Path $tempDir "notifications.json"

try {
    $budget | ConvertTo-Json -Depth 5 | Set-Content -Path $budgetFile -Encoding utf8
    $notificationsWithSubscribers | ConvertTo-Json -Depth 5 | Set-Content -Path $notificationsFile -Encoding utf8

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
