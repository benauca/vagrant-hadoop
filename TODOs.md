TODOs
===
# Crea un nodo hadoop
# owner: benauca
# Steps: 
# Test: hadoop jar /opt/hadoop-2.7.6/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.6.jar grep ~/source ~/output 'principal[.]*'
#  TODOs:
#        trabajar con versiones como vars
#        Revisar si hace falta el uso de algún template
#       Exportar para
#		Crear usuario hadoop
#		Modificar .bashrc (a nivel de usuario) para el usuario hadoop (o /etc/bashrc para hacerlas globales
#			export HADOOP_HOME=/opt/hadoop-
#			export PATH=$PATH:HADOOP_HOME/bin:/HADOOP_HOME/sbin
#			export JAVA_HOME => Lo hemos incluido en la instalacion de hadoop, no será necesario.
#		/etc/host include 10.0.2.15 nodo1						
#			. ./bashrc (ejecutanmos el bash rc sin necesidad de salir de la consola)
#		[vagrant@localhost ~]$ alternatives --config java
#		
#		There is 1 program that provides 'java'.
#		 Selection    Command
#		-----------------------------------------------
#		*+ 1           java-1.8.0-openjdk.x86_64 (/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64/jre/bin/ja
#