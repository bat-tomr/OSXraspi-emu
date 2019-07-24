# OSXraspi-emu

How to setup a raspi VM using QEMU on OSX. Extended from [tinjaw](https://gist.github.com/tinjaw)'s [Gist](https://gist.github.com/tinjaw/5bc5527ff379e8dd299a0b67e2bc9b62). I decided to create a Repo instead of a Gist because I am expecting to add more stuff including host/guest related scripts or other source code over time.

## Prerequisite
Have home brew installed (see https://brew.sh/)

## Setting up Raspi VM
1. Clone this repo
2. On OSX host start setup script:
```
cd OSXraspi-emu
./setupRaspiEmu.sh
```
Grab a coffee/tea/beer because this step will take a while, this script downloads and installs all the necessary bits. 

## run Raspi VM
On OSX host

```
cd qemu-rpi
./runme
```

After the start of the Raspi VM, you can log into your Raspi VM either from the OSX console you started your VM from or from the QEMU application window.

## Access Raspi VM via ssh
### Enable ssh access on Raspi VM:

On your Raspi VM:
1. Enter ``sudo raspi-config`` in a terminal window 
2. Select 'Interfacing Options' 
3. Navigate to and select 'SSH' 
4. Choose 'Yes' 
5. Select 'Ok' 
6. Choose 'Finish'

### Connect to Raspi from OSX host
To connect from the host to your Raspi VM:

```
ssh -p 5022 pi@localhost
```

The runme.sh script maps port 5022 on the host to port 22 on the Raspi VM. If you like to change it to a different port, just edit the line '-net user,hostfwd=tcp::5022-:22 -net nic' accordingly.

Remember, for a fresh Raspbian instance the default username is 
'pi' and the default password is 'raspberry'. You probably want to change that soon.

## Allow Raspi QEMU VM to access NFS share on OSX host
### setup OSX NFS server
- Add the following line to /etc/exports:
``/Users/tomr/Dev/Projects -network 127.0.0.0 -mask 255.255.240.0 -mapall=<username on OSX server>``

- /etc/nfs.conf add line
nfs.server.mount.require_resv_port = 0

- restart nfs server
sudo nfsd restart 

Notes: 
1. QEMU VMs are starting user networking by default, see also https://wiki.qemu.org/Documentation/Networking#User_Networking_.28SLIRP.29. That means host-to-guest traffic happens through the loopback interface and the host's ports need to be mapped to ports on the guest (i.e. host:5022 is mapped to guest:22 for ssh). Guest-to-host traffic goes through 10.0.2.2, so if you try to access netwerk services on the host, go through 10.0.2.2 (i.e. you would access your OSX host from your Raspi VM via ssh 10.0.2.2).

2. The Rspi VM's nfs mount request comes from an unprivileged port, which is why OSX' nfs setup (/etc/nfs.conf) needs to be modified, see also https://superuser.com/questions/183588/nfs-share-from-os-x-snow-leopard-to-ubuntu-linux.


### Mount on Raspi VM 

#### Make sure all nfs packages are installed
```sudo apt-get install nfs-common -y```

#### export your OSX folder via nfs
1. edit /etc/exports as superuser and add the following line:

```<share folder> -network 127.0.0.0 -mask 255.255.240.0 -mapall=<OSX user name>```

``<share folder>`` = Path to the folder on the OSX host you would like to share with the Raspi VM

``<OSX user name>`` = user name on your OSX server

i.e.:
/home/johndoe -network 127.0.0.0 -mask 255.255.240.0 -mapall=johndoe


2. restart nfs daemon
```sudo nfsd restart```

#### mount nfs share manually
```sudo mount -t nfs -o rw 10.0.2.2:/Users/tomr/Dev/Projects /mnt```

10.0.2.2 is the hosts IP address from your your Raspi VM.

#### mount nfs share at boot time
On the Raspi VM add following line to /etc/fstab:

```10.0.2.2:<share folder>       <mount location>    nfs     rw      0       0```

``<share folder>`` = Path to the folder on the OSX host you would like to share with the Raspi VM

``<mount location>`` = location on the Raspi VM where you would like to mount the OSX nfs share (i.e. ``/mnt``)


## Notes
Tested out with Raspbian Stretch full
