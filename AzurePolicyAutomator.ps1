###AzurePolicyAutomator
## Repo: github.com/msdirtbag/AzurePolicyAutomator

# Get all subscriptions in the tenant
$Subscriptions = Get-AzSubscription

# Loop over each subscription
foreach ($sub in $Subscriptions) { 
    # Set the context to the current subscription
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext

    # Get all policy assignments for the current subscription
    # The scope is set to the current subscription
    $PolicyAssignments = Get-AzPolicyAssignment -Scope "/subscriptions/$($sub.Id)"

    # Filter the policy assignments to only include those that have a System Managed or User Managed Identity
    # The Where-Object cmdlet is used to filter the policy assignments
    # The $_.Identity -ne $null condition checks if the Identity property of the policy assignment is not null
    $PolicyAssignmentsWithIdentity = $PolicyAssignments | Where-Object { $_.Identity -ne $null }

    # Loop over each policy assignment with an identity
    foreach ($Assignment in $PolicyAssignmentsWithIdentity) {
        # Start the remediation for the policy assignment
        # The -Name parameter is set to the name of the policy assignment
        # The -PolicyAssignmentId parameter is set to the ID of the policy assignment
        # The -ResourceCount parameter is set to 10000, which is the maximum number of resources to remediate in parallel
        # The -ParallelDeploymentCount parameter is set to 30, which is the maximum number of deployments to create in parallel
        # The -ResourceDiscoveryMode parameter is set to ReEvaluateCompliance, which means that the policy compliance state will be re-evaluated before the remediation task is created
        # The -AsJob parameter runs the cmdlet as a background job
        Start-AzPolicyRemediation -Name $Assignment.Name -PolicyAssignmentId $Assignment.PolicyAssignmentId -ResourceCount 10000 -ParallelDeploymentCount 30 -ResourceDiscoveryMode ReEvaluateCompliance -AsJob 
    }
}

# Output a message indicating that all remediation tasks have been started
Write-Output "All DeployIfNotExists Azure Policy Remediation Tasks have been started"

# End of script