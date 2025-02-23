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

###### INSTALL LVM2

    [root@exated ~]# yum install -y lvm2

###### CONFIGURE DEVICES

    [root@exated ~]# fdisk -l    
    Disco /dev/nvme1n1: 931,51 GiB, 1000204886016 bytes, 1953525168 setores
    Modelo de disco: KINGSTON SA2000M81000G                  
    Unidades: setor de 1 * 512 = 512 bytes
    Tamanho de setor (lógico/físico): 512 bytes / 512 bytes
    Tamanho E/S (mínimo/ótimo): 512 bytes / 512 bytes
    Tipo de rótulo do disco: gpt
    Identificador do disco: E1A6E5FF-EF06-4B50-B3EF-7B192F6A3ADE

    Disco /dev/nvme0n1: 931,51 GiB, 1000204886016 bytes, 1953525168 setores
    Modelo de disco: KINGSTON SA2000M81000G                  
    Unidades: setor de 1 * 512 = 512 bytes
    Tamanho de setor (lógico/físico): 512 bytes / 512 bytes
    Tamanho E/S (mínimo/ótimo): 512 bytes / 512 bytes
    Tipo de rótulo do disco: gpt
    Identificador do disco: 0DED2B1E-DF36-45EB-B5AA-1DB6D15C9B3E

    [root@exated ~]# fdisk /dev/nvme0n1
    n > p > 1 > w
    [root@exated ~]# fdisk /dev/nvme1n1
    n > p > 1 > w

###### CONFIGURE LVM 

    [root@exated ~]# pvcreate /dev/nvme0n1p1
    [root@exated ~]# pvcreate /dev/nvme1n1p1
    [root@exated ~]# vgcreate vg_lun_storage /dev/nvme0n1p1 /dev/nvme1n1p1 
    [root@exated ~]# lvcreate -n lv_lun_storage_l0 -L 20G vg_lun_storage
    [root@exated ~]# lvcreate -n lv_lun_storage_l1 -L 20G vg_lun_storage
    [root@exated ~]# lvcreate -n lv_lun_storage_l2 -L 20G vg_lun_storage
    [root@exated ~]# lvcreate -n lv_lun_storage_l3 -L 20G vg_lun_storage
    [root@exated ~]# lvcreate -n lv_lun_storage_l4 -L 20G vg_lun_storage  
    [root@exated ~]# lvs
    LV                VG             Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert                                                  
    lv_lun_storage_l0 vg_lun_storage -wi-a----- 20,00g                                                    
    lv_lun_storage_l1 vg_lun_storage -wi-a----- 20,00g                                                    
    lv_lun_storage_l2 vg_lun_storage -wi-a----- 20,00g                                                    
    lv_lun_storage_l3 vg_lun_storage -wi-a----- 20,00g                                                    
    lv_lun_storage_l4 vg_lun_storage -wi-a----- 20,00g


> *O targetcli é uma interface de linha de comando (CLI) para configurar o subsistema de destino Linux (LIO), que permite que um servidor Linux exponha dispositivos de armazenamento como destinos iSCSI, Fibre Channel ou outros protocolos de armazenamento em rede.*

>    *Criação de destinos iSCSI: Permite que você configure e gerencie destinos iSCSI, que são dispositivos de armazenamento em rede que podem ser acessados por outros servidores (iniciadores iSCSI) através de uma rede IP.*

>    *Gerenciamento de outros protocolos de armazenamento: Além do iSCSI, o targetcli também suporta outros protocolos de armazenamento em rede, como Fibre Channel (FC) e Fibre Channel over Ethernet (FCoE).*

>    *Configuração de LUNs (Logical Unit Numbers): Permite que você crie e gerencie LUNs, que são representações lógicas de dispositivos de armazenamento que são expostos aos iniciadores.*

>    *Controle de acesso: Permite que você configure o controle de acesso para seus destinos de armazenamento, definindo quais iniciadores podem acessar quais LUNs.*

>    *Gerenciamento de snapshots e clones: Em conjunto com outros softwares, o targetcli pode ser usado para gerenciar snapshots e clones de dispositivos de armazenamento.*

###### INSTALL AND CONFIGURE TARGETCLI


