# TP IASC

*TP Grupal -IASC 1C2022*

## Alumnos
 - Santiago Sanchez
 - Facundo Oviedo
 - Tianshu Wang
 - Ignacio Arrascaeta
 - Bruno Cobos

## Enunciado:

**[https://docs.google.com/document/d/1rOg2TUugXZgx23GhXBzUHakV3vDEkfaT2HLzVKIZ1Q0/edit](https://docs.google.com/document/d/1rOg2TUugXZgx23GhXBzUHakV3vDEkfaT2HLzVKIZ1Q0/edit)**


## Config Inicial + Uso:

[mix deps.get] en subastas, comprador y vendedor

## Subastas:

Para inicializar el servidor de subastas *./start_subastasA.sh* ejecutando los siguientes comandos:

*PORT=4000 iex --name subastasA@127.0.0.1 --cookie asdf -S mix phx.server*

y

*./start_subastasB.sh*

*PORT=4001 iex --name subastasB@127.0.0.1 --cookie asdf -S mix phx.server*

## Vendedor:

Para inicializar el cliente vendedor *./start_vendedorA.sh* ejecutando los siguientes comandos:

*PORT=8080 iex --name vendedorA@127.0.0.1 --cookie asdf -S mix*

y

*./start_vendedorB.sh*

*PORT=8080 iex --name vendedorA@127.0.0.1 --cookie asdf -S mix*

## Comprador:

Para inicializar el cliente comprador *./start_CompradorA.sh* ejecutando los siguientes comandos:

*PORT=8081 iex --name compradorA@127.0.0.1 --cookie asdf -S mix*

y

*./start_compradorB.sh*

*PORT=8082 iex --name compradorB@127.0.0.1 --cookie asdf -S mix*

## Arquitectura

![image1](https://user-images.githubusercontent.com/29739278/180338317-32afc519-7e2c-4746-b4b7-01fce88512af.png)
## Flujo:

**Estados de subasta: new, ofertada, terminada, ganada, cancelada**

1. **comprador_registro**

> GET　localhost:8081/comprador/:id_comprador
> 
1. **comprador_interes**

> GET　localhost:8081/interes/:tag
> 
1. **vendedor_new_subasta**

> POST localhost:8080/new_subasta
> 
> 
> {
> 
> "id":"1",
> 
> "tag":"fruta",
> 
> "nombre":"manzana",
> 
> "precio":100,
> 
> "duracion":30000,
> 
> "estado":"nueva"
> 
> }
> 
1. **comprador_new_oferta**

> POST localhost:8081/new_oferta
> 
> 
> {
> 
> "id_comprador": "A",
> 
> "tag":"fruta",
> 
> "id_subasta":"1",
> 
> "precio":"120",
> 
> }
> 
1. **comprador_get_subastas(opcional y cuando quiere)**

> GET localhost:8081/subastas
> 
1. **vendedor_cancel_subasta(opcional)**

> POST localhost:8080/cancel_subasta
> 
> 
> {
> 
> "id":"1",
> 
> "tag":"fruta"
> 
> }
> 

![image3](https://user-images.githubusercontent.com/29739278/180338286-6083e37d-7157-4eeb-ad8b-166892bf1850.png)


**Estrategia de implementación**

Para implementar el sistema trabajamos de forma incremental, primeramente levantamos un phoenix server, luego, conseguimos conexión con los clientes mediante websockets utilizando las librerías de [phoenix.channel](https://hexdocs.pm/phoenix/channels.html).

Una vez lograda la conexión con los clientes implementamos los channels rooms del tag que nos llega mediante los endpoints que exponemos.

Configurados los channels dinámicos, implementamos los mensajes de broadcast, luego, decidimos agregar una cola de mensajes en el comprador y en subastas usando Agents para mantener el estado de los actores.

Mediante libcluster definimos la topología de los nodos, cuando conseguimos una conexión exitosa de los mismos implementamos Horde para la supervisión distribuida, creamos un NodeListener que detecta y conecta los nodos automáticamente.

**Para conseguir consistencia eventual**

Tenemos un cluster de nodos subastas los cuales se van a sincronizar mediante un mecanismo de crdt.

Para conseguir esto primeramente vamos utilizar la librería [DeltaCrdt](https://hexdocs.pm/delta_crdt/DeltaCrdt.html#content)

La estrategia que vamos a utilizar la describimos mediante el siguiente diagrama

## 

![image2](https://user-images.githubusercontent.com/29739278/180338331-9a566035-1a86-404a-996c-48e34b8de836.png)


Al tener la información replicada en distintos nodos, ante la falla de uno de los mismos, no perderemos información (la cual NO es persistida), porque siempre se mantendrá replicado en memoria en los nodos vivos, en caso de que un nodo falle, otro nodo tomará su lugar.

Cuando el nodo que falló se reinicia, los nodos vivos detectarán su reinicio con el NodeListener y entre ellos se sincronizan los estados.
