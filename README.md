# Laboratório de Infraestrutura Azure com Terraform

Infraestrutura Azure baseada em Terraform para uma pequena carga de trabalho web com Nginx. O laboratório provisiona uma ou mais máquinas virtuais Linux Ubuntu com endereços IP públicos e disponibiliza uma página estática de portfólio por HTTP.

## Arquitetura

```text
Internet
	|
	+-- HTTP/80 ------------------------------------> VM(s) web com Nginx
	|
	+-- SSH/22 somente de allowed_ssh_cidr ---------> VM(s) web com Nginx

Grupo de Recursos do Azure
	+-- Rede Virtual: 10.10.0.0/16
			+-- Subnet web: 10.10.1.0/24
					+-- Grupo de Segurança de Rede
					+-- Interface(s) de rede
					+-- Endereço(s) IP público(s) Standard estático(s)
					+-- Máquina(s) virtual(is) Ubuntu 22.04 LTS
```

## Recursos Criados pelo Terraform

- Um Grupo de Recursos dedicado no Azure.
- Uma rede virtual com espaço de endereçamento `10.10.0.0/16`.
- Uma subnet web com prefixo de endereço `10.10.1.0/24`.
- Um Network Security Group (NSG) associado à subnet.
- Uma regra de entrada HTTP permitindo TCP na porta `80` a partir da Internet.
- Uma regra de entrada SSH permitindo TCP na porta `22` somente de `allowed_ssh_cidr`.
- Um IP público Standard estático e uma interface de rede para cada VM.
- Máquinas virtuais Ubuntu 22.04 LTS usando apenas autenticação SSH por chave pública.
- Nginx instalado e configurado por cloud-init.
- Uma página estática exibindo `Projeto Azure Terraform 01`.

O NSG mantém a regra padrão `DenyAllInBound` do Azure. Portanto, todo tráfego de entrada diferente das regras explícitas de HTTP e SSH restrito é negado.

## Estrutura do Repositório

```text
.
|-- app/index.html
|-- cloud-init/cloud-init.yaml.tftpl
|-- compute.tf
|-- main.tf
|-- network.tf
|-- outputs.tf
|-- providers.tf
|-- variables.tf
|-- versions.tf
|-- terraform.tfvars.example
`-- docs/
		|-- architecture.md
		`-- troubleshooting.md
```

## Pré-requisitos

- Terraform `1.8.0` ou posterior.
- Azure CLI autenticada em uma assinatura em que você possua, no mínimo, o papel `Contributor`.
- Um cliente SSH e um par de chaves SSH ED25519.
- Cota e capacidade Azure para o tamanho e a região de VM selecionados.

Autentique-se e confirme a assinatura ativa:

```powershell
az login
az account show --output table
```

Se necessário, selecione a assinatura de destino:

```powershell
az account set --subscription "<subscription-id-or-name>"
```

Crie um par de chaves SSH se ainda não possuir um. Mantenha a chave privada fora deste repositório.

```powershell
ssh-keygen -t ed25519 -f "$HOME\.ssh\id_ed25519" -C "azure-terraform-01"
```

## Configurar Variáveis

Copie o arquivo de exemplo e informe seus valores:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Defina `subscription_id`, o caminho para sua chave pública e seu CIDR IPv4 público atual. Para descobrir seu endereço IPv4 público:

```powershell
(Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
```

Use esse resultado como `x.x.x.x/32` em `allowed_ssh_cidr`. Não use `0.0.0.0/0`; o Terraform rejeita esse valor para a variável.

## Implantação

Este repositório usa state local por padrão, adequado para um laboratório pessoal. Inicialize e valide antes de revisar o plano:

```powershell
terraform init
terraform fmt -check
terraform validate
terraform plan -out plan.out
```

Revise o plano cuidadosamente, incluindo a região, quantidade e tamanho das VMs, quantidade de IPs públicos e o CIDR de origem do SSH. Provisione somente após revisá-lo:

```powershell
terraform apply plan.out
```

## Validar a Implantação

Obtenha os endpoints gerados:

```powershell
terraform output
```

Teste HTTP com a primeira URL de `application_urls`:

```powershell
Invoke-WebRequest -Uri "http://<public-ip>" -UseBasicParsing
```

Teste SSH somente a partir do endereço IPv4 incluído em `allowed_ssh_cidr`:

```powershell
ssh -i "$HOME\.ssh\id_ed25519" azureuser@<public-ip>
```

## Considerações de Segurança

- Nenhuma senha de administrador é configurada; a VM aceita apenas autenticação SSH por chave pública.
- O SSH é limitado a um CIDR IPv4 explicitamente informado.
- HTTP é público por definição; HTTPS não está configurado neste laboratório introdutório.
- State do Terraform, arquivos `.tfvars`, planos salvos e formatos de chave privada são excluídos por `.gitignore`.
- Não insira segredos em variáveis Terraform, `terraform.tfvars` ou cloud-init. Dados do cloud-init podem ser registrados no state do Terraform e nos metadados de implantação Azure.
- Versione `.terraform.lock.hcl` após `terraform init`; ele registra a seleção de providers revisada.

## Custos e Limitações

Este laboratório pode gerar cobranças pela máquina virtual, disco de SO gerenciado, IP público Standard, saída de rede e qualquer configuração opcional de monitoramento. `Standard_B1s`, um disco de SO `Standard_LRS` de 30 GiB e uma VM foram escolhidos para reduzir custos, mas não são gratuitos.

Consulte os preços atuais para a região selecionada na [Calculadora de Preços do Azure](https://azure.microsoft.com/pricing/calculator/) e confirme a disponibilidade de `Standard_B1s` antes da implantação. A configuração não cria um workspace Log Analytics nem o Azure Monitor Agent. Métricas de plataforma Azure podem ficar disponíveis para a VM no portal; logs de convidado e monitoramento avançado exigem configuração adicional e podem gerar custos.

## Destruir o Laboratório

Quando o laboratório não for mais necessário, remova os recursos gerenciados e confirme o plano:

```powershell
terraform destroy
```

O Terraform gerencia todos os recursos deste repositório, portanto não deve ser necessário remover recursos Azure separadamente. Revise o plano de destruição antes de confirmá-lo.


