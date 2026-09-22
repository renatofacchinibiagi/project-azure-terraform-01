# Arquitetura

O laboratório usa um único Grupo de Recursos Azure para conter todos os recursos. Uma VNet com espaço de endereçamento `10.10.0.0/16` contém a subnet web `10.10.1.0/24`. O NSG é associado à subnet, de modo que cada NIC de VM nela recebe a mesma política de entrada.

Cada VM possui uma NIC com endereço IP privado dinâmico e um IP público Standard estático dedicado. O NSG permite tráfego da Internet para TCP `80` e permite TCP `22` apenas a partir do CIDR IPv4 público configurado. A regra padrão de negação de entrada do Azure trata todas as outras conexões de entrada.

A VM usa Ubuntu 22.04 LTS, uma chave pública SSH, um disco de SO gerenciado Standard_LRS e cloud-init. O cloud-init instala o Nginx, grava a página HTML estática e inicia o serviço.