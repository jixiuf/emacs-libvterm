# Build and run
# docker build -t vterm .
# docker run -t -i vterm

FROM docker.io/ubuntu:latest
RUN apt-get update --fix-missing
RUN apt-get -y install software-properties-common # install add-apt-repository command
RUN apt-get -y install apt-transport-https ca-certificates gnupg wget

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -

# http://ubuntuhandbook.org/index.php/2019/02/install-gnu-emacs-26-1-ubuntu-18-04-16-04-18-10/
RUN add-apt-repository ppa:kelleyk/emacs # for emacs26  (default emacs is not compile with module support)
RUN apt-get update

RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' # this is to install cmake > 11 on ubuntu 18.04, the latest at this time
RUN apt-get update

RUN apt-get -y install cmake make git libtool-bin

RUN apt-get -y install emacs26-nox #run emacs26
RUN mkdir -p ~/.emacs.d/

RUN echo "(require 'package)" > ~/.emacs.d/init.el
RUN echo "(add-to-list 'package-archives '(\"melpa\" . \"http://melpa.org/packages/\"))" >> ~/.emacs.d/init.el
RUN echo "(or (file-exists-p package-user-dir) (package-refresh-contents))" >> ~/.emacs.d/init.el
RUN echo "(package-initialize)" >> ~/.emacs.d/init.el
RUN echo "(package-install 'vterm)" >> ~/.emacs.d/init.el
RUN echo "(require 'vterm)" >> ~/.emacs.d/init.el