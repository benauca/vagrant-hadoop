# Curso De hadoop
===


## Comprobar Que Hadoop funciona
---
Partimos de una instalación de un nodo de hadoop. Una vez realizado esto, vamos a ejecutar haddop en modo Standalone.
Vamos a ejecutar un proceso mapreduce. proceso que permite ejecuart multiples hilos de un proceso. Para ello ejecutaremos dentro de la carpeta de ejemplos /opt/hadoop/share/hadoop/mapreduce/*-examples

vi /etc/host

* Incluinos la ip de la máquina en el fichero /etc/hosts [ debieramos automatizarlo en la propia creación del nodo]
* jar tf *.jar mostrará el contenido del fichero con las clases contenidas
* Vamos a usar la clase Grep.class para ejecutar con el map reduce
* Creamos mkdir /tmp/entrada
* cp /opt/hadoop/etc/hadoop/*.xml /tmp/entrada
* hadoop jar /opt/hadoop-2.7.6/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.6.jar grep /tmp/entrada/ /tmp/salida 'kms[a-z.]+'

```
	[vagrant@localhost ~]$ cat /tmp/salida/part-r-00000
	9       kms.acl.
	2       kms.keytab
	1       kms.keystore
	1       kms.key.provider.uri
	1       kms.current.key.cache.timeout.ms
	1       kms.cache.timeout.ms
	1       kms.cache.enable
	1       kms.authentication.type
	1       kms.authentication.signer.secret.provider.zookeeper.path
	1       kms.keystore.password
	1       kms.authentication.signer.secret.provider.zookeeper.kerberos.keytab
	1       kms.authentication.signer.secret.provider.zookeeper.connection.string
	1       kms.authentication.signer.secret.provider.zookeeper.auth.type
	1       kms.authentication.signer.secret.provider
	1       kms.authentication.kerberos.principal
	1       kms.authentication.kerberos.name.rules
	1       kms.authentication.kerberos.keytab
	1       kms.audit.aggregation.window.ms
	1       kms.authentication.signer.secret.provider.zookeeper.kerberos.principal
```

Configurar SSH (Secure Shell)
---


Antes de poner en práctica nuestro cluster de hadoop, necesitaremos configurar nuestro componente SSH. es la manera en la que las máquinas linux pueden contectarse de modo seguro, y lanzarse peticiones. Los comandos ssh es la manera en la que el servidor maestro es capaz de mandar comandos a los esclavos, que a su vez estos deberán estar conectados entre sí.

1.- Crear claves publicas y privadas. Ya las estamos creando desde vagrant
	```
	ssh-keygen 

	Genera id_rsa => Clave privada
	Genera id_rsa.pub => Clave Pública. Hay que pasar dichas claves para que se conozca....
	```
Una vez generada, lo que tenemos que asociarla es al almacen de claves publicas. De tal manera que ese fichero o almacen tendrá todas las claves publicas de los distintos nodos para que estos se puedan comunicar entre sí.

	````
	cd /home/vagrant/.ssh
	cp id_rsa.pub authorized_keys
	````
Hay manera más fáciles para definir eso (estudiar)

Aunque sólo haya u node, es necesario definirlos por que hadoop por derfecto va a intentar ejecutar comandos ssh

```
[vagrant@localhost ~]$ ssh nodo1
Warning: Permanently added 'nodo1,10.0.2.15' (ECDSA) to the list of known hosts.
Last login: Tue Apr 30 14:35:31 2019 from 10.0.2.2
[vagrant@localhost ~]$ pwd
/home/vagrant
[vagrant@localhost ~]$
```
Me permite conectarme a una máquina sin necesidad de tener que pasar la contraseña.....


# HDFS

HDFS es la capa de almacenamiento de hadoop. En ppo es un sistema de ficheros, es un sistema de almacenamiento en donce vamos a poder copiar todos los ficheros que queremos subir a hadoop.
Es un sistema tolerante a fallo que puede almacenar gran cantidad de ficheros, y sobrevivir a fallos de hardware sin perder fallos.



HDFS divide el archivo que queremos subir en partes y los sube (copia) a los distintos nodos. El tamaño del bloque es de 128Mb.
Por defecto lo intenta replicar en tres nodos distintos.  Puedo tener más de tres copias, pero las buenas practicas indican que no a mejorar el rendimiento, pero reducirá el número de bloques que vamos a poder almacenar en el cluster.

HDFS bien configurado es RAC <-------

Al crear un cluster hadoop hay:

- Un nodo que actúa como maestro de datos. Sólo contiene metadatos. el maestro gestiona toda la información que se escribe y se gestiona en el cluster.
- El resto de nodos son esclavos, Contiene los datos propiamente dichos.

Cluster PSeudodistribuido
---
Vamos a crear un cluster en que el mismo nodo será maestro y esclavo. Por eso el nombre de Pseudodistribuido

Para ello nos centraremos en los ficheros de configuración /etc/hadoop/*.xml de configuración-
NAMENODE => Nodo Maestro: Nodo1:9000
````
	<configuration>
		<property>
			<!-- Nos dice que sistema de ficheros vamos a usar con hadoop-->
			<name>fs.defaultFS</name>
			<!-- Puerto y el sistema de ficheros -->
			<value>hdfs://nodo1:9000</value>
		</property>
	</configuration>
````

Configuramos HDFS
/hdfs-site.xml
````
	<!-- Put site-specific property overrides in this file. -->
	<configuration>
		<property>
			<!-- Número de nodos en los que vamos a replicar. 1 = No replicar -->
			<name>dfs.replication</name>
			<value>1</value>
		</property>
		<property>
			<!-- Dónde se encuentra la información del maestro donde vamos a tener los metadatos.-->
			<name>dfs.namenode.name.dir</name>
			<value>/datos/namenode</value>
		</property>
		<property>
			<!-- En cada esclavo, donde se guardan los datos. Cuando tengamos un cluster con nodos maestro ey esclavos. En el maestro sólo tendremos
	el directorio anterior, y en los esclavos el siguiente -->
			<name>dfs.datanode.data.dir</name>
			<value>/datos/datanode</value>
		</property>
	</configuration>
```` 

Creamos los directorios
	```
	sudo mkdir /datos/namenode
	sudo mkdir /datos/datanode
	sudo chown -R vagrant:vagrant datos
	```

Antes de crear cualqueir operacion con hadoop, deberemos montar el sistema de ficheros hdfs

	```` Crea los metadatos del master
	hadoop namenode -format
	```` 

	```
	[vagrant@localhost namenode]$ pwd
	/datos/namenode
	[vagrant@localhost namenode]$ ls -l
	total 0
	drwxrwxr-x. 2 vagrant vagrant 112 Apr 30 15:35 current
	[vagrant@localhost namenode]$
	````

Arrancar HDFS
---
Para arrancar el sistema de ficheros invocamos el script
	```
	/opt/hadoop-2.x.x/sbin/start-dfs.sh
	```
HDFS se encargará de lanzar. Antes de ello hay que marcar como `sudo chown -R vagrant:vagrant datos`

	````
	[vagrant@nodo1 sbin]$ ./start-dfs.sh
	Starting namenodes on [nodo1]
	nodo1: Warning: Permanently added 'nodo1,10.0.2.15' (ECDSA) to the list of known hosts.
	nodo1: starting namenode, logging to /opt/hadoop-2.7.6/logs/hadoop-vagrant-namenode-nodo1.out
	localhost: Warning: Permanently added 'localhost' (ECDSA) to the list of known hosts.
	localhost: starting datanode, logging to /opt/hadoop-2.7.6/logs/hadoop-vagrant-datanode-nodo1.out
	Starting secondary namenodes [0.0.0.0]
	0.0.0.0: Warning: Permanently added '0.0.0.0' (ECDSA) to the list of known hosts.
	0.0.0.0: starting secondarynamenode, logging to /opt/hadoop-2.7.6/logs/hadoop-vagrant-secondarynamenode-nodo1.out
	```` 


Revisamos que están correctamente arrancados

	```
	[vagrant@nodo1 sbin]$ ps -ef | grep nodo1
	vagrant   4079     1  2 07:23 ?        00:00:06 /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64/jre//bin/java -Dproc_namenode -Xmx1000m -Djava.net.preferIPv4Stack=true -Dhadoop.log.dir=/opt/hadoop-2.7.6/logs -Dhadoop.log.file=hadoop.log -Dhadoop.home.dir=/opt/hadoop-2.7.6 -Dhadoop.id.str=vagrant -Dhadoop.root.logger=INFO,console -Djava.library.path=/opt/hadoop-2.7.6/lib/native -Dhadoop.policy.file=hadoop-policy.xml -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Stack=true -Dhadoop.log.dir=/opt/hadoop-2.7.6/logs -Dhadoop.log.file=hadoop-vagrant-namenode-nodo1.log -Dhadoop.home.dir=/opt/hadoop-2.7.6 -Dhadoop.id.str=vagrant -Dhadoop.root.logger=INFO,RFA -Djava.library.path=/opt/hadoop-2.7.6/lib/native -Dhadoop.policy.file=hadoop-policy.xml -Djava.net.preferIPv4Stack=true -Dhadoop.security.logger=INFO,RFAS -Dhdfs.audit.logger=INFO,NullAppender -Dhadoop.security.logger=INFO,RFAS -Dhdfs.audit.logger=INFO,NullAppender -Dhadoop.security.logger=INFO,RFAS -Dhdfs.audit.logger=INFO,NullAppender -Dhadoop.security.logger=INFO,RFAS org.apache.hadoop.hdfs.server.namenode.NameNode
	vagrant   4224     1  2 07:23 ?        00:00:05 /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64/jre//bin/java -Dproc_datanode -Xmx1000m -Djava.net.preferIPv4Stack=true -Dhadoop.log.dir=/opt/hadoop-2.7.6/logs -Dhadoop.log.file=hadoop.log -Dhadoop.home.dir=/opt/hadoop-2.7.6 -Dhadoop.id.str=vagrant -Dhadoop.root.logger=INFO,console -Djava.library.path=/opt/hadoop-2.7.6/lib/native -Dhadoop.policy.file=hadoop-policy.xml -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Stack=true -Dhadoop.log.dir=/opt/hadoop-2.7.6/logs -Dhadoop.log.file=hadoop-vagrant-datanode-nodo1.log -Dhadoop.home.dir=/opt/hadoop-2.7.6 -Dhadoop.id.str=vagrant -Dhadoop.root.logger=INFO,RFA -Djava.library.path=/opt/hadoop-2.7.6/lib/native -Dhadoop.policy.file=hadoop-policy.xml -Djava.net.preferIPv4Stack=true -server -Dhadoop.security.logger=ERROR,RFAS -Dhadoop.security.logger=ERROR,RFAS -Dhadoop.security.logger=ERROR,RFAS -Dhadoop.security.logger=INFO,RFAS org.apache.hadoop.hdfs.server.datanode.DataNode
	vagrant   4412     1  1 07:23 ?        00:00:03 /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64/jre//bin/java -Dproc_secondarynamenode -Xmx1000m -Djava.net.preferIPv4Stack=true -Dhadoop.log.dir=/opt/hadoop-2.7.6/logs -Dhadoop.log.file=hadoop.log -Dhadoop.home.dir=/opt/hadoop-2.7.6 -Dhadoop.id.str=vagrant -Dhadoop.root.logger=INFO,console -Djava.library.path=/opt/hadoop-2.7.6/lib/native -Dhadoop.policy.file=hadoop-policy.xml -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Stack=true -Dhadoop.log.dir=/opt/hadoop-2.7.6/logs -Dhadoop.log.file=hadoop-vagrant-secondarynamenode-nodo1.log -Dhadoop.home.dir=/opt/hadoop-2.7.6 -Dhadoop.id.str=vagrant -Dhadoop.root.logger=INFO,RFA -Djava.library.path=/opt/hadoop-2.7.6/lib/native -Dhadoop.policy.file=hadoop-policy.xml -Djava.net.preferIPv4Stack=true -Dhadoop.security.logger=INFO,RFAS -Dhdfs.audit.logger=INFO,NullAppender -Dhadoop.security.logger=INFO,RFAS -Dhdfs.audit.logger=INFO,NullAppender -Dhadoop.security.logger=INFO,RFAS -Dhdfs.audit.logger=INFO,NullAppender -Dhadoop.security.logger=INFO,RFAS org.apache.hadoop.hdfs.server.namenode.SecondaryNameNode
	vagrant   4543  3518  0 07:27 pts/0    00:00:00 grep --color=auto nodo1
	```` 

> Con el proceso jps -l (de la JVM) podemos ver que procesos de java tenemos arrancados, y que clases son las que se invocan.

> ps -ef | grep java

	```
	[vagrant@nodo1 bin]$ cd /datos/namenode/
	[vagrant@nodo1 namenode]$ ls
	current  in_use.lock
	[vagrant@nodo1 namenode]$ cd /datos/datanode/
	[vagrant@nodo1 datanode]$ ls -l
	total 4
	drwxrwxr-x. 3 vagrant vagrant 66 May  3 07:23 current
	-rw-rw-r--. 1 vagrant vagrant 10 May  4 19:21 in_use.lock
	````

Cuando arrancamos un entorno hadoop podemos ver que todo esta correctamenet ejecutado conectadndonos al puerto 50070


> curl -X GET http//localhost:50070

	````
	[vagrant@nodo1 datanode]$ curl -X GET http://localhost:50070
	<!--
	   Licensed to the Apache Software Foundation (ASF) under one or more
	   contributor license agreements.  See the NOTICE file distributed with
	   this work for additional information regarding copyright ownership.
	   The ASF licenses this file to You under the Apache License, Version 2.0
	   (the "License"); you may not use this file except in compliance with
	   the License.  You may obtain a copy of the License at

	       http://www.apache.org/licenses/LICENSE-2.0

	   Unless required by applicable law or agreed to in writing, software
	   distributed under the License is distributed on an "AS IS" BASIS,
	   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	   See the License for the specific language governing permissions and
	   limitations under the License.
	-->
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	<meta http-equiv="REFRESH" content="0;url=dfshealth.html" />
	<title>Hadoop Administration</title>
	</head>
	</html>
	````

Practicas
===
- [Trabajar con fsimage y edits](./4-Practicas-BigData-original.hdfs-site.pdf)
- [Trabajar con HDFS](./HDFS.md)
