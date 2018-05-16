# How to use the GUI with Docker.

## docker build Dockerfile
Dockerfile:[./Dockerfile](./Dockerfile)
```
sudo su
docker build -t xterm .
```

## Xauthority settings
* PC login user
```
touch $HOME/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $HOME/.docker.xauth nmerge -
```
* PC root user
```
sudo su
touch $HOME/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $HOME/.docker.xauth nmerge -
```
The point of Xauthority is owner of the .docker.xauth file.<br>
Use **the same uid and gid** between PC(Host Linux OS) and Docker(Ubuntu OS).<br>
To say command:<br>
>chown $(getent passwd 1000 | cut -d: -f1):$(getent group 1000 | cut -d: -f1) $HOME/.docker.xauth  

And, Dockerfile creates new user with uid:1000 and gid:1000.<br>
>########################################  
># Add new sudo user  
>########################################  
>ENV USERNAME ubuntu  
>RUN useradd -m $USERNAME && \  
>        echo "$USERNAME:$USERNAME" | chpasswd && \  
>        usermod --shell /bin/bash $USERNAME && \  
>        usermod -aG sudo $USERNAME && \  
>        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \  
>        chmod 0440 /etc/sudoers.d/$USERNAME && \  
>        # Replace 1000 with your user/group id  
>        usermod  --uid 1000 $USERNAME && \  
>        groupmod --gid 1000 $USERNAME  

There is no problem even if the user or group **name** are different between PC and Docker.  

## docker run
```
sudo su
docker run -it -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v /home/$(getent passwd 1000 | cut -d: -f1)/.docker.xauth:/home/ubuntu/.docker.xauth:rw -v /root/.docker.xauth:/root/.docker.xauth:rw -e "DISPLAY" --user ubuntu xterm
```
If you only use xterm, root user's Xauthority is not required.<br>
However, it is necessary when using GUI application with sudo such as firefox.<br>

## Firefox with Japanese fonts
example:
```
sudo apt-get install -y libcanberra-gtk3-module dbus-x11 firefox-locale-ja fonts-takao firefox
```
