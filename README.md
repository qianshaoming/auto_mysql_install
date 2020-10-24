1、ansible安装
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

yum clean all

yum makecache

yum -y install ansible

2、ansible配置
vim /etc/ansible/hosts
[webservers]
192.168.1.61
192.168.1.62
192.168.1.63

3、生成公钥
ssh-keygen
for i in {1,2,3}; do ssh-copy-id -i 192.168.1.6$i ; done

4、上传mysql安装的脚本auto_install_mysql.sh

5、拷贝这个脚本和安装文件到各个机器上
ansible webservers -m copy -a "src=/root/auto_install_mysql.sh dest=/tmp/auto_install_mysql.sh mode=0755"

6、批量执行该shell脚本
ansible webservers -m shell -a "/tmp/auto_install_mysql.sh"
