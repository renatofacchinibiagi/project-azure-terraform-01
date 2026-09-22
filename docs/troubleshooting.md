# Solução de Problemas

## `Standard_B1s` indisponível

Escolha outra região Azure ou altere `vm_size` para um tamanho disponível na assinatura e região selecionadas. Verifique a disponibilidade antes de aplicar.

## SSH expira por tempo limite

Confirme que o endereço IPv4 público atual corresponde a `allowed_ssh_cidr`, incluindo o sufixo `/32`. Redes domésticas e móveis podem alterar endereços públicos. Confirme também que a VM está em execução e que a associação do NSG está presente.

## HTTP não responde

Aguarde alguns minutos até a conclusão do cloud-init. Conecte-se por SSH e inspecione o serviço:

```bash
sudo systemctl status nginx
sudo cloud-init status --long
```

## Terraform não consegue autenticar

Execute `az login`, selecione a assinatura pretendida com `az account set` e confirme-a com `az account show --output table`. O `subscription_id` em `terraform.tfvars` deve corresponder à assinatura de destino ativa.