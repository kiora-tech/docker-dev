Installation
===========

make install
    
Utilisation
===========


edit the file `.env`
--------------------
|DOCKER_VOLUME_PATH|project path|
|DOCKER_VOLUME_CONFIG|ssh path|
|GIT_NAME|Your git name|
|GIT_EMAIL|Your git email|
|GIT_HOST|Your git host|
|GIT_IP|Your git IP|



edit the file `repos`
--------------------
The file must contain the list of your repot
It is for use  `make install-project`, this command clone the project and run `make install` on the projet



run `make watch`
