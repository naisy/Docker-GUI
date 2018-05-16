########################################
# Docker build
########################################
# time docker build -t xterm .


########################################
# Docker run
########################################
# PC login user
# touch $HOME/.docker.xauth
# xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $HOME/.docker.xauth nmerge -
# PC root user
# sudo su
# touch $HOME/.docker.xauth
# xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $HOME/.docker.xauth nmerge -
# getent passwd 1000
# getent group 1000
# 前提としてdockerで作るユーザはPCのGUIログインユーザIDと同じにする。
# GUIを持つPCのログインユーザ(ubuntu)はuid:1000, gid:1000なので、docker内でもその権限で書き込みが出来るように$HOME/.docker.xauthのオーナー権限を変更する。
# chown $(getent passwd 1000 | cut -d: -f1):$(getent group 1000 | cut -d: -f1) $HOME/.docker.xauth
# sudo su
# docker run -it -v /tmp/.X11-unix -v /home/ubuntu/.docker.xauth:/home/$(getent passwd 1000 | cut -d: -f1)/.docker.xauth -v /root/.docker.xauth -e DISPLAY=$DISPLAY --user ubuntu xterm


########################################
# Underlying OS repogitory
########################################
FROM ubuntu


########################################
# Maintainer Info
########################################
MAINTAINER Yoshiroh Takanashi <takanashi@gclue.jp>


########################################
# LABEL
########################################
LABEL Description="xterm" Version="1.0"


########################################
# Dcker build settings
########################################
ARG DEBIAN_FRONTEND=noninteractive


########################################
# Packages
########################################
RUN apt-get update && apt-get install -y sudo xauth xterm


########################################
# Add new sudo user
########################################
ENV USERNAME ubuntu
RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        # Replace 1000 with your user/group id
        usermod  --uid 1000 $USERNAME && \
        groupmod --gid 1000 $USERNAME


########################################
# .bashrc
########################################
# sed
# escape characters \'$.*/[]^
# 1. Write the regex between single quotes.
# 2. \ -> \\
# 3. ' -> '\''
# 4. Put a backslash before $.*/[]^ and only those characters.

# for user
# before
# #force_color_prompt=yes
# after
# force_color_prompt=yes
# before
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# after
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\[\033[01;37m\]\h\[\033[00m\]:\[\033[01;35m\]\w\[\033[00m\]\$ '
# before
# alias ls='ls --color=auto'
# after
# alias ls='ls -asiF --color=auto'

RUN sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/$USERNAME/.bashrc \
&& sed -i 's/PS1='\''\${debian_chroot:+(\$debian_chroot)}\\\[\\033\[01;32m\\\]\\u@\\h\\\[\\033\[00m\\\]:\\\[\\033\[01;34m\\\]\\w\\\[\\033\[00m\\\]\\\$ '\''/PS1='\''\${debian_chroot:+(\$debian_chroot)}\\\[\\033\[01;32m\\\]\\u@\\\[\\033\[01;37m\\\]\\h\\\[\\033\[00m\\\]:\\\[\\033\[01;35m\\\]\\w\\\[\\033\[00m\\\]\\\$ '\''/g' /home/$USERNAME/.bashrc \
&& sed -i 's/alias ls='\''ls --color=auto'\''/alias ls='\''ls -asiF --color=auto'\''/g' /home/$USERNAME/.bashrc
RUN echo 'alias xterm='"'"'xterm -fa '"'"'Monospace'"'"' -fs 10'"'"'\n' >> /home/$USERNAME/.bashrc
RUN echo 'export XAUTHORITY=$HOME/.docker.xauth' >> /home/$USERNAME/.bashrc

# for root
# before
#    xterm-color) color_prompt=yes;;
# after
#    xterm-color|*-256color) color_prompt=yes;;
# before
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# after
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;37m\]\u@\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;35m\]\w\[\033[00m\]\$ '

RUN sed -i 's/xterm-color) color_prompt=yes;;/xterm-color|\*-256color) color_prompt=yes;;/g' /root/.bashrc \
&& sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc \
&& sed -i 's/PS1='\''\${debian_chroot:+(\$debian_chroot)}\\\[\\033\[01;32m\\\]\\u@\\h\\\[\\033\[00m\\\]:\\\[\\033\[01;34m\\\]\\w\\\[\\033\[00m\\\]\\\$ '\''/PS1='\''\${debian_chroot:+(\$debian_chroot)}\\\[\\033\[01;37m\\\]\\u@\\\[\\033\[01;32m\\\]\\h\\\[\\033\[00m\\\]:\\\[\\033\[01;35m\\\]\\w\\\[\\033\[00m\\\]\\\$ '\''/g' /root/.bashrc \
&& sed -i 's/alias ls='\''ls --color=auto'\''/alias ls='\''ls -asiF --color=auto'\''/g' /root/.bashrc
RUN echo 'alias xterm='"'"'xterm -fa '"'"'Monospace'"'"' -fs 10'"'"'\n' >> /root/.bashrc
RUN echo 'export XAUTHORITY=$HOME/.docker.xauth' >> /root/.bashrc


#########################################
# .dircolors
########################################
COPY dircolors.txt /root/.dircolors
COPY dircolors.txt /home/$USERNAME/.dircolors
RUN chown $USERNAME:$USERNAME /home/$USERNAME/.dircolors


########################################
# Other packages
########################################
RUN apt-get install -y htop vim locate


########################################
# Default launcher
########################################
CMD bash -c "/usr/bin/xterm -fa 'Monospace' -fs 10"
