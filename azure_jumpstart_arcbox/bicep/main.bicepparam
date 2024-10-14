using 'main.bicep'

param sshRSAPublicKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrLGu9hUmoYN9bUy4lYQgNMlDtD+2vTInFXvDQQe8kL/UVDxagMHmktdLjVSWtmR3rfofRnnZlj+229Z9paJOE4xDrPDGkYiJcLMXQEOD0bMTCFBoqmKoKQwF0UtuTn/25KywVMRfm69M+0FzfvgtaKtFe6+ie4jhJxQBNhHrc9aEASITJ+VHsqI8IFZYbAB5CgD8yuOjCmxEw50YAy8uhk2/T5mgNyMoFPJRR99uQXx9/8Y38ueP+7RiNu32lrF1FgqS5ECydL+sW3a3KoHBvB5q33NO1V8YGNIe4jNgVrGhopztt8FguBh5bfli24hok4koSbuy6bJktT1oiuVkh northamerica\\jocorte@DESKTOP-TVILUHK'

param tenantId = 'dd960d1c-84f6-4f2c-b8c1-fe3608e751bc'

param windowsAdminUsername = 'arcdemo'

param windowsAdminPassword = 'R@d10H3@dP#03b3!'

param logAnalyticsWorkspaceName = 'jcortesarcboxlaw'

param flavor = 'ITPro'

param deployBastion = false

param vmAutologon = true

param resourceTags = {
  SecurityControl: 'Ignore'
} // Add tags as needed

param myIpAddress = '23.127.79.184'
