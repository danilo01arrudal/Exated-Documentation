LINUX (LIO) LVM PLUS STORAGE ON OL9.5

> *O Linux-IO Target (LIO) é uma implementação de destino SCSI (Small Computer System Interface) de código aberto incluída no kernel do Linux. 
Em termos mais simples, o LIO permite que um servidor Linux compartilhe seus dispositivos de armazenamento (como discos rígidos) com outros computadores através de uma rede.*

>    *(1) O LIO transforma um servidor Linux em um servidor de armazenamento em rede.*

>    *(2) Ele permite que esse servidor exponha dispositivos de armazenamento como "alvos" para outros computadores ("iniciadores") acessarem.*

![oracle linux iscsi logo.](https://github.com/danilo01arrudal/Exated/blob/main/SCSI/images/iSCSI.png)


> *LVM, ou Gerenciador de Volume Lógico (Logical Volume Manager), é uma ferramenta poderosa no Linux que oferece uma maneira flexível e eficiente de gerenciar dispositivos de armazenamento. Em vez de particionar discos físicos diretamente, o LVM cria uma camada de abstração que permite manipular o armazenamento de forma lógica.*

>    *Flexibilidade: Permite redimensionar volumes lógicos sem precisar reiniciar o sistema, o que é ideal para ambientes dinâmicos.*

>    *Snapshots: Permite criar snapshots de volumes lógicos, que são cópias instantâneas que podem ser usadas para backups ou testes.*

>    *Concatenação de discos: É possível combinar vários discos físicos em um único Grupo de Volumes, aumentando a capacidade de armazenamento.*

>    *Gerenciamento simplificado: Facilita o gerenciamento de grandes quantidades de armazenamento, especialmente em servidores e data centers.*

>    *Redimensionamento Online: a capacidade de aumentar ou diminuir o tamanho dos Volumes Lógicos sem a necessidade de desmontar os mesmos.*

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER


> *O targetcli é uma interface de linha de comando (CLI) para configurar o subsistema de destino Linux (LIO), que permite que um servidor Linux exponha dispositivos de armazenamento como destinos iSCSI, Fibre Channel ou outros protocolos de armazenamento em rede.*

>    *Criação de destinos iSCSI: Permite que você configure e gerencie destinos iSCSI, que são dispositivos de armazenamento em rede que podem ser acessados por outros servidores (iniciadores iSCSI) através de uma rede IP.*

>    *Gerenciamento de outros protocolos de armazenamento: Além do iSCSI, o targetcli também suporta outros protocolos de armazenamento em rede, como Fibre Channel (FC) e Fibre Channel over Ethernet (FCoE).*

>    *Configuração de LUNs (Logical Unit Numbers): Permite que você crie e gerencie LUNs, que são representações lógicas de dispositivos de armazenamento que são expostos aos iniciadores.*

>    *Controle de acesso: Permite que você configure o controle de acesso para seus destinos de armazenamento, definindo quais iniciadores podem acessar quais LUNs.*

>    *Gerenciamento de snapshots e clones: Em conjunto com outros softwares, o targetcli pode ser usado para gerenciar snapshots e clones de dispositivos de armazenamento.*
