ME_USER=$USER

sudo mkdir -p /media/$ME_USER
sudo chown -R $ME_USER /media/$ME_USER
sudo chgrp -R $ME_USER /media/$ME_USER

ln -s /media/$ME_USER /home/$ME_USER/Files
