FROM microsoft/windowsservercore
#FROM matthodge/hubotwindows:0.3
ADD install.ps1 /Windows/Temp/install.ps1
RUN powershell -executionpolicy bypass C:\Windows\Temp\install.ps1

# will only copy the package if its different
COPY hubotpackage/package.json /tmp/package.json
RUN cd /tmp && npm install && npm install -g pm2

# run npm install and move ot to C:\myhubot
RUN powershell -Command \
  $ErrorActionPreference = 'Stop'; \
  New-Item -Type 'Directory' -Path '\myhubot' -Force ; \
  New-Item -Type 'Directory' -Path '\logs' -Force ; \
  Move-Item -Path '\tmp\node_modules' -Destination '\myhubot' -Force

# copy the extracted windows hubot to C:\myhubot
COPY hubotpackage /myhubot
COPY processes.json /myhubot/processes.json

# pm2 needs a home path
ENV HUBOT_ADAPTER='slack' HUBOT_LOG_LEVEL='debug' HOME="C:\\Users\\ContainerAdministrator"

WORKDIR /myhubot

CMD [ "C:\\Users\\ContainerAdministrator\\AppData\\Roaming\\npm\\pm2.cmd", "start", "processes.json", "--no-daemon" ]
#CMD [ "node", ".\\node_modules\\coffee-script\\bin\\coffee", ".\\node_modules\\hubot\\bin\\hubot" ]
