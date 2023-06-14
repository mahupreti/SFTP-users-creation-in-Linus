# !/bin/bash

#command to create sftp group for all the sftp users
sudo addgroup sftp_users


#Loop to create individual user and set different permissions
for i in {1..3}
do 
    sudo adduser sftpuser$i  #creates different users as sftpuser1, sftpuser2 and so on
    sudo usermod -G sftp_users sftpuser$i #adds user to the group sftp_users ; -G represents adding user to secondary group
    sudo usermod -s /bin/false sftpuser$i  #to disable the shell access for the user
    sudo chown root:root /home/sftpuser$i #changes ownership to root 
    sudo mkdir /home/sftpuser$i/myfiles #creates myfiles directory which will be working directory in each sftp user
    sudo chown -R sftpuser$i:sftpuser$i /home/sftpuser$i/myfiles #changes ownership to respective user for security
    sudo chmod -R 755 /home/sftpuser$i/  #allows ful access to respective owner only and read and execute for group members and others
done

#search for the Subsystem sftp /usr/lib/openssh/sftp-server and replace with  Subsystem sftp internal-sftp
sudo sed -i 's/Subsystem\s\+sftp\s\+\/usr\/lib\/openssh\/sftp-server/Subsystem sftp internal-sftp/g' /etc/ssh/sshd_config


# open the /etc/ssh/sshd_config file and add the following required details
if ! pcregrep -M "Match Group sftp_users\nChrootDirectory %h\nForceCommand internal-sftp\nAllowTcpForwarding no\nMaxSessions 25\nMaxStartups 20:30:100" /etc/ssh/sshd_config > /dev/null
then 
    echo -e "Match Group sftp_users\nChrootDirectory %h\nForceCommand internal-sftp\nAllowTcpForwarding no\nMaxSessions 25\nMaxStartups 20:30:100"  >> /etc/ssh/sshd_config
fi


sudo systemctl restart sshd


#now we will have sftp users with their own home directory and secure access to sftp server