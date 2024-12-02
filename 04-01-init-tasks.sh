# Creating flex user and configure him
echo "creating user flex"
useradd -m flex
cp misc/.zshrc /home/flex
chsh -s /usr/bin/zsh flex

# Fully upgrading the system
echo "Upgrading System"
pacman -Syu

# Break point to check if everything is all right
echo "CTRL + C to abort - Enter to continue"
read -p "Continue?"

echo "installing java openjdk 17 and other related things"
pacman -S java-runtime-common java-environment-common jdk17-openjdk

# Setting it for the arch helper script
archlinux-java set java-17-openjdk
archlinux-java status
echo "archlinux-java settings set"

echo "new installed Java Version: "
java -version

# Setting up firewalld
echo "setting up firewalld"

echo "starting and enabling firewalld"
systemctl enable --now firewalld

firewall-cmd --list-all
# allowing ssh port
firewall-cmd --permanent --add-service=ssh --zone=public
# allowing smb port
firewall-cmd --permanent --add-port=445/tcp --zone=public
# allowing netbios ports
firewall-cmd --permanent --add-port=139/tcp --zone=public
firewall-cmd --permanent --add-port=137/udp --zone=public
firewall-cmd --permanent --add-port=138/udp --zone=public

# Reloading firewall
echo "ports opened - reloading firewall..."
firewall-cmd --reload

# Installing needed packages and configure them for our flex tasks
echo "installing and setuping up mosquitto"
pacman -S --noconfirm mosquitto
cat configs/mosquitto.txt > /etc/mosquitto/mosquitto.conf


echo "installing and setting up samba server"
sudo pacman -S --noconfirm samba
cat configs/samba.txt > /etc/samba/smb.conf

# User Services enablen
systemctl --user start default.target