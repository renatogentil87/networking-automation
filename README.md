# Network CI/CD Pipeline

Automated BGP configuration deployment using AWS CodePipeline.

## Topology
- R1 (CE) - AS 65001 -> R2 (PE) - AS 65100
- R3 (CE) - AS 65003 -> R4 (PE) - AS 65100
- R4 (CE) - AS 65100 -> R2 (PE) - AS 65100

## Workflow
1. Edit router YAML files locally
2. Push to GitHub
3. CodePipeline triggers automatically
4. CodeBuild validates configurations
5. Manual approval
6. CodeDeploy deploys to EC2
